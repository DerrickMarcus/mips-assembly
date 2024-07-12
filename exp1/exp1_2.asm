.text
main:
    li $v0, 5 # 读入i
    syscall
    move $t0, $v0 # t0中的值为i
    li $v0, 5 # 读入j
    syscall
    move $t1, $v0 # t1中的值为j

    sub $t0, $0, $t0 # 0-i，取i的相反数
    slt $t3, $t1, $0 # 若j<0则t3为1，否则为0
    beqz $t3, ready # 若t3=0，即j>=0，跳转到ready
    sub $t1, $0, $t1 # j<0，取j的相反数

# 循环前的准备
ready:
    li $t2, 0 # 循环次数计数temp，初始为0

loop:
    bge $t2, $t1, end_loop # temp>=j结束循环,temp<j继续循环
    addi $t0, $t0, 1 # i+=1
    addi $t2, $t2, 1 # temp++
    j loop # 下一轮循环

end_loop:
    move $a0, $t0
    li $v0, 1 # 打印i
    syscall
    move $v0, $t0 # 最后结果保存到v0

