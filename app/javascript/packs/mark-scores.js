import * as React from "react"
import { createRoot } from 'react-dom/client';
import MarkScores from '../react/MarkScores';


const staff_node = document.getElementById('staff-mark')
if (staff_node) {
  const staff_root = createRoot(staff_node);
  document.addEventListener('DOMContentLoaded', () => {
    staff_root.render(<MarkScores group_level='staff' />);
  });
}

const manager_node = document.getElementById('manager-mark');
if (manager_node) {
  const manager_root = createRoot(manager_node);
  document.addEventListener('DOMContentLoaded', () => {
    manager_root.render(<MarkScores group_level='manager' />);
  });
}
