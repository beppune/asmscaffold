
;	Program:	title
;	Author:		author
;	Updated:	date
;
;	compile with:
;		nasm nasm_flags -o base.o script_name
;		ld ld_flags -o base base.o
;

section .data

section .bss

section .text

_start:

	nop

Exit:	mov eax, 1		; sys_exit
		mov ebx, 0		; exit with value 0
		int 80h			; kernel

	nop

