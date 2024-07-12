#include "stdio.h"

int Hanoi(int n)
{
    if (n == 1) {   // 基准情形
        return 1;
    } else {        // 递归情形
        return 2 * Hanoi(n - 1) + 1;
    }
}

int main()
{
    int n;
    scanf("%d", &n);
    printf("%d", Hanoi(n));
    return 0;
}