export function markScoresTableHeader(group_level) {
  const app = document.getElementById(`${group_level}-mark`)
  const dataHeader = app.getAttribute('data-header')
  const parsedDataHeader = JSON.parse(dataHeader)

  const parsedDataHeaderWithSortType = parsedDataHeader.map(column => {
    return {
      ...column,
      sortType: (rowA, rowB, columnId) => {
        const a = parseFloat(rowA.values[columnId]);
        const b = parseFloat(rowB.values[columnId]);

        if (isNaN(a) || isNaN(b)) {
          return String(rowA.values[columnId]).localeCompare(String(rowB.values[columnId]));
        }

        return a - b;
      }
    };
  });

  return parsedDataHeaderWithSortType;
}

export function calibrationTableHeader() {
  const app = document.getElementById(`calibration-table`)
  const dataHeader = app.getAttribute('data-header')
  const parsedDataHeader = JSON.parse(dataHeader)

  return parsedDataHeader;
}

let parsedDataReview = null;

export function reviewLabels() {
  if (parsedDataReview) {
    return parsedDataReview;
  }
  const app = document.getElementById('i18n-root')
  const dataReview = app.getAttribute('data-review')
  parsedDataReview = JSON.parse(dataReview)

  return parsedDataReview;
}

let parsedDataCalibration = null;

export function calibrationLabels() {
  if (parsedDataCalibration) {
    return parsedDataCalibration;
  }
  const app = document.getElementById('i18n-root')
  const dataCalibration = app.getAttribute('data-calibration')
  parsedDataCalibration = JSON.parse(dataCalibration)

  return parsedDataCalibration;
}

let parsedDataCalibrationTable = null;

export function calibrationTableLabels() {
  if (parsedDataCalibrationTable) {
    return parsedDataCalibrationTable;
  }
  const app = document.getElementById('i18n-root')
  const dataCalibration = app.getAttribute('data-calibration-table')
  parsedDataCalibrationTable = JSON.parse(dataCalibration)

  return parsedDataCalibrationTable;
}

export function svgCilPrint() {
  const app = document.getElementById('i18n-root');
  return app.getAttribute('data-cil-print');
}

export function svgInfo() {
  const app = document.getElementById('i18n-root');
  return app.getAttribute('data-info');
}

export function svgCommentSquare() {
  const app = document.getElementById('i18n-root');
  return app.getAttribute('data-comment-square');
}

export function svgArrowFromTop() {
  const app = document.getElementById('i18n-root');
  return app.getAttribute('data-arrow-from-top');
}

export function svgArrowFromBottom() {
  const app = document.getElementById('i18n-root');
  return app.getAttribute('data-arrow-from-bottom');
}

export function calibrationSessionId() {
  const app = document.getElementById('i18n-root');
  return app.getAttribute('data-calibration-session-id');
}

export function userId() {
  const app = document.getElementById('i18n-root');
  return app.getAttribute('data-user-id');
}

export function groupLevel() {
  const app = document.getElementById('i18n-root');
  return app.getAttribute('data-group-level');
}

export function prepareTableSubmitData(data) {
  const skip_to_submit_accessor = ["chinese_name", "title", "department", "pre_total_evaluation_score", "total_evaluation_score", "form_status_name"];
  return data.map(function (obj) {
    let newObj = {};
    for (let key in obj) {
      if (!skip_to_submit_accessor.includes(key) && !key.endsWith('_fixed') && !key.endsWith('_id')) {
        newObj[key] = obj[key];
      }
    }
    return newObj;
  });
}
