# SO_First
DCL program for text encryption and decryption implemented in assembler.

# DCL
Write in assembler a program that simulates the operation of a DCL cipher machine. The DCL machine operates on a set of acceptable characters including: upper case letters of the English alphabet, numbers 1 to 9, colon, semicolon, question mark, equal sign, minor sign, majority sign, monkey. Only characters from this set can appear in the correct program parameters and in the correct program entry and exit.

The machine consists of three ciphering reels: left `L`, right `R` and inverting `T`. Reels `L` and `R` can rotate and each of them can be in one of 42 positions marked with signs from the allowed set. The machine replaces the input text with the output text by performing a permutation string for each character. If the reel `L` case is in the `l` position and the reel `R` case is in the `r` position, the machine performs the following permutation

```math
Qr^(-1)R-1Qr Ql-1L-1Ql T Ql-1LQl Qr-1RQr
```

where `L`, `R` and `T` are reel permutations given by program parameters. The encryption and decryption processes are interchangeable with each other.

`Q` permutations perform cyclic character shifts according to their ASCII codes. For example, `Q_5` replaces 1 for 5, 2 for 6, 9 for =, = for A, A for E, B for F, Z for 4, and Q = for 1, = 2 for>,? on K. Permutation `Q_1` is identity. Permutation `T` is a combination of 21 disjoint two-element cycles (`TT` assembly is identity). `X-1` means inverse permutation to `X` permutation. Permutation assembly is performed from right to left.

Before encrypting each character, the bobbin rotates one position (cyclically according to the position ASCII codes), i.e. its position changes, for example, from 1 to 2, with? to @, from A to B, from B to C, from Z to 1. If the drum reaches R so. rotational position, the drum also rotates one position. Rotational positions are L, R, T.

The encryption key is a character pair denoting the initial positions of the L and R drums.

The program adopts four parameters: L permutation, R permutation, T permutation, encryption key. The program reads encrypted or decrypted text from the standard input, and writes the result to the standard output. After processing the entire input, the program ends with a code of 0. The program should check the correctness of parameters and input data, and after detecting an error should immediately end with code 1. Reading and writing should take place in blocks, not character by character.

The examples attached to the task consist of three files. The *.key file contains program call parameters, and the *.a and *.b files contain a pair of texts corresponding to each other for encryption and decryption.

The program will be compiled with the commands:

`nasm -f elf64 -w+all -w+error -o dcl.o dcl.asm`

`ld --fatal-warnings -o dcl dcl.o`
