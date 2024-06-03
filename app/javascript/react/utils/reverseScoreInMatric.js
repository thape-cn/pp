export function reverseScoreInMatric(score, reverse_metric_name) {
  // Don't forget add Ruby code like reverse_5_metric also
  if (reverse_metric_name == 'reverse_5_metric') {
    if (score >= 4.5 && score <= 5) {
      return "A+";
    } else if (score >= 3.5 && score < 4.5) {
      return "A";
    } else if (score >= 2.5 && score < 3.5) {
      return "B";
    } else if (score >= 1.5 && score < 2.5) {
      return "C";
    } else if (score >= 1.0 && score < 1.5) {
      return "D";
    } else {
      return "N/A";
    }
  } else {
    return null;
  }
}
