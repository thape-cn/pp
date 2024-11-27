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

const manager_a_node = document.getElementById('manager_a-mark');
if (manager_a_node) {
  const manager_root = createRoot(manager_a_node);
  document.addEventListener('DOMContentLoaded', () => {
    manager_root.render(<MarkScores group_level='manager_a' />);
  });
}

const manager_b_node = document.getElementById('manager_b-mark');
if (manager_b_node) {
  const manager_root = createRoot(manager_b_node);
  document.addEventListener('DOMContentLoaded', () => {
    manager_root.render(<MarkScores group_level='manager_b' />);
  });
}

const auxiliary_node = document.getElementById('auxiliary-mark');
if (auxiliary_node) {
  const auxiliary_root = createRoot(auxiliary_node);
  document.addEventListener('DOMContentLoaded', () => {
    auxiliary_root.render(<MarkScores group_level='auxiliary' />);
  });
}
