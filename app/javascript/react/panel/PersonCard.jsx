import React from 'react';
import { createPortal } from 'react-dom';
import { useDrag } from 'react-dnd';
import {calibrationLabels} from "../utils/tableHeader";
import {EucModalDialog} from "../modal_dialog/EucModalDialog";
import {personBadgeBgClass} from "../utils/grade_help";

function PersonCard({id, user_id, chinese_name, pre_total_evaluation_score, work_attitude, row, column, group_level}) {
  const [{ isDragging }, drag] = useDrag(() => ({
    type: 'personCard',
    item: { id, user_id, chinese_name, person_row: row, pre_total_evaluation_score, work_attitude, person_column: column, group_level },
    collect: (monitor) => ({
      isDragging: monitor.isDragging(),
    }),
  }));

  const [showModal, setShowModal] = React.useState(0);

  const handleClick = () => {
    setShowModal(id);
  }

  const handleClose = () => {
    setShowModal(0);
  }

  return (
  <>
    <span 
      ref={drag}    
      className="btn btn-secondary rounded-pill m-1"
    >
      {chinese_name}
      <span className={personBadgeBgClass(group_level, work_attitude)}
        title={calibrationLabels().total_evaluation_score}
        onClick={handleClick}>
        {pre_total_evaluation_score}
      </span>
    </span>
    {showModal == id && createPortal(
      <EucModalDialog
        euc_id={id}
        onClose={handleClose}
      />,
      document.getElementById("coreuiModal")
    )}
  </>
  );
}

export default PersonCard;
