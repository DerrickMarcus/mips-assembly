# 汇编大作业2024
# merge_sort.asm
.data
buffer: .space 4004 # 1001个数，缓冲区大小4004
compare_count: .word 0 # 存放值为0的一个字
input_file: .asciiz "a.in"
output_file: .asciiz "a.out"


.text
main:
    la $a0, input_file # 输入文件名地址加载到a0
    li $a1, 0 # 文件打开模式为读取，flag=0
    li $a2, 0 # mode is ignored
    li $v0, 13 # 打开文件a.in
    syscall # 若打开成功，文件描述符返回到v0

    move $a0, $v0 # 文件描述符载入到a0
    la $a1, buffer # buffer地址加载到a1
    li $a2, 4004 # 写入4004 byte
    li $v0, 14 # 读取文件a.in
    syscall
    li $v0, 16 # 关闭文件a.in
    syscall

    la $s0, buffer # buffer地址加载到s0
    lw $t0, 0($s0) # t0:N=buffer[0]
    la $t8, compare_count # t8存放compare_count地址
    lw $t9, 0($t8) # t9:compare_count=0

    # create a linked list
    li $a0, 8 # 开辟8 byte空间
    li $v0, 9 # 系统调用，int *head=new int[2]
    syscall
    move $s1, $v0 # s1存放head首地址
    sw $0, 4($s1) # head[1]=NULL，设置为0
    move $s2, $s1 # int *pointer=head，s2存放pointer地址
    li $t1, 1 # 循环次数计数idx，初始为1
create_linked_list:
    bgt $t1, $t0, create_complete # idx>N退出循环，idx<=N继续循环
    li $a0, 8 # 开辟8 byte空间
    li $v0, 9 # 系统调用
    syscall
    sw $v0, 4($s2)
    # pointer[1]=(int)new int[2]，将新开辟的数组首地址存放在pointer[1]
    lw $s2, 4($s2)
    # pointer=(int *)pointer[1]，pointer指向新开辟的数组首地址
    sll $t2, $t1, 2 # t2=4*idx
    add $t2, $s0, $t2 # t2=buffer[idx]地址
    lw $t3, 0($t2) # t3=buffer[idx]
    sw $t3, 0($s2) # pointer[0]=buffer[idx]
    sw $0, 4($s2) # pointer[1]=(int)NULL
    
    addi $t1, $t1, 1 # idx++
    j create_linked_list # 下一轮循环
    
create_complete:
    # 此时链表创建完成
    lw $a0, 4($s1) # msort参数a0=(int *)head[1]
    jal msort_ready # 调用msort
    sw $v0, 4($s1) # 返回值到head[1]
    move $s2, $s1 # pointer=head


# 开始写入文件
write_in:
    la $a0, output_file # 输出文件名地址加载到a0
    li $a1, 1 # 文件打开模式为写入，flag=1
    li $a2, 0 # mode is ignored
    li $v0, 13 # 打开文件a.out
    syscall # 若打开成功，文件描述符返回到v0

    move $a0, $v0 # 文件描述符载入到a0
    move $t7, $v0 # 保存文件描述符
    sw $t9, 0($t8) # 保存compare_count
    move $a1, $t8 # compare_count地址加载到a1
    li $a2, 4
    li $v0, 15 # fwrite(&compare_count, 4, 1, outfile)
    syscall

    move $s2, $s1 # pointer=head


# do ... while(1)
write_loop:
    lw $s2, 4($s2) # pointer=(int*)pointer[1]，指向下一个
    beq $s2, $0, write_complete # if pointer==NULL,break
    move $a0, $t7 # 文件描述符载入到a0
    move $a1, $s2 # a1=pointer
    li $a2, 4
    li $v0, 15 # fwrite(pointer, 4, 1, outfile)
    syscall
    j write_loop


write_complete:
    li $v0, 16 # 关闭文件a.out
    syscall
    li $v0, 10 # 退出
    syscall


# msort函数参数a0=*head
# 主函数传递过来的形参是(int *)head[1]，将整数型的head[1]转换为指向下一个节点数组的地址
# 最后返回值赋给head[1]
# 为避免混淆，形参的head称为phead
msort_ready:
    lw $t2, 4($a0) # t2=phead[1]
    beq $t2, $0, msort_return_head # if phead[1]==NULL,return
    move $s3, $a0 # s3:stride_2_pointer,phead
    move $s4, $a0 # s4:stride_1_pointer,phead
    j msort_loop

msort_return_head:
    move $v0, $a0 # return phead
    jr $ra


# do ... while(1)
msort_loop:
    lw $t3, 4($s3) # t3=(int *)stride_2_pointer[1]
    beq $t3, $0, msort_recursion # if t3==NULL,break
    lw $s3, 4($s3)
    # stride_2_pointer=(int *)stride_2_pointer[1]，指向下一个
    
    lw $t3, 4($s3) # t3=(int *)stride_2_pointer[1]
    beq $t3, $0, msort_recursion # if t3==NULL,break
    lw $s3, 4($s3)
    # stride_2_pointer=(int *)stride_2_pointer[1]，指向下一个
    
    lw $s4, 4($s4)
    # stride_1_pointer=(int *)stride_1_pointer[1]，指向下一个
    j msort_loop


msort_recursion:
    lw $s3, 4($s4) # stride_2_pointer=(int *)stride_1_pointer[1]
    sw $0, 4($s4) # stride_1_pointer[1]=(int)NULL;

    addi $sp, $sp, -16 # 栈指针向下移动16
    sw $ra, 12($sp) # 保存ra
    sw $a0, 8($sp) # 保存a0=phead
    sw $s3, 4($sp) # 保存s3=stride_2_pointer
    sw $s4, 0($sp) # 保存s4=stride_1_pointer
    jal msort_ready # msort(head)，参数a0不变

    lw $a0, 4($sp) # 第二个递归参数a0，取出stride_2_pointer
    sw $v0, 4($sp) # 保存第一个递归返回值v0=l_head
    jal msort_ready # msort(stride_2_pointer)

    move $a2, $v0 # merge参数a2=r_head
    lw $a1, 4($sp) # merge参数a1=l_head
    jal merge_ready # 调用merge(l_head,r_head)
    lw $ra, 12($sp) # 恢复ra
    addi $sp, $sp, 16 # 恢复栈指针位置
    jr $ra


# merge函数参数a1=*l_head，a2=*r_head
merge_ready:
    # 为避免混淆，merge函数体内的head称为nhead
    li $a0, 8
    li $v0, 9 # *nhead=new int[2]，v0为nhead地址
    syscall
    move $t1, $v0 # t1=nhead
    sw $a1, 4($t1) # nhead[1]=l_head
    move $s5, $t1 # s5:p_left,=nhead
    move $s6, $a2 # s6:p_right,=r_head

merge_loop_outer:
    j merge_loop_inner1


merge_loop_inner1:
    lw $t2, 4($s5) # t2=p_left[1]
    beq $t2, $0, merge_continue # if p_left[1]==NULL,break
    addi $t9, $t9, 1 # compare_count++
    lw $t3, 0($t2) # t3=((int *)p_left[1])[0]
    lw $t4, 0($s6) # t4=p_right[0]
    bgt $t3, $t4, merge_continue # if ((int *)p_left[1])[0]>p_right[0],break
    lw $s5, 4($s5) # p_left=(int *)p_left[1]，指向下一个
    j merge_loop_inner1 # 下一轮内循环1


merge_continue:
    lw $t2, 4($s5) # t2=p_left[1]
    beq $t2, $0, merge_break # if p_left[1]==NULL,break
    move $t3, $s6 # t3:p_right_temp,=p_right
    j merge_loop_inner2


merge_break:
    sw $s6, 4($s5) # p_left[1]=(int)p_right
    j merge_end # break


merge_loop_inner2:
    lw $t4, 4($t3) # t4=p_right_temp[1]
    beq $t4, $0, merge_loop_insert # if p_right_temp[1]==(int)NULL,break
    addi $t9, $t9, 1 # compare_count++
    lw $t5, 0($t4) # t5=((int *)p_right_temp[1])[0]
    lw $t6, 4($s5) # t6=p_left[1]
    lw $t7, 0($t6) # t7=((int *)p_left[1])[0]
    bgt $t5, $t7, merge_loop_insert # if ((int *)p_right_temp[1])[0]>((int *)p_left[1])[0],break
    lw $t3, 4($t3) # p_right_temp=(int *)p_right_temp[1]指向下一个
    j merge_loop_inner2 # 下一轮内循环2


merge_loop_insert:
    lw $t4, 4($t3) # t4:int *temp_right_pointer_next,(int *)p_right_temp[1]
    lw $t5, 4($s5) # t5=p_left[1]
    sw $t5, 4($t3) # p_right_temp[1]=p_left[1]
    sw $s6, 4($s5) # p_left[1]=(int)p_right
    move $s5, $t3 # p_left=p_right_temp
    move $s6, $t4 # p_right=temp_right_pointer_next
    beq $s6, $0, merge_end # if p_right==NULL,break
    j merge_loop_outer # 下一轮外循环


merge_end:
    lw $v0, 4($t1) # return (int*)rv,=nhead[1]
    jr $ra
