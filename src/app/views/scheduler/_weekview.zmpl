@args current_date: *ZmplValue, appointments: *ZmplValue

<week-view id="schedule" current_date="{{current_date}}">
    @zig {
        for(appointments.array.array.items) |appt| {
            const appt_id = appt.getT(.integer, "appt_id") orelse continue;
            const title = appt.getT(.string, "title") orelse continue;
            const status = appt.getT(.string, "status") orelse continue;
            const client = appt.getT(.string, "client") orelse continue;
            const provider = appt.getT(.string, "provider") orelse continue;
            const location = appt.getT(.string, "location") orelse continue;
            const color = appt.getT(.string, "color") orelse continue;
            const appt_date = appt.getT(.string, "appt_date") orelse continue;
            const appt_from = appt.getT(.string, "appt_from") orelse continue;
            const appt_to = appt.getT(.string, "appt_to") orelse continue;
            <mv-appt slot="{{appt_date}}" appt_id="{{appt_id}}" appt_title="{{title}}"
                appt_date="{{appt_date}}" appt_from="{{appt_from}}" appt_to="{{appt_to}}" color="{{color}}"
                status="{{status}}" client="{{client}}" provider="{{provider}}" location="{{location}}"
                hx-get="/scheduler/{{appt_id}}" hx-target="global #cb-window" 
                hx-swap="outerHTML" hx-trigger="dblclick target:mv-appt"></mv-appt>
        }
    }
</week-view>