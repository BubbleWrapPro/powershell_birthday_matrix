Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- 1. CONFIGURATION DE LA FENÊTRE ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "SYSTEME TONTON"
$form.BackColor = "Black"
$form.FormBorderStyle = "None"
$form.WindowState = "Maximized"
$form.TopMost = $true
$form.KeyPreview = $true

# Quitter avec ECHAP
$form.Add_KeyDown({
    if ($_.KeyCode -eq "Escape") { $form.Close() }
})

# Dimensions écran (Sécurisées)
$screenWidth = [int][System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
$screenHeight = [int][System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height

# --- 2. FOND (MATRIX) ---
# On met le fond Matrix sur toute la fenêtre
$lblMatrix = New-Object System.Windows.Forms.Label
$lblMatrix.Dock = "Fill" 
$lblMatrix.ForeColor = [System.Drawing.Color]::DarkGreen 
$lblMatrix.BackColor = "Black"
$lblMatrix.Font = New-Object System.Drawing.Font("Consolas", 14)
$lblMatrix.Size = New-Object System.Drawing.Size($($screenWidth*1.5), $($screenHeight*1.5))
$lblMatrix.Text = ""
$form.Controls.Add($lblMatrix)

# --- 3. CONTENEUR CENTRAL (Le Terminal) ---
$terminalPanel = New-Object System.Windows.Forms.Panel

$panelWidth = 1000 
$panelHeight = 750

$terminalPanel.Size = New-Object System.Drawing.Size($panelWidth, $panelHeight)
$terminalPanel.BackColor = "Black" 
$terminalPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle 

# CALCUL DU CENTRE
$terminalPanel.Location = New-Object System.Drawing.Point(
    (($screenWidth - $panelWidth) / 2),
    (($screenHeight - $panelHeight) / 2)
)
$form.Controls.Add($terminalPanel)
$terminalPanel.BringToFront()

# --- 4. TEXTE DU MESSAGE ---
$lblMessage = New-Object System.Windows.Forms.Label
$lblMessage.Dock = "Fill" 
$lblMessage.TextAlign = "MiddleCenter" 
$lblMessage.ForeColor = "Lime" # Vert fluo pour le texte principal
$lblMessage.BackColor = "Black"
$lblMessage.Font = New-Object System.Drawing.Font("Consolas", 28, [System.Drawing.FontStyle]::Bold)
$terminalPanel.Controls.Add($lblMessage)

# --- 5. BOUTON QUITTER ---
$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = "[ DÉCONNEXION ]"
$btnClose.ForeColor = "Black"
$btnClose.BackColor = "Lime"
$btnClose.FlatStyle = "Flat"
$btnClose.Font = New-Object System.Drawing.Font("Consolas", 12, [System.Drawing.FontStyle]::Bold)
$btnClose.Size = New-Object System.Drawing.Size(200, 40)
# Centrage du bouton dans le panneau
$btnClose.Location = New-Object System.Drawing.Point(
    (($panelWidth - 200) / 2),
    ($panelHeight - 60)
)
$btnClose.Visible = $false
$btnClose.Add_Click({ $form.Close() })
$terminalPanel.Controls.Add($btnClose)

# --- 6. LOGIQUE ET VARIABLES ---
$script:storyLines = @(
    "System check...",
    "User: TONTON identified.",
    "Firewall: DISABLED.",
    "",
    "Wake up, Tonton...",
    "The Matrix has you.",
    "",
    "Target Date Detected: TODAY",
    "Executing: JOYEUX_ANNIVERSAIRE.exe",
    "",
    "********************************",
    "*     JOYEUX ANNIVERSAIRE !    *",
    "*              **              *",
    "*    Meilleur Tonton codeur    *",
    "********************************",
    "",
    "[Echap] pour se réveiller...    "
)

$script:currentLineIndex = 0
$script:currentCharIndex = 0
$script:currentText = ""

# --- 7. ANIMATIONS ---

# Timer Texte (Machine à écrire)
$timerTypewriter = New-Object System.Windows.Forms.Timer
$timerTypewriter.Interval = 50
$timerTypewriter.Add_Tick({
    if ($script:currentLineIndex -lt $script:storyLines.Count) {
        $targetLine = $script:storyLines[$script:currentLineIndex]
        
        if ($script:currentCharIndex -lt $targetLine.Length) {
            $script:currentText += $targetLine[$script:currentCharIndex]
            $lblMessage.Text = $script:currentText + "█" 
            $script:currentCharIndex++
        } else {
            $script:currentText += "`n"
            $script:currentLineIndex++
            $script:currentCharIndex = 0
            $timerTypewriter.Interval = 400
        }
    } else {
        $timerTypewriter.Stop()
        $lblMessage.Text = $script:currentText
        $btnClose.Visible = $true
        
        # Mélodie de fin
        [console]::Beep(523, 200); [console]::Beep(523, 200); [console]::Beep(587, 400); 
        [console]::Beep(523, 400); [console]::Beep(698, 400); [console]::Beep(659, 800);
    }
    
    if ($timerTypewriter.Interval -eq 400 -and $script:currentCharIndex -gt 0) {
        $timerTypewriter.Interval = 50 
    }
})

# Timer Fond (Pluie de code)
$timerMatrix = New-Object System.Windows.Forms.Timer
$timerMatrix.Interval = 100
$rng = New-Object Random
$cols = [Math]::Floor($lblMatrix.Width)
$rows = 80 

$timerMatrix.Add_Tick({
    $sb = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $rows; $i++) {
        $line = ""
        # Optimisation : Génération par blocs
        if ($rng.Next(0,10) -gt 2) { 
             for ($j = 0; $j -lt $cols; $j++) {
                if ($rng.Next(0, 10) -gt 8) { $line += $rng.Next(0, 2) } else { $line += " " }
            }
        }
        [void]$sb.AppendLine($line)
    }
    $lblMatrix.Text = $sb.ToString()
})

# --- 8. LANCEMENT ---
$form.Add_Shown({
    $timerMatrix.Start()
    $timerTypewriter.Start()
})

[void]$form.ShowDialog()