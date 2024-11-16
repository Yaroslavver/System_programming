#include <stdio.h>

int main() {
    int n;
    scanf("%d", &n);
    for (int i = 1; i <= n; i++) {
        int q1 = i % 100;
        q1 /= 10;
        int q2 = i % 10;
        if (q1 != 0 && q2 != 0) {
            if (i % q1 == 0 && i % q2 == 0) {
                printf("%d\n", i);
            }
        }
    }
    return 0;
}