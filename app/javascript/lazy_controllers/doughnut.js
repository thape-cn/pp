import { Controller } from "@hotwired/stimulus"

Stimulus.register("doughnut", class extends Controller {
  static targets = [ "cardChart" ];
  static values = {
    labels: Array,
    data: Array
  }

  connect() {
    this.cardChart = new Chart(this.cardChartTarget, {
      type: 'doughnut',
      data: {
        labels: this.labelsValue,
        datasets: [
          {
            backgroundColor: ['#FF6384', '#4BC0C0', '#FFCE56', '#E7E9ED', '#36A2EB', '#DDDDDD'],
            hoverBackgroundColor: ['#FF6384', '#4BC0C0', '#FFCE56', '#E7E9ED', '#36A2EB', '#DDDDDD'],
            data: this.dataValue
          }
        ]
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            display: false
          }
        },
        onClick: (evt, item) => {
          const chart = this.cardChart;
          const activePoints = chart.getElementsAtEventForMode(evt, 'nearest', { intersect: true }, true);
          if (activePoints.length > 0) {
            const firstPoint = activePoints[0];
            const label = chart.data.labels[firstPoint.index];
            window.location.href = window.location.href.split('?')[0] + '?label=' + encodeURIComponent(label);
          }
        }        
      }
    });
  }
});
