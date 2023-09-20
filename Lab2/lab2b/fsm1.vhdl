-- fsm1 for shifting out the data bits. / ljs Sep 13 2023

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm1 is
  generic (width : natural range 1 to 16);
  port (d      : in  std_logic_vector(width - 1 downto 0);
        clk    : in  std_logic;
        reset  : in  std_logic; --Assume active high
        load   : in  std_logic;
        start  : in  std_logic;
	spi_clk: in std_logic; --Clock for the sensor which is slower than the system clock
        shout  : out std_logic;
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

	output_proc : process (cur_state, count)
	begin
		case cur_state is 
			when idle =>
				shout <= '0';
				done <= '0';
				if load = '1' then
					done <= '0';
				end if;
			when shouting =>
				shout <= input_buffer(count);
				if count = 0 then
					done <= '1';
				end if;
		end case;
	end process;

	-- next state calculation
	next_state_proc : process (cur_state, start, spi_clk)
	begin
		next_state <= cur_state;
		case cur_state is
			when idle =>
				if start = '1' and rising_edge(spi_clk) then
					next_state <= shouting;
					count <= width-1;
				end if;
			when shouting =>
				if rising_edge(spi_clk) then
					if count = 0 then
						count <= width-1;
						next_state <= idle;
					else
						count <= count - 1;
					end if;
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