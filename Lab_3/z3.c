#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc == 4) {
        int a = atoi(argv[1]);
        int b = atoi(argv[2]);
        int c = atoi(argv[3]);
        if (a == 0 || b == 0 || c == 0) {
            return 1;
        }
        int d = (((b/b)/a)/a)/c;
        printf("%i\n", d);
    }
    return 0;
}
