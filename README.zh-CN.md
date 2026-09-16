[English](README.md) | 中文

# David 的技能库

**面向内容运营与开发者工作流的 AI Agent 技能集合。**

个人技能库，兼容 [Hermes Agent](https://github.com/nousresearch/hermes-agent) 与 [OpenClaw](https://github.com/openclaw/openclaw)。

---

## 安装

适用于 [Hermes Agent](https://github.com/nousresearch/hermes-agent)、[OpenClaw](https://github.com/openclaw/openclaw) 以及所有兼容 [Agent Skills](https://agentskills.io/specification) 的工具（Amp、Cline、Codex、Cursor、Gemini CLI、Kimi Code CLI、OpenCode、Warp）。

```bash
npx skills add thedavidweng/skills
```

安装器会打开交互式多选菜单。要一次性安装所有技能，可以使用：

```bash
npx skills add thedavidweng/skills --all
```

---

## 技能

### 个人知识库 Wiki

从你的笔记、消息和文档中构建并维护一个持续积累的知识库。

| 技能 | 说明 |
|------|------|
| **[wiki-core](wiki/wiki-core/)** | 构建 Wiki。摄取原始数据、吸收成文章、查询、清理。其他所有技能的基础。 |
| **[wiki-linking](wiki/wiki-linking/)** | 添加行内双链、扫描未链接提及、验证反向链接。不再需要 `## Related` 区块。 |
| **[wiki-slug-rename](wiki/wiki-slug-rename/)** | 重命名页面 slug，同时保持全库链接有效。 |
| **[wiki-sources](wiki/wiki-sources/)** | Source 层：内联还是存文件、摄入证书合同、保护 `## Sources` 区块。 |
| **[wiki-vcf-import](wiki/wiki-vcf-import/)** | 将 VCF 联系人导入 `wiki/people/` 页面。处理中文姓名反转和号码脱敏。 |
| **[wiki-audit](wiki/wiki-audit/)** | 全库审计：孤立页面、断链、重复页面、草稿、标签合规、内容健康度。 |
| **[wiki-quartz-publish](wiki/wiki-quartz-publish/)** | 将 Wiki 发布为私有 Quartz 站点。强烈建议使用 Cloudflare Access / Zero Trust。 |

### Content Operations

为已上传视频生成符合频道风格统一性的元数据。

| 技能 | 说明 |
|------|------|
| **[youtube-content-ops](content-ops/youtube-content-ops/)** | 生成匹配频道品牌风格的标题、描述和标签。 |

### 文档生成

以文本为源的文档工作流。管理源文件而非 PDF——按需生成。

| 技能 | 说明 |
|------|------|
| **[cover-letter](document-generation/cover-letter/)** | 基于 Typst 生成专业求职信。校准过的模板，精确排版——一条命令出 PDF。 |
| **[json-resume](document-generation/json-resume/)** | 基于 JSON Resume 标准管理简历。数据/样式分离，主题渲染，自动发布到 Registry。 |
| **[cli-invoice](document-generation/cli-invoice/)** | 基于 maaslalani/invoice CLI 生成发票。命令本身就是源文件——存在笔记里，随时重新生成。 |

### 代码质量

面向 AI 优先和 vibe coding 团队的系统化代码库维护。

| 技能 | 说明 |
|------|------|
| **[entropy-reduction](code-review/entropy-reduction/)** | 通过安全、渐进式重构，识别并修复结构性、语义性、行为性和演化性代码混乱。 |
| **[go-production-review](code-review/go-production-review/)** | 审计 Go 代码库的生产就绪性——模块、错误处理、并发、测试、安全、CI/CD、可观测性。 |

### Web 开发

审计并优化网站的 AI 可发现性和 Agent 体验。

| 技能 | 说明 |
|------|------|
| **[aeo-audit](web-dev/aeo-audit/)** | 审计任意网站的 Agent 体验优化——llms.txt、schema.org、语义化 HTML、站点地图及跨信号一致性。 |

### 写作

风格引导的内容生成与审查。

| 技能 | 说明 |
|------|------|
| **[david-weng-writing-style](writing/david-weng-writing-style/)** | 按 David Weng 的个人风格写作或审查文字——直截了当、不废话。融合声音结构规则与中英混排排版规范。 |

### 维护

| 技能 | 说明 |
|------|------|
| **[roast-my-computer](maintenance/roast-my-computer/)** | 扫描本地机器，生成隐私安全的开发者吐槽报告——废弃项目、依赖坟场、Git 耻辱、AI 垃圾、脱敏后的泄密风险。 |
| **[skill-repo-maintenance](maintenance/skill-repo-maintenance/)** | 维护和重组 Agent Skills 仓库。重命名技能、修复安装命令、规避 CLI 陷阱。 |
| **[stale-docs-cleanup](maintenance/stale-docs-cleanup/)** | 清理过期文档，将未来工作移入 issue，保留面向人工的指南和冻结接口契约。 |
---

## 使用方法

安装后，用自然语言向你的 Agent 提问：

```
"用我的笔记和消息构建一个 Wiki"
"审计我的 Wiki，检查断链和孤立页面"
"为这条视频写一段 YouTube 描述"
"重构这段代码，减少技术债务"
"帮我写一封求职信"
"把我的简历渲染成 PDF"
"生成上个月的发票"
```

每个技能会自动检测合适的工作流，从你的数据或代码库中获取上下文，并输出结果。Agent Skills 遵循标准格式：每个技能目录包含一个记录完整工作流规范的 `SKILL.md`，以及可选的 `references/` 目录存放模板、速查表和示例。

---

## 目录结构

每个技能遵循标准的 Agent Skills 格式：

```
skill-name/
├── SKILL.md           # Agent 的完整工作流规范
├── agents/
│   └── openai.yaml    # UI 元数据
└── references/        # 模板、速查表、示例
```

- `SKILL.md` — 命令、决策树、陷阱、发布前检查清单
- `agents/openai.yaml` — 技能名称与描述，用于 Agent UI 发现
- `references/` — 品牌指南模板、CLI 命令参考、支持文档

分类目录（例如 `wiki/`、`code-review/`）下的 `README.md` 汇总该分类中的所有技能。

仓库根目录还包含 `.claude-plugin/plugin.json`，用于声明 `npx skills add thedavidweng/skills` 默认展示哪些技能。新增、移动或重命名技能时，需要同步更新这个清单。

---

## 贡献

个人收藏，但欢迎提交 Bug 报告和改进。详见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 许可证

[MIT](LICENSE)
