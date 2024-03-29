LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

PACKAGE kasumi_pack IS
	SUBTYPE u128 IS std_logic_vector(127 DOWNTO  0);
	SUBTYPE u64  IS std_logic_vector(63  DOWNTO  0);
	SUBTYPE u48  IS std_logic_vector(47  DOWNTO  0);
	SUBTYPE u32  IS std_logic_vector(31  DOWNTO  0);
	SUBTYPE u16  IS std_logic_vector(15  DOWNTO  0);
	SUBTYPE u9   IS std_logic_vector(8   DOWNTO  0);
	SUBTYPE u7   IS std_logic_vector(6   DOWNTO  0);
	
	TYPE SBOX7_T IS ARRAY(0 TO 127) OF integer;
	TYPE SBOX9_T IS ARRAY(0 TO 511) OF integer;
	
	CONSTANT S7_TABLE: SBOX7_T := (
		 54, 50, 62, 56, 22, 34, 94, 96, 38,  6, 63, 93,  2, 18,123, 33,
		 55,113, 39,114, 21, 67, 65, 12, 47, 73, 46, 27, 25,111,124, 81,
		 53,  9,121, 79, 52, 60, 58, 48,101,127, 40,120,104, 70, 71, 43,
		 20,122, 72, 61, 23,109, 13,100, 77,  1, 16,  7, 82, 10,105, 98,
		117,116, 76, 11, 89,106,  0,125,118, 99, 86, 69, 30, 57,126, 87,
		112, 51, 17,  5, 95, 14, 90, 84, 91,  8, 35,103, 32, 97, 28, 66,
		102, 31, 26, 45, 75,  4, 85, 92, 37, 74, 80, 49, 68, 29,115, 44,
		64 ,107,108, 24,110, 83, 36, 78, 42, 19, 15, 41, 88,119, 59,  3
	);
	
	CONSTANT S9_TABLE: SBOX9_T := (
		167,239,161,379,391,334,  9,338, 38,226, 48,358,452,385, 90,397,
		183,253,147,331,415,340, 51,362,306,500,262, 82,216,159,356,177,
		175,241,489, 37,206, 17,  0,333, 44,254,378, 58,143,220, 81,400,
		 95,  3,315,245, 54,235,218,405,472,264,172,494,371,290,399, 76,
		165,197,395,121,257,480,423,212,240, 28,462,176,406,507,288,223,
		501,407,249,265, 89,186,221,428,164, 74,440,196,458,421,350,163,
		232,158,134,354, 13,250,491,142,191, 69,193,425,152,227,366,135,
		344,300,276,242,437,320,113,278, 11,243, 87,317, 36, 93,496, 27,
		487,446,482, 41, 68,156,457,131,326,403,339, 20, 39,115,442,124,
		475,384,508, 53,112,170,479,151,126,169, 73,268,279,321,168,364,
		363,292, 46,499,393,327,324, 24,456,267,157,460,488,426,309,229,
		439,506,208,271,349,401,434,236, 16,209,359, 52, 56,120,199,277,
		465,416,252,287,246,  6, 83,305,420,345,153,502, 65, 61,244,282,
		173,222,418, 67,386,368,261,101,476,291,195,430, 49, 79,166,330,
		280,383,373,128,382,408,155,495,367,388,274,107,459,417, 62,454,
		132,225,203,316,234, 14,301, 91,503,286,424,211,347,307,140,374,
		 35,103,125,427, 19,214,453,146,498,314,444,230,256,329,198,285,
		 50,116, 78,410, 10,205,510,171,231, 45,139,467, 29, 86,505, 32,
		 72, 26,342,150,313,490,431,238,411,325,149,473, 40,119,174,355,
		185,233,389, 71,448,273,372, 55,110,178,322, 12,469,392,369,190,
		  1,109,375,137,181, 88, 75,308,260,484, 98,272,370,275,412,111,
		336,318,  4,504,492,259,304, 77,337,435, 21,357,303,332,483, 18,
		 47, 85, 25,497,474,289,100,269,296,478,270,106, 31,104,433, 84,
		414,486,394, 96, 99,154,511,148,413,361,409,255,162,215,302,201,
		266,351,343,144,441,365,108,298,251, 34,182,509,138,210,335,133,
		311,352,328,141,396,346,123,319,450,281,429,228,443,481, 92,404,
		485,422,248,297, 23,213,130,466, 22,217,283, 70,294,360,419,127,
		312,377,  7,468,194,  2,117,295,463,258,224,447,247,187, 80,398,
		284,353,105,390,299,471,470,184, 57,200,348, 63,204,188, 33,451,
		 97, 30,310,219, 94,160,129,493, 64,179,263,102,189,207,114,402,
		438,477,387,122,192, 42,381,  5,145,118,180,449,293,323,136,380,
		 43, 66, 60,455,341,445,202,432,  8,237, 15,376,436,464, 59,461
	);
	
	FUNCTION ROL16(
		X: u16;
		N: integer)
	RETURN u16;
	
	FUNCTION S7(
		X: u7)
	RETURN u7;
	
	FUNCTION S9(
		X: u9)
	RETURN u9;
	
	FUNCTION FL(
		I:  IN u32;
		KL: IN u32)
	RETURN u32;
	
	FUNCTION FI(
		I:  IN u16;
		KI: IN u16)
	RETURN u16;
	
	FUNCTION FO(
		I:  IN u32;
		KO: IN u48;
		KI: IN u48)
	RETURN u32;
	
	FUNCTION round_function(
		RD: IN integer;
		I:  IN u32;
		KL: IN u32;
		KO: IN u48;
		KI: IN u48) 
	RETURN u32;
	
	PROCEDURE round_key(
		CONSTANT RD:  IN integer;
		SIGNAL   KEY: IN u128;
		VARIABLE KL:  OUT u32;
		VARIABLE KO:  OUT u48;
		VARIABLE KI:  OUT u48);
	
END PACKAGE kasumi_pack;



PACKAGE BODY kasumi_pack IS

	FUNCTION ROL16(
		X: u16;
		N: integer)
	RETURN u16 IS
	BEGIN
		RETURN u16(X(15 - N DOWNTO 0) & X(15 DOWNTO 16 - N));
	END;
	
	FUNCTION S7(
		X: u7)
	RETURN u7 IS
		VARIABLE X_INT: integer;
	BEGIN
		X_INT := to_integer(unsigned(X));
		X_INT := S7_TABLE(X_INT);
		RETURN u7(to_unsigned(X_INT, 7));
	END;
	
	FUNCTION S9(
		X: u9)
	RETURN u9 IS
		VARIABLE X_INT: integer;
	BEGIN
		X_INT := to_integer(unsigned(X));
		X_INT := S9_TABLE(X_INT);
		RETURN u9(to_unsigned(X_INT, 9));
	END;

	FUNCTION FL(
		I:  IN u32;
		KL: IN u32)
	RETURN u32 IS
		VARIABLE R, L:    u16;
		VARIABLE KL1, KL2: u16;
	BEGIN
		L := I(31 DOWNTO 16);
		R := I(15 DOWNTO 0);
		
		KL1 := KL(31 DOWNTO 16);
		KL2 := KL(15 DOWNTO 0);
		
		R := R XOR ROL16(L AND KL1, 1);
		L := L XOR ROL16(R OR  KL2, 1);
		
		RETURN u32(R & L);
	END;
	
	FUNCTION FI(
		I:  IN u16;
		KI: IN u16)
	RETURN u16 IS
		VARIABLE L, KI2: u9;
		VARIABLE R, KI1: u7;
		VARIABLE R1, L2, R3, R4: u9;
		VARIABLE L1, R2, L3, L4: u7;
	BEGIN
		L := I(15 DOWNTO  7);
		R := I(6  DOWNTO  0);
		
		KI1 := KI(15 DOWNTO  9);
		KI2 := KI(8  DOWNTO  0);
		
		L1 := R;
		R1 := S9(L) XOR ("00" & R);
		L2 := R1 XOR KI2;
		R2 := S7(L1) XOR R1(6 DOWNTO 0) XOR KI1;
		L3 := R2;
		R3 := S9(L2) XOR ("00" & R2);
		L4 := S7(L3) XOR R3(6 DOWNTO 0);
		R4 := R3;
		
		RETURN u16(L4 & R4);
	END;
	
	FUNCTION FO(
		I:  IN u32;
		KO: IN u48;
		KI: IN u48)
	RETURN u32 IS
		VARIABLE L, R, TMP: u16;
		VARIABLE KO1, KO2, KO3: u16;
		VARIABLE KI1, KI2, KI3: u16;
	BEGIN
		L := I(31 DOWNTO 16);
		R := I(15 DOWNTO 0);
		
		KO1 := KO(47 DOWNTO 32);
		KO2 := KO(31 DOWNTO 16);
		KO3 := KO(15 DOWNTO 0);
		
		KI1 := KI(47 DOWNTO 32);
		KI2 := KI(31 DOWNTO 16);
		KI3 := KI(15 DOWNTO 0);
		
		TMP := R;
		R := FI(L XOR KO1, KI1) XOR R;
		L := TMP;
		
		TMP := R;
		R := FI(L XOR KO2, KI2) XOR R;
		L := TMP;
		
		TMP := R;
		R := FI(L XOR KO3, KI3) XOR R;
		L := TMP;
		
		RETURN u32(L & R);
	END;

	FUNCTION round_function(
		RD: IN integer;
		I:  IN u32;
		KL: IN u32;
		KO: IN u48;
		KI: IN u48) 
	RETURN u32 IS
	BEGIN
		IF RD MOD 2 = 0 THEN
			return FO(FL(I,KL),KO,KI);
		ELSE
			return FL(FO(I,KO,KI),KL);
		END IF;
	END;
	
	PROCEDURE round_key(
		CONSTANT   RD:  IN  integer;
		SIGNAL   KEY: IN  u128;
		VARIABLE KL:  OUT u32;
		VARIABLE KO:  OUT u48;
		VARIABLE KI:  OUT u48) 
	IS
		CONSTANT C:  u128 := X"0123456789ABCDEFFEDCBA9876543210";
		VARIABLE Kp: u128;
		VARIABLE K1, K2, K3, K4, K5, K6, K7, K8: u16;
		VARIABLE Kp1, Kp2, Kp3, Kp4, Kp5, Kp6, Kp7, Kp8: u16;
	BEGIN
		Kp := KEY XOR C;
		
		K1  := KEY(127 DOWNTO 112);
		K2  := KEY(111 DOWNTO  96);
		K3  := KEY(95  DOWNTO  80);
		K4  := KEY(79  DOWNTO  64);
		K5  := KEY(63  DOWNTO  48);
		K6  := KEY(47  DOWNTO  32);
		K7  := KEY(31  DOWNTO  16);
		K8  := KEY(15  DOWNTO   0);
		
		Kp1 := KEY(127 DOWNTO 112);
		Kp2 := KEY(111 DOWNTO  96);
		Kp3 := KEY(95  DOWNTO  80);
		Kp4 := KEY(79  DOWNTO  64);
		Kp5 := KEY(63  DOWNTO  48);
		Kp6 := KEY(47  DOWNTO  32);
		Kp7 := KEY(31  DOWNTO  16);
		Kp8 := KEY(15  DOWNTO   0);
		
		CASE RD IS
			WHEN 1 =>
				KL := ROL16(K1,  1) & Kp3;
				KO := ROL16(K2,  5) & ROL16(K6,  8) & ROL16(K7, 13);
				KI := Kp5 & Kp4 & Kp8;
				
			WHEN 2 =>
				KL := ROL16(K2,  1) & Kp4;
				KO := ROL16(K3,  5) & ROL16(K7,  8) & ROL16(K8, 13);
				KI := Kp6 & Kp5 & Kp1;
				
			WHEN 3 =>
				KL := ROL16(K3,  1) & Kp5;
				KO := ROL16(K4,  5) & ROL16(K8,  8) & ROL16(K1, 13);
				KI := Kp7 & Kp6 & Kp2;
				
			WHEN 4 =>
				KL := ROL16(K4,  1) & Kp6;
				KO := ROL16(K5,  5) & ROL16(K1,  8) & ROL16(K2, 13);
				KI := Kp8 & Kp7 & Kp3;
				
			WHEN 5 =>
				KL := ROL16(K5,  1) & Kp7;
				KO := ROL16(K6,  5) & ROL16(K2,  8) & ROL16(K3, 13);
				KI := Kp1 & Kp8 & Kp4;
				
			WHEN 6 =>
				KL := ROL16(K6,  1) & Kp8;
				KO := ROL16(K7,  5) & ROL16(K3,  8) & ROL16(K4, 13);
				KI := Kp2 & Kp1 & Kp5;
				
			WHEN 7 =>
				KL := ROL16(K7,  1) & Kp1;
				KO := ROL16(K8,  5) & ROL16(K4,  8) & ROL16(K5, 13);
				KI := Kp3 & Kp2 & Kp6;
				
			WHEN OTHERS => -- RD = 8
				KL := ROL16(K8,  1) & Kp2;
				KO := ROL16(K1,  5) & ROL16(K5,  8) & ROL16(K6, 13);
				KI := Kp4 & Kp3 & Kp7;
		END CASE;
	END round_key;
	
END PACKAGE BODY kasumi_pack;
