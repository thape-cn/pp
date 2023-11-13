export function calibrateGrade(row, column) {
  if (row == 1 && column == 1) return "B";
  if (row == 1 && column == 2) return "A";
  if (row == 1 && column == 3) return "A+";
  if (row == 2 && column == 1) return "C";
  if (row == 2 && column == 2) return "B";
  if (row == 2 && column == 3) return "A";
  if (row == 3 && column == 1) return "D";
  if (row == 3 && column == 2) return "C";
  if (row == 3 && column == 3) return "B";
  return "";
}

export function calibrateGradeQuota(row, column, {group_level, apa_grade, b_grade, cd_grade, below_standard, standards_compliant, beyond_standard}) {
  let grade_quota = undefined;

  if (group_level == "staff") {
    grade_quota = calibrateStaffRate(row, column, apa_grade, b_grade, cd_grade);
  } else if (group_level == "auxiliary") {
    grade_quota = calibrateStaffRate(row, column, apa_grade, b_grade, cd_grade);
  } else if (group_level == "manager") {
    grade_quota = calibrateManagerRate(row, column, below_standard, standards_compliant, beyond_standard);
  }
  return grade_quota;
}

export function calibrateStaffRate(row, column, apa_grade, b_grade, cd_grade) {
  if (row == 1 && column == 1) return b_grade;
  if (row == 1 && column == 2) return apa_grade;
  if (row == 1 && column == 3) return apa_grade;
  if (row == 2 && column == 1) return cd_grade;
  if (row == 2 && column == 2) return b_grade;
  if (row == 2 && column == 3) return apa_grade;
  if (row == 3 && column == 1) return cd_grade;
  if (row == 3 && column == 2) return cd_grade;
  if (row == 3 && column == 3) return b_grade;
  return null;
}

export function calibrationEucsByStaff(row, column, calibration_eucs) {
  if (row == 1 && column == 1 || row == 2 && column == 2 || row == 3 && column == 3) {
    const b_grade_11 = calibration_eucs[`11`] ? calibration_eucs[`11`].length : 0;
    const b_grade_22 = calibration_eucs[`22`] ? calibration_eucs[`22`].length : 0;
    const b_grade_33 = calibration_eucs[`33`] ? calibration_eucs[`33`].length : 0;
    return b_grade_11 + b_grade_22 + b_grade_33;
  } else if (row == 1 && column == 2 || row == 1 && column == 3 || row == 2 && column == 3) {
    const apa_grade_12 = calibration_eucs[`12`] ? calibration_eucs[`12`].length : 0;
    const apa_grade_13 = calibration_eucs[`13`] ? calibration_eucs[`13`].length : 0;
    const apa_grade_23 = calibration_eucs[`23`] ? calibration_eucs[`23`].length : 0;
    return apa_grade_12 + apa_grade_13 + apa_grade_23
  } else if (row == 2 && column == 1 || row == 3 && column == 1 || row == 3 && column == 2) {
    const cd_grade_21 = calibration_eucs[`21`] ? calibration_eucs[`21`].length : 0;
    const cd_grade_31 = calibration_eucs[`31`] ? calibration_eucs[`31`].length : 0;
    const cd_grade_32 = calibration_eucs[`32`] ? calibration_eucs[`32`].length : 0;
    return cd_grade_21 + cd_grade_31 + cd_grade_32;
  } else {
    return null;
  }
}

export function calibrateManagerRate(row, column, below_standard, standards_compliant, beyond_standard) {
  if (row == 1 && column == 1) return below_standard;
  if (row == 1 && column == 2) return standards_compliant;
  if (row == 1 && column == 3) return beyond_standard;
  if (row == 2 && column == 1) return below_standard;
  if (row == 2 && column == 2) return standards_compliant;
  if (row == 2 && column == 3) return beyond_standard;
  if (row == 3 && column == 1) return below_standard;
  if (row == 3 && column == 2) return standards_compliant;
  if (row == 3 && column == 3) return beyond_standard;
  return null;
}

export function calibrationEucsByManager(row, column, calibration_eucs) {
  if (column >= 1 && column <= 3) {
    const row_1 = calibration_eucs[`1${column}`] ? calibration_eucs[`1${column}`].length : 0;
    const row_2 = calibration_eucs[`2${column}`] ? calibration_eucs[`2${column}`].length : 0;
    const row_3 = calibration_eucs[`3${column}`] ? calibration_eucs[`3${column}`].length : 0;
    return row_1 + row_2 + row_3
  } else {
    return null;
  }
}

function calibrateStaffClass(grade, is_over) {
  if (is_over) return "col-3 bg-secondary min-vh-22";
  if (grade == "A+") return "col-3 bg-info min-vh-22";
  if (grade == "A") return "col-3 bg-info min-vh-22";
  if (grade == "B") return "col-3 bg-primary min-vh-22";
  if (grade == "C") return "col-3 bg-warning min-vh-22";
  if (grade == "D") return "col-3 bg-warning min-vh-22";
  return "col-3 min-vh-22";
}

function calibrateManagerClass(row, column, is_over) {
  if (is_over) return "col-3 bg-secondary min-vh-22";
  if (column == "1") return "col-3 bg-warning min-vh-22";
  if (column == "2") return "col-3 bg-primary min-vh-22";
  if (column == "3") return "col-3 bg-info min-vh-22";
  return "col-3 min-vh-22";
}

export function calibrateClass(group_level, row, column, grade, is_over) {
  if (group_level == "staff") {
    return calibrateStaffClass(grade, is_over);
  } else if (group_level == "auxiliary") {
    return calibrateStaffClass(grade, is_over);
  } else {
    return calibrateManagerClass(row, column, is_over);
  }
}

export function personBadgeBgClass(group_level, work_attitude) {
  if (group_level == "staff" && work_attitude <= 1)
    return "badge link-light ms-1 rounded-pill bg-warning";
  else {
    return "badge link-light ms-1 rounded-pill bg-info";
  }
}
