import 'dart:async';

bool viewTimer = false;
bool viewAuthenticationFail = false;
int countdownSeconds = 60;
Timer? timer;

void countdown() {
  countdownSeconds--;
  if (countdownSeconds == 0) {
    viewTimer = false;
    timer?.cancel();
    countdownSeconds = 60;
  }
}
