format ELF64
public _start

include 'func.asm'

msg db "TTaQgEqQJZdfGgqazcJpCDzwNgDdwpM", 0
length = $ - msg

_start:
    mov rcx, msg
    mov rdx, length
    .iter:
      dec rdx
      push rdx
      call print
      pop rdx
      
      cmp rdx, 0
      jne .iter
    call new_line
    call exit

print:
    mov rax, 4
    mov rbx, 1
    mov rcx, msg
    add rcx, rdx
    mov rdx, 1
    int 0x80
    ret

exit:
    mov rax, 1
    mov rbx, 0
    int 0x80