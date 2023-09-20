library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm2 is 
	port(
		clk 	: in std_logic;
		enable	: in std_logic;
		reset 	: in std_logic;
		spi_clk	: in std_logic;
		done	: in std_logic;
		load	: out std_logic;
		start	: out std_logic;
		shout	: out std_logic);
end entity;

architecture fsm2_arch of fsm2 is

	type state_type is (idle, send_channel, send_dummy, send_gain, send_shutdown, send_data);
	signal cur_state : state_type;
	signal next_state: state_type;

begin

	-- next state calculation
	next_state_proc : process (cur_state, enable, spi_clk)
	begin
		next_state <= cur_state;
		--case cur_state is
			--when idle =>
				
			--when shouting =>
				--if rising_edge(spi_clk) then
					
				--end if;
		--end case;
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
		
