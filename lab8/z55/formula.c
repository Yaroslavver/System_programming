#include <math.h>
#define M_PI 3.14159265358979323846
double exact_value(double x) {
    return (pow(M_PI, 2)/8) - (M_PI/4*fabs(x));
}

double power(double x, int exponent) {
    return pow(x, exponent);
}