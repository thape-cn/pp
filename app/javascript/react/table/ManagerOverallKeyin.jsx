import * as React from "react";

export function ManagerOverallKeyin({
  label_text,
  showSaveCloseButton,
  keyin_control_id,
  value,
  onChange,
  html_value}) {
  return <>
    <label htmlFor={keyin_control_id} className="form-label">{label_text}</label>
    {showSaveCloseButton
      ?
      <textarea className="form-control" id={keyin_control_id} rows="3" value={value}
                onChange={onChange}/>
      : <div className="form-control min-vh-8"
             dangerouslySetInnerHTML={{__html: html_value}}></div>}
  </>;
}
