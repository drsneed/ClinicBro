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

# Make the POST request
Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body
