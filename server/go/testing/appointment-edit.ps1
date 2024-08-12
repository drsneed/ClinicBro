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

    # Set up the headers for the appointment edit request
    $appointmentEditHeaders = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $token"
    }

    # Define the URI for the edit appointment data endpoint
    $editAppointmentUri = "$baseUri/edit-appointment-data?appointment_id=$appointment_id"

    # Make the GET request for the appointment edit data
    $editAppointmentResponse = Invoke-RestMethod -Uri $editAppointmentUri -Method Get -Headers $appointmentEditHeaders

    # Convert the appointment edit data response to JSON string
    $editAppointmentJson = $editAppointmentResponse | ConvertTo-Json -Depth 5

    # Output the appointment edit data response to the console
    Write-Host "Appointment Edit Data Response:"
    Write-Host $editAppointmentJson

    # Optionally, output the appointment edit data response to a file
    $editAppointmentJson | Out-File -FilePath "appointment_edit_response.json"
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
