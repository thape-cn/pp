import * as React from 'react';
import {reverseScoreInMatric} from "../utils/reverseScoreInMatric";
import {JobPerformanceInfo} from "./JobPerformanceInfo";
import {CapabilitySelect} from "./CapabilitySelect";

export const EditableCell = ({
  value: initialValue,
  row: { index, original: row_data},
  column: { id },
  updateRawData, // This is a custom function that we supplied to our table instance
  setFirstSaved,
  company_evaluation_templates,
  not_rated_text
}) => {
  // We need to keep and update the state of the cell normally
  const [value, setValue] = React.useState(initialValue)

  const onChange = e => {
    setFirstSaved(false);
    setValue(e.target.value);
  }

  // We'll only update the external data when the input is blurred
  const onBlur = () => {
    updateRawData(index, id, value)
  }

  // If the initialValue is changed external, sync it up with our state
  React.useEffect(() => {
    setValue(initialValue)
  }, [initialValue])

  const work_quality_matric = company_evaluation_templates[row_data.id_cet].work_quality_matric;
  const work_load_matric = company_evaluation_templates[row_data.id_cet].work_load_matric;
  const work_attitude_matric = company_evaluation_templates[row_data.id_cet].work_attitude_matric;
  const professional_management_matric = company_evaluation_templates[row_data.id_cet].professional_management_matric;
  const performance_matric = company_evaluation_templates[row_data.id_cet].performance_matric;
  const total_reverse_matric = company_evaluation_templates[row_data.id_cet].total_reverse_matric;

  if (value == 'none') {
    return null;
  } else if (row_data[id+"_fixed"] == true) {
    if (id.startsWith('p_')) {
      const item = performance_matric.find(item => item.value === value);
      return (
        <div className="m-1 text-end">
          <span className="me-2">{item ? item.label : null}</span>
          <JobPerformanceInfo
            out_class_name="m-1"
            jrep_id={row_data[id+"_id"]}
          />
        </div>
      );
    } else if ( id == 'work_quality' || id == "calibration_work_quality") {
      const item = work_quality_matric.find(item => item.value === value);
      return <p className="m-1 text-end">{item ? item.label : null}</p>;
    } else if ( id == 'work_load' || id == "calibration_work_load") {
      const item = work_load_matric.find(item => item.value === value);
      return <p className="m-1 text-end">{item ? item.label : null}</p>;
    } else if ( id == 'work_attitude' || id == "calibration_work_attitude") {
      const item = work_attitude_matric.find(item => item.value === value);
      return <p className="m-1 text-end">{item ? item.label : null}</p>;
    } else {
      const item = professional_management_matric.find(item => item.value === value);
      return <p className="m-1 text-end">{item ? item.label : null}</p>;
    }
  } else {
    if (id == 'total_evaluation_score' || id == 'pre_total_evaluation_score') {
      return <p className="m-1 text-end">{reverseScoreInMatric(value, total_reverse_matric)}</p>;
    } else if (id.startsWith('p_')) {
      return (
        <div className="input-group">
          <select value={value} onChange={onChange} onBlur={onBlur} className="form-control form-control-sm">
            <option value='0'>{not_rated_text}</option>
            {performance_matric.map(option => (
              <option key={option.value} value={option.value}>{option.label}</option>
            ))}
          </select>
          <JobPerformanceInfo
            out_class_name="input-group-text"
            jrep_id={row_data[id+"_id"]}
          />
        </div>
      );
    } else if ( id == 'work_quality' || id == "calibration_work_quality") {
      return <CapabilitySelect value={value} ercd={row_data[id+"_ercd"]} onChange={onChange} onBlur={onBlur} matric={work_quality_matric} not_rated_text={not_rated_text} />;
    } else if ( id == 'work_load' || id == "calibration_work_load") {
      return <CapabilitySelect value={value} ercd={row_data[id+"_ercd"]} onChange={onChange} onBlur={onBlur} matric={work_load_matric} not_rated_text={not_rated_text} />;
    } else if ( id == 'work_attitude' || id == "calibration_work_attitude") {
      return <CapabilitySelect value={value} ercd={row_data[id+"_ercd"]} onChange={onChange} onBlur={onBlur} matric={work_attitude_matric} not_rated_text={not_rated_text} />;
    } else if ( id == 'annual_output' || id == "calibration_performance_score") {
      return <CapabilitySelect value={value} ercd={row_data[id+"_ercd"]} onChange={onChange} onBlur={onBlur} matric={performance_matric} not_rated_text={not_rated_text} />;
    } else {
      return <CapabilitySelect value={value} ercd={row_data[id+"_ercd"]} onChange={onChange} onBlur={onBlur} matric={professional_management_matric} not_rated_text={not_rated_text} />;
    }
  }
}
