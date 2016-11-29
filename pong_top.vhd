LIBRARY  ieee;
USE ieee.std_logic_1164.all;

ENTITY pong_top IS
	PORT(
	iCLK_50 :IN STD_LOGIC;                     --VGA clock clock
	oHEX0_D : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 7seg  display 1
	oHEX1_D : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 7seg  display 2
	ps2_clk      : IN  STD_LOGIC;                     --clock signal from PS/2 keyboard
	ps2_data     : IN  STD_LOGIC;                    --data signal from PS/2 keyboard
	oVGA_HS : out STD_LOGIC;
	oVGA_VS : out STD_LOGIC;
	oVGA_R : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
	oVGA_G : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
	oVGA_B : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
	oVGA_BLANK_N   :  OUT  STD_LOGIC;  --direct blacking output 
   oVGA_SYNC_N    :  OUT  STD_LOGIC --sync-on-green output
	
	); 

END pong_top;

	ARCHITECTURE logic OF pong_top IS
	
		SIGNAL scancode:  STD_LOGIC_VECTOR(7 downto 0);
		SIGNAL rightPaddleDirection : INTEGER := 0;
		SIGNAL leftPaddleDirection : INTEGER := 0;
		signal halfClock : STD_LOGIC;
		signal horizontalPosition : integer range 0 to 800 := 0;
		signal verticalPosition : integer range 0 to 521 := 0;
		signal hsyncEnable : STD_LOGIC;
		signal vsyncEnable : STD_LOGIC;

		signal photonX : integer range 0 to 640 := 0;
		signal photonY : integer range 0 to 480 := 0;


		signal color : STD_LOGIC_VECTOR (2 downto 0) := "000";
	
		COMPONENT x7seg IS
			PORT(
			digit: IN STD_LOGIC_VECTOR(3 downto 0); -- input
			out1 : OUT STD_LOGIC_VECTOR(6 downto 0)
			);
		END COMPONENT;
		
		COMPONENT ps2_keyboard IS
			PORT(
			    Clock          : IN  STD_LOGIC;                     --system clock
				 KeyboardClock      : IN  STD_LOGIC;                     --clock signal from PS/2 keyboard
				 KeyboardData     : IN  STD_LOGIC;                     --data signal from PS/2 keyboard
				 leftPaddleDirection : buffer  integer;
             rightPaddleDirection : buffer  integer;
			    scancode : buffer STD_LOGIC_VECTOR(7 downto 0)

			);
		END COMPONENT;
		
	BEGIN
	oVGA_SYNC_N <= '0';   --no sync on green
	oVGA_BLANK_N <= '1';  --no direct blanking
	
		keyboard:ps2_keyboard
			    PORT MAP(
				 Clock => clk, 
				 KeyboardClock => ps2_clk, 
				 KeyboardData => ps2_data, 
				 leftPaddleDirection=>leftPaddleDirection,
				 rightPaddleDirection=>rightPaddleDirection,
				 scancode => scancode

				 );
				 
		display1:x7seg
				 PORT MAP(
				digit=>scancode(3 downto 0),
				out1=>oHEX0_D
					);
					
		display2:x7seg
				 PORT MAP(
				digit=>scancode(7 downto 4),
				out1=>oHEX1_D			
					);

	-- Half the clock
	clockScaler : process(iCLK_50)
	begin
		if iCLK_50'event and iCLK_50 = '1' then
			halfClock <= not halfClock;
		end if;
	end process clockScaler;
		
	

	signalTiming : process(halfClock)
	  begin
		if halfClock'event and halfClock = '1' then
			if horizontalPosition = 800 then
				horizontalPosition <= 0;
				verticalPosition <= verticalPosition + 1;
				
				if verticalPosition = 521 then
					verticalPosition <= 0;
				else
					verticalPosition <= verticalPosition + 1;
				end if;
			else
				horizontalPosition <= horizontalPosition + 1;
			end if;
		end if;
	end process signalTiming;
	
	vgaSync : process(halfClock, horizontalPosition, verticalPosition)
	begin
		if halfClock'event and halfClock = '1' then
			if horizontalPosition > 0 and horizontalPosition < 97 then --145?
				hsyncEnable <= '0';
			else
				hsyncEnable <= '1';
			end if;
			
			if verticalPosition > 0 and verticalPosition < 3 then --2?
				vsyncEnable <= '0';
		   else
				vsyncEnable <= '1';
			end if;
		end if;
	end process vgaSync;
	
	coordinates : process(horizontalPosition, verticalPosition)
	begin
		photonX <= horizontalPosition - 144; --96+48
		photonY <= verticalPosition - 31;    --33-2
	end process coordinates;
	
	colorSetter : process(photonX, photonY, halfClock)
	begin
			color <= "100";
	end process colorSetter;


	
	--drawing process
	draw : process(photonX, photonY, halfClock)
	begin
		if halfClock'event and halfClock = '1' then
			oVGA_HS <= hsyncEnable;
			oVGA_VS <= vsyncEnable;
		
			if (photonX < 640 and photonY < 480) then
				oVGA_R <= (others => color(2));
				oVGA_G <= (others => color(1));
				oVGA_B <= (others => color(0));
			else
				oVGA_R <= (others => '0');
				oVGA_G <= (others => '0');
				oVGA_B <= (others => '0');
			end if;
		end if;
	end process draw;

END logic;
	

	
	