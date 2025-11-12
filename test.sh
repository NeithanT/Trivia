nasm -f elf32 src/showQuestions.asm -o main.o

ld -s -m elf_i386 main.o -o main io.o

./main

rm main.o main