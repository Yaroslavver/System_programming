#include<stdio.h>

unsigned long * create_array(unsigned long);
unsigned long * free_memory();
unsigned long * edit();

int main(){
  unsigned long *p, n;
  scanf("%ld",&n);
  p = create_array(n);
  edit();
  //p[0] = 8;
  //p[1] = 7;
  //p[2] = p[0]+p[1];
  printf("%ld\n",p[0]);
  printf("%ld\n",p[1]);
  free_memory();
  return 0;

}