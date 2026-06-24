export function currentPageJsonPath(group_level, mark_score_group = null) {
  const url = new URL(window.location.href);
  const pathname = url.pathname + '.json';
  url.pathname = pathname;
  url.searchParams.append('group_level', group_level);
  if (mark_score_group) {
    url.searchParams.append('mark_score_group', mark_score_group);
  }
  return url;
}

export function signingEvaluationUserCapabilityPath(id_euc) {
  return `/staff/signing/${id_euc}?print_page=true`
}

export function evaluationUserCapabilitiesPath(id_euc) {
  return `/staff/evaluation_user_capabilities/${id_euc}.json`
}

export function userJobRolePerformancesPath(jrep_id) {
  return `/staff/user_job_role_performances/${jrep_id}.json`
}

export function finalizeCalibrationPath(calibration_session_id) {
  return `/staff/calibration_sessions/${calibration_session_id}/finalize_calibration.json`
}

export function scoreConfirmPath(user_id) {
  return `/staff/mark_scores/${user_id}/score_confirm.json${window.location.search}`
}
