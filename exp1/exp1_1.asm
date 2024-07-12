.data
buffer: .space 8
input_file: .asciiz "a.in"
output_file: .asciiz "a.out"

.text
main:
    la $a0, input_file # 输入文件名地址加载到a0
    li $a1, 0 # 文件打开模式为读取，flag=0
    li $a2, 0 # mode is ignored 设置为0就可以了
    li $v0, 13 # 13为打开文件的 syscall 编号
    syscall # 若打开成功，文件描述符返回到v0

    move $a0, $v0 # 文件描述符载入到a0
    la $a1, buffer # buffer地址加载到a1
    li $a2, 8 # 读取8 byte，2个整数
    li $v0, 14 # 14为读取文件的 syscall 编号
    syscall
    li $v0, 16 # 16为关闭文件的 syscall 编号
    syscall

    la $a0, output_file # 输出文件名地址加载到a0
    li $a1, 1 # 文件打开模式为写入，flag=1
    li $a2, 0 # mode is ignored 设置为0就可以了
    li $v0, 13 # 13为打开文件的 syscall 编号
    syscall # 若打开成功，文件描述符返回到v0

    move $a0, $v0 # 文件描述符载入到a0
    la $a1, buffer # buffer地址加载到a1
    li $a2, 8 # 写入8 byte
    li $v0, 15 # 15为写入文件的 syscall 编号
    syscall
    li $v0, 16 # 16为关闭文件的 syscall 编号
    syscall

    li $v0, 5 # 5为读取整数的 syscall 编号
    syscall
    addi $a0, $v0, 10 # i=i+10
    li $v0, 1 # 1为打印整数的 syscall 编号
    syscall
