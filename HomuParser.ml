(*
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
*)


exception InvalidNumberOfHomus;
exception IllegalHomu;
exception ReadBeforeWrite;
exception IllegalWrite;
exception IllegalHalt;

datatype instruction = Instr of int * int * int * int | Halt;

fun parse s =
    let fun make_capital s = if Char.ord s > 90 then Char.chr (Char.ord s - 32) else s
	
	    fun is_valid_homu (a::b::c::d::r) = (make_capital a) = #"H" andalso (make_capital b) = #"O"
                andalso (make_capital c) = #"M" andalso (make_capital d) = #"U" andalso (is_valid_homu r)
        | is_valid_homu [] = true
		| is_valid_homu _ = false;
			
	    fun split [] [] = []
		  | split [] current =
		        let val homu = rev current
				in if is_valid_homu homu then [implode homu]
				   else raise IllegalHomu end
          | split (x::xs) current =
                if x = #" " orelse x = #"\n" then
				    if current = [] then split xs [] else
				    let val homu = rev current
				    in if is_valid_homu homu then (implode homu)::(split xs [])
				       else raise IllegalHomu end
				else split xs (x::current)
		
	    fun numerate s =
            let fun eval [] acc = acc
                  | eval (x::xs) acc =
						if Char.ord x > 90 then eval xs (acc * 2)
	                    else eval xs (acc * 2 + 1)
	        in eval (explode s) 0 end
		
		fun group [] = []
          | group (a::b::c::d::r) = (Instr (numerate a, numerate b, numerate c, numerate d))::(group r)
          | group _ = raise InvalidNumberOfHomus;
	in group (split (explode s) []) end;
	
fun execute code =
    let fun read [] _ = 0
          | read ((x, y)::xs) z = if x = z then y else read xs z;

        fun store _ (0, _) = raise IllegalWrite
          | store [] (x, y) = [(x, y)]
          | store ((a, b)::xs) (x, y) = if a = x then ((a, y)::xs) else ((a, b)::(store xs (x, y)));
  
        fun get_instr [] _ = Halt
          | get_instr (x::xs) 0 = x
          | get_instr (_::xs) n = if n < 0 then Halt else get_instr xs (n - 1)
		
		fun interp code cp env =
                let val i = get_instr code cp
	            in case i of
	                Halt => read env 1
	                | Instr (a, b, c, d) =>
		                  let val result = if b mod 2 = 1 then (read env a) - (b div 2)
			                               else (read env a) - (read env (b div 2))
			              in if result < 0 then
						         if d mod 2 = 1 then interp code (d div 2) (store env (c, result))
								 else interp code (read env (d div 2)) (store env (c, result))
			                 else interp code (cp + 1) (store env (c, result)) end
	            end
    in interp code 0 [(0, 0), (1, 0)] end;
	
fun execute_from_file fin =
    let fun read filename =
            let val fd = TextIO.openIn filename
                val content = TextIO.inputAll fd handle e => (TextIO.closeIn fd; raise e)
                val _ = TextIO.closeIn fd
            in content end
	in execute (parse (read fin)) end;