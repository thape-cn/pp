import * as React from 'react';
import {reverseScoreInMetric} from "../utils/reverseScoreInMetric";
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

  const work_quality_metric = company_evaluation_templates[row_data.id_cet].work_quality_metric;
  const work_load_metric = company_evaluation_templates[row_data.id_cet].work_load_metric;
  const work_attitude_metric = company_evaluation_templates[row_data.id_cet].work_attitude_metric;
  const professional_management_metric = company_evaluation_templates[row_data.id_cet].professional_management_metric;
  const performance_metric = company_evaluation_templates[row_data.id_cet].performance_metric;

  if (value == 'none') {
    return null;
  } else if (row_data[id+"_fixed"] == true) {
    if (id.startsWith('p_')) {
      const item = performance_metric.find(item => item.value === value);
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
      const item = work_quality_metric.find(item => item.value === value);
      return <p className="m-1 text-end">{item ? item.label : null}</p>;
    } else if ( id == 'work_load' || id == "calibration_work_load") {
      const item = work_load_metric.find(item => item.value === value);
      return <p className="m-1 text-end">{item ? item.label : null}</p>;
    } else if ( id == 'work_attitude' || id == "calibration_work_attitude") {
      const item = work_attitude_metric.find(item => item.value === value);
      return <p className="m-1 text-end">{item ? item.label : null}</p>;
    } else if ( id == 'annual_output' || id == "calibration_performance_score") {
      const item = performance_metric.find(item => item.value === value);
      return <p className="m-1 text-end">{item ? item.label : null}</p>;
    } else {
      const item = professional_management_metric.find(item => item.value === value);
      return <p className="m-1 text-end">{item ? item.label : null}</p>;
    }
  } else {
    if (id == 'total_evaluation_score' || id == 'raw_total_evaluation_score') {
      return <p className="m-1 text-end">{reverseScoreInMetric(value)}</p>;
    } else if (id.startsWith('p_')) {
      return (
        <div className="input-group">
          <select id={`r${index}-${id}`} value={value} onChange={onChange} onBlur={onBlur} className="form-control form-control-sm">
            <option value='0'>{not_rated_text}</option>
            {performance_metric.map(option => (
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
      return <CapabilitySelect id={`r${index}-${id}`} value={value} ercd={row_data[id+"_ercd"]} onChange={onChange} onBlur={onBlur} metric={work_quality_metric} not_rated_text={not_rated_text} />;
    } else if ( id == 'work_load' || id == "calibration_work_load") {
      return <CapabilitySelect id={`r${index}-${id}`} value={value} ercd={row_data[id+"_ercd"]} onChange={onChange} onBlur={onBlur} metric={work_load_metric} not_rated_text={not_rated_text} />;
    } else if ( id == 'work_attitude' || id == "calibration_work_attitude") {
      return <CapabilitySelect id={`r${index}-${id}`} value={value} ercd={row_data[id+"_ercd"]} onChange={onChange} onBlur={onBlur} metric={work_attitude_metric} not_rated_text={not_rated_text} />;
    } else if ( id == 'annual_output' || id == "calibration_performance_score") {
      return <CapabilitySelect id={`r${index}-${id}`} value={value} ercd={row_data[id+"_ercd"]} onChange={onChange} onBlur={onBlur} metric={performance_metric} not_rated_text={not_rated_text} />;
    } else {
      return <CapabilitySelect id={`r${index}-${id}`} value={value} ercd={row_data[id+"_ercd"]} onChange={onChange} onBlur={onBlur} metric={professional_management_metric} not_rated_text={not_rated_text} />;
    }
  }
}
