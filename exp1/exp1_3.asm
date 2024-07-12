.text
main:
    li $v0, 5 # 读入数组长度n
    syscall
    move $t0, $v0 # t0中的值为n

    move $a0, $t0
    sll $a0, $a0, 2 # 调用的传入参数为n*4，左移2位
    li $v0, 9 # 系统调用，开辟长度为n的空间，a=new int[n]
    syscall
    move $s0, $v0 # 数组首地址为s0

    li $t1, 0 # 循环次数计数i，初始为0

scanf_loop:
    bge $t1, $t0, reverse_ready # i>=n退出循环，i<n继续循环
    li $v0, 5 # 系统调用，读入整数
    syscall
    sll $t2, $t1, 2 # t2=t1*4,偏移地址
    add $t2, $s0, $t2 # 加上首地址，t2为a[i]地址
    sw $v0, 0($t2) # 存放a[i]
    addi $t1, $t1, 1 # i++
    j scanf_loop # 下一轮循环

reverse_ready:
    li $t1, 0 # 循环次数计数i，初始为0
    srl $t2, $t0, 1 # n右移1位，循环次数上限为n/2

reverse_loop:
    bge $t1, $t2, printf_ready # i>=n/2退出循环，i<n/2继续循环
    sll $t3, $t1, 2 # t3=i*4，a[i]的偏移量
    add $t3, $s0, $t3 # t3为a[i]的地址
    lw $t4, 0($t3) # t4=a[i]
    addi $t4, $t4, 1 # t4=a[i]+1

    sub $t5, $t0, $t1 # t5=n-i
    subi $t5, $t5, 1 # t5=n-i-1
    sll $t5, $t5, 2 # t5=(n-i-1)*4，a[n-i-1]的偏移量
    add $t5, $s0, $t5 # t5为a[n-i-1]的地址
    lw $t6, 0($t5) # t6=a[n-i-1]
    addi $t6, $t6, 1 # t6=a[n-i-1]+1

    sw $t6, 0($t3) # a[i]=a[n-i-1]+1
    sw $t4, 0($t5) # a[n-i-1]=a[i]+1
    addi $t1, $t1, 1 # i++
    j reverse_loop # 下一轮循环

printf_ready:
    li $t1, 0 # 循环次数计数i，初始为0

printf_loop:
    bge $t1, $t0, exit # i>=n退出循环，i<n继续循环
    sll $t2, $t1, 2 # t2=i*4
    add $t2, $s0, $t2 # t2为a[i]地址
    lw $a0, 0($t2) # a[i]装入到参数a0
    li $v0, 1 # 系统调用，打印整数
    syscall
    addi $t1, $t1, 1 # i++
    j printf_loop # 下一轮循环

exit:
    li $v0, 10 # 系统调用，退出程序
    syscall