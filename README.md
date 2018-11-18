# Homu Interpreter
This is a small project that started as a joke but ended up being pretty cool. This is an interpreter for a SIC that is Turing Complete using the capitalisation of the word 'homu'.

## Description of the Language
The Homu language works using a Single Instruction Computer (SIC) where there is only one instruction in the language.
Each instruction is made of 4 blocks (e.g. A B C D). To execute such an instruction, the value at location A is read and B is subtracted with the result being stored in C.
B can be either another location of a constant value which is indicated using a flag in the least significant bit with 1 for constant and 0 for location.
If the result of the operation was negative, jump to instruction D; otherwise, go to the next instruction. Instructions are labeled for this purpose in increasing order starting at 0.
As with B, D can also be a location or constant with the same flag system.
	
The blocks themselves are made up of the phrase 'homu' repeated one or more times (each instance of homu must be used in its entirity).
The block is simply a binary encoding of a number with an upper case letter representing 1 and a lower case letter representing 0.
The MSB is on the left and the LSB is on the right. Blocks are separated with at least one space and / or newline character
For example 'hoMu' represents 2 and 'homUhomu' represents 16. Each block may be arbitrarily long, only being limited in size by the size of memory available to represent the number.
	
Upon starting execution, location 0 is pre-initialised with constant 0 which cannot be overwritten. Location 1 is also initialised to 0 but this can be changed during execution.
To halt, a jump to an instruction index that is beyond the end of the program is performed. At this point, the value stored in location 1 is returned as the result.

## Universal Turing Machine
A Universal Turing Machine was implemented in the language to show that it was Turing Complete. The main file for this being in the Universal directory (with an annotated version to make it slightly more readable. At the moment, a very small program is loaded into this but this can be changed by using the appropriate encoding for register machine programs (X) / initial registers (Y) as noted in the annotated version. To help with writing this encoding, the HomuUtils file contains several methods to encode individual numbers, lists and programs.

To run the machine, requires using the HomuUtils file and then running:
```
execute_from_file "UniversalHomuMachine.homu";
```

### Register Locations
The interpretations for the registers are given below:
Register | Use | Literal Encoding | Register Encoding
0 | Const 0 = homu | homu
1 | Result (R0) / Constant -1 | homU | hoMu
2 | P | hoMu | hOmu
3 | A | hoMU | hOMu
4 | RA | hOmu | Homu
5 | Arg 1 / X | hOmU | HoMu
6 | Arg 2 / L | hOMu | HOmu
7 | PC | hOMU | HOMu
8 | N | Homu | homUhomu
9 | C | HomU | homUhoMu
10 | R | HoMu | homUhOmu
11 | S | HoMU | homUhOMu
12 | T | HOmu | homUHomu
13 | Z | HOmU | homUHoMu
14 | Exit | HOMu | homUHOmu
15 | Dump | HOMU | homUHOMu