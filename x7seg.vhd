library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity x7seg is
	port(
	digit: in STD_LOGIC_VECTOR(3 downto 0);        	--Input for hex digit
	out1: out STD_LOGIC_VECTOR(6 downto 0)		--output for segment
	);
end x7seg;

architecture logic of x7seg is
BEGIN

	--7 SEGMENT DECODER
	process(digit)
		BEGIN
			CASE digit is
				when X"0" => out1 <= "0111111"; --0
				when X"1" => out1 <= "0000110"; --1
				when X"2" => out1 <= "1011011"; --2
				when X"3" => out1 <= "1001111"; --3
				when X"4" => out1 <= "1100110"; --4
				when X"5" => out1 <= "1101101"; --5
				when X"6" => out1 <= "1111101"; --6
				when X"7" => out1 <= "0000111"; --7
				when X"8" => out1 <= "1111111"; --8
				when X"9" => out1 <= "1100111"; --9
				when X"A" => out1 <= "1110111"; --a
				when X"B" => out1 <= "1111100"; --b
				when X"C" => out1 <= "0111001"; --c
				when X"D" => out1 <= "1011110"; --d
				when X"E" => out1 <= "1111001"; --e
				when X"F" => out1 <= "1110001"; --f
		END CASE;
	END PROCESS;
END logic;
