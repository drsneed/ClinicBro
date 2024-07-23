insert into AppointmentType(active,name,abbreviation,color,date_created,date_updated,created_bro_id,updated_bro_id)
values(true, $1, $2, $3, NOW(), NOW(), $4, $4) returning id