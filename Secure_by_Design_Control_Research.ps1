#requires -Version 5.1
[CmdletBinding()]
param([Parameter(Mandatory)][string]$InputCsv,[string]$OutputPath)
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
if([string]::IsNullOrWhiteSpace($OutputPath)){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'Secure_by_Design_Research'}
New-Item -Path $OutputPath -ItemType Directory -Force|Out-Null
if(-not(Test-Path $InputCsv)){Write-Error 'Input CSV not found.';return}
$rows=Import-Csv $InputCsv|ForEach-Object{
 $implemented=$_.Implemented -match 'Yes|True'
 $defaultSecure=$_.DefaultSecure -match 'Yes|True'
 $evidence=-not [string]::IsNullOrWhiteSpace($_.Evidence)
 $score=0;if($implemented){$score+=45};if($defaultSecure){$score+=30};if($evidence){$score+=15};if($_.ReviewFrequency -match 'Monthly|Quarterly|Annual'){$score+=10}
 [PSCustomObject]@{Product=$_.Product;Owner=$_.Owner;ControlArea=$_.ControlArea;ControlName=$_.ControlName;Implemented=$implemented;DefaultSecure=$defaultSecure;Evidence=$_.Evidence;ReviewFrequency=$_.ReviewFrequency;Risk=$_.Risk;ControlScore=$score;Maturity=$(if($score -ge 85){'Established'}elseif($score -ge 60){'Developing'}else{'Gap'});Notes=$_.Notes}
}
$byProduct=$rows|Group-Object Product|ForEach-Object{[PSCustomObject]@{Product=$_.Name;Controls=$_.Count;Established=@($_.Group|Where-Object Maturity -eq 'Established').Count;Developing=@($_.Group|Where-Object Maturity -eq 'Developing').Count;Gaps=@($_.Group|Where-Object Maturity -eq 'Gap').Count;AverageScore=[math]::Round((($_.Group.ControlScore|Measure-Object -Average).Average),1)}}
$byArea=$rows|Group-Object ControlArea|ForEach-Object{[PSCustomObject]@{ControlArea=$_.Name;Controls=$_.Count;AverageScore=[math]::Round((($_.Group.ControlScore|Measure-Object -Average).Average),1)}}
$gaps=$rows|Where-Object Maturity -ne 'Established'|Select-Object Product,Owner,ControlArea,ControlName,Implemented,DefaultSecure,Evidence,ReviewFrequency,Risk,ControlScore,Maturity
$summary=[PSCustomObject]@{Controls=@($rows).Count;Established=@($rows|Where-Object Maturity -eq 'Established').Count;Developing=@($rows|Where-Object Maturity -eq 'Developing').Count;Gaps=@($rows|Where-Object Maturity -eq 'Gap').Count;AverageScore=[math]::Round((($rows.ControlScore|Measure-Object -Average).Average),1);Generated=Get-Date}
$rows|Export-Csv (Join-Path $OutputPath "control_register_$stamp.csv") -NoTypeInformation -Encoding UTF8
$byProduct|Export-Csv (Join-Path $OutputPath "product_summary_$stamp.csv") -NoTypeInformation -Encoding UTF8
$byArea|Export-Csv (Join-Path $OutputPath "control_area_summary_$stamp.csv") -NoTypeInformation -Encoding UTF8
$gaps|Export-Csv (Join-Path $OutputPath "control_gaps_$stamp.csv") -NoTypeInformation -Encoding UTF8
@{Summary=$summary;Controls=$rows;ProductSummary=$byProduct;AreaSummary=$byArea;Gaps=$gaps}|ConvertTo-Json -Depth 8|Set-Content (Join-Path $OutputPath "secure_by_design_research_$stamp.json") -Encoding UTF8
$html="<h1>Secure-by-Design Control Research</h1><p>Generated $(Get-Date)</p><h2>Summary</h2>$(@($summary)|ConvertTo-Html -Fragment)<h2>Product Summary</h2>$($byProduct|ConvertTo-Html -Fragment)<h2>Control Gaps</h2>$($gaps|ConvertTo-Html -Fragment)"
$html|ConvertTo-Html -Title 'Secure-by-Design Control Research'|Set-Content (Join-Path $OutputPath "secure_by_design_research_$stamp.html") -Encoding UTF8
$summary|Format-List
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
