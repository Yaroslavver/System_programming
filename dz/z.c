#include<stdio.h>

unsigned long * create_array(unsigned long);
unsigned long * free_memory();
unsigned long * edit();
int count_prost();
int count_chet();
void get_nechet();

int main(){
  unsigned long *p, n;
  scanf("%ld",&n);
  p = create_array(n);
  //return 0;
  edit();
  get_nechet();
  printf("Четных: %i\n\n", count_chet());
  printf("Простых: %i\n\n", count_prost());
  
    int N = sizeof(p);

    for (int i = 0; i < n; i++)
    {
        printf("%ld\n",p[i]);
    }
    

  free_memory();
  return 0;

}