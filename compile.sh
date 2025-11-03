nasm -f elf32 showMenu.asm -o showMenu.o
nasm -f elf32 main.asm -o main.o

ld -s -m elf_i386 main.o showMenu.o -o main io.o

./main

rm main.o showMenu.o main