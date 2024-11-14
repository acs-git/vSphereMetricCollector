Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Collection Script Input"
$form.Size = New-Object System.Drawing.Size(550,400)
$form.StartPosition = "CenterScreen"

# Create tooltip object
$tooltip = New-Object System.Windows.Forms.ToolTip
# Configure tooltip - make it appear faster and stay longer
$tooltip.InitialDelay = 100
$tooltip.ReshowDelay = 100
$tooltip.AutoPopDelay = 5000
$tooltip.ShowAlways = $true

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(350,320)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = "Save"
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(425,320)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = "Cancel"
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label1 = New-Object System.Windows.Forms.Label
$label1.Location = New-Object System.Drawing.Point(10,20)
$label1.Size = New-Object System.Drawing.Size(100,20)
$label1.Text = "vCenter Server:"
$form.Controls.Add($label1)

$vcenterTextBox = New-Object System.Windows.Forms.TextBox
$vcenterTextBox.Location = New-Object System.Drawing.Point(120,20)
$vcenterTextBox.Size = New-Object System.Drawing.Size(350,20)
$form.Controls.Add($vcenterTextBox)
$tooltip.SetToolTip($vcenterTextBox, "Enter vCenter IP address or FQDN (e.g., vcenter.domain.com)")

$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(10,50)
$label2.Size = New-Object System.Drawing.Size(100,20)
$label2.Text = "Username:"
$form.Controls.Add($label2)

$usernameTextBox = New-Object System.Windows.Forms.TextBox
$usernameTextBox.Location = New-Object System.Drawing.Point(120,50)
$usernameTextBox.Size = New-Object System.Drawing.Size(350,20)
$form.Controls.Add($usernameTextBox)
$tooltip.SetToolTip($usernameTextBox, "Enter your vCenter username (e.g., administrator@vsphere.local)")

$label3 = New-Object System.Windows.Forms.Label
$label3.Location = New-Object System.Drawing.Point(10,80)
$label3.Size = New-Object System.Drawing.Size(100,20)
$label3.Text = "Password:"
$form.Controls.Add($label3)

$passwordTextBox = New-Object System.Windows.Forms.TextBox
$passwordTextBox.Location = New-Object System.Drawing.Point(120,80)
$passwordTextBox.Size = New-Object System.Drawing.Size(350,20)
$passwordTextBox.PasswordChar = '*'
$form.Controls.Add($passwordTextBox)
$tooltip.SetToolTip($passwordTextBox, "Enter your vCenter password")

$label4 = New-Object System.Windows.Forms.Label
$label4.Location = New-Object System.Drawing.Point(10,110)
$label4.Size = New-Object System.Drawing.Size(100,20)
$label4.Text = "Output Directory:"
$form.Controls.Add($label4)

$outputDirTextBox = New-Object System.Windows.Forms.TextBox
$outputDirTextBox.Location = New-Object System.Drawing.Point(120,110)
$outputDirTextBox.Size = New-Object System.Drawing.Size(270,20)
$outputDirTextBox.ReadOnly = $true
$form.Controls.Add($outputDirTextBox)
$tooltip.SetToolTip($outputDirTextBox, "Select the directory where the script output files will be saved")

$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = New-Object System.Drawing.Point(395,110)
$browseButton.Size = New-Object System.Drawing.Size(75,20)
$browseButton.Text = "Browse..."
$browseButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select Output Directory"
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $outputDirTextBox.Text = $folderBrowser.SelectedPath
    }
})
$form.Controls.Add($browseButton)
$tooltip.SetToolTip($browseButton, "Click to browse and select output directory")

$label5 = New-Object System.Windows.Forms.Label
$label5.Location = New-Object System.Drawing.Point(10,140)
$label5.Size = New-Object System.Drawing.Size(100,20)
$label5.Text = "Metric Level:"
$form.Controls.Add($label5)

$metricLevelComboBox = New-Object System.Windows.Forms.ComboBox
$metricLevelComboBox.Location = New-Object System.Drawing.Point(120,140)
$metricLevelComboBox.Size = New-Object System.Drawing.Size(350,20)
$metricLevelComboBox.Items.AddRange(@("L1", "L2", "L3"))
$form.Controls.Add($metricLevelComboBox)
$tooltip.SetToolTip($metricLevelComboBox, "Select metric collection level, unless instructed otherwise please select L1 (L1: Basic, L2: Medium, L3: Advanced)")

$label6 = New-Object System.Windows.Forms.Label
$label6.Location = New-Object System.Drawing.Point(10,170)
$label6.Size = New-Object System.Drawing.Size(100,20)
$label6.Text = "History Level:"
$form.Controls.Add($label6)

$histLevelComboBox = New-Object System.Windows.Forms.ComboBox
$histLevelComboBox.Location = New-Object System.Drawing.Point(120,170)
$histLevelComboBox.Size = New-Object System.Drawing.Size(350,20)
$histLevelComboBox.Items.AddRange(@("H1", "H2", "H3", "H4"))
$form.Controls.Add($histLevelComboBox)
$tooltip.SetToolTip($histLevelComboBox, "Select amount of data to collect, unless instructed otherwise, please select H4 (H1: 1 day, H2: 1 week, H3: 1 month, H4: 1 year)")

$label7 = New-Object System.Windows.Forms.Label
$label7.Location = New-Object System.Drawing.Point(10,200)
$label7.Size = New-Object System.Drawing.Size(100,30)
$label7.Text = "Max File Size (MB):"
$form.Controls.Add($label7)

$maxFileSizeComboBox = New-Object System.Windows.Forms.ComboBox
$maxFileSizeComboBox.Location = New-Object System.Drawing.Point(120,200)
$maxFileSizeComboBox.Size = New-Object System.Drawing.Size(350,20)
$maxFileSizeComboBox.Items.AddRange(@(10, 20, 30, 40, 50))
$form.Controls.Add($maxFileSizeComboBox)
$tooltip.SetToolTip($maxFileSizeComboBox, "Enter maximum file size in megabytes (MB) - recommended 30")

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    # Create summary message
    $summaryMessage = @"
Please confirm the following settings:

vCenter Server: $($vcenterTextBox.Text)
Username: $($usernameTextBox.Text)
Output Directory: $($outputDirTextBox.Text)
Metric Level: $($metricLevelComboBox.SelectedItem)
History Level: $($histLevelComboBox.SelectedItem)
Max File Size: $($maxFileSizeComboBox.SelectedItem) MB

Do you want to save these settings?
"@

    # Show confirmation dialog
    $confirmResult = [System.Windows.Forms.MessageBox]::Show(
        $summaryMessage,
        "Confirm Settings",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($confirmResult -eq [System.Windows.Forms.DialogResult]::Yes) {
        # Convert password to secure string and encrypt it
        $securePassword = ConvertTo-SecureString $passwordTextBox.Text -AsPlainText -Force
        $encryptedPassword = $securePassword | ConvertFrom-SecureString

        $inputValues = @{
            'vcenter' = $vcenterTextBox.Text
            'username' = $usernameTextBox.Text
            'Password' = $encryptedPassword
            'OutputDIR' = $outputDirTextBox.Text
            'metricLevel' = $metricLevelComboBox.SelectedItem
            'histLevel' = $histLevelComboBox.SelectedItem
            'maxFileSize' = [int]$maxFileSizeComboBox.SelectedItem
        }

        # Save input values to JSON
        $inputValues | ConvertTo-Json | Out-File -FilePath 'collection_input.json'

        # Close the form
        $form.Close()

         # Notify the user it is attempting to collect metrics form choosen vCenter
         write-host "Attempting to collect metrics from chosen vCenter" -ForegroundColor Green
        # Run the collection script and wait for it to complete
        Start-Process powershell -ArgumentList "-File `"$PSScriptRoot\01_Collection.ps1`"" -NoNewWindow -Wait
    } else {
        # Close current form
        $form.Close()
        # Re-run the script
        Start-Process powershell -ArgumentList "-File `"$PSCommandPath`""
        exit
    }
}
