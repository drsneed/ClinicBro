# Check if the correct number of arguments is provided
if ($args.Count -ne 3) {
    Write-Host "Usage: ./script.ps1 <current_password> <new_password> <token>"
    exit 1
}

# Assign command-line arguments to variables
$password = $args[0]
$newPassword = $args[1]
$token = $args[2]

# Define the URI and headers
$uri = "http://192.168.1.34:33420/change-password"
$headers = @{ 
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $($token)"
}

# Create the body with the provided username and password
$body = @{
    current_password = $password
    new_password = $newPassword
} | ConvertTo-Json

# Make the POST request and capture the response
$response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body

# Convert the response to JSON string to see the full content
$responseJson = $response | ConvertTo-Json -Depth 5

# Output the full JSON response to the console
Write-Host "Response:"
Write-Host $responseJson

# Optionally, you can output the response to a file for easier inspection
$responseJson | Out-File -FilePath "response.json"
