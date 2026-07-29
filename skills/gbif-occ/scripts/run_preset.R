# ==============================================================================
# run_preset.R — 一键跑完某个预设的完整流程：
#   resolve_keys → (verify_coverage) → download → (filter_habitat) → (visualize)
# 各步骤仍以独立 Rscript 子进程调用，保证与手动分步运行行为一致。
#
# 用法：
#   Rscript run_preset.R --preset china_freshwater_fish --out gbif_out
#   --preset   预设名（presets/<名>.R）或预设文件路径
#   --out      输出根目录（默认 gbif_out）
#   --no-wait  下载只提交不等待（透传给 download.R）
# 需要 GBIF 账号（.env 或环境变量）；解析/核查/可视化步骤不需要。
# ==============================================================================

.self <- sub("^--file=", "", commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))])
.dir  <- if (length(.self) == 1 && nzchar(.self)) dirname(.self) else "."
source(file.path(.dir, "common.R"))
a <- parse_args()

preset_arg <- arg_get(a, "preset", "china_freshwater_fish")
outdir <- arg_get(a, "out", "gbif_out")
pfile <- if (file.exists(preset_arg)) preset_arg
         else file.path(.dir, "..", "presets", paste0(preset_arg, ".R"))
if (!file.exists(pfile)) stop("找不到预设文件：", pfile, call. = FALSE)
source(pfile)
if (!exists("PRESET")) stop("预设文件未定义 PRESET 列表：", pfile, call. = FALSE)

paths <- make_paths(outdir)
RSCRIPT <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript")
run_step <- function(script, args) {
  log_msg(">>> ", script, " ", paste(args, collapse = " "))
  code <- system2(RSCRIPT, c(shQuote(file.path(.dir, script)), args))
  if (code != 0) stop(script, " 退出码 ", code, "，流程中止。", call. = FALSE)
}

`%g%` <- function(x, d) if (is.null(x) || length(x) == 0) d else x
keys_csv <- file.path(paths$reference, "taxon_keys.csv")

# ---- 1) 解析 taxonKey ----
res_args <- c("--out", shQuote(keys_csv))
if (!is.null(PRESET$taxon_preset)) res_args <- c(res_args, "--preset", PRESET$taxon_preset)
else if (!is.null(PRESET$taxon))   res_args <- c(res_args, "--taxon", shQuote(paste(PRESET$taxon, collapse = ",")))
else if (!is.null(PRESET$under)) {
  res_args <- c(res_args, "--under", shQuote(as.character(PRESET$under)))
  if (!is.null(PRESET$under_ranks)) res_args <- c(res_args, "--rank", paste(PRESET$under_ranks, collapse = ","))
}
run_step("resolve_keys.R", res_args)

# ---- 2) 覆盖核查（可选，先于下载，确认无遗漏再下）----
if (isTRUE(PRESET$coverage)) {
  cov_args <- c("--keys-file", shQuote(keys_csv),
                "--parent", shQuote(as.character(PRESET$coverage_parent %g% 44)),
                "--child-ranks", paste(PRESET$coverage_ranks %g% c("ORDER","CLASS"), collapse = ","),
                "--out", shQuote(file.path(paths$logs, "coverage.log")))
  if (length(PRESET$region)) cov_args <- c(cov_args, "--region", paste(PRESET$region, collapse = ","))
  run_step("verify_coverage.R", cov_args)
}

# ---- 3) 提交并领取下载 ----
dl_args <- c("--keys-file", shQuote(keys_csv), "--out", shQuote(outdir),
             "--format", PRESET$format %g% "DWCA",
             "--has-coordinate", tolower(as.character(isTRUE(PRESET$has_coordinate))))
if (length(PRESET$region)) dl_args <- c(dl_args, "--region", paste(PRESET$region, collapse = ","))
if (isTRUE(PRESET$keep_issue)) dl_args <- c(dl_args, "--keep-issue")
if (length(PRESET$year) == 2)  dl_args <- c(dl_args, "--year", paste(PRESET$year, collapse = ","))
if (length(PRESET$basis))      dl_args <- c(dl_args, "--basis", paste(PRESET$basis, collapse = ","))
if (arg_lgl(a, "no-wait", FALSE)) dl_args <- c(dl_args, "--no-wait")
run_step("download.R", dl_args)
if (arg_lgl(a, "no-wait", FALSE)) { log_msg("已按 --no-wait 提交，稍后重跑领取。"); quit(save = "no") }

# ---- 4) FishBase 栖息地过滤（可选；鱼类预设）----
if (isTRUE(PRESET$filter_habitat)) {
  occ_txt <- file.path(paths$interim, "occurrence.txt")
  fh_args <- c("--occ", shQuote(occ_txt), "--out", shQuote(outdir))
  if (isTRUE(PRESET$drop_unranked)) fh_args <- c(fh_args, "--drop-unranked")
  run_step("filter_habitat.R", fh_args)
}

# ---- 5) 数据可视化（可选，展示/分析已下载数据）----
if (isTRUE(PRESET$visualize)) {
  viz_occ <- if (isTRUE(PRESET$filter_habitat))
               file.path(paths$processed, "occurrences_freshwater.csv")
             else file.path(paths$interim, "occurrence.txt")
  fig_pfx <- file.path(outdir, "figures",
                       gsub("[^A-Za-z0-9]+", "_", PRESET$viz_title %g% (PRESET$label %g% preset_arg)))
  viz_args <- c("--occ", shQuote(viz_occ), "--out", shQuote(fig_pfx),
                "--title", shQuote(PRESET$viz_title %g% (PRESET$label %g% preset_arg)))
  hab_csv <- file.path(paths$reference, "fishbase_habitat.csv")
  if (file.exists(hab_csv)) viz_args <- c(viz_args, "--habitat", shQuote(hab_csv))
  run_step("visualize.R", viz_args)
}

log_msg("预设「", PRESET$label %g% preset_arg, "」全流程完成。产物见 ", outdir)
