# include <stdio.h>

int main() {
    long num = 2710058798;
    int sum = 0;
    while(num > 0){
        sum += num % 10;
        num = num / 10;
    }
    printf("%d\n", sum);
    return 0;
}