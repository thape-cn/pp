import * as React from "react";
import {put} from '@rails/request.js'
import {reviewLabels, userId} from "../utils/tableHeader";
import {scoreConfirmPath} from "../utils/url";

export function MarkScoreConfirmDialog({accepted, message, euc_ids, onClose}) {
  const modalRef = React.useRef();
  const submittingRef = React.useRef(false);
  const [submitting, setSubmitting] = React.useState(false);
  React.useEffect(() => {
    const modal = new coreui.Modal('#coreuiModal');
    modal.show();
    modalRef.current.parentNode.addEventListener('hidden.coreui.modal', event => {
      onClose();
    });
  }, []);

  const handleConfirm = (event) => {
    event.preventDefault();
    if (submittingRef.current) return;

    submittingRef.current = true;
    setSubmitting(true);
    put(scoreConfirmPath(userId()), {body: {euc_ids}}).then((response) => {
      if (!response.ok) throw new Error("Failed to confirm mark scores");

      return response.json;
    }).then(result => {
      window.location.href = result.go_path;
    }).catch(() => {
      submittingRef.current = false;
      setSubmitting(false);
    });
  }

  return (
    <div ref={modalRef} className="modal-dialog">
      <div className="modal-content">
        <div className="modal-header">
          <h5 className="modal-title">{accepted ? reviewLabels().accept_title : reviewLabels().reject_title}</h5>
          <button className="btn-close" type="button" data-coreui-dismiss="modal" aria-label="Close"></button>
        </div>
        <div className="modal-body">
          {message}
        </div>
        <div className="modal-footer">
          {accepted ? <button onClick={handleConfirm} className="btn btn-primary" disabled={submitting}>{reviewLabels().submit}</button> : null}
          <button className="btn btn-secondary" type="button" data-coreui-dismiss="modal">{reviewLabels().close}</button>
        </div>
      </div>
    </div>
  );
}
