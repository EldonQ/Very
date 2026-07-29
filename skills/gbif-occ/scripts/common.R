# ==============================================================================
# common.R — gbif-occ 通用共享层
#   · 极简 CLI 参数解析
#   · .env 加载 + GBIF 凭据检查（凭据只从环境变量读，绝不写入文件）
#   · 日志、目录、DwC-A 读取工具
#   · 鱼类分类定义（供 fish 预设与覆盖核查复用）
# 供其余脚本 source()；本文件不发起任何网络请求。
# ==============================================================================

suppressPackageStartupMessages({
  library(rgbif)
  library(data.table)
})

# ---- CLI 参数解析：支持 `--flag value` 与布尔 `--flag` -------------------------
parse_args <- function(args = commandArgs(trailingOnly = TRUE)) {
  out <- list()
  i <- 1L
  while (i <= length(args)) {
    a <- args[[i]]
    if (startsWith(a, "--")) {
      key <- sub("^--", "", a)
      if (i < length(args) && !startsWith(args[[i + 1L]], "--")) {
        out[[key]] <- args[[i + 1L]]; i <- i + 2L
      } else {
        out[[key]] <- TRUE; i <- i + 1L
      }
    } else {
      i <- i + 1L
    }
  }
  out
}

arg_get <- function(a, key, default = NULL) if (!is.null(a[[key]])) a[[key]] else default
arg_lgl <- function(a, key, default = FALSE) {
  v <- a[[key]]; if (is.null(v)) return(default)
  if (isTRUE(v)) return(TRUE)
  tolower(as.character(v)) %in% c("true", "t", "1", "yes", "y")
}
# 逗号分隔的多值："CN,HK,MO" -> c("CN","HK","MO")
arg_vec <- function(a, key, default = character()) {
  v <- a[[key]]; if (is.null(v) || isTRUE(v)) return(default)
  trimws(strsplit(as.character(v), ",", fixed = TRUE)[[1]])
}

# ---- 日志 ---------------------------------------------------------------------
log_msg <- function(...) cat(format(Sys.time(), "[%H:%M:%S] "), ..., "\n", sep = "")

# ---- 输出目录布局 -------------------------------------------------------------
make_paths <- function(outdir) {
  p <- list(
    root      = outdir,
    raw       = file.path(outdir, "raw"),        # DwC-A 压缩包 + CITATION
    interim   = file.path(outdir, "interim"),    # 解压出的 occurrence 表
    processed = file.path(outdir, "processed"),  # 过滤后的成果
    reference = file.path(outdir, "reference"),  # taxonKey / 栖息地对照
    logs      = file.path(outdir, "logs")
  )
  invisible(lapply(p, dir.create, recursive = TRUE, showWarnings = FALSE))
  p
}

# ---- .env 加载（KEY=VALUE，每行一个；已存在的环境变量优先）--------------------
load_dotenv <- function(dir = getwd()) {
  f <- file.path(dir, ".env")
  if (!file.exists(f)) return(invisible(FALSE))
  lines <- readLines(f, warn = FALSE)
  lines <- lines[nzchar(trimws(lines)) & !grepl("^\\s*#", lines)]
  for (ln in lines) {
    kv <- strsplit(ln, "=", fixed = TRUE)[[1]]
    if (length(kv) >= 2) {
      key <- trimws(kv[1]); val <- trimws(paste(kv[-1], collapse = "="))
      if (!nzchar(Sys.getenv(key))) do.call(Sys.setenv, setNames(list(val), key))
    }
  }
  invisible(TRUE)
}

check_gbif_credentials <- function() {
  u <- Sys.getenv("GBIF_USER"); p <- Sys.getenv("GBIF_PWD"); e <- Sys.getenv("GBIF_EMAIL")
  missing <- c("GBIF_USER", "GBIF_PWD", "GBIF_EMAIL")[c(!nzchar(u), !nzchar(p), !nzchar(e))]
  if (length(missing) > 0) {
    stop("缺少 GBIF 凭据环境变量：", paste(missing, collapse = ", "), "\n",
         "  在项目根目录建 .env（GBIF_USER=... / GBIF_PWD=... / GBIF_EMAIL=...），\n",
         "  或在 shell 中 export/$env: 设置。注册：https://www.gbif.org/user/profile",
         call. = FALSE)
  }
  invisible(TRUE)
}

# ---- DwC-A / GBIF 导出表读取 --------------------------------------------------
# GBIF 的 occurrence.txt / SIMPLE_CSV 都是【制表符分隔、无引号包裹】，
# 必须用 sep="\t", quote="" 读取，否则含引号/逗号的字段会错位。
read_gbif_table <- function(path, select = NULL) {
  fread(path, sep = "\t", quote = "", na.strings = c("", "NA"),
        select = select, showProgress = FALSE)
}

# ---- 鱼类分类定义（GBIF 骨干库：辐鳍鱼各目直接挂 Chordata(44) 下，无统一纲）----
CHORDATA_KEY <- 44
FISH_CLASSES <- c("Elasmobranchii", "Holocephali", "Myxini",
                  "Petromyzonti", "Dipneusti", "Coelacanthi")
NON_FISH_CLASSES <- c("Amphibia", "Aves", "Mammalia", "Crocodylia", "Squamata",
                      "Testudines", "Sphenodontia", "Ascidiacea", "Thaliacea",
                      "Leptocardii")
NON_FISH_ORDERS <- c("Copelata", "Amphioxiformes", "Aplousobranchia",
                     "Phlebobranchia", "Stolidobranchia", "Enterogona",
                     "Pleurogona", "Salpida", "Doliolida", "Pyrosomatida")
