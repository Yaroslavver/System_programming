;  fasm z5.asm; ld z5.o -lc -lncurses -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o a.out; ./a.out

format elf64
public _start
include 'func.asm'
extrn printf

section '.data' writable
t10000 dq 10000
r dq 0
s dq 0
x dq 0.75 
m dq 1
n dq 0
e dq 0.000001
buf db "%.10f", 0xa, 0

section '.bss' writable
t rq 1
z rq 1
buffer rb 32



section '.text' executable

_start:
  
  mov qword[t], 8
  fldpi
  fldpi
  fmulp
  fild [t]
  fdivp

  mov qword[t], 4
  fldpi
  fild [t]
  fdivp
  fld [x]
  fabs
  fmulp
  fsubp
  fstp [z]



_loop:
  inc qword[n]
  fild [m]; m = 2*n + 1
  fld [x]
  fmulp
  fcos ; st(0) = cos(st(0))
  fild [m]
  fild [m]
  fmulp
  fdivp; st(1) = cos(mx), st(0) = m^2
  fld [s]
  faddp
  fstp [s] ; в s добавляем

  

  fld [z]
  fld [s]
  fsubp
  fabs; модуль st(0)
  fld [e]
  fcompp; сравн. st(0) и st(1)
  fstsw ax
  sahf
  ja _finish
  add qword[m], 2
  jmp _loop

_finish:
  mov rax, 1
  mov rdi, buf
  movq xmm0, [z]
  call printf

  mov rax, 1
  mov rdi, buf
  movq xmm0, [s]
  call printf

  mov rax, [n]
  mov rsi, buffer
  call number_str
  call print_str
  call new_line
  
  
  call exit

