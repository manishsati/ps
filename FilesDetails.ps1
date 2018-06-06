param (
[string]$pathcsv="\\nbnco.local\filestore\SYD-Users\tejaswidheekonda\Desktop\Streams\AD.csv"
)

$Paths = (Import-CSV ) $pathcsv

$files = @()
$errorpaths = @()
ForEach ($line in $Paths) {
Get-ChildItem $line.path -recurse |
ForEach-Object { 
    if($_.PSIsContainer)
    {
        write-host $_.FullName
        try{
        $Item = Get-ChildItem $_.FullName  -Recurse  �ErrorAction SilentlyContinue �ErrorVariable AccessDenied | Measure-object -Property Length -Sum
        $count = (Get-ChildItem $_.FullName | Measure-object).count
        $fileobject = New-Object PSobject
        $fileobject | Add-Member -MemberType NoteProperty -Name "Path" -Value $_.FullName
        $fileobject | Add-Member -MemberType NoteProperty -Name "Count" -Value $Item.Count
        $fileobject | Add-Member -MemberType NoteProperty -Name "Size" -Value $Item.Sum
        $fileobject | Add-Member -MemberType NoteProperty -Name "Type" -Value $_.PSIsContainer
        $files += $fileobject
        }
        Catch [System.UnauthorizedAccessException] {
            Write-Host "[CATCH] You do not have the proper access to this system!"
        }
        Catch {
            Write-Warning "[CATCH] Errors found during attempt"
        }
    }
    else
    {
        $fileobject = New-Object PSobject
        $fileobject | Add-Member -MemberType NoteProperty -Name "Path" -Value $_.FullName
        $fileobject | Add-Member -MemberType NoteProperty -Name "Count" -Value 1
        $fileobject | Add-Member -MemberType NoteProperty -Name "Size" -Value $_.Length
        $fileobject | Add-Member -MemberType NoteProperty -Name "Type" -Value $_.PSIsContainer
        $files += $fileobject
    }
    $AccessDenied | ForEach-Object {
        $ResObj1 = new-object PSobject
        $ResObj1 | add-member -membertype NoteProperty -name "Path" -Value $_.TargetObject
        $errorpaths += $ResObj1 
    }
}
}



$files | Export-csv "\\nbnco.local\filestore\SYD-Users\tejaswidheekonda\Desktop\Streams\ADOutputFile.csv" -notypeinformation 
$errorpaths | Export-csv "\\nbnco.local\filestore\SYD-Users\tejaswidheekonda\Desktop\Streams\ADErrorFile.csv" -notypeinformation 

