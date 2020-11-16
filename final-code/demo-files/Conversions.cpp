/*
  Conversions.cpp

  Demo program to test converting byte arrays
  to shorts.
*/

#include<iostream>

int main () {
  char charA = 1;
  char charB = 0;

  int intCastA = (int) (u_char) charA;
  int intCastB = (int) (u_char) charB;

  std::cout << intCastA * 256 + intCastB << std::endl;
  return 0;
}

