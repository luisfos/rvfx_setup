
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
# $configFilePath = "C:\path\to\configfile.ini"
$configFilePath = Join-Path $PSScriptRoot "config.ini"
$config = New-Object System.Collections.Generic.Dictionary[string,string]
Get-Content $configFilePath | ForEach-Object {
    if ($_ -match "^\[(.*)\]$") {
        $section = $matches[1]
    }
    elseif ($_ -match "^(.*)=(.*)$") {
        $config["$section.$($matches[1])"] = $matches[2]
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

# Add event handler for add button
$addButton.Add_Click({
    $section = Read-Host "Enter software name"
    if ($section -eq "") { return }
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $section
    $label.Dock = [System.Windows.Forms.DockStyle]::Top
    $panel.Controls.Add($label)

    $filepath = New-Object System.Windows.Forms.TextBox
    $filepath.Dock = [System.Windows.Forms.DockStyle]::Top
    $panel.Controls.Add($filepath)

    # $filename
    $filename = New-Object System.Windows.Forms.TextBox
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
})

# Add event handler for save button
$saveButton.Add_Click({
    $config.Clear()
    $softwareElements | ForEach-Object {
        $config[$_.Section + ".filepath"] = $_.Filepath.Text
        $config[$_.Section + ".filename"] = $_.Filename.Text
    }
    Set-Content $configFilePath ($config.GetEnumerator() | ForEach-Object { "[{0}]{1}={2}" -f ($_.Key -split ".")[0],($_.Key -split ".")[1],$_.Value })
    [System.Windows.Forms.MessageBox]::Show("Changes saved.", "Info")
})


# Show the form

$form.ShowDialog() | Out-Null
