<# Script to gat the files COUNT and SIZE #>
param 
(
    [Parameter(Mandatory=$true)]
    [string]$pathcsv
)
$Paths = Import-CSV -LiteralPath $pathcsv
$resultsarray = @()
$errorArray = @()
ForEach ($line in $Paths)
{
    $ResObj = new-object PSobject
    Write-Host $line.Path
    try
    {
        $Item = Get-ChildItem $line.Path –Force –Recurse –ErrorAction SilentlyContinue –ErrorVariable AccessDenied | Measure-object -property Length -sum 
        $cal = [math]::Round(($Item.sum)/1mb, 3)
        $count = $Item.count
        $ResObj | add-member -membertype NoteProperty -name "Path" -Value $line.Path
        $ResObj | add-member -membertype NoteProperty -name "No.of Files" -Value $count
        $ResObj | add-member -membertype NoteProperty -name "FolderSize(KB)" -Value $cal
        $resultsarray += $ResObj 
        Write-Host $Item.Count
        $AccessDenied | ForEach-Object {
        $ResObj1 = new-object PSobject
        $ResObj1 | add-member -membertype NoteProperty -name "Path" -Value $_.TargetObject
        $errorArray += $ResObj1  
    }
} 
Catch [System.UnauthorizedAccessException]
{
    Write-Host "[CATCH] You do not have the proper access to this system!"
    BREAK
}
Catch {
    Write-Warning "[CATCH] Errors found during attempt"
    BREAK
}
}
$resultsarray | Export-csv "C:\Test\OutputFile.csv" -notypeinformation 
$errorArray | Export-csv "C:\Test\ErrorFile.csv" -notypeinformation 
