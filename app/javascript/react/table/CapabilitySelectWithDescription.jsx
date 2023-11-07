import * as React from "react";
import {svgInfo} from "../utils/tableHeader";

export function CapabilitySelectWithDescription({ value, ercd, onChange, onBlur, matric, not_rated_text }) {
  return <div className="input-group">
    <select value={value} onChange={onChange} onBlur={onBlur} className="form-control form-control-sm">
      <option value='0'>{not_rated_text}</option>
      {matric.map(option => (
        <option key={option.value} value={option.value}>{option.label}</option>
      ))}
    </select>
    <span className="input-group-text" role="button">
      <svg className="icon">
        <use xlinkHref={svgInfo()}></use>
      </svg>
    </span>
  </div>
}
