param(
    [string] $ExpectedProfile = '',
    [switch] $CheckOnly
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '_profile.ps1')
$active = Resolve-ActiveClashProfile
if ($ExpectedProfile -and $active.ProfileName -ne $ExpectedProfile) {
    throw "当前订阅为「$($active.ProfileName)」，预期为「$ExpectedProfile」。请检查规则中的代理组名称。"
}

$repoRoot = Split-Path $PSScriptRoot -Parent
if ($CheckOnly) {
    & (Join-Path $PSScriptRoot 'build.ps1') -CheckOnly
} else {
    & (Join-Path $PSScriptRoot 'build.ps1')
}
$sourceRules = Join-Path $repoRoot 'clash-verge\rules.yaml'
$sourceScript = Join-Path $repoRoot 'clash-verge\extension.js'
foreach ($path in @($sourceRules, $sourceScript)) {
    if (-not (Test-Path -LiteralPath $path)) { throw "仓库文件缺失：$path" }
}

$rulesText = Get-Content -LiteralPath $sourceRules -Raw -Encoding utf8
$scriptText = Get-Content -LiteralPath $sourceScript -Raw -Encoding utf8
if ($rulesText -notmatch '(?m)^prepend:\s*$' -or $rulesText -notmatch '(?m)^append:\s*\[\]\s*$') {
    throw '规则文件结构与 Clash Verge 的规则增强格式不符'
}
if ($scriptText -notmatch 'function\s+main\s*\(') { throw '扩展脚本缺少 main 函数' }

Write-Output "当前订阅：$($active.ProfileName)"
Write-Output "规则目标：$($active.RulePath)"
Write-Output "脚本目标：$($active.ScriptPath)"
if ($CheckOnly) {
    Write-Output '检查完成，未修改 Clash Verge。'
    return
}

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDir = Join-Path $active.Root ("codex-rule-backups\$stamp")
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
$backupRules = Join-Path $backupDir 'rules.yaml'
$backupScript = Join-Path $backupDir 'extension.js'
Copy-Item -LiteralPath $active.RulePath -Destination $backupRules
Copy-Item -LiteralPath $active.ScriptPath -Destination $backupScript

try {
    Copy-Item -LiteralPath $sourceRules -Destination $active.RulePath -Force
    Copy-Item -LiteralPath $sourceScript -Destination $active.ScriptPath -Force
    if ((Get-FileHash -LiteralPath $sourceRules).Hash -ne (Get-FileHash -LiteralPath $active.RulePath).Hash -or
        (Get-FileHash -LiteralPath $sourceScript).Hash -ne (Get-FileHash -LiteralPath $active.ScriptPath).Hash) {
        throw '复制后的文件校验失败'
    }
} catch {
    Copy-Item -LiteralPath $backupRules -Destination $active.RulePath -Force
    Copy-Item -LiteralPath $backupScript -Destination $active.ScriptPath -Force
    throw
}

Write-Output "已应用。备份：$backupDir"
Write-Output '请在 Clash Verge 的「订阅」页面点击「重新激活订阅」，使新规则生效。'
