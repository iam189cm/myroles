param([switch] $CheckOnly)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
$target = Join-Path $repoRoot 'clash-verge\rules.yaml'
$categories = @(
    '10-private-domain.list',
    '20-cn-domain.list',
    '30-foreign-domain.list',
    '40-cn-ip.list'
)
$begin = '  # BEGIN MANAGED CATEGORY RULES'
$end = '  # END MANAGED CATEGORY RULES'
$raw = Get-Content -LiteralPath $target -Raw -Encoding utf8
$start = $raw.IndexOf($begin, [StringComparison]::Ordinal)
$finish = $raw.IndexOf($end, [StringComparison]::Ordinal)
if ($start -lt 0 -or $finish -le $start) {
    throw 'rules.yaml 缺少分类规则标记，无法安全生成。'
}
if ($raw.IndexOf($begin, $start + $begin.Length, [StringComparison]::Ordinal) -ge 0 -or
    $raw.IndexOf($end, $finish + $end.Length, [StringComparison]::Ordinal) -ge 0) {
    throw 'rules.yaml 中分类规则标记重复。'
}

$newline = if ($raw.Contains("`r`n")) { "`r`n" } else { "`n" }
$generated = [System.Collections.Generic.List[string]]::new()
$generated.Add($begin)
foreach ($file in $categories) {
    $path = Join-Path $repoRoot (Join-Path 'rules' $file)
    if (-not (Test-Path -LiteralPath $path)) { throw "缺少分类规则文件：$path" }
    $generated.Add("  # $file")
    foreach ($line in [System.IO.File]::ReadAllLines($path, [System.Text.Encoding]::UTF8)) {
        $rule = $line.Trim()
        if (-not $rule -or $rule.StartsWith('#')) { continue }
        if ($rule -notmatch '^[A-Z][A-Z0-9-]*,[^,]+,[^,]+(?:,no-resolve)?$') {
            throw "规则格式不符合预期：${file}: $rule"
        }
        $escaped = $rule.Replace("'", "''")
        $generated.Add("  - '$escaped'")
    }
}
$generated.Add($end)
$replacement = $generated -join $newline
$expected = $raw.Substring(0, $start) + $replacement + $raw.Substring($finish + $end.Length)

if ($CheckOnly) {
    if ($expected -cne $raw) { throw '分类规则已修改，请先运行 scripts/build.ps1 生成 rules.yaml。' }
    Write-Output '分类规则与 rules.yaml 一致。'
    return
}
if ($expected -cne $raw) {
    [System.IO.File]::WriteAllText($target, $expected, [System.Text.UTF8Encoding]::new($false))
    Write-Output "已生成：$target"
} else {
    Write-Output '规则文件已是最新。'
}
