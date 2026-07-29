# ==============================================================================
# filter_habitat.R — 用 FishBase 栖息地属性从出现记录中剔除「纯海洋」鱼类
#   （可选步骤；仅对鱼类数据有意义）。
#
# 策略（保守，最大召回，适合先建库再人工筛）：
#   · 淡水(Fresh) 或 河口/半咸水(Brack) 为真   -> 保留 keep_freshwater
#   · 仅海洋(Saltwater) 为真                    -> 剔除 drop_marine
#   · FishBase 查不到 / 无种名（属级及以上）    -> 保留并标记 unknown_keep
# 若只想要最干净的淡水【物种级】数据，加 --drop-unranked 一并剔除无种名记录。
#
# 用法：
#   Rscript filter_habitat.R --occ gbif_out/interim/occurrence.txt --out gbif_out
#   --occ            解压出的 occurrence 表（download.R 的产物）
#   --out            输出根目录（写 processed/ 与 reference/），默认 ./gbif_out
#   --species-col    物种名列（默认 species）
#   --drop-unranked  连同无种名记录一并剔除（默认保留）
# 需要 rfishbase（首次运行会缓存 FishBase 数据）。
# ==============================================================================

.self <- sub("^--file=", "", commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))])
.dir  <- if (length(.self) == 1 && nzchar(.self)) dirname(.self) else "."
source(file.path(.dir, "common.R"))
suppressPackageStartupMessages(library(rfishbase))
a <- parse_args()

occ_txt <- arg_get(a, "occ")
if (is.null(occ_txt) || !file.exists(occ_txt))
  stop("需要 --occ 指向 occurrence 表（download.R 解压产物）。", call. = FALSE)
paths <- make_paths(arg_get(a, "out", "gbif_out"))
sp_col <- arg_get(a, "species-col", "species")
drop_unranked <- arg_lgl(a, "drop-unranked", FALSE)

# ---- 1. 唯一物种名（先只读物种列，省内存）----
log_msg("读取物种列 ...")
sp_only <- read_gbif_table(occ_txt, select = sp_col)
species_list <- sort(unique(sp_only[[sp_col]]))
species_list <- species_list[!is.na(species_list) & nzchar(species_list)]
log_msg("唯一物种数（有种名）：", length(species_list))
if (length(species_list) == 0) stop("未在列 '", sp_col, "' 中找到任何物种名。", call. = FALSE)

# ---- 2. 查询 FishBase 栖息地属性 ----
log_msg("查询 FishBase 栖息地属性（Fresh / Brack / Saltwater）...")
hab <- as.data.table(rfishbase::species(
  species_list, fields = c("Species", "Fresh", "Brack", "Saltwater")))
truthy <- function(x) !is.na(x) & x != 0
hab[, `:=`(is_fresh = truthy(Fresh), is_brack = truthy(Brack), is_salt = truthy(Saltwater))]
hab[, decision := fifelse(is_fresh | is_brack, "keep_freshwater",
                   fifelse(is_salt, "drop_marine", "unknown_keep"))]

# ---- 3. 完整判定表（含 FishBase 未匹配的物种）----
dec <- data.table(species = species_list)
dec <- merge(dec, hab[, .(species = Species, Fresh, Brack, Saltwater, decision)],
             by = "species", all.x = TRUE)
dec[is.na(decision), decision := "unknown_keep"]
hab_file <- file.path(paths$reference, "fishbase_habitat.csv")
fwrite(dec, hab_file)
log_msg("物种判定：淡水/半咸水保留 ", dec[decision == "keep_freshwater", .N],
        "；纯海洋剔除 ", dec[decision == "drop_marine", .N],
        "；未知保留 ", dec[decision == "unknown_keep", .N])
log_msg("栖息地对照表 -> ", hab_file)

# ---- 4. 过滤出现记录 ----
keep_species <- dec[decision %in% c("keep_freshwater", "unknown_keep"), species]
log_msg("读取全部出现记录并过滤 ...")
occ <- read_gbif_table(occ_txt)
no_name <- is.na(occ[[sp_col]]) | occ[[sp_col]] == ""
if (drop_unranked) {
  keep_rows <- occ[[sp_col]] %in% keep_species     # 只留判定为淡水/未知的物种级记录
  log_msg("--drop-unranked：无种名（属级及以上）记录将被剔除。")
} else {
  keep_rows <- occ[[sp_col]] %in% keep_species | no_name   # 无种名记录保守保留
}
occ_fresh <- occ[keep_rows]

out_file <- file.path(paths$processed, "occurrences_freshwater.csv")
fwrite(occ_fresh, out_file)
log_msg("原始记录 ", nrow(occ), " 条 -> 剔除海洋种后 ", nrow(occ_fresh), " 条")
log_msg("最终成果 -> ", out_file)

# ---- 5. 物种级汇总 ----
summ <- occ_fresh[!is.na(get(sp_col)) & get(sp_col) != "",
                  .(records = .N), by = sp_col][order(-records)]
summ_file <- file.path(paths$processed, "species_summary.csv")
fwrite(summ, summ_file)
log_msg("物种级记录统计（", nrow(summ), " 种）-> ", summ_file)
log_msg("完成。")
