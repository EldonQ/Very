# ==============================================================================
# china_freshwater_fish.R — 旗舰预设：中国大陆+港澳台「淡水鱼类」全量下载
#
# 这是 gbif-occ 的示范预设，一步复现我们完整跑通的流程：
#   鱼类分类学全覆盖 → 四地区带坐标全量下载 → 覆盖核查 → FishBase 剔除纯海洋种
#   → 出数据展示/分析图。
# 被 run_preset.R 读取；改这里的字段即可派生你自己的预设（如某省两栖类）。
# ==============================================================================

PRESET <- list(
  label          = "中国四地淡水鱼类（CN/HK/MO/TW）",

  # —— taxonKey 解析（见 resolve_keys.R）——
  taxon_preset   = "fish",                 # 鱼类：Chordata 下全部目 + 6 鱼纲，剔非鱼
  taxon          = NULL,                   # 或改用分类名，如 c("Odonata")
  under          = NULL, under_ranks = NULL,# 或改用父节点枚举

  # —— 下载谓词（见 download.R）——
  region         = c("CN", "HK", "MO", "TW"),
  has_coordinate = TRUE,                   # 仅带经纬度（SDM 常用）
  keep_issue     = FALSE,                  # 排除 hasGeospatialIssue
  year           = NULL,                   # 如 c(1970, 2025)
  basis          = NULL,                   # 如 c("PRESERVED_SPECIMEN","HUMAN_OBSERVATION")
  format         = "DWCA",

  # —— 覆盖核查（见 verify_coverage.R）——
  coverage        = TRUE,
  coverage_parent = 44,                    # Chordata
  coverage_ranks  = c("ORDER", "CLASS"),

  # —— 栖息地过滤（见 filter_habitat.R）——
  filter_habitat = TRUE,                   # 鱼类专属；非鱼预设请置 FALSE
  drop_unranked  = FALSE,                  # 保守保留无种名记录

  # —— 数据可视化（见 visualize.R）——
  visualize      = TRUE,                   # 出空间密度图 + 概览四面板 + 栖息地构成
  viz_title      = "China Freshwater Fish (GBIF)"
)
