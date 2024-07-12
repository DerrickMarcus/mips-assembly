.text
main:
    li $v0, 5 # 系统调用，读入n
    syscall
    move $a0, $v0 # a0中的值为n
    jal Hanoi # 调用Hanoi函数
    move $a0, $v0 # 结果保存到a0
    li $v0, 1 # 系统调用，打印结果
    syscall
    li $v0, 10 # 系统调用，退出程序
    syscall

Hanoi:
    addi $sp, $sp, -8 # 栈指针向下移动8
    sw $ra, 4($sp) # ra入栈
    sw $a0, 0($sp) # a0入栈，参数n在a0中
    slti $t0, $a0, 2 # t0=(n<2)
    beq $t0, $0, recursion # t0=0，n>=2，则跳转到递归
    li $v0, 1 # n=1, return 1
    addi $sp, $sp, 8 # 恢复栈指针位置
    jr $ra # 返回上一层函数

# n>1的情况
recursion:
    addi $a0, $a0, -1 # n=n-1
    jal Hanoi
    lw $a0, 0($sp)
    lw $ra, 4($sp) # 取出上一层函数的n和ra
    addi $sp, $sp, 8 # 恢复栈指针位置
    sll $v0, $v0, 1 # 2*Hanoi(n-1)
    addi $v0, $v0, 1 # 2*Hanoi(n-1)+1
    jr $ra # 返回上一层函数
