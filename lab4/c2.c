#include <stdio.h>

long func(long n) {
    long new = 0;
    int counter = 0;
    while (n > 0) {
        int a = n % 10;
        for (int i=0; i < counter; i++){
            a *= 10;
        }
        new += a;
        counter += 2;
        n /= 10;
    }
    new *= 10;
    return new;
}

int main() {
    long n;
    scanf("%ld", &n);
    long new = func(n);
    printf("%ld\n", new);
    return 0;
}
