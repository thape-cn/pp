import * as React from "react";
import {get} from '@rails/request.js'
import {userJobRolePerformancesPath} from "../utils/url";

export function JrepModalDialog({jrep_id, onClose}) {
  const [userJobRolePerformance, setUserJobRolePerformance] = React.useState({});
  const modalRef = React.useRef();

  React.useEffect(() => {
    get(userJobRolePerformancesPath(jrep_id)).then((response) => {
      if (response.ok) {
        const result_json = response.json;
        result_json.then(result => {
          const modal = new coreui.Modal('#coreuiModal');
          setUserJobRolePerformance(result);
          modal.show();
          modalRef.current.parentNode.addEventListener('hidden.coreui.modal', event => {
            onClose();
          });
        });
      }
    });
  }, [])

  return (
    <div ref={modalRef} className="modal-dialog">
      <div className="modal-content">
        <div className="modal-header">
          <h5 className="modal-title">{userJobRolePerformance.obj_name}</h5>
          <button className="btn-close" type="button" data-coreui-dismiss="modal" aria-label="Close"></button>
        </div>
        <div className="modal-body">
          <div dangerouslySetInnerHTML={{__html: userJobRolePerformance.obj_metric}}></div>
        </div>
        <div className="modal-footer">
          <button className="btn btn-secondary" type="button" data-coreui-dismiss="modal">{userJobRolePerformance.close}</button>
        </div>
      </div>
    </div>
  );
}
