import * as React from "react"
import { createRoot } from 'react-dom/client';
import MarkScores from '../react/MarkScores';

function mountWhenReady(callback) {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', callback);
  } else {
    callback();
  }
}

mountWhenReady(() => {
  const staff_node = document.getElementById('staff-mark')
  if (staff_node) {
    const staff_root = createRoot(staff_node);
    staff_root.render(<MarkScores group_level='staff' />);
  }

  const manager_a_node = document.getElementById('manager_a-mark');
  if (manager_a_node) {
    const manager_root = createRoot(manager_a_node);
    manager_root.render(<MarkScores group_level='manager_a' />);
  }

  const manager_b_node = document.getElementById('manager_b-mark');
  if (manager_b_node) {
    const manager_root = createRoot(manager_b_node);
    manager_root.render(<MarkScores group_level='manager_b' />);
  }

  const auxiliary_node = document.getElementById('auxiliary-mark');
  if (auxiliary_node) {
    const auxiliary_root = createRoot(auxiliary_node);
    auxiliary_root.render(<MarkScores group_level='auxiliary' />);
  }

  const supervisor_node = document.getElementById('supervisor-mark');
  if (supervisor_node) {
    const supervisor_root = createRoot(supervisor_node);
    const mark_score_groups = JSON.parse(supervisor_node.getAttribute('data-mark-score-groups') || '[]');
    supervisor_root.render(
      <>
        {mark_score_groups.map(({label, value, table_header}) => (
          <section key={value} className="mb-4">
            <h5 className="my-3">{label}</h5>
            <MarkScores group_level='supervisor' mark_score_group={value} table_header={table_header} />
          </section>
        ))}
      </>
    );
  }
});
