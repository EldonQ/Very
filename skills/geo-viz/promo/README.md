# geo-viz 宣传物料（promo）

为「抖音 / 小红书 / 微信公众号」三平台准备的**可直接粘贴发布**的文案与配图。

## 目录结构

```
promo/
├── douyin/            抖音
│   ├── 文案.md         口播脚本 + 分镜 + 发布框文案 + 话题标签
│   └── images/        配图（效果图 + 封面）
├── xiaohongshu/       小红书
│   ├── 文案.md         标题 + 正文 + 标签 + 配图顺序
│   └── images/
└── wechat/            微信公众号
    ├── 文章.md         完整长文，图文位置已标好
    └── images/
```

## 使用方法

1. 打开对应平台的 `文案.md` / `文章.md`，按里面的分区复制内容。
2. 按文中标注插入 `images/` 里的配图。
3. GitHub 链接：https://github.com/EldonQ/Very （抖音/小红书放主页或评论区，公众号可直接放正文）。

## 配图说明

`images/` 中的图片是 geo-viz **对真实环境数据渲染的成品**（非示意图，均由校正后的引擎生成，中国比例/配色/图例均合规）：

- `cover.png`：封面（中国年均温渐变图，含南海小地图，最出片）。
- `demo_temperature.png`：连续场（年均温），Python 引擎输出。
- `demo_landcover.png`：离散分类（土地覆盖 9 类）效果。
- `demo_soil_ph.png`：土壤 pH（发散配色）。
- `demo_ndvi.png`：最大 NDVI（顺序绿色配色）。
- `demo_human_impact.png`：人类活动强度（高值=深色）。
- `demo_temperature_R.png`（仅公众号）：R 引擎输出，用于对比双引擎一致性。

> 建议自行补拍/截图：①终端「一行命令→出图」5 秒录屏；②GitHub 仓库页面截图。
> 这两张能显著提升可信度与转化。
