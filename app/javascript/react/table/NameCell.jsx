import * as React from "react";
import {svgCilPrint} from "../utils/tableHeader";
import {signingEvaluationUserCapabilityPath} from "../utils/url";

export function NameCell({initialValue, row_data, need_print}) {
  const toolTipRef = React.useRef();
  React.useEffect(() => {
    const toolTip = new coreui.Tooltip(toolTipRef.current);
  }, []);

  return (
  <div className="m-1">
    <span className="m-1" ref={toolTipRef} data-coreui-toggle="tooltip" data-coreui-placement="top" data-coreui-title={row_data.form_status_name}>
      {initialValue}
    </span>
    { need_print &&
    <a href={signingEvaluationUserCapabilityPath(row_data.id_euc)} target="_blank">
      <svg className="icon">
        <use xlinkHref={svgCilPrint()}></use>
      </svg>
    </a>
    }
  </div>
  );
}
