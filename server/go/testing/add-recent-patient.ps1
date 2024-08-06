# Check if the correct number of arguments is provided
if ($args.Count -ne 4) {
    Write-Host "Usage: ./script.ps1 <org_id> <username> <password> <patient_id>"
    exit 1
}

# Assign command-line arguments to variables
$org_id = $args[0]
$username = $args[1]
$password = $args[2]
$patient_id = $args[3]

# Define the URI and headers for authentication
$authUri = "http://192.168.1.34:33420/authenticate"
$authHeaders = @{ "Content-Type" = "application/json" }

# Create the body with the provided username and password
$authBody = @{
    org_id = $org_id
    name = $username
    password = $password
} | ConvertTo-Json

# Make the POST request for authentication and capture the response
$authResponse = Invoke-RestMethod -Uri $authUri -Method Post -Headers $authHeaders -Body $authBody

# Convert the authentication response to JSON string to see the full content
$authResponseJson = $authResponse | ConvertTo-Json -Depth 5

# Output the full JSON response to the console
Write-Host "Authentication Response:"
Write-Host $authResponseJson

# Extract the JWT token from the authentication response
$jwtToken = $authResponse.token

# Check if the token was successfully retrieved
if (-not $jwtToken) {
    Write-Host "Error: Authentication failed. No token received."
    exit 1
}

# Define the URI and headers for adding a recent patient
$recentPatientUri = "http://192.168.1.34:33420/recent-patients/$patient_id"
$recentPatientHeaders = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $jwtToken"
}

# Make the POST request to add the recent patient
$recentPatientResponse = Invoke-RestMethod -Uri $recentPatientUri -Method Post -Headers $recentPatientHeaders

# Convert the response to JSON string to see the full content
$recentPatientResponseJson = $recentPatientResponse | ConvertTo-Json -Depth 5

# Output the full JSON response to the console
Write-Host "Add Recent Patient Response:"
Write-Host $recentPatientResponseJson

# Optionally, you can output the response to a file for easier inspection
$recentPatientResponseJson | Out-File -FilePath "recent_patient_response.json"
