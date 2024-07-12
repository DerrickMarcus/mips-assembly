#include "stdio.h"
/*
  二分插入排序：通过二分查找找到插入位置，然后将元素插入到指定位置。
*/

// 统计待排序数据的比较次数
int compare_count = 0;

// 递归二分查找插入位置
int binary_search(int v[], int left, int right, int n)
{
    if (left > right)
        return left; // 递归边界，此处不统计比较次数
    int mid = (left + right) >> 1;
    compare_count++; // 统计比较次数
    if (v[mid] > v[n])
        return binary_search(v, left, mid - 1, n);
    else
        return binary_search(v, mid + 1, right, n);
}

// 将新的元素插入到指定位置，并将后续元素后移
void insert(int *v, int k, int n)
{
    int i;
    int tmp = v[n];
    for (i = n - 1; i >= k; i--)
    {
        v[i + 1] = v[i];
    }
    v[k] = tmp;
}

void binary_insertion_sort(int v[], int n)
{
    int i;
    for (i = 1; i < n; i++)
    { // 从第二个元素开始，依次插入到前面已经排好序的序列中
        int place = binary_search(v, 0, i - 1, i);
        insert(v, place, i);
    }
}

int main()
{
    FILE *infile, *outfile;
    int buffer[1001];
    infile = fopen("a.in", "rb");
    fread(buffer, 4, 1001, infile);
    fclose(infile);
    int N = buffer[0];
    binary_insertion_sort(&(buffer[1]), N);
    buffer[0] = compare_count;
    outfile = fopen("a.out", "wb");
    fwrite(buffer, 4, N + 1, outfile);
    fclose(outfile);
    return 0;
}
