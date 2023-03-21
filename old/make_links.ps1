$csvPath = "C:\path\to\config.csv"

# read the configuration file
$config = Import-Csv $csvPath

# create symlinks for each row
$config | ForEach-Object {
    $source = $.Source
    $link = $.Link
    # check if the source path exists
    if (-not (Test-Path $source)) {
        Write-Error "Source path '$source' does not exist"
        continue
    }
    # check if the link path already exists
    if (Test-Path $link) {
        Write-Error "Link path '$link' already exists"
        continue
    }
    # create the symlink
    try {
        New-Item -ItemType SymbolicLink -Path $link -Target $source -Force
        Write-Output "Created symlink from '$source' to '$link'"
    } catch {
        Write-Error "Failed to create symlink from '$source' to '$link': $_"
    }
}