function Show-InputForm()
{
    #create input form
    $inputForm               = New-Object System.Windows.Forms.Form 
    $inputForm.Text          = $args[0]
    $inputForm.Size          = New-Object System.Drawing.Size(330, 100) 
    $inputForm.StartPosition = "CenterScreen"
    [System.Windows.Forms.Application]::EnableVisualStyles()

    #handle button click events
    $inputForm.KeyPreview = $true
    $inputForm.Add_KeyDown(
    {
        if ($_.KeyCode -eq "Enter")  
        {
            $inputForm.Close() 
        } 
    })
    $inputForm.Add_KeyDown(
    {
        if ($_.KeyCode -eq "Escape") 
        {
            $inputForm.Close() 
        } 
    
    })

    #create OK button
    $okButton          = New-Object System.Windows.Forms.Button
    $okButton.Size     = New-Object System.Drawing.Size(75, 23)
    $okButton.Text     = "OK" 
    $okButton.Add_Click(
    {
        $inputForm.DialogResult = [System.Windows.Forms.DialogResult]::OK
    })
    $inputForm.Controls.Add($okButton)
    $inputForm.AcceptButton = $okButton

    #create Cancel button
    $cancelButton          = New-Object System.Windows.Forms.Button 
    $cancelButton.Size     = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text     = "Cancel"
    $inputForm.Controls.Add($cancelButton)
    $inputForm.CancelButton = $cancelButton

    [System.Collections.Generic.List[System.Windows.Forms.TextBox]] $txtBoxes = New-Object System.Collections.Generic.List[System.Windows.Forms.TextBox]
    $y = -15;
    for($i=1;$i -lt $args.Count;$i++)
    {
        $y+=30
        $inputForm.Height += 30

        #create label
        $objLabel          = New-Object System.Windows.Forms.Label
        $objLabel.Location = New-Object System.Drawing.Size(10,  $y)
        $objLabel.Size     = New-Object System.Drawing.Size(280, 20)
        $objLabel.Text     = $args[$i] +":"
        $inputForm.Controls.Add($objLabel)
        $y+=20
        $inputForm.Height+=20
        
        #create TextBox
        $objTextBox          = New-Object System.Windows.Forms.TextBox 
        $objTextBox.Location = New-Object System.Drawing.Size(10,  $y)
        $objTextBox.Size     = New-Object System.Drawing.Size(290, 20) 
        $inputForm.Controls.Add($objTextBox)

        $txtBoxes.Add($objTextBox)

        $cancelButton.Location = New-Object System.Drawing.Size(165, (35+$y))
        $okButton.Location     = New-Object System.Drawing.Size(90, (35+$y))

        if ($args[$i].Contains("*"))
        {
            $objLabel.Text = ($objLabel.Text -replace '\*','')
            $objTextBox.UseSystemPasswordChar = $true 
        }
    }

    $inputForm.Topmost = $true 
    $inputForm.MinimizeBox = $false
    $inputForm.MaximizeBox = $false
    
    $inputForm.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
    $inputForm.SizeGripStyle = [System.Windows.Forms.SizeGripStyle]::Hide
    $inputForm.Add_Shown({$inputForm.Activate(); $txtBoxes[0].Focus()})
    if ($inputForm.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK)
    {
        exit
    }

    return ($txtBoxes | Select-Object {$_.Text} -ExpandProperty Text)
}

Add-Type -AssemblyName "system.windows.forms"

#variables for our SQL Server login form
$login    = Show-InputForm "SQL Server database login" "SQL Server" "Username" "Password*" "Database"
$server   = $login[0]
$user     = $login[1]
$password = $login[2]
$database = $login[3] 

$ConnectionString = "Server = $server; Database = $database; Integrated Security = False; User ID = $user; Password = $password;"
Write-Output $ConnectionString
