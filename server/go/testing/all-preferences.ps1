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

# Define the headers for authentication with the hardcoded API key
$authHeaders = @{ 
    "Content-Type" = "application/json"
    "X-Client-Api-Key" = "turkey"
}

# Create the body with the provided username and password
$authBody = @{
    org_id = $org_id
    name = $username
    password = $password
} | ConvertTo-Json

# Make the POST request for authentication and capture the response
try {
    $authResponse = Invoke-RestMethod -Uri "$baseUri/authenticate-user" -Method Post -Headers $authHeaders -Body $authBody
    Write-Host "Authentication successful"

    # Extract the token from the authentication response
    $token = $authResponse.token

    # Set up the headers for the get all preferences request
    $preferencesHeaders = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $token"
        "X-Client-Api-Key" = "turkey"
    }

    # Make the GET request for all preferences
    $preferencesResponse = Invoke-RestMethod -Uri "$baseUri/user-preferences" -Method Get -Headers $preferencesHeaders

    # Convert the preferences response to JSON string
    $preferencesJson = $preferencesResponse | ConvertTo-Json -Depth 5

    # Output the preferences response to the console
    Write-Host "Preferences Response:"
    Write-Host $preferencesJson

    # Optionally, output the preferences response to a file
    $preferencesJson | Out-File -FilePath "all_preferences_response.json"
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
