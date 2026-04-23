[English](README.md) | 中文

# David 的技能库

**面向内容运营与开发者工作流的 AI Agent 技能集合。**

个人技能库，兼容 [Hermes Agent](https://github.com/nousresearch/hermes-agent) 与 [OpenClaw](https://github.com/openclaw/openclaw)。

---

## 安装

### Hermes Agent

```bash
git clone https://github.com/thedavidweng/skills.git ~/.hermes/skills/david-skills
```

重启 Hermes。技能会从 `~/.hermes/skills/` 自动发现，无需额外配置。

### OpenClaw

```bash
git clone https://github.com/thedavidweng/skills.git ~/.openclaw/skills/david-skills
```

重启 OpenClaw。技能会在下次会话启动时自动注册。

### 其他 Agent

这些技能也适用于所有兼容 [Agent Skills](https://agentskills.io/specification) 的工具：Amp、Cline、Codex、Cursor、Gemini CLI、Kimi Code CLI、OpenCode、Warp，以及通用的 `.agents/skills` 路径。

```bash
npx skills add thedavidweng/skills --full-depth
```

> 所有 Agent 会自动发现其技能路径下的 `SKILL.md` 文件。使用 `--full-depth` 以安装嵌套技能（例如 `wiki/` 下的全部技能）。

---

## 技能

### 个人知识库 Wiki

从你的笔记、消息和文档中构建并维护一个持续积累的知识库。

| 技能 | 说明 |
|------|------|
| **[wiki-core](wiki/wiki-core/)** | 构建 Wiki。摄取原始数据、吸收成文章、查询、清理。其他所有技能的基础。 |
| **[wiki-inline-linking](wiki/wiki-inline-linking/)** | 添加维基百科风格的行内双链。不再需要 `## Related` 区块。 |
| **[wiki-inline-link-audit](wiki/wiki-inline-link-audit/)** | 自动发现并修复全库中未链接的提及。 |
| **[wiki-slug-rename](wiki/wiki-slug-rename/)** | 重命名页面 slug，同时保持全库链接有效。 |
| **[wiki-sources-integrity](wiki/wiki-sources-integrity/)** | 在批量清理时保护 `## Sources` 区块，防止丢失身份文档链接。 |
| **[wiki-source-integration](wiki/wiki-source-integration/)** | 决定文档是内联嵌入还是存储在 `sources/` 中。 |
| **[wiki-source-document-ingest](wiki/wiki-source-document-ingest/)** | 将证书、合同、公函等文档摄入 sources 和 wiki 页面。 |
| **[wiki-vcf-import](wiki/wiki-vcf-import/)** | 将 VCF 联系人导入 `wiki/people/` 页面。处理中文姓名反转和号码脱敏。 |
| **[wiki-audit](wiki/wiki-audit/)** | 全库审计：孤立页面、断链、重复页面、草稿、标签合规、内容健康度。 |
| **[wiki-link-audit](wiki/wiki-link-audit/)** | 验证反向链接合法性。捕获虚假链接和同名冲突。 |
| **[wiki-quartz-publish](wiki/wiki-quartz-publish/)** | 将 Wiki 发布为私有 Quartz 站点。强烈建议使用 Cloudflare Access / Zero Trust。 |

### YouTube 内容运营

为已上传视频生成符合频道风格统一性的元数据。

| 技能 | 说明 |
|------|------|
| **[youtube-content-ops](youtube-content-ops/)** | 生成匹配频道品牌风格的标题、描述和标签。 |

### 代码质量

面向 AI 优先和 vibe coding 团队的系统化代码库维护。

| 技能 | 说明 |
|------|------|
| **[entropy-reduction](code-review/entropy-reduction/)** | 通过安全、渐进式重构，识别并修复结构性、语义性、行为性和演化性代码混乱。 |

---

## 使用方法

安装后，用自然语言向你的 Agent 提问：

```
"用我的笔记和消息构建一个 Wiki"
"审计我的 Wiki，检查断链和孤立页面"
"为这条视频写一段 YouTube 描述"
"重构这段代码，减少技术债务"
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

---

## 贡献

个人收藏，但欢迎提交 Bug 报告和改进。详见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 许可证

[MIT](LICENSE)
