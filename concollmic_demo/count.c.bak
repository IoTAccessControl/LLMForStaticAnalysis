#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define FLOATS_BETWEEN_BUG 20
int cnt = 0;

int count(float start, float end) {
    for (float cur = start; cur != end; cnt++) {
        fprintf(stderr, "[src/count.c] enter count 1\n");
        unsigned temp;
        memcpy(&temp, &cur, sizeof(float));
        temp++;
        memcpy(&cur, &temp, sizeof(float));
        // fprintf(stderr, "[src/count.c] exit count 1\n");
    }

    if (cnt <= FLOATS_BETWEEN_BUG) {
        fprintf(stderr, "[src/count.c] enter count 2\n");
        printf("BUG triggered!\n");
        return -1;
        // fprintf(stderr, "[src/count.c] exit count 2\n");
    }
}

int main(int argc, char **argv) {
    fprintf(stderr, "[src/count.c] enter main 1\n");
    float start = atof(argv[1]), end = atof(argv[2]);
    // __assume__(start < end);
    count(start, end);
    // fprintf(stderr, "[src/count.c] exit main 1\n");
}