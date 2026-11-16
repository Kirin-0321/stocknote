# 交易日记 StockNote

面向 A 股的交易日记：记录盘中的观察、判断与计划，事后自动验证判断对错并复盘。

> 仅供个人记录与复盘，不构成任何投资建议。

## 功能

- **大盘看板**：指数、涨跌家数、涨跌停、成交额、板块 / ETF 排行、自选，交易时段自动刷新。
- **日记**：一行输入，按交易时段（竞价 / 早盘 / 午间 / 尾盘 / 盘后）自动分条；
  一级 / 二级分类、标签、快捷短语；输入 `$` 联想指数 / 板块 / 题材 / ETF / 个股（代码、名称、首字母）。
  每条日记保存当时的行情快照，可修改并保留修改历史。
- **判断验证与复盘**：判断类日记自动生成判断，在当日收盘 / 次日开盘 / 次日收盘 / T+3 / T+5（中期加 T+20）
  多个时点判定对错；阈值按标的类型和周期可调；复盘笔记与准确率统计。
- **AI 大盘分析**：默认 DeepSeek（deepseek-flash，思考 max），也可选通义、Kimi、GLM、Claude、OpenAI 或任意 OpenAI 兼容接口；
  结构化输出趋势 / 情绪 / 支撑压力 / 要点 / 风险 / 展望，展望自动生成 AI 判断参与验证，可对比"我 vs AI"准确率；交易日定时分析。
- **持仓与交易**：手动记账（费用按账户费率自动算）、导入券商交割单（CSV / Excel，自动识别列，AI 推荐映射）、识别券商持仓 / 成交截图；
  摊薄 / 移动加权成本、浮动 / 当日 / 已实现盈亏、胜率与盈亏比。
- **AI 助手**：按需调用工具查询你的日记、判断与验证结果、持仓交易、AI 分析和实时行情来回答问题；多会话、滚动摘要、长期记忆；
  起草日记 / 保存记忆需你确认；回答中的引用可点击查看原文。
- **账户与云同步**：注册登录后多设备同步；自建同步服务器与网页管理后台（见 [server/](server/README.md)）。详见 [docs/SPEC.md](docs/SPEC.md)。

## 技术栈

Flutter（Android 优先，Windows 次之）· Riverpod · Drift (SQLite)。

行情数据源可配置优先级与自动降级：Tushare Pro（默认）、东方财富、腾讯。

## 运行

需要 Flutter 3.50+。

```bash
flutter pub get
```

Tushare token 在「设置 → 数据源」填写，AI 模型 Key 在「设置 → AI 模型」填写；开发时也可以写进项目根目录的 `.env`（已被 gitignore），参照 `.env.example`：

```bash
flutter run --dart-define-from-file=.env
```

> 用 `--dart-define-from-file` 构建时 token 会被编译进安装包，这样的包不要分发给别人。

测试：

```bash
flutter test --exclude-tags live
```

`test/live` 下的用例会请求真实接口，需要设置环境变量 `TUSHARE_TOKEN`（AI 用例另需 `DEEPSEEK_API_KEY`）。

## License

[MIT](LICENSE)
