#include "stdio.h" /*

链表的归并排序的核心是将链表分成前后两段，分别排序后对两个有序链表归并，递归边界是当前链表长度为1。

！！！注意：此代码为可运行版本，目的是让大家检验自己的实验结果是否正确
！！！其中的链表节点是通过结构体实现的，实际汇编的实现中指针也是32位整数，请参考另一个版本的代码（merge_sort.cpp）

*/

// 统计待排序数据的比较次数
int compare_count = 0;

// 链表节点, 结构体实现
struct Node
{
    int value;
    Node *next;
};

// 两个有序链表合并，将右链元素插入到左链中 。
Node *merge(Node *l_head, Node *r_head)
{
    // 这里构建一个虚拟头结点，方便在第一个元素前插入。
    Node *head = new Node;
    head->next = l_head;
    Node *p_left = head;
    Node *p_right = r_head;
    do
    {
        do
        { // 寻找左链中的插入位置
            if (p_left->next == (int)NULL)
                break;
            compare_count++; // 统计比较次数
            if ((p_left->next)->value > p_right->value)
                break;
            p_left = p_left->next;
        } while (1);
        // 如果到达左链尾端，右链直接接上
        if (p_left->next == NULL)
        {
            p_left->next = p_right;
            break;
        }
        Node *p_right_temp = p_right;
        do
        { // 寻找右链待插入片段
            if (p_right_temp->next == NULL)
                break;
            compare_count++; // 统计比较次数
            if ((p_right_temp->next)->value > (p_left->next)->value)
                break;
            p_right_temp = p_right_temp->next;
        } while (1);
        // 完成插入操作
        Node *temp_right_pointer_next = p_right_temp->next;
        p_right_temp->next = p_left->next;
        p_left->next = p_right;
        p_left = p_right_temp;
        p_right = temp_right_pointer_next;
        if (p_right == NULL)
            break;
    } while (1);
    Node *rv = head->next;
    delete head;
    return rv;
}

// 归并排序主函数，先找链表中点，再分别排序，最后归并
Node *msort(Node *head)
{
    if (head->next == NULL)
        return head;
    Node *stride_2_pointer = head;
    Node *stride_1_pointer = head;
    do
    { // 通过同时进行步长为 1 和步长为 2 的跳转找中点
        if (stride_2_pointer->next == NULL)
            break;
        stride_2_pointer = stride_2_pointer->next;
        if (stride_2_pointer->next == NULL)
            break;
        stride_2_pointer = stride_2_pointer->next;
        stride_1_pointer = stride_1_pointer->next;
    } while (1);
    // 拆成两个链表分别排序 ， 再归并 。
    stride_2_pointer = stride_1_pointer->next;
    stride_1_pointer->next = NULL;
    Node *l_head = msort(head);
    Node *r_head = msort(stride_2_pointer);
    return merge(l_head, r_head);
}

int main()
{
    FILE *infile, *outfile;
    int buffer[1001];
    infile = fopen("a.in", "rb");
    fread(buffer, 4, 1001, infile);
    fclose(infile);
    int N = buffer[0];
    Node *head = new Node;
    head->next = NULL;
    Node *pointer = head;
    for (int idx = 1; idx <= N; idx++)
    {
        pointer->next = new Node;
        pointer = pointer->next;
        pointer->value = buffer[idx];
        pointer->next = NULL;
    }
    // 排序
    head->next = msort(head->next);
    // 输出到文件
    pointer = head;
    outfile = fopen("a.out", "wb");
    // 输出比较次数
    fwrite(&compare_count, 4, 1, outfile);
    do
    {
        pointer = pointer->next;
        if (pointer == NULL)
            break;
        fwrite(&(pointer->value), 4, 1, outfile);
    } while (1);
    fclose(outfile);
    // 释放链表内存
    while (head != NULL)
    {
        Node *temp = head;
        head = head->next;
        delete temp;
    }
    return 0;
}
