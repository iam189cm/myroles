# 分流规则分类

Clash Verge 使用 Mihomo 规则。每条规则由「匹配类型、匹配内容、动作」组成，例如 `DOMAIN-SUFFIX,example.com,自选代理`。域名匹配、IP 匹配、进程匹配是不同的**匹配类型**；`DIRECT`（直连）、`自选代理`（经选中的节点）、`REJECT`（拒绝）是**动作**。

规则从上到下匹配，第一条命中后就停止。因此分类文件的先后顺序也是优先级，文件名中的数字决定生成顺序。当前分类规则排在约 4.6 万条历史迁移规则之后，以保持原有分流结果。

| 文件 | 用途 | 当前规则 |
| --- | --- | --- |
| `10-private-domain.list` | 私有域名直连 | MetaCubeX `geosite/private` |
| `20-cn-domain.list` | 国内域名直连 | MetaCubeX `geosite/cn` |
| `30-foreign-domain.list` | 国外域名走代理 | MetaCubeX `geosite/geolocation-!cn` |
| `40-cn-ip.list` | 国内 IP 直连 | MetaCubeX `geoip/cn` |

私有域名与局域网 IP 是两回事。当前 `10-private-domain.list` 只引用私有**域名**集合；历史规则中有若干特定私有 IP 例外。以后需要完整处理局域网 IP 时，应另加明确的 IP 规则，并检查它与历史规则及订阅自带规则的优先级。

添加规则时，一行写一条 Mihomo 规则，不要写 YAML 引号或前导 `-`。例如把 `DOMAIN-SUFFIX,example.com,DIRECT` 放入国内域名文件，或把 `DOMAIN-SUFFIX,example.org,自选代理` 放入国外域名文件。具体例外应排在宽泛规则之前。同一域名若需要覆盖历史规则，应放到 `clash-verge/rules.yaml` 历史规则之前，并先检查是否与已有规则冲突；仅放在分类文件末尾不会覆盖更早命中的历史规则。

运行 `pwsh -File .\scripts\build.ps1` 生成 `clash-verge/rules.yaml`，再运行 `pwsh -File .\scripts\apply.ps1 -CheckOnly` 检查，最后运行 `pwsh -File .\scripts\apply.ps1` 并在 Clash Verge 中重新激活订阅。
