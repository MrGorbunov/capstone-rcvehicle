/*
  Conversions.cpp

  Demo program to test converting byte arrays
  to shorts.
*/

#include<iostream>
#include<math.h>

/*
 * PWM Logarithmic Value
 * Put values from 0-256 (linearly) and it will return
 * values on a logarithmic scale from 0-1024
 */
int pwmLogarithmicValue (int inputVal) {
  if (inputVal <= 1)
    return 0;

  double power = inputVal * 5 / 128;
  return (int) exp2(power);
}

int main () {
  for (int i=0; i<=10; i++) {
    double input = i * 25.6;
    std::cout << pwmLogarithmicValue((int) input) << std::endl;
  }

  return 0;
}

