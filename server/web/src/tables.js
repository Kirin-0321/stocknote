// 各表在后台的显示：中文名与列表列（列名为 App 数据库的原始列名）。
import { fmtTime } from './api'

const time = (k) => ({ key: k, label: '时间', fmt: fmtTime })

export const LABELS = {
  category: { observe: '观察', judge: '判断', plan: '计划', review: '复盘', other: '其他' },
  side: { buy: '买入', sell: '卖出', dividend: '分红', bonus: '送转', init: '期初持仓' },
  direction: { up: '看多', down: '看空', range: '震荡' },
  status: { correct: '正确', partial: '部分正确', wrong: '错误', pending_manual: '待手动' },
  source: { user: '用户', ai: 'AI', manual: '手动', table: '表格导入', image: '截图导入' },
}

const lab = (dict) => (v) => LABELS[dict][v] ?? v ?? '—'

export const TABLES = [
  {
    tbl: 'journal_entries',
    name: '日记',
    cols: [time('ts'), { key: 'category', label: '分类', fmt: lab('category') }, { key: 'subcategory', label: '二级' }, { key: 'content', label: '内容', wide: true }],
  },
  {
    tbl: 'trades',
    name: '交易',
    cols: [time('ts'), { key: 'instrument_code', label: '代码' }, { key: 'side', label: '方向', fmt: lab('side') }, { key: 'price', label: '价格' }, { key: 'qty', label: '数量' }, { key: 'amount', label: '金额' }, { key: 'source', label: '来源', fmt: lab('source') }, { key: 'note', label: '备注', wide: true }],
  },
  {
    tbl: 'accounts',
    name: '账户',
    cols: [{ key: 'name', label: '名称' }, { key: 'broker', label: '券商' }, { key: 'commission_rate', label: '佣金费率' }, { key: 'min_commission', label: '最低佣金' }],
  },
  {
    tbl: 'predictions',
    name: '判断',
    cols: [time('created_at'), { key: 'source', label: '来源', fmt: lab('source') }, { key: 'target_code', label: '标的' }, { key: 'direction', label: '方向', fmt: lab('direction') }, { key: 'horizon_type', label: '周期' }, { key: 'due_date', label: '到期' }, { key: 'base_price', label: '基准价' }],
  },
  {
    tbl: 'prediction_results',
    name: '验证结果',
    cols: [time('decided_at'), { key: 'checkpoint', label: '时点' }, { key: 'status', label: '结果', fmt: lab('status') }, { key: 'actual_close', label: '价格' }, { key: 'change_pct', label: '涨跌%' }],
  },
  { tbl: 'review_notes', name: '复盘笔记', cols: [time('created_at'), { key: 'content', label: '内容', wide: true }] },
  { tbl: 'ai_analyses', name: 'AI 分析', cols: [time('ts'), { key: 'trigger', label: '触发' }, { key: 'model', label: '模型' }, { key: 'output', label: '结果', wide: true, fmt: (v) => { try { return JSON.parse(v).summary } catch { return v } } }] },
  { tbl: 'market_snapshots', name: '行情快照', cols: [time('ts')] },
  { tbl: 'revisions', name: '修改历史', cols: [time('ts'), { key: 'entity_type', label: '对象' }, { key: 'revision_no', label: '版本' }, { key: 'changed_fields', label: '改动字段', wide: true }] },
  { tbl: 'quick_phrases', name: '常用短语', cols: [{ key: 'text', label: '短语', wide: true }, { key: 'category', label: '分类' }] },
  { tbl: 'threshold_rules', name: '判定阈值', cols: [{ key: 'scope', label: '范围' }, { key: 'instrument_type', label: '类型' }, { key: 'horizon_type', label: '周期' }, { key: 'pct', label: '阈值%' }] },
  { tbl: 'import_batches', name: '导入批次', cols: [time('ts'), { key: 'kind', label: '方式' }, { key: 'file_name', label: '文件' }, { key: 'row_count', label: '条数' }] },
  { tbl: 'column_mappings', name: '列映射', cols: [{ key: 'name', label: '名称', wide: true }] },
  { tbl: 'position_snapshots', name: '持仓快照', cols: [{ key: 'date', label: '日期' }, { key: 'instrument_code', label: '代码' }, { key: 'qty', label: '数量' }, { key: 'cost_price', label: '成本' }] },
  { tbl: 'entry_templates', name: '模板', cols: [{ key: 'name', label: '名称' }] },
  { tbl: 'agent_threads', name: 'Agent 会话', cols: [{ key: 'title', label: '标题', wide: true }] },
  { tbl: 'agent_messages', name: 'Agent 消息', cols: [time('ts'), { key: 'role', label: '角色' }, { key: 'content', label: '内容', wide: true }] },
  { tbl: 'agent_memories', name: 'Agent 记忆', cols: [{ key: 'kind', label: '类型' }, { key: 'content', label: '内容', wide: true }] },
]
