select apt.id, apt.active, apt.name, apt.abbreviation, apt.color,
    to_char(apt.date_created, 'YYYY-MM-DD at HH12:MI AM') as date_created,
    to_char(apt.date_updated, 'YYYY-MM-DD at HH12:MI AM') as date_updated,
    created_bro.name, updated_bro.name from AppointmentType apt
    left join Bro created_bro on apt.created_bro_id=created_bro.id
    left join Bro updated_bro on apt.updated_bro_id=updated_bro.id
where apt.id=$1