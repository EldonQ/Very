# ==============================================================================
# resolve_keys.R — 把「类群」解析为 GBIF taxonKey 列表，写出 CSV 供下载谓词使用
#
# 三种解析方式（任选其一）：
#   1) 单/多分类名：   --taxon "Aves"  或  --taxon "Mammalia,Amphibia"
#        每个名字经 name_backbone 解析为一个 usageKey；对单系类群（有独立节点）
#        一个 key 即可覆盖其全部后代，无需枚举。
#   2) 鱼类预设：      --preset fish
#        鱼类在 GBIF 骨干库中不是单一节点（辐鳍鱼各目直接挂 Chordata 下、无统一纲）,
#        因此取 Chordata(44) 直接子节点里的「全部目 + 6 个鱼纲」,剔除非鱼类群。
#   3) 通用父节点枚举：--under "Reptilia" --rank ORDER,CLASS
#        对任意并系/需要枚举的类群,取某父节点在指定 rank 上的直接子节点。
#
# 用法：
#   Rscript resolve_keys.R --preset fish --out keys.csv
#   Rscript resolve_keys.R --taxon "Odonata" --out keys.csv
#   Rscript resolve_keys.R --under 44 --rank ORDER,CLASS --out keys.csv
# 不需要 GBIF 账号。
# ==============================================================================

.self <- sub("^--file=", "", commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))])
.dir  <- if (length(.self) == 1 && nzchar(.self)) dirname(.self) else "."
source(file.path(.dir, "common.R"))
a <- parse_args()

out_file <- arg_get(a, "out", "taxon_keys.csv")

# ---- 工具：取某 key 的全部直接子节点（children 按 rank 升序返回）--------------
fetch_children <- function(parent_key, max_pages = 8L) {
  acc <- list(); start <- 0L; pages <- 0L
  repeat {
    res <- name_usage(key = parent_key, data = "children", start = start, limit = 1000)
    d <- res$data; if (is.null(d) || nrow(d) == 0) break
    acc[[length(acc) + 1L]] <- as.data.table(d)
    pages <- pages + 1L
    # 需要 CLASS/ORDER 时，出现 FAMILY 即说明高阶元区块已取完，可停止
    if ("FAMILY" %in% d$rank) break
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

resolve_one_name <- function(nm) {
  bb <- name_backbone(name = nm, strict = FALSE)
  if (is.null(bb$usageKey)) stop("无法解析分类名：", nm, call. = FALSE)
  data.table(key = bb$usageKey, rank = toupper(bb$rank %||% "UNKNOWN"),
             name = bb$canonicalName %||% nm, numDescendants = NA_integer_)
}
`%||%` <- function(x, y) if (is.null(x) || length(x) == 0 || is.na(x)) y else x

# ---- 主流程 ------------------------------------------------------------------
preset <- arg_get(a, "preset")
under  <- arg_get(a, "under")
taxon  <- arg_vec(a, "taxon")

if (!is.null(preset) && tolower(preset) == "fish") {
  log_msg("预设 fish：解析 Chordata(", CHORDATA_KEY, ") 下的全部鱼类目 + 鱼纲 ...")
  ch <- fetch_children(CHORDATA_KEY)
  fish <- ch[(rank == "ORDER") | (rank == "CLASS" & canonicalName %in% FISH_CLASSES)]
  fish <- fish[!canonicalName %in% NON_FISH_CLASSES]
  fish <- fish[!canonicalName %in% NON_FISH_ORDERS]
  keys <- fish[, .(key, rank, name = canonicalName,
                   numDescendants = if ("numDescendants" %in% names(fish)) numDescendants else NA_integer_)]
  keys <- unique(keys, by = "key")[order(rank, name)]
  miss <- setdiff(FISH_CLASSES, keys[rank == "CLASS", name])
  if (length(miss)) log_msg("警告：以下鱼纲未命中，请人工核对：", paste(miss, collapse = ", "))
  log_msg("命中鱼目 ", sum(keys$rank == "ORDER"), " 个、鱼纲 ", sum(keys$rank == "CLASS"), " 个。")
  if (nrow(keys) < 20) stop("解析到的鱼类 key 过少（", nrow(keys), "），骨干库结构可能变化。", call. = FALSE)

} else if (!is.null(under)) {
  ranks <- toupper(arg_vec(a, "rank", c("ORDER", "CLASS")))
  pk <- suppressWarnings(as.integer(under))
  if (is.na(pk)) pk <- resolve_one_name(under)$key
  log_msg("枚举父节点 ", under, "(key=", pk, ") 在 rank ∈ {", paste(ranks, collapse = ","), "} 的子节点 ...")
  ch <- fetch_children(pk)
  keys <- ch[rank %in% ranks, .(key, rank, name = canonicalName,
              numDescendants = if ("numDescendants" %in% names(ch)) numDescendants else NA_integer_)]
  keys <- unique(keys, by = "key")[order(rank, name)]
  log_msg("命中子节点 ", nrow(keys), " 个。")

} else if (length(taxon) > 0) {
  log_msg("解析分类名：", paste(taxon, collapse = ", "))
  keys <- rbindlist(lapply(taxon, resolve_one_name))
  keys <- unique(keys, by = "key")
  for (i in seq_len(nrow(keys)))
    log_msg("  ", keys$name[i], " -> key=", keys$key[i], " (", keys$rank[i], ")")

} else {
  stop("请指定 --preset fish | --taxon \"名1,名2\" | --under <父名/父key> [--rank ORDER,CLASS]",
       call. = FALSE)
}

dir.create(dirname(out_file), recursive = TRUE, showWarnings = FALSE)
fwrite(keys, out_file)
log_msg("已写出 ", nrow(keys), " 个 taxonKey -> ", out_file)
