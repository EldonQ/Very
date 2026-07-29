# ==============================================================================
# visualize.R — 对下载到的 GBIF 出现记录做「数据展示 / 分析可视化」（R / ggplot2）
#   产出两张图（600 dpi PNG）：
#     <prefix>_map.png      出现点空间密度图（六边形分箱，log 计数）—— 数据的"全景"
#                           叠合规中国底图：省界 + 南海九段线 + 右下角南海小地图
#     <prefix>_summary.png  4 面板概览：Top 物种 / 各地区记录 / Top 目 / 年度趋势
#   若提供 --habitat，则额外产出 <prefix>_habitat.png（FishBase 淡水/海洋判定构成）。
#
# 用法：
#   Rscript visualize.R --occ gbif_out/processed/occurrences_freshwater.csv \
#           --out figures/china_fish --title "China Freshwater Fish (GBIF)"
#   --occ       出现表：DwC-A occurrence.txt（tab/无引号）或 fwrite 的 .csv（自动识别）
#   --out       输出前缀（不含扩展名），目录自动创建
#   --title     图标题（可选）
#   --top       Top 物种/目 的数量（默认 20）
#   --habitat   fishbase_habitat.csv（可选，filter_habitat.R 的产物）
#   --assets    中国底图目录（默认 ../assets/china，含 china.shp + dashline.shp）
#   --no-inset  不画南海小地图
# 依赖：ggplot2, data.table, patchwork, scales, viridisLite, hexbin, sf
#      （sf/底图不可用时自动回退到 maps 世界轮廓）
# ==============================================================================

.self <- sub("^--file=", "", commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))])
.dir  <- if (length(.self) == 1 && nzchar(.self)) dirname(.self) else "."
source(file.path(.dir, "common.R"))
suppressPackageStartupMessages({
  library(ggplot2); library(patchwork); library(scales); library(viridisLite)
})
a <- parse_args()
`%||%` <- function(x, y) if (is.null(x) || length(x) == 0) y else x

occ_path <- arg_get(a, "occ")
if (is.null(occ_path) || !file.exists(occ_path))
  stop("需要 --occ 指向出现表（occurrence.txt 或 processed .csv）。", call. = FALSE)
out_pfx <- arg_get(a, "out", "figures/gbif")
title   <- arg_get(a, "title", "GBIF Occurrences")
topn    <- suppressWarnings(as.integer(arg_get(a, "top", "20"))); if (is.na(topn)) topn <- 20L
hab_path <- arg_get(a, "habitat")
assets_dir <- arg_get(a, "assets", normalizePath(file.path(.dir, "..", "assets", "china"), mustWork = FALSE))
dir.create(dirname(out_pfx), recursive = TRUE, showWarnings = FALSE)

want <- c("decimalLatitude", "decimalLongitude", "countryCode",
          "order", "family", "species", "year", "basisOfRecord")

# ---- 读取（.txt=GBIF tab/无引号；.csv=fwrite 标准带引号）----
log_msg("读取出现表 ", occ_path, " ...")
is_txt <- grepl("\\.txt$", occ_path, ignore.case = TRUE)
d <- if (is_txt) read_gbif_table(occ_path) else
     fread(occ_path, na.strings = c("", "NA"), showProgress = FALSE)
keep <- intersect(want, names(d))
d <- d[, ..keep]
d[, decimalLatitude := as.numeric(decimalLatitude)]
d[, decimalLongitude := as.numeric(decimalLongitude)]
log_msg("记录数 = ", nrow(d), "；有坐标 = ", d[is.finite(decimalLatitude) & is.finite(decimalLongitude), .N])

# ---- 统一视觉主题 ----
PAL <- "#2C7FB8"; BORDER_COL <- "#4E5963"
DISP_TE <- c(73.40, 18.10, 135.15, 53.60)   # 中国主图范围（同 geo-viz）xmin ymin xmax ymax
INSET_XLIM <- c(105, 126); INSET_YLIM <- c(2, 26)  # 南海小地图范围
theme_gbif <- function(base = 11) {
  theme_minimal(base_size = base) +
    theme(panel.grid.minor = element_blank(),
          panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
          plot.title = element_text(face = "bold", size = rel(1.05)),
          plot.subtitle = element_text(color = "grey35", size = rel(0.85)),
          axis.title = element_text(color = "grey30"),
          plot.margin = margin(8, 12, 8, 8))
}
region_name <- c(CN = "Mainland (CN)", HK = "Hong Kong", MO = "Macau", TW = "Taiwan")

# ---- 1) 空间密度图（hexbin, log 计数）叠中国合规底图 ----
pts <- d[is.finite(decimalLatitude) & is.finite(decimalLongitude) &
         abs(decimalLatitude) <= 90 & abs(decimalLongitude) <= 180]
fill_scale <- scale_fill_viridis_c(name = "Records\n(log)", trans = "log10",
                                   option = "C", labels = label_number(accuracy = 1))
hex_layer  <- stat_bin_hex(data = pts, aes(decimalLongitude, decimalLatitude), bins = 60)

china_shp <- file.path(assets_dir, "china.shp"); dash_shp <- file.path(assets_dir, "dashline.shp")
use_sf <- requireNamespace("sf", quietly = TRUE) && file.exists(china_shp)

if (use_sf) {
  read_vec <- function(p) {
    v <- sf::st_read(p, quiet = TRUE)
    if (is.na(sf::st_crs(v)) || (sf::st_crs(v)$epsg %||% 0L) != 4326L)
      v <- suppressWarnings(sf::st_transform(v, 4326))
    sf::st_make_valid(v)
  }
  china <- read_vec(china_shp)
  dash  <- if (file.exists(dash_shp)) read_vec(dash_shp) else NULL
  log_msg("底图：china.shp", if (!is.null(dash)) " + dashline.shp（九段线）" else "")

  make_map <- function(xlim, ylim, with_data) {
    g <- ggplot() + geom_sf(data = china, fill = "grey95", color = "grey78", linewidth = 0.18)
    if (with_data) g <- g + hex_layer + fill_scale
    if (!is.null(dash)) g <- g + geom_sf(data = dash, color = BORDER_COL, linewidth = 0.45)
    g + coord_sf(xlim = xlim, ylim = ylim, expand = FALSE)
  }
  p_main <- make_map(DISP_TE[c(1, 3)], DISP_TE[c(2, 4)], TRUE) +
    labs(title = paste0(title, " — spatial density"),
         subtitle = paste0(format(nrow(pts), big.mark = ","),
                           " georeferenced records · hexagonal binning"),
         x = "Longitude", y = "Latitude") +
    theme_gbif() + theme(legend.position = "right")
  p_map <- p_main
  if (!is.null(dash) && !arg_lgl(a, "no-inset", FALSE)) {   # 南海小地图（合规要素）
    p_inset <- make_map(INSET_XLIM, INSET_YLIM, FALSE) + theme_void() +
      theme(panel.background = element_rect(fill = "white", color = BORDER_COL, linewidth = 0.5),
            plot.margin = margin(0, 0, 0, 0))
    p_map <- p_main + inset_element(p_inset, left = 0.83, bottom = 0.02, right = 1.0, top = 0.28)
  }
} else {
  log_msg("未找到 sf 或 china.shp，回退到 maps 世界轮廓底图。")
  world <- as.data.table(map_data("world"))
  xr <- range(pts$decimalLongitude); yr <- range(pts$decimalLatitude)
  padx <- diff(xr) * 0.06 + 0.5; pady <- diff(yr) * 0.06 + 0.5
  p_map <- ggplot() +
    geom_polygon(data = world, aes(long, lat, group = group),
                 fill = "grey94", color = "grey80", linewidth = 0.2) +
    hex_layer + fill_scale +
    coord_quickmap(xlim = c(xr[1] - padx, xr[2] + padx),
                   ylim = c(yr[1] - pady, yr[2] + pady), expand = FALSE) +
    labs(title = paste0(title, " — spatial density"),
         subtitle = paste0(format(nrow(pts), big.mark = ","),
                           " georeferenced records · hexagonal binning"),
         x = "Longitude", y = "Latitude") +
    theme_gbif() + theme(legend.position = "right")
}
ggsave(paste0(out_pfx, "_map.png"), p_map, width = 8.2, height = 7.2, dpi = 600, bg = "white")
log_msg("已出图 ", out_pfx, "_map.png")

# ---- 2) 概览 4 面板 ----
bar_base <- function(dt, xcol, ycol, fillcol = PAL) {
  ggplot(dt, aes(x = reorder(get(xcol), get(ycol)), y = get(ycol))) +
    geom_col(fill = fillcol, width = 0.72) + coord_flip() +
    scale_y_continuous(labels = label_number(scale_cut = cut_short_scale()),
                       expand = expansion(mult = c(0, 0.08))) +
    theme_gbif()
}

# (a) Top 物种
sp <- d[!is.na(species) & species != "", .(n = .N), by = species][order(-n)][seq_len(min(topn, .N))]
p_sp <- bar_base(sp, "species", "n") +
  labs(title = paste0("Top ", nrow(sp), " species"), x = NULL, y = "Records") +
  theme(axis.text.y = element_text(face = "italic", size = 8))

# (b) 各地区
rg <- d[!is.na(countryCode) & countryCode != "", .(n = .N), by = countryCode][order(-n)]
rg[, label := ifelse(countryCode %in% names(region_name), region_name[countryCode], countryCode)]
p_rg <- bar_base(rg, "label", "n", "#41B6C4") +
  labs(title = "Records by region", x = NULL, y = "Records")

# (c) Top 目
od <- d[!is.na(order) & order != "", .(n = .N), by = order][order(-n)][seq_len(min(topn, .N))]
p_od <- bar_base(od, "order", "n", "#7FB972") +
  labs(title = paste0("Top ", nrow(od), " orders"), x = NULL, y = "Records") +
  theme(axis.text.y = element_text(size = 8))

# (d) 年度趋势
now_y <- as.integer(format(Sys.Date(), "%Y"))
yr_dt <- d[is.finite(year) & year >= 1900 & year <= now_y, .(n = .N), by = year][order(year)]
p_yr <- ggplot(yr_dt, aes(year, n)) +
  geom_area(fill = PAL, alpha = 0.25) + geom_line(color = PAL, linewidth = 0.7) +
  scale_y_continuous(labels = label_number(scale_cut = cut_short_scale())) +
  labs(title = "Records by year", x = "Year", y = "Records") + theme_gbif()

overview <- (p_sp | p_od) / (p_rg | p_yr) +
  plot_annotation(title = paste0(title, " — dataset overview"),
                  subtitle = paste0(format(nrow(d), big.mark = ","), " records · ",
                                    d[!is.na(species) & species != "", uniqueN(species)], " species"),
                  theme = theme(plot.title = element_text(face = "bold", size = 15),
                                plot.subtitle = element_text(color = "grey35")))
ggsave(paste0(out_pfx, "_summary.png"), overview, width = 11, height = 8.4, dpi = 600, bg = "white")
log_msg("已出图 ", out_pfx, "_summary.png")

# ---- 3) 栖息地构成（可选）----
if (!is.null(hab_path) && file.exists(hab_path)) {
  hb <- fread(hab_path)
  if ("decision" %in% names(hb)) {
    hc <- hb[, .(n = .N), by = decision][order(-n)]
    lab <- c(keep_freshwater = "Freshwater / brackish (keep)",
             drop_marine = "Pure marine (drop)", unknown_keep = "Unknown (keep)")
    hc[, label := ifelse(decision %in% names(lab), lab[decision], decision)]
    p_hab <- bar_base(hc, "label", "n", "#DFA43B") +
      labs(title = paste0(title, " — FishBase habitat decision"),
           subtitle = paste0(sum(hc$n), " species classified"),
           x = NULL, y = "Species")
    ggsave(paste0(out_pfx, "_habitat.png"), p_hab, width = 8, height = 4.6, dpi = 600, bg = "white")
    log_msg("已出图 ", out_pfx, "_habitat.png")
  }
}

log_msg("可视化完成。前缀 = ", out_pfx)
