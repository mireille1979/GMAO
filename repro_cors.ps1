$url = "http://127.0.0.1:8081/api/auth/authenticate"
$headers = @{ "Content-Type" = "application/json" }
$body = '{"email": "manager1@gmail.com", "password": "password"}'

function Test-Cors {
    param($origin)
    Write-Host "Testing Origin: $origin"
    $currentHeaders = $headers.Clone()
    if ($origin) {
        $currentHeaders['Origin'] = $origin
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $currentHeaders -Body $body -ErrorAction Stop
        Write-Host "Success: 200 OK"
    } catch {
        Write-Host "Error: $($_.Exception.Message)"
        if ($_.Exception.Response) {
             Write-Host "Status: $($_.Exception.Response.StatusCode)"
             # We can't see server logs here, but user will see them in their terminal
        }
    }
    Write-Host "----------------"
}

Test-Cors $null
