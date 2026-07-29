# ==============================================================================
# download.R — 向 GBIF 提交异步下载、等待生成、领取压缩包、解压、留存引用(DOI)
#
# 需要 GBIF 账号（环境变量 GBIF_USER / GBIF_PWD / GBIF_EMAIL，或 .env）。
#
# 谓词由参数拼装（全部 AND）：
#   --keys-file <csv>      含 key 列的 taxonKey 表（resolve_keys.R 的产物）
#   --taxon-keys "1,2,3"   直接给定 taxonKey（与 --keys-file 二选一）
#   --region "CN,HK,MO,TW" ISO 国家/地区码（可选；不给=全球）
#   --wkt "POLYGON((...))" 空间多边形（可选）
#   --year "1970,2025"     采集年份范围（可选）
#   --basis "PRESERVED_SPECIMEN,HUMAN_OBSERVATION"  记录类型（可选）
#   --has-coordinate BOOL  仅带经纬度记录，默认 true（SDM 常用）
#   --keep-issue           保留坐标存在问题的记录（默认排除 hasGeospatialIssue=FALSE）
#   --format DWCA|SIMPLE_CSV  默认 DWCA
#   --out <dir>            输出目录，默认 ./gbif_out
#   --no-wait             只提交并保存 download key，不阻塞等待
# ==============================================================================

.self <- sub("^--file=", "", commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))])
.dir  <- if (length(.self) == 1 && nzchar(.self)) dirname(.self) else "."
source(file.path(.dir, "common.R"))
a <- parse_args()

load_dotenv(getwd())
check_gbif_credentials()

paths <- make_paths(arg_get(a, "out", "gbif_out"))

# ---- 取 taxonKey ----
keys <- character()
kf <- arg_get(a, "keys-file")
if (!is.null(kf)) {
  if (!file.exists(kf)) stop("找不到 keys 文件：", kf, call. = FALSE)
  keys <- as.character(fread(kf)$key)
}
keys <- unique(c(keys, arg_vec(a, "taxon-keys")))
keys <- keys[!is.na(keys) & nzchar(keys)]
if (length(keys) == 0) stop("未提供 taxonKey，请用 --keys-file 或 --taxon-keys。", call. = FALSE)

region <- arg_vec(a, "region")
fmt    <- toupper(arg_get(a, "format", "DWCA"))

# ---- 拼装谓词 ----
preds <- list(pred_in("taxonKey", keys))
if (length(region) > 0) preds <- c(preds, list(pred_in("country", region)))
if (arg_lgl(a, "has-coordinate", TRUE)) preds <- c(preds, list(pred("hasCoordinate", TRUE)))
if (!arg_lgl(a, "keep-issue", FALSE))   preds <- c(preds, list(pred("hasGeospatialIssue", FALSE)))
wkt <- arg_get(a, "wkt"); if (!is.null(wkt)) preds <- c(preds, list(pred_within(wkt)))
yr <- arg_vec(a, "year")
if (length(yr) == 2) preds <- c(preds, list(pred_gte("year", yr[1]), pred_lte("year", yr[2])))
basis <- arg_vec(a, "basis"); if (length(basis) > 0) preds <- c(preds, list(pred_in("basisOfRecord", basis)))

log_msg("taxonKey 数=", length(keys), "；地区=", if (length(region)) paste(region, collapse=",") else "全球",
        "；格式=", fmt)
log_msg("提交下载请求 ...")
gd <- do.call(occ_download, c(preds, list(
  format = fmt, user = Sys.getenv("GBIF_USER"),
  pwd = Sys.getenv("GBIF_PWD"), email = Sys.getenv("GBIF_EMAIL"))))

dl_key <- as.character(gd)
dlkey_file <- file.path(paths$raw, "download_key.txt")
writeLines(dl_key, dlkey_file)
log_msg("download key = ", dl_key, "  (已存 ", dlkey_file, ")")

if (arg_lgl(a, "no-wait", FALSE)) {
  log_msg("已按 --no-wait 退出。稍后可重跑本脚本（自动读取 download key）领取。")
  quit(save = "no")
}

# ---- 等待后台生成 ----
log_msg("等待 GBIF 生成数据（每 30s 轮询；数据量大时可能数分钟~数十分钟）...")
occ_download_wait(dl_key, status_ping = 30, curlopts = list(http_version = 2))
meta <- occ_download_meta(dl_key)
log_msg("状态=", meta$status, "；记录数=", meta$totalRecords, "；DOI=", meta$doi)

# ---- 下载 + 解压 ----
zip_path <- occ_download_get(dl_key, path = paths$raw, overwrite = TRUE)
zf <- file.path(paths$raw, paste0(dl_key, ".zip"))
if (!file.exists(zf)) zf <- as.character(zip_path)
inside <- unzip(zf, list = TRUE)$Name
# DWCA -> occurrence.txt；SIMPLE_CSV -> <key>.csv（都是制表符分隔）
data_name <- if ("occurrence.txt" %in% inside) "occurrence.txt" else
             inside[grep("(occurrence\\.txt|\\.csv)$", inside)][1]
if (is.na(data_name)) stop("压缩包内未找到数据表（occurrence.txt / *.csv）。", call. = FALSE)
unzip(zf, files = data_name, exdir = paths$interim, overwrite = TRUE)
log_msg("已解压 ", data_name, " -> ", paths$interim)

# ---- 留存引用（学术使用必须引用该 DOI）----
citation_lines <- c(
  paste0("GBIF Occurrence Download  ", meta$doi),
  paste0("download key : ", dl_key),
  paste0("records      : ", meta$totalRecords),
  paste0("created      : ", meta$created),
  paste0("format       : ", fmt),
  paste0("filter       : taxonKey(", length(keys), " keys)",
         if (length(region)) paste0(" AND country IN {", paste(region, collapse=","), "}") else "",
         if (arg_lgl(a, "has-coordinate", TRUE)) " AND hasCoordinate=TRUE" else "",
         if (!arg_lgl(a, "keep-issue", FALSE)) " AND hasGeospatialIssue=FALSE" else ""),
  paste0("access URL   : https://www.gbif.org/occurrence/download/", dl_key))
writeLines(citation_lines, file.path(paths$raw, "CITATION.txt"))
log_msg("引用信息 -> ", file.path(paths$raw, "CITATION.txt"))
log_msg("完成。数据表在 ", paths$interim, "，可接 verify_coverage.R / filter_habitat.R。")
