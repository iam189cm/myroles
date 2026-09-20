# Clash Verge 个人规则

这个私有仓库保存当前 Clash Verge 订阅的**规则增强文件**和**扩展脚本**。它不保存节点订阅文件、订阅链接、密码或私钥。

## 当前内容

1. `clash-verge/rules.yaml`：保留从 Karing 迁移的原有规则，并在末尾加入四条 MetaCubeX 远程规则集的引用。原有 ZeroTier 等直连例外排在新规则之前。
2. `clash-verge/extension.js`：为当前订阅登记 `private`、`cn`、`geolocation-!cn` 和 `geoip/cn` 四组远程规则。规则源来自 [MetaCubeX/meta-rules-dat](https://github.com/MetaCubeX/meta-rules-dat)，由 Clash Verge 的 mihomo 内核下载和定期更新。
3. `scripts/apply.ps1`：将仓库版本应用到这台电脑当前启用的 Clash Verge 订阅；修改前自动备份原文件。
4. `scripts/capture.ps1`：如果在 Clash Verge 中改了增强文件，可将当前版本收集回仓库，供检查和提交。

规则中的代理目标目前是 `狗狗加速.com`。将来改用自己的 VPS 节点时，先把 `rules.yaml` 中的这一代理组名称，以及 `extension.js` 中的 `proxyGroup`，改为新配置中实际存在的代理组名称。

## 下载并应用

在 Windows 上克隆此私有仓库，或对已有副本执行 `git pull`。进入仓库后运行：

```powershell
pwsh -File .\scripts\apply.ps1 -CheckOnly
pwsh -File .\scripts\apply.ps1
```

然后在 Clash Verge 的「订阅」页面点击「重新激活订阅」。脚本只修改当前订阅已经绑定的规则增强文件与扩展脚本；若订阅名称不匹配或未绑定这两类文件，脚本会停止。

GitHub 私有仓库的原始文件需要身份验证。这里采用 `git pull` 后本地应用；不要将 GitHub 访问令牌放进 Clash Verge 的远程规则 URL。四组 MetaCubeX 规则仍会由 Clash Verge 从其公开地址自动更新。

## 整理并推送

直接编辑 `clash-verge/rules.yaml` 和 `clash-verge/extension.js`。自定义规则应放在 `rules.yaml` 的 `prepend` 列表末尾、`append: []` 之前；先写具体例外，再写宽泛的分流规则。这个文件很大，建议在文本编辑器中修改；当前版本的 Clash Verge 可视化规则编辑器打开它时曾出现内存不足。

编辑后运行应用脚本，在 Clash Verge 中重新激活订阅。确认可用后提交：

```powershell
git diff --check
git diff --stat
git add clash-verge/rules.yaml clash-verge/extension.js
git commit -m "更新 Clash Verge 分流规则" -m "1. 说明本次增删的规则及原因。"
git push
```

如果先在 Clash Verge 中修改了增强文件，可运行 `pwsh -File .\scripts\capture.ps1`，再检查差异并提交。不要把 `profiles.yaml`、远程订阅文件、密钥或含令牌的 URL 放进仓库。
