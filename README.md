# Clash Verge 个人规则

这个公开仓库保存 Clash Verge 的**规则增强文件**和**扩展脚本**。它不保存节点订阅文件、订阅链接、密码或私钥。

## 当前内容

1. `clash-verge/rules.yaml`：Clash Verge 实际读取的合并文件。保留从 Karing 迁移的原有规则顺序，在末尾加入四条分类规则。原有 ZeroTier 等直连例外排在新规则之前。
2. `clash-verge/extension.js`：创建通用的「自选代理」组，并登记 `private`、`cn`、`geolocation-!cn` 和 `geoip/cn` 四组远程规则。规则源来自 [MetaCubeX/meta-rules-dat](https://github.com/MetaCubeX/meta-rules-dat)，由 Clash Verge 的 mihomo 内核下载和定期更新。
3. `rules/*.list`：日后维护的分类规则源文件，按文件名顺序生成到 `rules.yaml`。详见 [规则分类说明](rules/README.md)。
4. `scripts/build.ps1`：从分类文件更新合并文件；`scripts/apply.ps1` 应用时会自动调用它，并在修改 Clash Verge 前备份。
5. `scripts/capture.ps1`：如果在 Clash Verge 中改了增强文件，可将当前版本收集回仓库，供检查和提交。

规则统一指向「自选代理」组，不写死任何订阅服务商。扩展脚本会把当前订阅中第一个可选择的代理组作为初始选项，并列出所有可用节点。将来换成自己的 VPS 节点时，在 Clash Verge 的「自选代理」组中选中该节点即可。

## 下载并应用

在 Windows 上克隆此仓库，或对已有副本执行 `git pull`。进入仓库后运行：

```powershell
pwsh -File .\scripts\apply.ps1 -CheckOnly
pwsh -File .\scripts\apply.ps1
```

然后在 Clash Verge 的「订阅」页面点击「重新激活订阅」。脚本只修改当前订阅已经绑定的规则增强文件与扩展脚本；若没有绑定这两类文件，脚本会停止。需要限定订阅时，可加 `-ExpectedProfile '订阅名称'`。

仓库公开后可以直接下载原始文件，但 `rules.yaml` 是 Clash Verge 的**规则增强格式**，不是可直接粘贴到「订阅链接」栏的完整订阅。这里仍采用 `git pull` 后本地应用。四组 MetaCubeX 规则会由 Clash Verge 从其公开地址自动更新。

## 整理并推送

新的分流规则请按用途编辑 `rules/*.list`，一行一条；运行 `pwsh -File .\scripts\build.ps1` 生成合并文件。代理组和远程规则源在 `clash-verge/extension.js` 中维护。历史迁移规则保留在 `clash-verge/rules.yaml` 分类标记之前，暂不按动作重新排列；这个文件很大，建议在文本编辑器中修改，当前版本的 Clash Verge 可视化规则编辑器打开它时曾出现内存不足。

编辑后运行应用脚本，在 Clash Verge 中重新激活订阅。确认可用后提交：

```powershell
git diff --check
git diff --stat
git add clash-verge/rules.yaml clash-verge/extension.js rules scripts README.md
git commit -m "更新 Clash Verge 分流规则" -m "1. 说明本次增删的规则及原因。"
git push
```

如果先在 Clash Verge 中修改了增强文件，可运行 `pwsh -File .\scripts\capture.ps1`，再检查差异并提交；分类标记内的规则仍以 `rules/*.list` 为准。不要把 `profiles.yaml`、远程订阅文件、密钥或含令牌的 URL 放进仓库。

当前历史迁移规则中有少量内网 IP 和一条本机程序路径，且它们已进入公开仓库的 Git 历史。将它们从最新文件删除不会清除旧提交的历史。
