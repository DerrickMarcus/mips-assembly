# 汇编大作业2024
# binary_insert_sort.asm
.data
buffer: .space 4004 # 1001个数，缓冲区大小4004
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
    li $a2, 4004
    li $v0, 14 # 读取文件a.in
    syscall
    li $v0, 16 # 关闭文件a.in
    syscall

    la $a0, buffer # buffer地址加载到a0
    lw $a1, 0($a0) # binary_insertion_sort参数a1=N=buffer[0]，排序元素个数
    addi $a0, $a0, 4 # binary_insertion_sort参数a0=buffer[1]地址，即v[0]地址
    li $t0, 0 # compare_count=0
    jal binary_insertion_sort_ready # 调用binary_insertion_sort


exit:
    la $s0, buffer # buffer地址加载到s0
    lw $t1, 0($s0) # t1临时保存个数N
    sw $t0, 0($s0) # buffer[0]=compare_count

    la $a0, output_file # 输出文件名地址加载到a0
    li $a1, 1 # 文件打开模式为写入，flag = 1
    li $a2, 0 # mode is ignored
    li $v0, 13 # 打开文件a.out
    syscall # 若打开成功，文件描述符返回到v0

    move $a0, $v0 # 文件描述符载入到a0
    la $a1, buffer # buffer地址加载到a1
    addi $t1, $t1, 1 # t1=N+1
    sll $a2, $t1, 2 # a2=4*t1=4*(N+1)，写入的字节数
    li $v0, 15 # 写入文件a.out
    syscall
    li $v0, 16 # 关闭文件a.out
    syscall
    li $v0, 10 # 退出
    syscall


# binary_insort_sort函数参数：a0=v[0]地址，a1=序列长度N
binary_insertion_sort_ready:
    addi $sp, $sp, -12 # 栈指针向下移动12
    sw $ra, 8($sp) # 保存ra
    sw $a0, 4($sp) # 保存a0
    sw $a1, 0($sp) # 保存a1
    li $t1, 1 # 循环次数计数i，初始为1


binary_insertion_sort_loop:
    bge $t1, $a1, binary_insertion_sort_end # i>=N退出循环，i<N继续循环

    move $a1, $t1 # binary_search参数a1=i
    li $a2, 0 # binary_search参数a2=left=0
    addi $a3, $t1, -1 # binary_search参数a3=right=i-1
    jal binary_search # 调用binary_search
    lw $a1, 0($sp) # 恢复a1（可能被binary_search修改）
    lw $a0, 4($sp) # 恢复a0（可能被binary_search修改）

    move $a3, $v0 # insert参数a3=place，即插入位置k
    move $a2, $t1 # insert参数a2=i
    jal insert_ready # 调用insert
    lw $a0, 4($sp) # 恢复a0（可能被insert修改）

    addi $t1, $t1, 1 # i++
    j binary_insertion_sort_loop # 下一轮循环


binary_insertion_sort_end:
    lw $a1, 0($sp) # 恢复a1
    lw $a0, 4($sp) # 恢复a0
    lw $ra, 8($sp) # 恢复ra
    addi $sp, $sp, 12 # 恢复栈指针位置
    jr $ra # 返回


# binary_search函数参数：a0=v[0]地址，a1为待插入元素下标i，a2为left，a3为right
binary_search:
    addi $sp, $sp, -20 # 栈指针向下移动20
    sw $ra, 16($sp) # 保存ra
    sw $a0, 12($sp) # 保存a0
    sw $a1, 8($sp) # 保存a1
    sw $a2, 4($sp) # 保存a2
    sw $a3, 0($sp) # 保存a3

    bgt $a2, $a3, binary_search_return # left>right,return left
    add $t2, $a2, $a3 # t2=left+right
    srl $t2, $t2, 1 # t2=mid
    addi $t0, $t0, 1 # compare_count++

    sll $t3, $t2, 2 # t3=4*mid
    add $t3, $a0, $t3 # t3=v[mid]的地址
    lw $t4, 0($t3) # t4=v[mid]
    sll $t5, $a1, 2 # t5=4*i
    add $t5, $a0, $t5 # t5=v[i]的地址
    lw $t6, 0($t5) # t6=v[i]
    bgt $t4, $t6, binary_search_continue_left # v[mid]>v[i]
    j binary_search_continue_right # v[mid]<=v[i]


binary_search_return:
    move $v0, $a2 # return left
    j binary_search_end


# binary_search(v, left, mid - 1, i)
binary_search_continue_left:
    addi $a3, $t2, -1 # right=mid-1
    j binary_search_recursion

# binary_search(v, mid + 1, right, i)
binary_search_continue_right:
    addi $a2, $t2, 1 # left=mid+1
    j binary_search_recursion

# 开始递归
binary_search_recursion:
    jal binary_search


binary_search_end:
    lw $a3, 0($sp) # 恢复a3
    lw $a2, 4($sp) # 恢复a2
    lw $a1, 8($sp) # 恢复a1
    lw $a0, 12($sp) # 恢复a0
    lw $ra, 16($sp) # 恢复ra
    addi $sp, $sp, 20 # 恢复栈指针位置
    jr $ra # 返回


# insert函数参数：a0为v[0]地址，a2为待插入元素下标i，a3为插入位置k
insert_ready:
    addi $sp, $sp, -16 # 栈指针向下移动16
    sw $ra, 12($sp) # 保存ra
    sw $a0, 8($sp) # 保存a0
    sw $a2, 4($sp) # 保存a2
    sw $a3, 0($sp) # 保存a3
    sll $t2, $a2, 2 # t2=4*i
    add $t2, $a0, $t2 # t2=v[i]的地址
    lw $t3, 0($t2) # t3=v[i]=tmp
    addi $t4, $a2, -1 # 循环次数计数j，初始为i-1


insert_loop:
    blt $t4, $a3, insert_end # j<k退出循环，j>=k继续循环
    sll $t5, $t4, 2 # t5=4*j
    add $t5, $a0, $t5 # t5=v[j]的地址
    lw $t6, 0($t5) # t6=v[j]
    sw $t6, 4($t5) # v[j+1]=v[j]
    addi $t4, $t4, -1 # j--
    j insert_loop # 下一轮循环


insert_end:
    sll $t5, $a3, 2 # t5=4*k
    add $t5, $a0, $t5 # t5=v[k]的地址
    sw $t3, 0($t5) # v[k]=tmp
    lw $a3, 0($sp) # 恢复a3
    lw $a2, 4($sp) # 恢复a2
    lw $a0, 8($sp) # 恢复a0
    lw $ra, 12($sp) # 恢复ra
    addi $sp, $sp, 16 # 恢复栈指针位置
    jr $ra # 返回
