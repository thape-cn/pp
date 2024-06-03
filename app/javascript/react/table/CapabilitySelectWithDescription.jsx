import * as React from "react";
import {svgInfo} from "../utils/tableHeader";

export function CapabilitySelectWithDescription({ value, ercd, onChange, onBlur, metric, not_rated_text, description }) {
  const popoverRef = React.useRef();

  React.useEffect(() => {
    if (popoverRef.current) {
      const popover = new coreui.Popover(popoverRef.current, {trigger: "hover", html: true});
    }
  }, [])

  let formattedDescription = ""

  if (ercd) {
    formattedDescription = ercd.replace(/\n/g, "<br>");
  }

  return (
    <div className="input-group">
      <select value={value} onChange={onChange} onBlur={onBlur} className="form-control form-control-sm">
        <option value='0'>{not_rated_text}</option>
        {metric.map(option => (
          <option key={option.value} value={option.value}>{option.label}</option>
        ))}
      </select>
      <span className="input-group-text" role="button" ref={popoverRef}
        data-coreui-content={formattedDescription}
        data-coreui-placement="top"
        data-coreui-toggle="popover" title="">
        <svg className="icon">
          <use xlinkHref={svgInfo()}></use>
        </svg>
      </span>
    </div>
  )
}
