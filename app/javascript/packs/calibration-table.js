import * as React from "react"
import { createRoot } from 'react-dom/client';
import CalibrationTable from '../react/CalibrationTable';

function mountWhenReady(callback) {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', callback);
  } else {
    callback();
  }
}

const calibration_table_node = document.getElementById('calibration-table');
if (calibration_table_node) {
  const calibration_table = createRoot(calibration_table_node);
  mountWhenReady(() => {
    calibration_table.render(<CalibrationTable />);
  });
}
