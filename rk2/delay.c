#include <unistd.h>
#include <math.h>
#include <stdio.h>
void mydelay(int delay){
  usleep(delay);
}
int mysin(int delay){
  double rez = sin(delay/0.01);
  return (int) (rez*5);
}