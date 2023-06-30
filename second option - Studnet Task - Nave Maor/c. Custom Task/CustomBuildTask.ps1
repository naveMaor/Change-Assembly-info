

# Get the input values
$AssemblyDescription = Get-VstsInput -Name 'AssemblyDescription'
$AssemblyCompany = Get-VstsInput -Name 'AssemblyCompany'
$AssemblyProduct = Get-VstsInput -Name 'AssemblyProduct'


# Set the path to the AssemblyInfo.cs file
$assemblyInfoFile = "$ENV:BUILD_SOURCESDIRECTORY\naveProjectNew\naveProjectNew\AssemblyInfo.cs"

git config --global user.email "rsd.nave@gmail.com"
git config --global user.name "DESKTOP-I58DGNN"

# Change the directory to local repository
Set-Location -Path "$ENV:SYSTEM_DEFAULTWORKINGDIRECTORY"


Write-Host "Create a new branch"
git branch DevOps/test_$ENV:BUILD_BUILDNUMBER --quiet
git checkout DevOps/test_$ENV:BUILD_BUILDNUMBER --quiet


#set AssemblyVersion and AssemblyFileVersion from AssemblyInfo.cs
$AssemblyVersion = Get-Content $assemblyInfoFile | Select-String -Pattern 'AssemblyVersion' | ForEach-Object { $_.ToString().Split('"')[1] }
$AssemblyVersionArray = $AssemblyVersion.Split('.')
$AssemblyVersionArray[3] = [int]$AssemblyVersionArray[3] + 1
$NewAssemblyVersion = $AssemblyVersionArray[0] + '.' + $AssemblyVersionArray[1] + '.' + $AssemblyVersionArray[2] + '.' + $AssemblyVersionArray[3]

$AssemblyFileVersion = Get-Content $assemblyInfoFile | Select-String -Pattern 'AssemblyFileVersion' | ForEach-Object { $_.ToString().Split('"')[1] }
$AssemblyFileVersionArray = $AssemblyFileVersion.Split('.')
$AssemblyFileVersionArray[3] = [int]$AssemblyFileVersionArray[3] + 1
$NewAssemblyFileVersion = $AssemblyFileVersionArray[0] + '.' + $AssemblyFileVersionArray[1] + '.' + $AssemblyFileVersionArray[2] + '.' + $AssemblyFileVersionArray[3]




 # Read the content of the AssemblyInfo.cs file
 $assemblyInfoContent = Get-Content -Path $assemblyInfoFile -Raw

 # Update the AssemblyDescription attribute
 $assemblyInfoContent = $assemblyInfoContent -replace '(?<=\[assembly: AssemblyDescription\(").*?(?="\)\])', $AssemblyDescription

 # Update the AssemblyCompany attribute
 $assemblyInfoContent = $assemblyInfoContent -replace '(?<=\[assembly: AssemblyCompany\(").*?(?="\)\])', $AssemblyCompany

 # Update the AssemblyProduct attribute
 $assemblyInfoContent = $assemblyInfoContent -replace '(?<=\[assembly: AssemblyProduct\(").*?(?="\)\])', $AssemblyProduct

# Update the AssemblyVersion attribute
 $assemblyInfoContent = $assemblyInfoContent -replace '(?<=\[assembly: AssemblyVersion\(").*?(?="\)\])', $NewAssemblyVersion

# Update the AssemblyFileVersion attribute
 $assemblyInfoContent = $assemblyInfoContent -replace '(?<=\[assembly: AssemblyFileVersion\(").*?(?="\)\])', $NewAssemblyFileVersion

 # Write the updated content back to the AssemblyInfo.cs file
 $assemblyInfoContent | Set-Content -Path $assemblyInfoFile

 Write-Host "assemblyInfoContent: $assemblyInfoContent"


# Stage the changes
git add .
git add $ProjectFile

# Commit the changes with a version number in the commit message
git commit -m "[skip ci] Pipeline Modification: AssemblyVersion = $NewVersion" --quiet

# Push the changes to the server repository
git push origin DevOps/test_$ENV:SYSTEM_DEFAULTWORKINGDIRECTORY --quiet
