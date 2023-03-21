Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# create a form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Create Symlinks"
$form.Size = New-Object System.Drawing.Size(400, 150)
$form.StartPosition = "CenterScreen"

# create a label for the configuration file path
$csvLabel = New-Object System.Windows.Forms.Label
$csvLabel.Text = "Configuration file path:"
$csvLabel.Location = New-Object System.Drawing.Point(10, 10)
$csvLabel.AutoSize = $true
$form.Controls.Add($csvLabel)

# create a text box for the configuration file path
$csvBox = New-Object System.Windows.Forms.TextBox
$csvBox.Location = New-Object System.Drawing.Point(10, 30)
$csvBox.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($csvBox)

# create a button to launch Notepad
$editButton = New-Object System.Windows.Forms.Button
$editButton.Text = "Edit Configuration File"
$editButton.Location = New-Object System.Drawing.Point(10, 60)
$editButton.Size = New-Object System.Drawing.Size(150, 30)
$editButton.Add_Click({
    notepad.exe $csvBox.Text
})
$form.Controls.Add($editButton)

# create a button to create the symlinks
$createButton = New-Object System.Windows.Forms.Button
$createButton.Text = "Create Symlinks"
$createButton.Location = New-Object System.Drawing.Point(170, 60)
$createButton.Size = New-Object System.Drawing.Size(150, 30)
$createButton.Add_Click({
    $csvPath = $csvBox.Text
    if (-not (Test-Path $csvPath)) {
        [System.Windows.Forms.MessageBox