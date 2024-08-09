-- Step 1: Insert into the appointments table
WITH random_appointments AS (
    SELECT 
        CASE WHEN random() < 0.5 THEN TRUE ELSE FALSE END AS is_event, -- Flipped logic for is_event
        CASE WHEN random() < 0.5 THEN 'Event ' || generate_series ELSE 'Appointment ' || generate_series END AS title,
        (DATE '2024-08-01' + (random() * (DATE '2024-09-30' - DATE '2024-08-01'))::int) AS appt_date,
        (TIME '08:00:00' + (random() * INTERVAL '9 hours'))::time AS appt_from,
        floor(random() * 72 + 1)::int AS patient_id,
        floor(random() * 10 + 6)::int AS provider_id,
        floor(random() * 5 + 1)::int AS appointment_type_id,
        floor(random() * 6 + 1)::int AS appointment_status_id,
        floor(random() * 5 + 1)::int AS location_id,
        floor(random() * 10 + 6)::int AS created_user_id
    FROM generate_series(1, 50)
),
inserted_appointments AS (
    INSERT INTO appointments (
        title,
        appt_date, 
        appt_from, 
        appt_to, 
        notes, 
        patient_id, 
        provider_id, 
        appointment_type_id, 
        appointment_status_id, 
        location_id, 
        date_created, 
        date_updated, 
        created_user_id, 
        updated_user_id,
        is_event
    )
    SELECT 
        CASE WHEN is_event THEN title ELSE NULL END AS title,
        appt_date,
        appt_from,
        (appt_from + INTERVAL '30 minutes')::time AS appt_to,
        CASE WHEN is_event THEN 'Random event notes for ' || title ELSE 'Random appointment notes for ' || title END AS notes,
        CASE WHEN is_event THEN NULL ELSE patient_id END AS patient_id,
        CASE WHEN is_event THEN NULL ELSE provider_id END AS provider_id,
        CASE WHEN is_event THEN NULL ELSE appointment_type_id END AS appointment_type_id,
        CASE WHEN is_event THEN NULL ELSE appointment_status_id END AS appointment_status_id,
        CASE WHEN is_event THEN location_id ELSE location_id END AS location_id, -- Ensure location_id is assigned
        CURRENT_TIMESTAMP AS date_created,
        CURRENT_TIMESTAMP AS date_updated,
        created_user_id,
        created_user_id AS updated_user_id,
        is_event
    FROM random_appointments
    RETURNING id, title, is_event
),
inserted_events AS (
    SELECT id
    FROM inserted_appointments
    WHERE is_event = TRUE
),
unique_event_user_links AS (
    SELECT
        e.id AS appointment_id,
        floor(random() * 10 + 6)::int AS user_id
    FROM inserted_events e
    CROSS JOIN LATERAL generate_series(1, 3) AS participant -- assuming 1 to 3 additional participants per event
    -- Ensure unique user_id per appointment_id
    WHERE NOT EXISTS (
        SELECT 1
        FROM event_user_links eul
        WHERE eul.appointment_id = e.id
        AND eul.user_id = floor(random() * 10 + 6)::int
    )
),
insert_event_user_links AS (
    INSERT INTO event_user_links (appointment_id, user_id)
    SELECT appointment_id, user_id
    FROM unique_event_user_links
    ON CONFLICT (appointment_id, user_id) DO NOTHING -- This will ignore conflicts
)
-- Final select to confirm the insertions
SELECT * FROM inserted_appointments;
