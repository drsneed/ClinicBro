# Check if the correct number of arguments is provided
if ($args.Count -ne 3) {
    Write-Host "Usage: ./script.ps1 <org_id> <username> <password>"
    exit 1
}

# Assign command-line arguments to variables
$org_id = $args[0]
$username = $args[1]
$password = $args[2]

# Define the base URI
$baseUri = "http://192.168.1.34:33420"

# Define the headers
$headers = @{ "Content-Type" = "application/json" }

# Create the body with the provided username and password
$body = @{
    org_id = $org_id
    name = $username
    password = $password
} | ConvertTo-Json

# Make the POST request for authentication and capture the response
try {
    $authResponse = Invoke-RestMethod -Uri "$baseUri/authenticate" -Method Post -Headers $headers -Body $body
    Write-Host "Authentication successful"

    # Extract the token from the authentication response
    $token = $authResponse.token

    # Set up the headers for the recent patients request
    $recentPatientsHeaders = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $token"
    }

    # Make the GET request for recent patients
    $recentPatientsResponse = Invoke-RestMethod -Uri "$baseUri/recent-patients" -Method Get -Headers $recentPatientsHeaders

    # Convert the recent patients response to JSON string
    $recentPatientsJson = $recentPatientsResponse | ConvertTo-Json -Depth 5

    # Output the recent patients response to the console
    Write-Host "Recent Patients Response:"
    Write-Host $recentPatientsJson

    # Optionally, output the recent patients response to a file
    $recentPatientsJson | Out-File -FilePath "recent_patients_response.json"
}
catch {
    Write-Host "An error occurred:"
    Write-Host $_.Exception.Message
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd()
        Write-Host $responseBody
    }
}
