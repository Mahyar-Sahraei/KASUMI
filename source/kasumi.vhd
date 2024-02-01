LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.kasumi_pack.ALL;



ENTITY kasumi IS
	PORT(
		pt:   IN  u64;
		kt:   IN  u128;
		clk:  IN  std_logic;
		nrst: IN  std_logic;
		ct:   OUT u64
	);
END kasumi;



ARCHITECTURE behavioural OF kasumi IS
BEGIN
	PROCESS(clk)
		VARIABLE v_Li, v_Ri, TMP: u32;
		VARIABLE v_KL: u32;
		VARIABLE v_KO, v_KI: u48;
	BEGIN
		IF rising_edge(clk) THEN
			IF nrst = '0' THEN
				ct <= (others => '0');
			ELSE
				v_Li := pt(63 DOWNTO 32);
				v_Ri := pt(31 DOWNTO 0);
				FOR round IN 1 TO 8 LOOP 
					round_key(round, kt, v_KL, v_KO, v_KI);
					TMP := v_Li;
					v_Li := v_Ri XOR round_function(round, v_Li, v_KL, v_KO, v_KI);
					v_Ri := TMP;
				END LOOP;
				ct <= v_Li & v_Ri;
			END IF;
		END IF;
	END PROCESS;
END behavioural;