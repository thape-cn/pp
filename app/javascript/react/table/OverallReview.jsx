import * as React from "react";
import {get, put} from '@rails/request.js'
import {evaluationUserCapabilitiesPath} from "../utils/url";

export function OverallReview({
  row: { index: rowIndex, original: {id_euc} },
  visibleColumns, review_labels, show_save_close_button,
  setExpandedByRowIndex, onManagerOverallChange
}) {
  const [overallReview, setOverallReview] = React.useState({});
  const [managerOverallOutput, setManagerOverallOutput] = React.useState("");
  const [managerOverallImprovement, setManagerOverallImprovement] = React.useState("");
  const [managerOverallPlan, setManagerOverallPlan] = React.useState("");

  React.useEffect(() => {
    get(evaluationUserCapabilitiesPath(id_euc)).then((response) => {
      if (response.ok) {
        const result_json = response.json;
        result_json.then(result => {
          setOverallReview(result.evaluation_user_capability);
          setManagerOverallOutput(result.evaluation_user_capability.edit_manager_overall_output);
          setManagerOverallImprovement(result.evaluation_user_capability.edit_manager_overall_improvement);
          setManagerOverallPlan(result.evaluation_user_capability.edit_manager_overall_plan);
        });
      }
    });
  }, []);

  const handleSubmit = (event) => {
    const action = event.nativeEvent.submitter['name'];
    event.preventDefault();
    const data = {
      manager_overall_output: event.target.elements.manager_overall_output.value,
      manager_overall_improvement: event.target.elements.manager_overall_improvement.value,
      manager_overall_plan: event.target.elements.manager_overall_plan.value
    }
    put(evaluationUserCapabilitiesPath(id_euc), {body: data}).then((response) => {
      if (response.ok) {
        if (action == "submit") {
          setExpandedByRowIndex(rowIndex);
        }
      }
    });
  }

  function showSaveCloseButton() {
    return <div className="col-4">
      <button name="submit" type="submit" className="btn btn-primary btn-sm">{review_labels.save_comment_close}</button>
      <button name="save" type="submit" className="ms-3 btn btn-secondary btn-sm">{review_labels.save_comment}</button>
    </div>;
  }

  const handleOverallOutputChange = (event) => {
    setManagerOverallOutput(event.target.value);
    onManagerOverallChange(rowIndex, 'manager_overall_output', event.target.value);
  };
  
  const handleOverallImprovementChange = (event) => {
    setManagerOverallImprovement(event.target.value);
    onManagerOverallChange(rowIndex, 'manager_overall_improvement', event.target.value);
  };
  
  const handleOverallPlanChange = (event) => {
    setManagerOverallPlan(event.target.value);
    onManagerOverallChange(rowIndex, 'manager_overall_plan', event.target.value);
  };

  return (
    <tr>
      <td colSpan={visibleColumns.length}>
        <form onSubmit={handleSubmit} className="row g-3">
          <div className="col-4">
            <label htmlFor="self_overall_output" className="form-label">{review_labels.self_overall_output}</label>
            <div className="form-control min-vh-8" dangerouslySetInnerHTML={{__html: overallReview.self_overall_output}}></div>
          </div>
          <div className="col-4">
            <label htmlFor="self_overall_improvement" className="form-label">{review_labels.self_overall_improvement}</label>
            <div className="form-control min-vh-8" dangerouslySetInnerHTML={{__html: overallReview.self_overall_improvement}}></div>
          </div>
          <div className="col-4">
            <label htmlFor="self_overall_plan" className="form-label">{review_labels.self_overall_plan}</label>
            <div className="form-control min-vh-8" dangerouslySetInnerHTML={{__html: overallReview.self_overall_plan}}></div>
          </div>
          <div className="col-4">
            <label htmlFor="manager_overall_output" className="form-label">{review_labels.manager_overall_output}</label>
            {show_save_close_button
             ? <textarea className="form-control" id="manager_overall_output" rows="3" value={managerOverallOutput} onChange={handleOverallOutputChange} />
             : <div className="form-control min-vh-8" dangerouslySetInnerHTML={{__html: overallReview.manager_overall_output}}></div>}
          </div>
          <div className="col-4">
            <label htmlFor="manager_overall_improvement" className="form-label">{review_labels.manager_overall_improvement}</label>
            {show_save_close_button
             ? <textarea className="form-control" id="manager_overall_improvement" rows="3" value={managerOverallImprovement} onChange={handleOverallImprovementChange} />
             : <div className="form-control min-vh-8" dangerouslySetInnerHTML={{__html: overallReview.manager_overall_improvement}}></div>}
          </div>
          <div className="col-4">
            <label htmlFor="manager_overall_plan" className="form-label">{review_labels.manager_overall_plan}</label>
            {show_save_close_button
             ? <textarea className="form-control" id="manager_overall_plan" rows="3" value={managerOverallPlan} onChange={handleOverallPlanChange} />
             : <div className="form-control min-vh-8" dangerouslySetInnerHTML={{__html: overallReview.manager_overall_plan}}></div>}
          </div>
          {show_save_close_button && showSaveCloseButton()}
        </form>
      </td>
    </tr>
  );
}
