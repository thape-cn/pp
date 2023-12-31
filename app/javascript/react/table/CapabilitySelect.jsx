import * as React from "react";
import {CapabilitySelectWithDescription} from "./CapabilitySelectWithDescription";

export function CapabilitySelect({ value, ercd, onChange, onBlur, matric, not_rated_text }) {
  if (ercd) {
    return <CapabilitySelectWithDescription value={value} ercd={ercd} onChange={onChange} onBlur={onBlur} matric={matric} not_rated_text={not_rated_text} />;
  } else {
    return <select value={value} onChange={onChange} onBlur={onBlur} className="form-control form-control-sm">
      <option value='0'>{not_rated_text}</option>
      {matric.map(option => (
        <option key={option.value} value={option.value}>{option.label}</option>
      ))}
    </select>
  }
}
