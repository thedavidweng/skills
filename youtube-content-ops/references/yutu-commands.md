# yutu 命令速查

完整的 yutu CLI 命令参考，用于 YouTube API 操作。

## 认证

```bash
# 首次授权
yutu auth --credential client_secret.json

# 指定 token 存储位置
yutu auth --credential client_secret.json --cacheToken token.json
```

## 字幕操作 (caption)

```bash
# 列出视频所有字幕
yutu caption list --videoId VIDEO_ID --output json

# 下载字幕
yutu caption download --id CAPTION_ID --file output.srt --tfmt srt

# 下载为 VTT 格式
yutu caption download --id CAPTION_ID --file output.vtt --tfmt vtt

# 下载翻译后的字幕
yutu caption download --id CAPTION_ID --file output.srt --tlang zh-Hans

# 上传字幕
yutu caption insert --videoId VIDEO_ID --file subtitle.srt --language en

# 删除字幕
yutu caption delete --id CAPTION_ID
```

## 视频操作 (video)

```bash
# 获取视频信息
yutu video list --ids VIDEO_ID --output json

# 获取多个视频信息
yutu video list --ids VIDEO_ID1,VIDEO_ID2,VIDEO_ID3 --output json

# 更新视频标题
yutu video update --id VIDEO_ID --title "新标题"

# 更新视频描述
yutu video update --id VIDEO_ID --description "新描述"

# 更新视频标签
yutu video update --id VIDEO_ID --tags "tag1,tag2,tag3"

# 更新视频分类
yutu video update --id VIDEO_ID --categoryId 27

# 更新隐私设置
yutu video update --id VIDEO_ID --privacy public    # public/private/unlisted

# 组合更新
yutu video update --id VIDEO_ID \
  --title "标题" \
  --description "描述" \
  --tags "tag1,tag2" \
  --privacy public

# 删除视频
yutu video delete --id VIDEO_ID
```

## 频道操作 (channel)

```bash
# 列出用户管理的频道
yutu channel list --output json

# 获取频道详情
yutu channel list --id CHANNEL_ID --output json

# 更新频道信息
yutu channel update --id CHANNEL_ID --title "频道名称" --description "频道描述"
```

## 播放列表操作 (playlist)

```bash
# 列出频道的播放列表
yutu playlist list --mine --output json

# 创建播放列表
yutu playlist insert --title "播放列表名称" --description "描述" --privacy public

# 更新播放列表
yutu playlist update --id PLAYLIST_ID --title "新名称"

# 删除播放列表
yutu playlist delete --id PLAYLIST_ID
```

## 播放列表项操作 (playlistItem)

```bash
# 列出播放列表中的视频
yutu playlistItem list --playlistId PLAYLIST_ID --output json

# 添加视频到播放列表
yutu playlistItem insert --playlistId PLAYLIST_ID --videoId VIDEO_ID

# 从播放列表移除视频
yutu playlistItem delete --id PLAYLIST_ITEM_ID
```

## 缩略图操作 (thumbnail)

```bash
# 设置视频缩略图
yutu thumbnail set --videoId VIDEO_ID --file thumbnail.jpg
```

## 搜索操作 (search)

```bash
# 搜索视频
yutu search --query "搜索关键词" --type video --maxResults 10 --output json

# 搜索播放列表
yutu search --query "搜索关键词" --type playlist --maxResults 10

# 搜索频道
yutu search --query "搜索关键词" --type channel --maxResults 10
```

## 订阅操作 (subscription)

```bash
# 列出用户的订阅
yutu subscription list --output json

# 订阅频道
yutu subscription insert --channelId CHANNEL_ID

# 取消订阅
yutu subscription delete --id SUBSCRIPTION_ID
```

## 评论操作 (comment)

```bash
# 列出视频评论
yutu comment list --videoId VIDEO_ID --output json

# 发表评论
yutu comment insert --videoId VIDEO_ID --text "评论内容"

# 回复评论
yutu comment insert --parentId COMMENT_ID --text "回复内容"

# 删除评论
yutu comment delete --id COMMENT_ID
```

## 输出格式

所有 `--output` 参数支持：
- `table` - 表格格式（默认）
- `json` - JSON 格式
- `yaml` - YAML 格式

## 视频分类 ID

常用分类（美国）：
| ID | 分类 |
|----|------|
| 1 | Film & Animation |
| 2 | Autos & Vehicles |
| 10 | Music |
| 15 | Pets & Animals |
| 17 | Sports |
| 20 | Gaming |
| 22 | People & Blogs |
| 23 | Comedy |
| 24 | Entertainment |
| 25 | News & Politics |
| 26 | Howto & Style |
| 27 | Education |
| 28 | Science & Technology |
| 29 | Nonprofits & Activism |

完整分类列表：
```bash
yutu videoCategory list --output json
```

## 环境变量

```bash
# 凭证文件路径
export YUTU_CREDENTIAL=/path/to/client_secret.json

# Token 文件路径
export YUTU_TOKEN=/path/to/token.json

# 工作目录
export YUTU_ROOT=/path/to/workspace

# 日志级别
export YUTU_LOG_LEVEL=DEBUG
```

## 错误排查

| 错误 | 原因 | 解决方案 |
|------|------|---------|
| `dailyLimitExceeded` | API 配额用尽 | 等待次日重置或申请更高配额 |
| `authError` | Token 过期或无效 | 重新运行 `yutu auth` |
| `forbidden` | 无权限操作该资源 | 确认 OAuth 授权范围 |
| `notFound` | 视频/频道不存在 | 检查 ID 是否正确 |
| `quotaExceeded` | 请求频率过高 | 降低请求频率 |
