# gbif-occ — 关键知识与坑位

把这套流程从「中国四地淡水鱼」项目里沉淀出来时踩过的点，供复用与排错。

## 1. GBIF 分类骨干库：鱼类不是单一节点

鱼类是**并系类群**，GBIF 骨干库里没有统一的「鱼纲」。辐鳍鱼各目（Cypriniformes、
Perciformes…）**直接挂在脊索动物门 Chordata(key=44) 下**，纲级节点
`Actinopterygii`(204) 是**死节点**（四地区累计记录=0，记录不经由它路由）。

因此覆盖鱼类必须**枚举 Chordata 下的全部鱼目 + 6 个鱼纲**，而不能靠单个 key：

- 6 个鱼纲：Elasmobranchii（软骨鱼）、Holocephali（银鲛）、Myxini（盲鳗）、
  Petromyzonti（七鳃鳗）、Dipneusti（肺鱼）、Coelacanthi（腔棘鱼）
- 非鱼、需排除的纲：Amphibia/Aves/Mammalia/Crocodylia/Squamata/Testudines/
  Sphenodontia（四足类）、Ascidiacea/Thaliacea（被囊类）、Leptocardii（文昌鱼）
- 非鱼、需排除的目：Copelata（尾海鞘目）等被囊/头索动物

`resolve_keys.R --preset fish` 已内置这套取舍（见 `common.R` 的 `FISH_CLASSES` /
`NON_FISH_CLASSES` / `NON_FISH_ORDERS`）。

## 2. 覆盖核查（verify_coverage.R）为什么必要

Chordata 门下除了目/纲，还**直接挂着上千个科/属**（GBIF 常把化石类群和「分类
地位未定」类群直接挂门下）。核查分两问：

1. **有无遗漏**：目标 rank（目/纲）子节点是否都在 keys 里；
2. **有无漏网**：门下带记录、却不在 keys 的科/属（逃逸）。**必须按
   `basisOfRecord` 排除化石**——否则牙形石、恐龙、盾皮鱼等古生物会混进逃逸清单。
   排除化石后逃逸=0，即现生类群分类学全覆盖。

## 3. DwC-A / GBIF 导出表的读取格式（高频踩坑）

- GBIF 的 `occurrence.txt`（DWCA）与 `SIMPLE_CSV` 都是
  **制表符分隔、字段无引号包裹**。必须 `fread(sep="\t", quote="")`，
  否则含引号/逗号的字段会错位、报「Expected N fields but found M」。
- 反过来，`fwrite()` 生成的 CSV 是**标准带引号 CSV**（含逗号字段被引号包裹），
  再读回时要用**默认 quote**，不能 `quote=""`。
- 大表（数十万行、200+ 列）优先只 `select` 需要的列；按**列名** select 偶发
  匹配失败，稳妥时用**列索引**再 `setnames`。

## 4. 下载谓词

- `hasCoordinate=TRUE`：仅带经纬度记录（物种分布建模 SDM 常用）。
- `hasGeospatialIssue=FALSE`：排除坐标存在问题的记录（0/0、与国家不符等）。
- 谓词全部 **AND** 组合；国家/地区用 ISO 码（中国大陆 `CN`、香港 `HK`、
  澳门 `MO`、台湾 `TW`）。

## 5. 异步下载与凭据

- `occ_download()` 是**异步**的：提交后进入 PREPARING → RUNNING → SUCCEEDED，
  数据量大时排队**数分钟到数十分钟**属正常。`download.R` 用
  `occ_download_wait()` 轮询；不想阻塞用 `--no-wait`，稍后重跑领取。
- 凭据只从环境变量 / `.env` 读（`GBIF_USER` / `GBIF_PWD` / `GBIF_EMAIL`），
  **绝不写入任何产物或日志**。注册：https://www.gbif.org/user/profile
- 学术使用**必须引用下载 DOI**（`download.R` 落盘在 `raw/CITATION.txt`）。

## 6. FishBase 栖息地过滤（filter_habitat.R，仅鱼类）

用 rfishbase 的 `Fresh`/`Brack`/`Saltwater` 字段：淡水或半咸水→保留、仅海洋→
剔除、查不到/无种名→保守保留并标记 `unknown_keep`。想要最干净的物种级淡水数据
可加 `--drop-unranked` 一并剔除属级及以上的无种名记录。
