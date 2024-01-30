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
	SIGNAL Li, Ri: u32;
	SIGNAL KEY: u128;
	SIGNAL round: integer := 0;
BEGIN
	PROCESS(clk)
		VARIABLE v_Li, v_Ri: u32;
		VARIABLE v_KL: u32;
		VARIABLE v_KO, v_KI: u48;
	BEGIN
		IF rising_edge(clk) THEN
			IF nrst = '0' THEN
				round <= 0;
			ELSE
				IF round = 0 THEN
					Li <= pt(63 DOWNTO 32);
					Ri <= pt(31 DOWNTO 0);
					KEY <= kt;
				ELSE
					round_key(round, KEY, v_KL, v_KO, v_KI);
					v_Li := Ri XOR round_function(round, Li, v_KL, v_KO, v_KI);
					v_Ri := Li;
					IF round = 8 THEN
						ct <= v_Li & v_Ri;
						round <= 0;
					ELSE
						ct <= (others => '0');
						round <= round + 1;
					END IF;
					Li <= v_Li;
					Ri <= v_Ri;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END behavioural;