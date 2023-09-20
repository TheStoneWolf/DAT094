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
		channel	: in std_logic;
		gain    : in  std_logic;
        	shutdown: in  std_logic;
		load	: out std_logic;
		start	: out std_logic;
		shout	: out std_logic;
		dac_cs	: out std_logic;
		busy	: out std_logic);
end entity;

architecture fsm2_arch of fsm2 is

	type state_type is (idle, send_channel, send_dummy, send_gain, send_shutdown, send_data);
	signal cur_state : state_type;
	signal next_state: state_type;

	signal channel_reg  : std_logic;
  	signal gain_reg     : std_logic;
  	signal shutdown_reg : std_logic;


begin

	input_proc : process (clk)
	begin
		if reset = '1' then
			channel_reg  <= '0';
        		gain_reg     <= '0';
        		shutdown_reg <= '0';
		elsif enable = '1' and cur_state = idle then
        		channel_reg  <= channel;
        		gain_reg     <= gain;
        		shutdown_reg <= shutdown;
      		end if;

	end process;

	output_proc : process (cur_state)
	begin
		case cur_state is
			when idle =>
        			busy    <= '0';
        			dac_cs  <= '1';
				load <= '0';
				start <= '0';
      			when send_channel =>
        			busy    <= '1';
        			dac_cs  <= '0';
        			shout <= channel_reg;
      			when send_dummy =>
        			shout <= '0';
      			when send_gain =>
        			shout <= gain_reg;
				load <= '1';
      			when send_shutdown =>
        			shout <= shutdown_reg;
				start <= '1';
				load <= '0';
			when send_data =>
				shout <= '0';
				start <= '0';
		end case;
	end process;

	-- next state calculation
	next_state_proc : process (cur_state, enable, spi_clk, reset)
	begin
		--next_state <= cur_state;
		if reset = '1' then
			next_state <= idle;
		else
		case cur_state is
			when idle =>
				if enable = '1' then
					next_state <= send_channel;
				end if;
			when send_channel =>
				if falling_edge(spi_clk) then
					next_state <= send_dummy;
				end if;
			when send_dummy =>
				if falling_edge(spi_clk) then
					next_state <= send_gain;
				end if;
			when send_gain =>
				if falling_edge(spi_clk) then
					next_state <= send_shutdown;
				end if;
			when send_shutdown =>
				if falling_edge(spi_clk) then
					next_state <= send_data;
				end if;
			when send_data =>
				if falling_edge(spi_clk) and done = '1' then
					next_state <= idle;
				end if;
		end case;
		end if;
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
		
