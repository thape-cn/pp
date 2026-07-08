import * as React from 'react';
import {JobPerformanceInfo} from "./JobPerformanceInfo";
import {CapabilitySelect} from "./CapabilitySelect";

const HIDDEN_RANK_EN_NAMES = [
  'p_managedproject_profit',
  'p_managedproject_output',
  'p_individual_output',
  'p_individual_hours',
  'p_individual_trackedlaborratio'
];

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
  const rank_performance_metric = company_evaluation_templates[row_data.id_cet].rank_performance_metric;
  const jobRolePerformanceMetric = HIDDEN_RANK_EN_NAMES.includes(id) ? rank_performance_metric : performance_metric;
  const objResultExplain = row_data[`${id}_obj_result_explain`];
  const objResultExplainNode = (textAlignClass = "") => objResultExplain ? (
    <div className={`small text-body-secondary mt-1 ${textAlignClass}`.trim()}>{objResultExplain}</div>
  ) : null;

  if (value == 'none') {
    return null;
  } else if (row_data[id+"_fixed"] == true) {
    if (id.startsWith('p_')) {
      const item = jobRolePerformanceMetric.find(item => item.value === value);
      if (id == "p_individual_trackedlaborratio") {
        return (
          <div className="m-1">
            <div className="text-end">
              <span className="me-2"></span>
              <JobPerformanceInfo
                out_class_name="m-1"
                jrep_id={row_data[id+"_id"]}
              />
            </div>
            {objResultExplainNode("text-end")}
          </div>
        )
      } else {
        return (
          <div className="m-1">
            <div className="text-end">
              <span className="me-2">{item ? item.label : null}</span>
              <JobPerformanceInfo
                out_class_name="m-1"
                jrep_id={row_data[id+"_id"]}
              />
            </div>
            {objResultExplainNode("text-end")}
          </div>
        )
      }
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
    if (id == 'total_evaluation_score') {
      return <p className="m-1 text-end">{row_data["total_score_in_metric"]}</p>;
    } else if (id == 'raw_total_evaluation_score') {
      return <p className="m-1 text-end">{row_data["raw_total_score_in_metric"]}</p>;
    } else if (id == 'raw_total_evaluation_score_raw') {
      return <p className="m-1 text-end">{Math.round(row_data["raw_total_evaluation_score"] * 100) / 100}</p>;
    } else if (id.startsWith('p_')) {
      return (
        <>
          <div className="input-group">
            <select id={`r${index}-${id}`} value={value} onChange={onChange} onBlur={onBlur} className="form-control form-control-sm">
              <option value='0'>{not_rated_text}</option>
              {jobRolePerformanceMetric.map(option => (
                <option key={option.value} value={option.value}>{option.label}</option>
              ))}
            </select>
            <JobPerformanceInfo
              out_class_name="input-group-text"
              jrep_id={row_data[id+"_id"]}
            />
          </div>
          {objResultExplainNode("text-start")}
        </>
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
