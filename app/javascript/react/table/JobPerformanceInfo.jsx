import * as React from "react";
import { createPortal } from 'react-dom';
import {svgCommentSquare} from "../utils/tableHeader";
import {JrepModalDialog} from "../modal_dialog/JrepModalDialog";

export function JobPerformanceInfo({out_class_name, jrep_id}) {
  const [showModal, setShowModal] = React.useState(0);

  const handleClick = () => {
    setShowModal(jrep_id);
  }

  const handleClose = () => {
    setShowModal(0);
  }

  return (
  <>
    <span className={out_class_name} role="button" onClick={handleClick}>
      <svg className="icon">
        <use xlinkHref={svgCommentSquare()}></use>
      </svg>
    </span>
    {showModal == jrep_id && createPortal(
      <JrepModalDialog
        jrep_id={jrep_id}
        onClose={handleClose}
      />,
      document.getElementById("coreuiModal")
    )}
  </>
  );
}
