import * as React from "react";
import {put} from '@rails/request.js'
import {reviewLabels, userId} from "../utils/tableHeader";
import {scoreConfirmPath} from "../utils/url";

export function MarkScoreConfirmDialog({accepted, message, euc_ids, onClose}) {
  const modalRef = React.useRef();
  React.useEffect(() => {
    const modal = new coreui.Modal('#coreuiModal');
    modal.show();
    modalRef.current.parentNode.addEventListener('hidden.coreui.modal', event => {
      onClose();
    });
  }, []);

  const handleConfirm = (event) => {
    event.preventDefault();
    put(scoreConfirmPath(userId()), {body: {euc_ids}}).then((response) => {
      if (response.ok) {
        const result_json = response.json;
        result_json.then(result => {
          window.location.href = result.go_path;
        });
      }
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
          {accepted ? <button onClick={handleConfirm} className="btn btn-primary">{reviewLabels().submit}</button> : null}
          <button className="btn btn-secondary" type="button" data-coreui-dismiss="modal">{reviewLabels().close}</button>
        </div>
      </div>
    </div>
  );
}
