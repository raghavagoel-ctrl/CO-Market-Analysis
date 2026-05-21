# Reference parser for Colombia Top 8 BOs.xlsx (ZIP/XML — no Excel COM required)
# Usage:
#   .\parse_colombia_bo_xlsx.ps1 -SourcePath "..\data\Colombia Top 8 BOs.xlsx"
#
# Outputs CSV summaries under data/derived/ when -EmitCsv is set.

param(
    [string]$SourcePath = (Join-Path $PSScriptRoot "..\data\Colombia Top 8 BOs.xlsx"),
    [switch]$EmitCsv
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

if (-not (Test-Path $SourcePath)) {
    Write-Error "Source not found: $SourcePath. Copy xlsx to data/ (see data/README.md)."
}

$temp = Join-Path $env:TEMP "ColombiaBO_temp_$(Get-Date -Format 'yyyyMMddHHmmss').xlsx"
Copy-Item -Path $SourcePath -Destination $temp -Force

function Get-SharedStrings([System.IO.Compression.ZipArchive]$zip) {
    $entry = $zip.Entries | Where-Object { $_.FullName -eq "xl/sharedStrings.xml" }
    if (-not $entry) { return @() }
    $stream = $entry.Open()
    $reader = New-Object System.IO.StreamReader($stream)
    $xml = $reader.ReadToEnd()
    $reader.Close()
    $matches = [regex]::Matches($xml, '<t[^>]*>([^<]*)</t>')
    $list = New-Object System.Collections.Generic.List[string]
    foreach ($m in $matches) { $list.Add([System.Net.WebUtility]::HtmlDecode($m.Groups[1].Value)) }
    return $list.ToArray()
}

function Resolve-CellValue($cellNode, [string[]]$strings) {
    $t = $cellNode.GetAttribute("t")
    $vNode = $cellNode.SelectSingleNode("main:v", $cellNode.OwnerDocument.NamespaceManager)
    if (-not $vNode) { return $null }
    $v = $vNode.InnerText
    if ($t -eq "s") { return $strings[[int]$v] }
    return $v
}

# Legacy operator IDs to exclude from 2026-only double count (extend as needed)
$excludeOldIds = @(20982, 23180, 15612)

$zip = [System.IO.Compression.ZipFile]::OpenRead($temp)
try {
    $strings = Get-SharedStrings $zip
    Write-Host "Shared strings: $($strings.Count)"

    $sheetEntry = $zip.Entries | Where-Object { $_.FullName -eq "xl/worksheets/sheet1.xml" }
    $stream = $sheetEntry.Open()
    $reader = New-Object System.IO.StreamReader($stream)
    $sheetXml = $reader.ReadToEnd()
    $reader.Close()

    # Minimal row scan: extract route labels and monthly numeric columns by cell ref letter
    # Production use should mirror the full column map in METHODOLOGY.md (D,F,H / J,L,N)
    $rowMatches = [regex]::Matches($sheetXml, '<row[^>]*r="(\d+)"[^>]*>(.*?)</row>', 'Singleline')
    Write-Host "Sheet1 rows (XML): $($rowMatches.Count)"

    $artifactRows = 0
    $cleanRoutes = 0
    foreach ($row in $rowMatches) {
        $cells = [regex]::Matches($row.Groups[2].Value, '<c r="([A-Z]+)(\d+)"([^>]*)>(.*?)</c>', 'Singleline')
        $vals = @{}
        foreach ($c in $cells) {
            $col = $c.Groups[1].Value
            $vals[$col] = $c.Groups[4].Value
        }
        # Pivot artifact: D=F=H copied from J
        if ($vals.ContainsKey('D') -and $vals.ContainsKey('F') -and $vals.ContainsKey('H') -and $vals.ContainsKey('J')) {
            if ($vals['D'] -eq $vals['F'] -and $vals['F'] -eq $vals['H'] -and [double]$vals['D'] -gt 0) {
                $artifactRows++
                continue
            }
        }
        if ($vals.ContainsKey('B') -or $vals.ContainsKey('C')) { $cleanRoutes++ }
    }

    Write-Host "Pivot artifact rows (approx): $artifactRows"
    Write-Host "Rows with operator/route cols (approx): $cleanRoutes"
    Write-Host ""
    Write-Host "Next: implement full aggregation in Python or extend this script."
    Write-Host "See WORKFLOW.md and METHODOLOGY.md for business rules."
}
finally {
    $zip.Dispose()
    Remove-Item $temp -Force -ErrorAction SilentlyContinue
}

if ($EmitCsv) {
    $outDir = Join-Path (Split-Path $SourcePath) "derived"
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    Write-Host "EmitCsv: stub only — add CSV writers after validating aggregates."
}
