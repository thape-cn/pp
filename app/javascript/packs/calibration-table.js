import * as React from "react"
import { createRoot } from 'react-dom/client';
import CalibrationTable from '../react/CalibrationTable';


const calibration_table = createRoot(document.getElementById('calibration-table'));
document.addEventListener('DOMContentLoaded', () => {
  calibration_table.render(<CalibrationTable />);
});
