import * as React from "react";

export function ManagerOverallKeyin({
  managerOverallOutput,
  showSaveCloseButton,
  keyin_control_id,
  value,
  onChange,
  overallReview}) {
  return <>
    <label htmlFor={keyin_control_id} className="form-label">{managerOverallOutput}</label>
    {showSaveCloseButton
      ?
      <textarea className="form-control" id={keyin_control_id} rows="3" value={value}
                onChange={onChange}/>
      : <div className="form-control min-vh-8"
             dangerouslySetInnerHTML={{__html: overallReview.manager_overall_output}}></div>}
  </>;
}
