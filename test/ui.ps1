
# The script creates a Windows Forms form with a panel to hold the software elements
# and buttons to add new elements and save changes. The script loads the config file,
# adds the existing software elements to the panel, and creates an object for each 
# element to keep track of the section, filepath, and filename. 
# The add button event handler adds a new software element to the panel and creates
# a new object for it. The save button event handler saves the changes to the config file.


# Load the Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create a form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Config Editor"
$form.Width = 500
$form.Height = 400

# Create a panel to hold the software elements
$panel = New-Object System.Windows.Forms.Panel
$panel.Dock = [System.Windows.Forms.DockStyle]::Top
$form.Controls.Add($panel)

# Create a button to add new software element
$addButton = New-Object System.Windows.Forms.Button
$addButton.Text = "Add Software"
$addButton.Dock = [System.Windows.Forms.DockStyle]::Bottom
$form.Controls.Add($addButton)

# Create a button to save the changes
$saveButton = New-Object System.Windows.Forms.Button
$saveButton.Text = "Save Changes"
$saveButton.Dock = [System.Windows.Forms.DockStyle]::Bottom
$form.Controls.Add($saveButton)

# Load the config file
$configFilePath = Join-Path $PSScriptRoot "config.ini"

if (!(Test-Path $configFilePath)) {
    # Create default config file
    $defaultConfig = @'
[software1]
C:\path\to\software1.exe
filename1.exe

[software2]
C:\path\to\software2.exe
filename2.exe
'@
    $defaultConfig | Set-Content $configFilePath
}

$config = @{}
$configIni = Get-Content $configFilePath | Where-Object { $_ -match "^\[.*\].*=.*" } | ForEach-Object {
    $key, $value = $_ -split "="
    $config[$key] = $value.Trim()
}

$softwareElements = $config.GetEnumerator() | Where-Object { $_.Key -match "^\[.*\]\.filepath$" } | ForEach-Object {
    $section = ($_.Key -split "\.")[0] -replace "^\[|\]$"
    [PSCustomObject] @{
        Section = $section
        Filepath = $_.Value
        Filename = ($config["$section.filename"])
    }
}


# Add existing software elements to the panel
$softwareElements = @()
$config.Keys | Where-Object { $_ -match "^\w+\.filepath$" } | ForEach-Object {
    $section = $_ -replace "\.filepath$"
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $section
    $label.Dock = [System.Windows.Forms.DockStyle]::Top
    $panel.Controls.Add($label)

    $filepath = New-Object System.Windows.Forms.TextBox
    $filepath.Text = $config["$section.filepath"]
    $filepath.Dock = [System.Windows.Forms.DockStyle]::Top
    $panel.Controls.Add($filepath)

    $filename = New-Object System.Windows.Forms.TextBox
    $filename.Text = $config["$section.filename"]
    $filename.Dock = [System.Windows.Forms.DockStyle]::Top
    $panel.Controls.Add($filename)

    $removeButton = New-Object System.Windows.Forms.Button
    $removeButton.Text = "Remove"
    $removeButton.Dock = [System.Windows.Forms.DockStyle]::Top
    $removeButton.Tag = $section
    $removeButton.Add_Click({
        $tag = $_.Tag
        $panel.Controls | Where-Object { $_.Tag -eq $tag } | ForEach-Object { $panel.Controls.Remove($_) }
        $softwareElements = $softwareElements | Where-Object { $_.Section -ne $tag }
    })
    $panel.Controls.Add($removeButton)

    $softwareElements += [PSCustomObject]@{
        Section = $section
        Filepath = $filepath
        Filename = $filename
    }
}

# Add event handler for add software button
$addButton.Add_Click({
    $newSoftwareElement = New-Object System.Windows.Forms.GroupBox
    $newSoftwareElement.Size = New-Object System.Drawing.Size(600, 70)
    $newSoftwareElement.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $newSoftwareElement.Location = New-Object System.Drawing.Point(10, $softwareElements.Count * ($softwareElements[0].Size.Height + 10) + $addButton.Height + 20)

    $newSoftwareElement.Section = ""

    $newSoftwareElement.Filepath = New-Object System.Windows.Forms.TextBox
    $newSoftwareElement.Filepath.Size = New-Object System.Drawing.Size(300, 20)
    $newSoftwareElement.Filepath.Location = New-Object System.Drawing.Point(10, 20)
    $newSoftwareElement.Filepath.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $newSoftwareElement.Controls.Add($newSoftwareElement.Filepath)

    $newSoftwareElement.Filename = New-Object System.Windows.Forms.TextBox
    $newSoftwareElement.Filename.Size = New-Object System.Drawing.Size(200, 20)
    $newSoftwareElement.Filename.Location = New-Object System.Drawing.Point($newSoftwareElement.Filepath.Right + 10, 20)
    $newSoftwareElement.Filename.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
    $newSoftwareElement.Controls.Add($newSoftwareElement.Filename)

    $removeButton = New-Object System.Windows.Forms.Button
    $removeButton.Size = New-Object System.Drawing.Size(70, 20)
    $removeButton.Location = New-Object System.Drawing.Point($newSoftwareElement.Filename.Right + 10, 20)
    $removeButton.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
    $removeButton.Text = "Remove"
    $removeButton.Add_Click({
        $newSoftwareElement.Dispose()
    })
    $newSoftwareElement.Controls.Add($removeButton)

    $softwareElements.Add($newSoftwareElement)
    $form.Controls.Add($newSoftwareElement)
    $form.Height += $newSoftwareElement.Height + 10
    $form.CenterToScreen()
})



# Add event handler for save button
$saveButton.Add_Click({
     Write-Host "The value of softwareElements is: $softwareElements"
    Write-Host "Printing contents of `$config before clearing:"
    foreach ($key in $config.Keys) {
        Write-Host "${key}: $($config[$key])" # wrap $key to ${key} so the : isn't recognised as part of the variable
    }
    $config.Clear()
    $softwareElements | ForEach-Object {
        $config[$_.Section + ".filepath"] = $_.Filepath.Text
        $config[$_.Section + ".filename"] = $_.Filename.Text
    }
    Set-Content $configFilePath ($config.GetEnumerator() | ForEach-Object { "[{0}]{1}={2}" -f ($_.Key -split ".")[0],($_.Key -split ".")[1],$_.Value })

    Write-Host "Printing contents of `$config after saving changes:"
    foreach ($key in $config.Keys) {
        Write-Host "${key}: $($config[$key])"
    }
    [System.Windows.Forms.MessageBox]::Show("Changes saved.", "Info")
})


# Show the form

$form.ShowDialog() | Out-Null

