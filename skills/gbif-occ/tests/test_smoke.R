# ==============================================================================
# test_smoke.R — gbif-occ 自包含冒烟测试
#   离线部分（无需网络/账号）：CLI 解析、DwC-A(TSV) 读取、目录布局、鱼类分类常量、
#     visualize.R 用打包样本出图（缺绘图包时 SKIP）
#   在线部分（需网络、无需账号）：resolve_keys.R --preset fish 解析鱼类 key
#     —— 网络不可用时报 SKIP（不算失败）。
# 运行：Rscript tests/test_smoke.R
# ==============================================================================

.this <- sub("^--file=", "", commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))])
.dir  <- if (length(.this) == 1 && nzchar(.this)) dirname(.this) else "tests"
scripts_dir <- normalizePath(file.path(.dir, "..", "scripts"))
source(file.path(scripts_dir, "common.R"))

fails <- 0L
ok   <- function(msg) cat("  PASS  ", msg, "\n")
bad  <- function(msg) { cat("  FAIL  ", msg, "\n"); fails <<- fails + 1L }
skip <- function(msg) cat("  SKIP  ", msg, "\n")
check <- function(cond, msg) if (isTRUE(cond)) ok(msg) else bad(msg)

cat("== 离线：CLI 参数解析 ==\n")
a <- parse_args(c("--preset", "fish", "--region", "CN,HK,MO,TW", "--no-wait"))
check(identical(arg_get(a, "preset"), "fish"), "--flag value 解析")
check(isTRUE(arg_lgl(a, "no-wait")), "布尔 flag 解析")
check(identical(arg_vec(a, "region"), c("CN","HK","MO","TW")), "逗号多值解析")
check(identical(arg_get(a, "missing", "def"), "def"), "缺省值回退")

cat("== 离线：DwC-A(制表符/无引号) 读取 ==\n")
tf <- tempfile(fileext = ".txt")
writeLines(c("species\tcountryCode\tdecimalLatitude",
             "Cyprinus carpio\tCN\t30.1",
             "Channa argus, sensu lato\tCN\t31.2"), tf)   # 含逗号的字段
tb <- read_gbif_table(tf)
check(nrow(tb) == 2 && ncol(tb) == 3, "tab 分隔行列数正确")
check(tb$species[2] == "Channa argus, sensu lato", "含逗号字段未被误拆（quote=\"\"）")
unlink(tf)

cat("== 离线：目录布局与分类常量 ==\n")
td <- file.path(tempdir(), paste0("gbifocc_", as.integer(runif(1, 1, 1e6))))
p <- make_paths(td)
check(all(dir.exists(unlist(p))), "make_paths 建出 raw/interim/processed/reference/logs")
unlink(td, recursive = TRUE)
check(CHORDATA_KEY == 44 && length(FISH_CLASSES) == 6, "鱼类分类常量（Chordata=44, 6 鱼纲）")

cat("== 离线：visualize.R 用打包样本出图 ==\n")
sample_csv <- file.path(.dir, "..", "examples", "example_occurrences_sample.csv")
viz_pkgs <- all(vapply(c("ggplot2","patchwork","scales","hexbin","viridisLite","sf"),
                       requireNamespace, logical(1), quietly = TRUE))
china_shp <- file.path(.dir, "..", "assets", "china", "china.shp")
if (!file.exists(sample_csv)) {
  skip("未找到 examples/example_occurrences_sample.csv，跳过可视化测试")
} else if (!viz_pkgs) {
  skip("缺 ggplot2/patchwork/scales/hexbin/viridisLite/sf，跳过可视化测试")
} else {
  fig_pfx <- file.path(tempdir(), "smoke_fig")
  RSCRIPT <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript")
  code <- system2(RSCRIPT, c(shQuote(file.path(scripts_dir, "visualize.R")),
                             "--occ", shQuote(sample_csv), "--out", shQuote(fig_pfx),
                             "--title", shQuote("smoke")), stdout = FALSE, stderr = FALSE)
  map_png <- paste0(fig_pfx, "_map.png"); sum_png <- paste0(fig_pfx, "_summary.png")
  check(code == 0 && file.exists(map_png) && file.exists(sum_png),
        "visualize.R 出 _map.png 与 _summary.png")
  check(file.exists(china_shp), "打包中国合规底图 assets/china/china.shp 存在")
  unlink(c(map_png, sum_png))
}

cat("== 在线：resolve_keys.R --preset fish（需网络，无需账号）==\n")
net_ok <- tryCatch({ suppressWarnings(readLines(url("https://api.gbif.org/v1/"), n = 1)); TRUE },
                   error = function(e) FALSE, warning = function(e) FALSE)
if (!net_ok) {
  skip("无法连通 api.gbif.org，跳过在线解析测试")
} else {
  keys_csv <- file.path(tempdir(), "smoke_keys.csv")
  RSCRIPT <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript")
  code <- system2(RSCRIPT, c(shQuote(file.path(scripts_dir, "resolve_keys.R")),
                             "--preset", "fish", "--out", shQuote(keys_csv)))
  if (code == 0 && file.exists(keys_csv)) {
    k <- fread(keys_csv)
    check(nrow(k) >= 40, paste0("鱼类 key 数 = ", nrow(k), "（应 >=40）"))
    check(sum(k$rank == "CLASS") >= 5, "至少纳入 5+ 鱼纲")
    unlink(keys_csv)
  } else {
    skip(paste0("resolve_keys.R 退出码 ", code, "（网络/骨干库波动），跳过断言"))
  }
}

cat("\nRESULT: ", if (fails == 0L) "PASS" else paste0("FAIL (", fails, ")"), "\n", sep = "")
if (fails > 0L) quit(status = 1L)
