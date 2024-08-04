# Check if the correct number of arguments is provided
if ($args.Count -ne 2) {
    Write-Host "Usage: ./script.ps1 <username> <password>"
    exit 1
}

# Assign command-line arguments to variables
$username = $args[0]
$password = $args[1]

# Define the URI and headers
$uri = "http://192.168.1.34:33420/authenticate"
$headers = @{ "Content-Type" = "application/json" }

# Create the body with the provided username and password
$body = @{
    name = $username
    password = $password
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
