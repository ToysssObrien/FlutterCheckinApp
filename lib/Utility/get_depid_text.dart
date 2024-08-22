String getDepidText(String? depid) {
  switch (depid) {
    case '000':
      return 'แผนก0';
    case '111':
      return 'แผนก1';
    case '222':
      return 'แผนก2';
    case '333':
      return 'แผนก3';
    case '444':
      return 'แผนก4';
    case '555':
      return 'แผนก5';
    case '666':
      return 'แผนก6';
    case '777':
      return 'แผนก7';
    case '888':
      return 'แผนก8';
    case '999':
      return 'แผนก9';
    default:
      return 'ไม่ทราบแผนกฯ';
  }
}
