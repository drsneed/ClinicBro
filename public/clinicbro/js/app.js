document.addEventListener("DOMContentLoaded", function(event) {
    document.querySelectorAll('.cb_date').forEach(function(date_td) {
        var intDate = parseInt(date_td.innerHTML) / 1000;
        var dt = new Date(intDate);
        date_td.innerHTML = dt.toLocaleString();
    });
  });