var calendar: MonthCalendar;

Date.prototype.addDays = function(days) {
    var date = new Date(this.valueOf());
    date.setDate(date.getDate() + days);
    return date;
}

const months = ["January","February","March","April","May","June",
    "July","August","September","October","November","December"];

class MonthCalendar {
    date: Date;
   
    constructor(date: Date) {
      this.date = date;
      this.refresh();
    }

    refresh() {
        // set header
        const monthIndex = this.date.getMonth();
        const year = this.date.getFullYear();
        document.getElementById("month_title").innerText = months[monthIndex] + " " + year;
        
        // populate dates on calendar grid
        let firstOfDaMonth = new Date(year, monthIndex, 1);
        let d = firstOfDaMonth.getDay();
        for (let i = 0; i < 42; i++) {
            const thisDaysDate = firstOfDaMonth.addDays(i-d);
            let daySlot = document.getElementById('d'+i);
            daySlot.classList.remove("this-month");
            if(thisDaysDate.getMonth() == this.date.getMonth()) {
                daySlot.classList.add("this-month");
            }
            daySlot.querySelector('.num').innerText = thisDaysDate.getDate();
        }

    }
    
   
    next() {
      this.date.setMonth(this.date.getMonth() + 1, this.date.getDay());
      this.refresh();
    }
    prev() {
        this.date.setMonth(this.date.getMonth() - 1, this.date.getDay());
        this.refresh();
    }
}


document.addEventListener("DOMContentLoaded", function(event) {
    console.log("DOM is ready. Let's do this!");
    calendar = new MonthCalendar(new Date());
});