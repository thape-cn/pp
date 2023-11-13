import React from 'react';
import { useDrop } from 'react-dnd';
import {calibrationLabels} from "../utils/tableHeader";
import {calibrateGrade, calibrateGradeQuota, calibrateStaffRate, calibrateManagerRate, calibrateClass} from "../utils/grade_help";

function GradeSquare({ row, column, calibration_template, children, onDrop, onCountingGradePeople, group_level }) {
  const grade = calibrateGrade(row, column);
  const grade_quota = calibrateGradeQuota(row, column, calibration_template);
  const enforce_distribute = calibration_template.enforce_distribute;

  const [{ isOver }, drop] = useDrop(() => ({
    accept: 'personCard',
    drop: item => {
      if ((item.group_level == "manager" && item.person_row == row) || item.group_level == "staff" || group_level == "auxiliary") {
        onDrop(item, row, column);
      }
    },
    collect: monitor => {
      const item = monitor.getItem();
      const isAllowed = item && ((item.group_level == "manager" && item.person_row == row) || item.group_level == "staff" || group_level == "auxiliary");
      return {
        isOver: monitor.isOver() && isAllowed,
      };
    },
  }));

  return (
    <div
      ref={drop}
      className={calibrateClass(group_level, row, column, grade, isOver)}
    >
      {grade} &nbsp;
      {enforce_distribute ? calibrationLabels().enforce : calibrationLabels().encourage}{grade_quota && grade_quota.grade_title}：{grade_quota && grade_quota.lower_quota} 人 &nbsp;
      {calibrationLabels().current_people}：{onCountingGradePeople(row, column)} 人
      <div className="p-2">
        {children}
      </div>
    </div>
  );
}

export default GradeSquare;
