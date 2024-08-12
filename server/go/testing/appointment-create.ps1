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

# Define the base URI
$baseUri = "http://192.168.1.34:33420"

# Define the headers for authentication
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

    # Set up the headers for the create appointment data request
    $createAppointmentHeaders = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $token"
    }

    # Define the URI for the create appointment data endpoint
    $createAppointmentUri = "$baseUri/create-appointment-data?patient_id=$patient_id"

    # Make the GET request for the create appointment data
    $createAppointmentResponse = Invoke-RestMethod -Uri $createAppointmentUri -Method Get -Headers $createAppointmentHeaders

    # Convert the create appointment data response to JSON string
    $createAppointmentJson = $createAppointmentResponse | ConvertTo-Json -Depth 5

    # Output the create appointment data response to the console
    Write-Host "Create Appointment Data Response:"
    Write-Host $createAppointmentJson

    # Optionally, output the create appointment data response to a file
    $createAppointmentJson | Out-File -FilePath "create_appointment_response.json"
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
