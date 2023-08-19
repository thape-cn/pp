import * as React from "react";
import {get} from '@rails/request.js'
import {calibrationLabels} from "../utils/tableHeader";
import {evaluationUserCapabilitiesPath} from "../utils/url";

function FixedOutputDetail({fixed_output, callbackfn}) {
  return <table className="table">
    <thead>
    <tr>
      <th className="w-75">{calibrationLabels().fixed_output}</th>
      <th>{calibrationLabels().capability_result}</th>
    </tr>
    </thead>
    <tbody>
      {Object.entries(fixed_output).map(callbackfn)}
    </tbody>
  </table>;
}

function ManagementCapabilityDetail({management_capability, callbackfn}) {
  return <table className="table">
    <thead>
    <tr>
      <th className="w-75">{calibrationLabels().management_capability}</th>
      <th>{calibrationLabels().capability_result}</th>
    </tr>
    </thead>
    <tbody>
      {Object.entries(management_capability).map(callbackfn)}
    </tbody>
  </table>;
}

function ProfessionalCapabilityDetail({profession_capability, callbackfn}) {
  return <table className="table">
    <thead>
    <tr>
      <th className="w-75">{calibrationLabels().professional_capability}</th>
      <th>{calibrationLabels().capability_result}</th>
    </tr>
    </thead>
    <tbody>
      {Object.entries(profession_capability).map(callbackfn)}
    </tbody>
  </table>;
}

function PerformanceDetail({job_role_performances, callbackfn}) {
  return <table className="table">
    <thead>
    <tr>
      <th className="w-75">{calibrationLabels().performance}</th>
      <th>{calibrationLabels().obj_result}</th>
    </tr>
    </thead>
    <tbody>
    {Object.entries(job_role_performances).map(callbackfn)}
    </tbody>
  </table>;
}

export function EucModalDialog({euc_id, onClose}) {
  const [evaluationUserCapability, setEvaluationUserCapability] = React.useState({});
  const [companyEvaluationTemplate, setCompanyEvaluationTemplate] = React.useState({});
  const modalRef = React.useRef();

  React.useEffect(() => {
    get(evaluationUserCapabilitiesPath(euc_id)).then((response) => {
      if (response.ok) {
        const result_json = response.json;
        result_json.then(result => {
          const modal = new coreui.Modal('#coreuiModal');
          setCompanyEvaluationTemplate(result.company_evaluation_template);
          setEvaluationUserCapability(result.evaluation_user_capability);
          modal.show();
          modalRef.current.parentNode.addEventListener('hidden.coreui.modal', event => {
            onClose();
          });
        });
      }
    });
  }, [])

  return (
    <div ref={modalRef} className="modal-dialog">
      <div className="modal-content">
        <div className="modal-header">
          <h5 className="modal-title">{evaluationUserCapability.chinese_name} - {evaluationUserCapability.form_status}</h5>
          <button className="btn-close" type="button" data-coreui-dismiss="modal" aria-label="Close"></button>
        </div>
        <div className="modal-body">
          {evaluationUserCapability.job_role_performances && <PerformanceDetail job_role_performances={evaluationUserCapability.job_role_performances}
          callbackfn={([key, value]) => {
            const item = companyEvaluationTemplate.performance_matric.find(item => item.value === value);

            return (
              <tr key={key}>
                <td>{key}</td>
                <td>{item ? item.label : null}</td>
              </tr>
            );
          }}/>}
          {evaluationUserCapability.profession_capability && <ProfessionalCapabilityDetail profession_capability={evaluationUserCapability.profession_capability}
          callbackfn={([key, value]) => {
            const item = companyEvaluationTemplate.professional_management_matric.find(item => item.value === value);

            return (
              <tr key={key}>
                <td>{key}</td>
                <td>{item ? item.label : null}</td>
              </tr>
            );
          }}/>}
          {evaluationUserCapability.management_capability && <ManagementCapabilityDetail management_capability={evaluationUserCapability.management_capability}
          callbackfn={([key, value]) => {
            const item = companyEvaluationTemplate.professional_management_matric.find(item => item.value === value);

            return (
              <tr key={key}>
                <td>{key}</td>
                <td>{item ? item.label : null}</td>
              </tr>
            );
          }}/>}
          {evaluationUserCapability.fixed_output && <FixedOutputDetail fixed_output={evaluationUserCapability.fixed_output}
          callbackfn={([key, value]) => {
            let item = undefined;

            if (key == "work_quality") {
              item = companyEvaluationTemplate.work_quality_matric.find(item => item.value === value);
            } else if (key == "work_load") {
              item = companyEvaluationTemplate.work_load_matric.find(item => item.value === value);
            } else if (key == "work_attitude") {
              item = companyEvaluationTemplate.work_attitude_matric.find(item => item.value === value);
            } else {
              item = companyEvaluationTemplate.professional_management_matric.find(item => item.value === value);
            }

            return (
              <tr key={key}>
                <td>{calibrationLabels()[`${key}_pct`]}</td>
                <td>{item ? item.label : null}</td>
              </tr>
            );
          }}/>}
          <div className="col-12">
            <div className="m-2">{calibrationLabels().self_overall_output}</div>
            <div className="form-control min-vh-8" dangerouslySetInnerHTML={{__html: evaluationUserCapability.self_overall_output}}></div>
          </div>
          <div className="col-12">
            <div className="m-2">{calibrationLabels().self_overall_improvement}</div>
            <div className="form-control min-vh-8" dangerouslySetInnerHTML={{__html: evaluationUserCapability.self_overall_improvement}}></div>
          </div>
          <div className="col-12">
            <div className="m-2">{calibrationLabels().self_overall_plan}</div>
            <div className="form-control min-vh-8" dangerouslySetInnerHTML={{__html: evaluationUserCapability.self_overall_plan}}></div>
          </div>
          <div className="col-12">
            <div className="m-2">{calibrationLabels().manager_overall_output}</div>
            <div className="form-control min-vh-8" dangerouslySetInnerHTML={{__html: evaluationUserCapability.manager_overall_output}}></div>
          </div>
          <div className="col-12">
            <div className="m-2">{calibrationLabels().manager_overall_improvement}</div>
            <div className="form-control min-vh-8" dangerouslySetInnerHTML={{__html: evaluationUserCapability.manager_overall_improvement}}></div>
          </div>
          <div className="col-12">
            <div className="m-2">{calibrationLabels().manager_overall_plan}</div>
            <div className="form-control min-vh-8" dangerouslySetInnerHTML={{__html: evaluationUserCapability.manager_overall_plan}}></div>
          </div>
        </div>
        <div className="modal-footer">
          <button className="btn btn-secondary" type="button"
                  data-coreui-dismiss="modal">{calibrationLabels().close}</button>
        </div>
      </div>
    </div>
  );
}
