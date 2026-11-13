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
- 规划中：AI 大盘分析（默认 DeepSeek）、持仓与交易记录、全局 Agent 助手、云同步。详见 [docs/SPEC.md](docs/SPEC.md)。

## 技术栈

Flutter（Android 优先，Windows 次之）· Riverpod · Drift (SQLite)。

行情数据源可配置优先级与自动降级：Tushare Pro（默认）、东方财富、腾讯。

## 运行

需要 Flutter 3.50+。

```bash
flutter pub get
```

Tushare token 可以在 App 的「设置 → 数据源」中填写；开发时也可以写进项目根目录的 `.env`（已被 gitignore），参照 `.env.example`：

```bash
flutter run --dart-define-from-file=.env
```

> 用 `--dart-define-from-file` 构建时 token 会被编译进安装包，这样的包不要分发给别人。

测试：

```bash
flutter test --exclude-tags live
```

`test/live` 下的用例会请求真实接口，需要设置环境变量 `TUSHARE_TOKEN`。

## License

[MIT](LICENSE)
