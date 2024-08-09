# Check if the correct number of arguments is provided
if ($args.Count -ne 4) {
    Write-Host "Usage: ./script.ps1 <org_id> <username> <password> <appointment_id>"
    exit 1
}

# Assign command-line arguments to variables
$org_id = $args[0]
$username = $args[1]
$password = $args[2]
$appointment_id = $args[3]

# Define the base URI
$baseUri = "http://192.168.1.34:33420"

# Define the headers for authentication
$authHeaders = @{ "Content-Type" = "application/json" }

# Create the body with the provided username and password
$authBody = @{
    org_id = $org_id
    name = $username
    password = $password
} | ConvertTo-Json

# Make the POST request for authentication and capture the response
try {
    $authResponse = Invoke-RestMethod -Uri "$baseUri/authenticate" -Method Post -Headers $authHeaders -Body $authBody
    Write-Host "Authentication successful"

    # Extract the token from the authentication response
    $token = $authResponse.token

    # Set up the headers for the event participants request
    $eventParticipantsHeaders = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $token"
    }

    # Define the URI for the event-participants endpoint
    $participantsUri = "$baseUri/event-participants?appointment_id=$appointment_id"

    # Make the GET request for event participants
    $participantsResponse = Invoke-RestMethod -Uri $participantsUri -Method Get -Headers $eventParticipantsHeaders

    # Convert the event participants response to JSON string
    $participantsJson = $participantsResponse | ConvertTo-Json -Depth 5

    # Output the event participants response to the console
    Write-Host "Event Participants Response:"
    Write-Host $participantsJson

    # Optionally, output the event participants response to a file
    $participantsJson | Out-File -FilePath "event_participants_response.json"
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
