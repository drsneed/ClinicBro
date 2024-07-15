<div class="container" id="scheduler">
    @zig {
        const mode = zmpl.getT(.string, "mode").?;
        if(std.mem.eql(u8, mode, "month")) {
            @partial scheduler/monthview(current_date: .current_date, appointments: .appointments)
        }
        else if(std.mem.eql(u8, mode, "day")) {
            @partial scheduler/dayview(current_date: .current_date, appointments: .appointments)
        }
        else if(std.mem.eql(u8, mode, "week")) {
            @partial scheduler/weekview(current_date: .current_date, appointments: .appointments)
        }
    }
</div>