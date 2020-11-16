/*
  Conversions.cpp

  Demo program to test converting byte arrays
  to shorts.
*/

#include<iostream>

int main () {
  // Should be
  // 255, 10, 360, 270, 330
  char packetBuffer[] = {0, -1, 0, 10, 1, 104, 1, 14, 1, 74};

  int reconstructedValues[5] = { 0 };

  for (int i=0; i<10; i+=2) {
    int intCast1 = (int) (u_char) packetBuffer[i];
    int intCast2 = (int) (u_char) packetBuffer[i+1];

    reconstructedValues[i/2] = intCast1 * 256 + intCast2;
  }

  for (int i=0; i<5; i++) {
    std::cout << reconstructedValues[i] << ", ";
  }
  std::cout << std::endl;

  return 0;
}

