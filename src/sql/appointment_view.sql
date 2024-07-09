CREATE VIEW AppointmentView as 
  select a.id as appt_id,
  case when appt_type is not null then appt_type.name else a.title end as title,
  case when appt_status is null then 'New' else appt_status.name end as status,
  case when cl is null then '' else concat(cl.last_name, ', ', cl.first_name) end as client,
  case when provider is null then '' else provider.name end as provider,
  case when loc is null then '' else loc.name end as location,
  case when appt_type is null then '' else appt_type.color end as color,
  to_char(a.appt_date, 'YYYY-MM-DD') as appt_date, 
  to_char(a.appt_from, 'HH24:MI') as appt_from, 
  to_char(a.appt_to, 'HH24:MI') as appt_to
  from appointment a 
  left join client cl on cl.id=a.client_id
  left join bro provider on provider.id=a.bro_id
  left join location loc on loc.id=a.location_id
  left join appointmenttype appt_type on appt_type.id=a.type_id
  left join appointmentstatus appt_status on appt_status.id=a.status_id
  order by a.appt_date, a.appt_from;