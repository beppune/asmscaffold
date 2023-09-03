
base:	base.o
	ld ld_flags -o basename basename.o

basename.o:	base.asm
	nasm nasm_flags -o base.o base.asm

clean:
	rm base base.o


