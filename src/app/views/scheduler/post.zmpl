<div class="container" id="scheduler">
    <month-view id="schedule">
        @zig {
            const appointments = zmpl.getT(.array, "appointments").?;
            for(appointments) |appt| {
                const id = appt.getT(.integer, "id") orelse continue;
                const title = appt.getT(.string, "title") orelse continue;
                const appt_date = appt.getT(.string, "appt_date") orelse continue;
                const appt_from = appt.getT(.string, "appt_from") orelse continue;
                const appt_to = appt.getT(.string, "appt_to") orelse continue;
                <mv-appt slot="{{appt_date}}" appt_id="{{id}}" appt_title="{{title}}"
                    appt_date="{{appt_date}}" appt_from="{{appt_from}}" appt_to="{{appt_to}}"></mv-appt>
            }
        }
    </month-view>
</div>