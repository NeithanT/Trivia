nasm -f elf32 src/main.asm -o main.o
nasm -f elf32 src/showIntro.asm -o showIntro.o
nasm -f elf32 src/game.asm -o game.o
nasm -f elf32 src/addQuestion.asm -o addQuestion.o
nasm -f elf32 src/readQuestion.asm -o readQuestion.o
nasm -f elf32 src/getQuestion.asm -o getQuestion.o
nasm -f elf32 src/getRand.asm -o getRand.o
nasm -f elf32 src/wipeFile.asm -o wipeFile.o
nasm -f elf32 src/saveScore.asm -o saveScore.o
nasm -f elf32 src/showScores.asm -o showScores.o
nasm -f elf32 src/writeString.asm -o writeString.o

ld -s -m elf_i386 main.o showIntro.o game.o addQuestion.o getQuestion.o readQuestion.o getRand.o wipeFile.o saveScore.o showScores.o writeString.o -o main io.o

./main

rm main.o showIntro.o game.o addQuestion.o getQuestion.o readQuestion.o getRand.o wipeFile.o saveScore.o showScores.o writeString.o main