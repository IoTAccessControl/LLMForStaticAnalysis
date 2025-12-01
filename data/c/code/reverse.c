#include <stdio.h>
#include <string.h>

#define BUF_SIZE 8

int main() {
    int buffer[BUF_SIZE] = {0};
    int i, j;
    int sum = 0;
    int factor = 1;

    for (i = 0; i < BUF_SIZE; i++) {
        buffer[i] = i * 2;
    }

    for (i = 0; i < BUF_SIZE; i++) {
        for (j = i; j < BUF_SIZE; j++) {
            buffer[i] += factor * buffer[j];
        }
        factor = buffer[i] % 3 + 1;
    }

    for (i = 0; i < BUF_SIZE; i++) {
        sum += buffer[i];
    }

    printf("sum = %d\n", sum);
    return 0;
}
