import * as React from "react"
import { createRoot } from 'react-dom/client';
import CalibrationPanel from '../react/CalibrationPanel';

const calibration_node = createRoot(document.getElementById('calibration-panel'));
document.addEventListener('DOMContentLoaded', () => {
  calibration_node.render(<CalibrationPanel />);
});
