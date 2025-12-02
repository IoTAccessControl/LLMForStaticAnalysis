#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define FLOATS_BETWEEN_BUG 20
int cnt = 0;

int count(float start, float end) {
    for (float cur = start; cur != end; cnt++) {
        unsigned temp;
        memcpy(&temp, &cur, sizeof(float));
        temp++;
        memcpy(&cur, &temp, sizeof(float));
    }

    if (cnt <= FLOATS_BETWEEN_BUG) {
        printf("BUG triggered!\n");
        return -1;
    }
}

int main(int argc, char **argv) {
    float start = atof(argv[1]), end = atof(argv[2]);
    // __assume__(start < end);
    count(start, end);
}