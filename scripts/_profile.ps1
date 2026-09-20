function Resolve-ActiveClashProfile {
    $root = Join-Path $env:APPDATA 'io.github.clash-verge-rev.clash-verge-rev'
    $profilesDir = Join-Path $root 'profiles'
    $manifestPath = Join-Path $root 'profiles.yaml'
    if (-not (Test-Path -LiteralPath $manifestPath)) {
        throw "未找到 Clash Verge 配置：$manifestPath"
    }

    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding utf8
    $currentMatch = [regex]::Match($manifest, '(?m)^current:\s*(\S+)\s*$')
    if (-not $currentMatch.Success) { throw '未找到当前启用的订阅' }
    $currentUid = $currentMatch.Groups[1].Value

    $blocks = [regex]::Matches($manifest, '(?ms)^- uid:\s*([^\r\n]+)\r?\n(.*?)(?=^- uid:|\z)')
    $items = @{}
    foreach ($block in $blocks) {
        $items[$block.Groups[1].Value.Trim()] = $block.Value
    }
    if (-not $items.ContainsKey($currentUid)) { throw '当前订阅在配置清单中不存在' }
    $activeBlock = $items[$currentUid]
    $nameMatch = [regex]::Match($activeBlock, '(?m)^  name:\s*(.+?)\s*$')
    $profileName = if ($nameMatch.Success) { $nameMatch.Groups[1].Value.Trim('"', "'") } else { '' }

    $rulesMatch = [regex]::Match($activeBlock, '(?m)^    rules:\s*(\S+)\s*$')
    $scriptMatch = [regex]::Match($activeBlock, '(?m)^    script:\s*(\S+)\s*$')
    if (-not $rulesMatch.Success -or -not $scriptMatch.Success) {
        throw '当前订阅尚未绑定规则增强文件和扩展脚本'
    }

    function Get-LinkedFile([string] $uid) {
        if (-not $items.ContainsKey($uid)) { throw "找不到扩展文件：$uid" }
        $match = [regex]::Match($items[$uid], '(?m)^  file:\s*(\S+)\s*$')
        if (-not $match.Success) { throw "扩展文件缺少路径：$uid" }
        $filename = $match.Groups[1].Value
        if ([IO.Path]::GetFileName($filename) -ne $filename) { throw '扩展文件路径无效' }
        $path = Join-Path $profilesDir $filename
        if (-not (Test-Path -LiteralPath $path)) { throw "扩展文件不存在：$filename" }
        return $path
    }

    [pscustomobject]@{
        Root = $root
        ProfileName = $profileName
        RulePath = Get-LinkedFile $rulesMatch.Groups[1].Value
        ScriptPath = Get-LinkedFile $scriptMatch.Groups[1].Value
    }
}
