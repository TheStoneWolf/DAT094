-- fsm1 for shifting out the data bits. / ljs Sep 13 2023

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm1 is
  generic (width : natural range 1 to 16);
  port (d      : in  std_logic_vector(width - 1 downto 0);
        clk    : in  std_logic;
        reset  : in  std_logic;
        load   : in  std_logic; --Load becomes '1' one spi cycle before start becomes '1'
        start  : in  std_logic;
	spi_comp: in std_logic; --True if dac_slk will fall in one system clock cycle
        shout  : out std_logic; --Data output
        done   : out std_logic);
end entity fsm1;

architecture fsm1_arch of fsm1 is

	signal input_buffer : std_logic_vector(width -1 downto 0);
	signal count : natural range 0 to width-1;
	type state_type is (idle, shouting);

	signal cur_state : state_type;
	signal next_state : state_type;
begin

	input_proc : process (clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				input_buffer <= (others => '0');
			elsif  cur_state = idle and load = '1' then
				input_buffer <= d;
			end if;
		end if;
	end process;

	output_proc : process (cur_state, spi_comp)
	begin
		case cur_state is 
			when idle =>
				shout <= '0';
				if load = '1' then
					done <= '0';
					count <= width-1;
				end if;
			when shouting =>
				--Split into two since decrementing somehow happens before input_buffer(count) gets resolved otherwise
				if falling_edge(spi_comp) or cur_state'event then
					shout <= input_buffer(count);
				end if;
				if rising_edge(spi_comp) then
					if count = 0 then
						done <= '1';
					else 
						count <= count-1;
					end if;
				end if;
		end case;
	end process;

	-- next state calculation
	next_state_proc : process (cur_state, spi_comp)
	begin
		next_state <= cur_state;
		case cur_state is
			when idle =>
				if start = '1' and spi_comp = '1' then
					next_state <= shouting;
				end if;
			when shouting =>
				if spi_comp = '1' and count = 0 then
					next_state <= idle;
				end if;
		end case;
	end process;

	-- State transistion
	state_change_proc : process (clk)
  	begin
    		if rising_edge(clk) then
      			if reset = '1' then
        			cur_state <= idle;
      			else
        			cur_state <= next_state;
      			end if;
    		end if;
  	end process;

end architecture;