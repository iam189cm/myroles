param([string] $ExpectedProfile = '狗狗加速.com')

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '_profile.ps1')
$active = Resolve-ActiveClashProfile
if ($active.ProfileName -ne $ExpectedProfile) {
    throw "当前订阅为「$($active.ProfileName)」，预期为「$ExpectedProfile」。"
}

$rulesText = Get-Content -LiteralPath $active.RulePath -Raw -Encoding utf8
$scriptText = Get-Content -LiteralPath $active.ScriptPath -Raw -Encoding utf8
$sensitivePattern = '(?im)^\s*(?:password|private[-_]?key|secret|token|authorization|api[-_]?key)\s*[:=]'
if ($rulesText -match $sensitivePattern -or $scriptText -match $sensitivePattern) {
    throw '扩展文件中疑似包含密钥或密码，已停止复制；请先人工检查。'
}

$repoRoot = Split-Path $PSScriptRoot -Parent
Copy-Item -LiteralPath $active.RulePath -Destination (Join-Path $repoRoot 'clash-verge\rules.yaml') -Force
Copy-Item -LiteralPath $active.ScriptPath -Destination (Join-Path $repoRoot 'clash-verge\extension.js') -Force
Write-Output '已从当前 Clash Verge 订阅收集规则和脚本。请检查 Git 差异后再提交和推送。'
