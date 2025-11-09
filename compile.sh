nasm -f elf32 src/main.asm -o main.o
nasm -f elf32 src/showIntro.asm -o showIntro.o
nasm -f elf32 src/game.asm -o game.o
nasm -f elf32 src/addQuestion.asm -o addQuestion.o
nasm -f elf32 src/showQuestions.asm -o showQuestions.o
nasm -f elf32 src/readQuestion.asm -o readQuestion.o
nasm -f elf32 src/getQuestion.asm -o getQuestion.o
nasm -f elf32 src/getRand.asm -o getRand.o

ld -s -m elf_i386 main.o showIntro.o game.o addQuestion.o showQuestions.o getQuestion.o readQuestion.o -o main io.o

./main

rm main.o showIntro.o game.o addQuestion.o showQuestions.o readQuestion.o getQuestion.o getRand.o main