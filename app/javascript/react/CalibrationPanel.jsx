import * as React from 'react';
import { createPortal } from 'react-dom';
import { DndProvider } from 'react-dnd';
import { HTML5Backend } from 'react-dnd-html5-backend';
import {get, put} from '@rails/request.js'
import {calibrationLabels, groupLevel} from "./utils/tableHeader";
import {currentPageJsonPath} from "./utils/url";
import {calibrationEucsByStaff, calibrationEucsByManager} from "./utils/grade_help";
import GradeSquare from './panel/GradeSquare';
import PersonCard from './panel/PersonCard';
import {FinalizeConfirmDialog} from "./modal_dialog/FinalizeConfirmDialog";

const group_level = groupLevel();

function CalibrationPanel() {
  const [canFinalize, setCanFinalize] = React.useState(false);
  const [calibrationTemplate, setCalibrationTemplate] = React.useState({});
  const [calibrationEucs, setCalibrationEucs] = React.useState({});
  const [successSaveMessage, setSuccessSaveMessage] = React.useState("");
  const [finalizeMessage, setFinalizeMessage] = React.useState({accepted: false, message: ""});

  React.useEffect(() => {
    get(currentPageJsonPath(group_level)).then((response) => {
      if (response.ok) {
        const result_json = response.json;
        result_json.then(result => {
          setCanFinalize(result.can_finalize);
          setCalibrationTemplate(result.calibration_template);
          setCalibrationEucs(result.to_calibration_euc);
        });
      }
    });
  }, []);

  function renderPersonCards(row, column, group_level) {
    if (calibrationEucs && Array.isArray(calibrationEucs[`${row}${column}`])) {
      return calibrationEucs[`${row}${column}`].map(euc => {
        return (
          <PersonCard key={euc.id} id={euc.id} user_id={euc.id} chinese_name={euc.chinese_name}
            raw_total_evaluation_score={euc.raw_total_evaluation_score}
            work_attitude={euc.work_attitude}
            row={row} column={column} group_level={group_level} />
        )
      });
    }
  }

  const handleOnDrop = (item, newRow, newColumn) => {
    setCalibrationEucs((currentCalibrationEucs) => {
      // Step 1: Create a deep copy of the current calibrationEucs state
      const updatedCalibrationEucs = JSON.parse(JSON.stringify(currentCalibrationEucs));

      // Step 2: Find the old row and column of the dropped item using its euc_id
      let oldRow, oldColumn;
      for (const key in updatedCalibrationEucs) {
        if (updatedCalibrationEucs[key]) {
          const eucIndex = updatedCalibrationEucs[key].findIndex(euc => euc.id === item.id);
          if (eucIndex !== -1) {
            oldRow = key[0];
            oldColumn = key[1];
            break;
          }
        }
      }

      // Step 3: Remove the item from its old position in the copied state
      const oldKey = `${oldRow}${oldColumn}`;
      if (updatedCalibrationEucs[oldKey]) {
        const oldEucIndex = updatedCalibrationEucs[oldKey].findIndex(euc => euc.id === item.id);
        updatedCalibrationEucs[oldKey].splice(oldEucIndex, 1);
      }

      // Step 4: Add the item to its new position (row, column) in the copied state
      const newKey = `${newRow}${newColumn}`;
      if (!updatedCalibrationEucs[newKey]) {
        updatedCalibrationEucs[newKey] = [];
      }
      updatedCalibrationEucs[newKey].push(item);

      // Step 5: Sort the updatedCalibrationEucs[newKey] array based on the total_evaluation_score property
      updatedCalibrationEucs[newKey].sort((a, b) => a.total_evaluation_score - b.total_evaluation_score);

      // Return the modified copy to update the calibrationEucs state
      return updatedCalibrationEucs;
    });
  };

  const handleCountingGradePeople = (row, column) => {
    if (!calibrationEucs) return 0;

    if (group_level == "staff" && Array.isArray(calibrationEucs[`${row}${column}`])) {
      return calibrationEucsByStaff(row, column, calibrationEucs);
    } else if (group_level == "auxiliary" && Array.isArray(calibrationEucs[`${row}${column}`])) {
      return calibrationEucsByStaff(row, column, calibrationEucs);
    } else if (group_level == "manager_b" && Array.isArray(calibrationEucs[`${row}${column}`])) {
      return calibrationEucsByStaff(row, column, calibrationEucs);
    } else if (group_level == "manager_a" && Array.isArray(calibrationEucs[`${row}${column}`])) {
      return calibrationEucsByManager(row, column, calibrationEucs);
    } else {
      return null;
    }
  };

  const handleSave = (event) => {
    event.preventDefault();
    put(currentPageJsonPath(group_level), {body: {calibration: calibrationEucs}}).then((response) => {
      if (response.ok) {
        const result_json = response.json;
        result_json.then(result => {
          setSuccessSaveMessage(result.message);
          setCalibrationEucs(result.to_calibration_euc);
        });
      }
    });
  }

  const handleSaveAndFinalize = (event) => {
    event.preventDefault();
    put(currentPageJsonPath(group_level), {body: {finalize: true, calibration: calibrationEucs}}).then((response) => {
      if (response.ok) {
        const result_json = response.json;
        result_json.then(result => {
          setFinalizeMessage((currentFinalizeMessage) => {
            return {accepted: result.accepted, message: result.message}
          });
          setCalibrationEucs(result.to_calibration_euc);
        });
      }
    });
  }

  const handleSaveAndSwitch = (event) => {
    event.preventDefault();
    put(currentPageJsonPath(group_level), {body: {calibration: calibrationEucs}}).then((response) => {
      if (response.ok) {
        const result_json = response.json;
        result_json.then(result => {
          window.location.href = result.calibration_table_sessions_path;
        });
      }
    });
  }

  const handleClose = () => {
    setFinalizeMessage((currentFinalizeMessage) => {
      return {accepted: currentFinalizeMessage.accepted, message: ""}
    });
  }

  function finalizeButton() {
    return <div className="col-4">
      <button onClick={handleSaveAndFinalize} className="btn btn-warning">{calibrationLabels().finalize}</button>
    </div>;
  }

  return (
  <DndProvider backend={HTML5Backend}>
    {createPortal(
      <>
        <button className="nav-link active" type="button" role="tab" aria-controls="nav-square" aria-selected="true">{calibrationLabels().nine_square_grid}</button>
        <button onClick={handleSaveAndSwitch} className="nav-link" type="button" role="tab" aria-controls="nav-table" aria-selected="false">{calibrationLabels().table_grid}</button>
      </>,
      document.getElementById("switch-nav")
    )}
    <div className="row">
      <div className="col-2 text-end">
        <span className="fs-6">{group_level == "staff" ? calibrationLabels().work_load_pct : (group_level == "manager_b" ? calibrationLabels().professional_capability : calibrationLabels().performance)}</span>
        <br />
        {calibrationLabels().beyond_standard}
      </div>
      <GradeSquare row={1} column={1} calibration_template={calibrationTemplate} onDrop={handleOnDrop} onCountingGradePeople={handleCountingGradePeople} group_level={group_level}>
        {renderPersonCards(1, 1, group_level)}
      </GradeSquare>
      <GradeSquare row={1} column={2} calibration_template={calibrationTemplate} onDrop={handleOnDrop} onCountingGradePeople={handleCountingGradePeople} group_level={group_level}>
        {renderPersonCards(1, 2, group_level)}
      </GradeSquare>
      <GradeSquare row={1} column={3} calibration_template={calibrationTemplate} onDrop={handleOnDrop} onCountingGradePeople={handleCountingGradePeople} group_level={group_level}>
        {renderPersonCards(1, 3, group_level)}
      </GradeSquare>
    </div>
    <div className="row">
      <div className="col-2 text-end">
        <span className="fs-6">{group_level == "staff" ? calibrationLabels().work_load_pct : (group_level == "manager_b" ? calibrationLabels().professional_capability : calibrationLabels().performance)}</span>
        <br />
        {calibrationLabels().standards_compliant}
      </div>
      <GradeSquare row={2} column={1} calibration_template={calibrationTemplate} onDrop={handleOnDrop} onCountingGradePeople={handleCountingGradePeople} group_level={group_level}>
        {renderPersonCards(2, 1, group_level)}
      </GradeSquare>
      <GradeSquare row={2} column={2} calibration_template={calibrationTemplate} onDrop={handleOnDrop} onCountingGradePeople={handleCountingGradePeople} group_level={group_level}>
        {renderPersonCards(2, 2, group_level)}
      </GradeSquare>
      <GradeSquare row={2} column={3} calibration_template={calibrationTemplate} onDrop={handleOnDrop} onCountingGradePeople={handleCountingGradePeople} group_level={group_level}>
        {renderPersonCards(2, 3, group_level)}
      </GradeSquare>
    </div>
    <div className="row">
      <div className="col-2 text-end">
        <span className="fs-6">{group_level == "staff" ? calibrationLabels().work_load_pct :  (group_level == "manager_b" ? calibrationLabels().professional_capability : calibrationLabels().performance)}</span>
        <br />
        {calibrationLabels().below_standard}
      </div>
      <GradeSquare row={3} column={1} calibration_template={calibrationTemplate} onDrop={handleOnDrop} onCountingGradePeople={handleCountingGradePeople} group_level={group_level}>
        {renderPersonCards(3, 1, group_level)}
      </GradeSquare>
      <GradeSquare row={3} column={2} calibration_template={calibrationTemplate} onDrop={handleOnDrop} onCountingGradePeople={handleCountingGradePeople} group_level={group_level}>
        {renderPersonCards(3, 2, group_level)}
      </GradeSquare>
      <GradeSquare row={3} column={3} calibration_template={calibrationTemplate} onDrop={handleOnDrop} onCountingGradePeople={handleCountingGradePeople} group_level={group_level}>
        {renderPersonCards(3, 3, group_level)}
      </GradeSquare>
    </div>
    <div className="row">
      <div className="col-2">
      </div>
      <div className="col-3 border-top border-white border-top-2">
        <span className="fs-6">
          {group_level == "staff" ? calibrationLabels().work_quality_pct : (group_level == "manager_b" ? calibrationLabels().management_capability : calibrationLabels().professional_capability)}
          &nbsp;{(group_level == "staff" || group_level == "manager_b") ? null : `/ ${calibrationLabels().management_capability}`}
        </span>
        <br />
        {calibrationLabels().below_standard}
      </div>
      <div className="col-3 border-top border-white border-top-2">
        <span className="fs-6">
          {group_level == "staff" ? calibrationLabels().work_quality_pct : (group_level == "manager_b" ? calibrationLabels().management_capability : calibrationLabels().professional_capability)}
          &nbsp;{(group_level == "staff" || group_level == "manager_b") ? null : `/ ${calibrationLabels().management_capability}`}
        </span>
        <br />
        {calibrationLabels().standards_compliant}
      </div>
      <div className="col-3 border-top border-white border-top-2">
        <span className="fs-6">
          {group_level == "staff" ? calibrationLabels().work_quality_pct : (group_level == "manager_b" ? calibrationLabels().management_capability : calibrationLabels().professional_capability)}
          &nbsp;{(group_level == "staff" || group_level == "manager_b") ? null : `/ ${calibrationLabels().management_capability}`}
        </span>
        <br />
        {calibrationLabels().beyond_standard}
      </div>
    </div>
    <div className="row mt-2">
      <div className="col-2 text-end">
        <button onClick={handleSave} className="btn btn-primary">{calibrationLabels().save}</button>
      </div>
      {canFinalize && finalizeButton()}
    </div>
    {successSaveMessage && createPortal(
      <div className="mb-0 alert alert-primary alert-dismissible fade show" role="alert">
        {successSaveMessage}
        <button onClick={() => setSuccessSaveMessage("")} aria-label="Close" className="btn-close" type="button"></button>
      </div>,
      document.getElementById("flash-root")
    )}
    {finalizeMessage.message && createPortal(
      <FinalizeConfirmDialog
        accepted={finalizeMessage.accepted}
        message={finalizeMessage.message}
        onClose={handleClose}
      />,
      document.getElementById("coreuiModal")
    )}
  </DndProvider>
  );
}

export default CalibrationPanel;
