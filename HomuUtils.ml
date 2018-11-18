datatype mode = NUM | LOC | CON;
datatype operation = PLUS of int * int | MINUS of int * int * int | HALT;

fun dec2homu LOC n = dec2homu NUM (2 * n)
  | dec2homu CON n = dec2homu NUM (2 * n + 1)
  | dec2homu NUM n =
    let fun dec2bin 0 = []
	      | dec2bin m = (dec2bin (m div 2)) @ [m mod 2]
	
	    fun pad_list 0 l = l
	      | pad_list n l = 0::(pad_list (n-1) l)
	
	    val bin =
	        let val raw = dec2bin n
			    val len = length raw
			in if len > 0 andalso len mod 4 = 0 then raw
			   else pad_list ((len div 4 + 1) * 4 - len) raw
			end
			  
		val symbols = [(0, #"h"), (1, #"o"), (2, #"m"), (3, #"u")]
		
		fun get_symbol ((s, c)::ss) 0 = c
		  | get_symbol (_::ss) n = get_symbol ss (n - 1)
		
		fun convert [] _ = []
		  | convert (0::xs) n = (get_symbol symbols n)::(convert xs ((n + 1) mod 4))
		  | convert (1::xs) n = (Char.chr (Char.ord (get_symbol symbols n) - 32))::(convert xs ((n + 1) mod 4))
		  
		val result = implode (convert bin 0)
	in result end;

fun encode_program l = let
    fun pow x 0 = 1
      | pow x n = if n mod 2 = 0 then pow (x*x) (n div 2)
                  else x * pow (x*x) (n div 2)
    fun main [] = 0
      | main (x::xs) =
	    let val encoding = case x of
		                       HALT => 0
							   | PLUS (i, j) => (pow 2 (2 * i)) * (2 * j + 1)
							   | MINUS (i, j, k) => (pow 2 (2 * i + 1)) * (2 * ((pow 2 j) * (2 * k + 1) - 1) + 1)
	    in (pow 2 encoding) * (2 * (main xs) + 1) end
    in main l end;
	
fun encode_list l = let
    fun pow x 0 = 1
      | pow x n = if n mod 2 = 0 then pow (x*x) (n div 2)
                  else x * pow (x*x) (n div 2)
    fun main [] = 0
      | main (x::xs) = (pow 2 x) * (2 * (main xs) + 1)
    in main l end;
	
fun decode_list value = let
    fun pair num = let
        fun calc y x =
            if y mod 2 = 1 then (x, y div 2)
            else calc (y div 2) (x + 1)
        in calc num 0 end
    fun main 0 = []
      | main rem = let val (x, y) = pair rem
            in x::(main y) end
    in main value end;
