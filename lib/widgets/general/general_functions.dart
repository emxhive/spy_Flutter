


///Calculating percentage
num xp(num n, num d, int? dir) {
  num result;
  switch (dir) {
    case -1:
      result = d * (100 - n) / 100;
      break;
    case 1:
      result = d * (100 + n) / 100;
      break;
    default:
      result = (d * n) / 100;
      break;
  }

  return result;
}




///FontStyle
