import * as React from "react"
import { createRoot } from 'react-dom/client';
import CalibrationPanel from '../react/CalibrationPanel';

function mountWhenReady(callback) {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', callback);
  } else {
    callback();
  }
}

const calibration_node = document.getElementById('calibration-panel');
if (calibration_node) {
  const calibration_root = createRoot(calibration_node);
  mountWhenReady(() => {
    calibration_root.render(<CalibrationPanel />);
  });
}
