import * as React from "react";

export function ManagerOverallKeyin({
  label_text,
  showSaveCloseButton,
  keyin_control_id,
  value,
  onChange,
  html_hint,
  html_value}) {
  return <>
    <label htmlFor={keyin_control_id} className="form-label">{label_text}</label>
    {
      showSaveCloseButton
      ?
      <>
        <div class="alert alert-dark alert-dismissible fade show mb-1" role="alert">
          {html_hint}
          <button type="button" class="btn-close" data-coreui-dismiss="alert" aria-label="Close"></button>
        </div>
        <textarea className="form-control" id={keyin_control_id} rows="3" value={value}
                  onChange={onChange}/>
      </>
      :
      <div className="form-control min-vh-8"
             dangerouslySetInnerHTML={{__html: html_value}}></div>
    }
  </>;
}
