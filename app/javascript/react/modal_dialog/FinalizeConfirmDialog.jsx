import * as React from "react";
import {put} from '@rails/request.js'
import {calibrationLabels, calibrationSessionId} from "../utils/tableHeader";
import {finalizeCalibrationPath} from "../utils/url";

export function FinalizeConfirmDialog({accepted, message, onClose}) {
  const modalRef = React.useRef();
  React.useEffect(() => {
    const modal = new coreui.Modal('#coreuiModal');
    modal.show();
    modalRef.current.parentNode.addEventListener('hidden.coreui.modal', event => {
      onClose();
    });
  }, []);

  const handleFinalize = (event) => {
    event.preventDefault();
    put(finalizeCalibrationPath(calibrationSessionId()), {body: {}}).then((response) => {
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
          <h5 className="modal-title">{accepted ? calibrationLabels().accept_title : calibrationLabels().enforce_distribute_title}</h5>
          <button className="btn-close" type="button" data-coreui-dismiss="modal" aria-label="Close"></button>
        </div>
        <div className="modal-body">
          {message}
        </div>
        <div className="modal-footer">
          {accepted ? <button onClick={handleFinalize} className="btn btn-primary">{calibrationLabels().finalize}</button> : null}
          <button className="btn btn-secondary" type="button" data-coreui-dismiss="modal">{calibrationLabels().close}</button>
        </div>
      </div>
    </div>
  );
}
