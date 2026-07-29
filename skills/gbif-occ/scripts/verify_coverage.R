# ==============================================================================
# verify_coverage.R — 分类学「全覆盖」核查：确认一份 taxonKey 清单是否完整
#   覆盖某父类群下的目标子类群，且没有带记录的类群从清单里逃逸。
#
# 解决的痛点：像「鱼类」这种在 GBIF 骨干库里【不是单一节点】的并系类群
#   （辐鳍鱼各目直接挂 Chordata 下、无统一纲），靠一个 key 无法覆盖，
#   必须枚举多个目/纲。本脚本自上而下穷举父节点子代，回答两件事：
#     ① 目标子类群是否被 keys 全部纳入（有无遗漏）；
#     ② 父节点下是否有【带现生记录】的科/属逃逸出 keys（有无漏网）。
#
# 用法：
#   Rscript verify_coverage.R --keys-file keys.csv --parent 44 \
#           --child-ranks ORDER,CLASS --region CN,HK,MO,TW --out logs/coverage.log
#   --parent        父节点名或 key（默认 44 = Chordata）
#   --child-ranks   视作「应覆盖」的子节点 rank（默认 ORDER,CLASS）
#   --region        统计逃逸记录时限定的国家码（可选；不给=全球）
#   --exclude-fossil 逃逸核查排除化石标本（默认开；化石类群对现生名录无意义）
#   --out           核查报告输出路径（默认 logs/coverage.log）
# 不需要 GBIF 账号。
# ==============================================================================

.self <- sub("^--file=", "", commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))])
.dir  <- if (length(.self) == 1 && nzchar(.self)) dirname(.self) else "."
source(file.path(.dir, "common.R"))
a <- parse_args()

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0 || is.na(x)) y else x

kf <- arg_get(a, "keys-file")
if (is.null(kf) || !file.exists(kf)) stop("需要 --keys-file 指向含 key/rank/name 列的 CSV。", call. = FALSE)
mine <- fread(kf)
parent <- arg_get(a, "parent", "44")
child_ranks <- toupper(arg_vec(a, "child-ranks", c("ORDER", "CLASS")))
region <- arg_vec(a, "region")
excl_fossil <- arg_lgl(a, "exclude-fossil", TRUE)
out_file <- arg_get(a, "out", "logs/coverage.log")

pk <- suppressWarnings(as.integer(parent))
if (is.na(pk)) {
  bb <- name_backbone(name = parent, strict = FALSE)
  pk <- bb$usageKey %||% stop("无法解析父节点：", parent, call. = FALSE)
}

dir.create(dirname(out_file), recursive = TRUE, showWarnings = FALSE)
out <- file(out_file, open = "w", encoding = "UTF-8")
w <- function(...) writeLines(paste0(...), out)
sec <- function(t) { w(""); w("==== ", t, " ====") }

# ---- 取父节点全部直接子节点 ----
fetch_all_children <- function(parent_key, max_pages = 10L) {
  acc <- list(); start <- 0L; pages <- 0L
  repeat {
    res <- name_usage(key = parent_key, data = "children", start = start, limit = 1000)
    d <- res$data; if (is.null(d) || nrow(d) == 0) break
    acc[[length(acc) + 1L]] <- as.data.table(d)
    pages <- pages + 1L
    if (isTRUE(res$meta$endOfRecords)) break
    if (pages >= max_pages) break
    start <- start + 1000L
  }
  ch <- unique(rbindlist(acc, fill = TRUE), by = "key")
  if (!"canonicalName" %in% names(ch)) ch$canonicalName <- ch$scientificName
  ch$canonicalName <- ifelse(is.na(ch$canonicalName) | ch$canonicalName == "",
                             ch$scientificName, ch$canonicalName)
  ch
}

w("分类学全覆盖核查报告")
w("父节点          : ", parent, " (key=", pk, ")")
w("视作应覆盖的rank: ", paste(child_ranks, collapse = ", "))
w("keys 清单       : ", kf, "（", nrow(mine), " 个 key）")
w("逃逸统计地区    : ", if (length(region)) paste(region, collapse = ",") else "全球")
w("排除化石标本    : ", excl_fossil)

ch <- fetch_all_children(pk)
sec(paste0(parent, " 直接子节点分布（按 rank）"))
tab <- ch[, .N, by = rank][order(-N)]
for (i in seq_len(nrow(tab))) w("  ", tab$rank[i], " = ", tab$N[i])

# ---- ① 目标 rank 子类群覆盖核查 ----
sec("① 目标子类群覆盖核查（有无遗漏）")
want <- ch[rank %in% child_ranks, .(key, rank, name = canonicalName)]
my_keys <- as.integer(mine$key)
want[, in_keys := key %in% my_keys]
covered <- want[in_keys == TRUE]
missing <- want[in_keys == FALSE]
w("目标 rank 子节点总数 = ", nrow(want), "；已被 keys 覆盖 = ", nrow(covered),
  "；未覆盖 = ", nrow(missing))
if (nrow(missing) > 0) {
  w("未覆盖的子节点（需人工判断是否属于目标类群）：")
  for (i in seq_len(nrow(missing)))
    w("  [", missing$rank[i], "] ", missing$name[i], " (key=", missing$key[i], ")")
} else {
  w("→ 目标 rank 下无遗漏。")
}

# ---- ② 逃逸核查：父节点下带记录、却不在 keys 之列的科/属 ----
sec("② 逃逸核查（父节点下带记录却不在 keys 的 FAMILY/GENUS）")
fam_direct <- ch[rank == "FAMILY", .(key, canonicalName)]
gen_direct <- ch[rank == "GENUS",  .(key, canonicalName)]
w("父节点直接挂载的 FAMILY = ", nrow(fam_direct), "；GENUS = ", nrow(gen_direct))

NONFOSSIL <- c("PRESERVED_SPECIMEN", "HUMAN_OBSERVATION", "MACHINE_OBSERVATION",
               "MATERIAL_SAMPLE", "LIVING_SPECIMEN", "OBSERVATION", "OCCURRENCE",
               "MATERIAL_CITATION")
base_args <- list(limit = 0, facetLimit = 1200)
if (length(region) > 0) base_args$country <- region
if (excl_fossil) base_args$basisOfRecord <- NONFOSSIL

facet_counts <- function(facet_field) {
  args <- c(base_args, list(facet = facet_field))
  res <- do.call(occ_search, args)
  f <- res$facets[[facet_field]]
  if (is.null(f) || nrow(f) == 0) return(data.table(key = integer(), records = numeric()))
  ft <- as.data.table(f)
  ft[, .(key = as.integer(name), records = as.numeric(count))]
}

esc_report <- function(direct, facet_field, label) {
  if (nrow(direct) == 0) { w("  无直接挂载的 ", label, "。"); return(invisible()) }
  fc <- tryCatch(facet_counts(facet_field), error = function(e) {
    w("  [警告] ", label, " 分面查询失败：", conditionMessage(e)); NULL })
  if (is.null(fc)) return(invisible())
  esc <- merge(direct, fc, by = "key")[records > 0][order(-records)]
  esc <- esc[!key %in% my_keys]
  if (nrow(esc) == 0) {
    w("  ", label, " 逃逸 = 0（无带记录的", if (excl_fossil) "现生" else "", "类群逃逸）。")
  } else {
    w("  ", label, " 逃逸 = ", nrow(esc), " 个（需确认是否目标类群 / 是否同物异名重定向）：")
    for (i in seq_len(min(nrow(esc), 40L)))
      w("    ", esc$canonicalName[i], " (key=", esc$key[i], ", records=", esc$records[i], ")")
  }
}
esc_report(fam_direct, "familyKey", "FAMILY")
esc_report(gen_direct, "genusKey",  "GENUS")

sec("结论")
if (nrow(missing) == 0)
  w("✔ 目标 rank 子类群无遗漏；逃逸核查见上（逃逸=0 即分类学全覆盖）。")
else
  w("⚠ 存在未覆盖的目标 rank 子节点，请核对上面清单。")

close(out)
cat("核查完成，报告 -> ", out_file, "\n", sep = "")
