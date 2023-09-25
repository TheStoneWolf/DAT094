library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm2 is
	generic ( SPI_PERIOD : integer); --A multiplicative of the system clock 
	port(
		clk 	: in std_logic;
		reset 	: in std_logic;
		enable	: in std_logic;
		done	: in std_logic;
		channel	: in std_logic;
		gain    : in  std_logic;
        	shutdown: in  std_logic;
		load	: out std_logic;
		start	: out std_logic;
		shout	: out std_logic;
		dac_cs	: out std_logic;
		busy	: out std_logic;
		dac_sck	: out std_logic;  --SPI clock
		spi_comp: out std_logic); --SPI period almost completed, neccessary to make FSM 1 prepare for state change 1 sys clock period ahead
end entity;

architecture fsm2_arch of fsm2 is

	type state_type is (idle, send_channel, send_dummy, send_gain, send_shutdown, send_data);
	signal cur_state : state_type;
	signal next_state: state_type;

	signal channel_reg  : std_logic;
  	signal gain_reg     : std_logic;
  	signal shutdown_reg : std_logic;
	signal spi_comp_in   : std_logic;
	
	signal spi_cnt	    : integer range 0 to SPI_PERIOD-1;
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
	next_state_proc : process (reset, enable, spi_comp_in, done)
	begin
		if reset = '1' then
			next_state <= idle;
		else
		case cur_state is
			when idle =>
				if enable = '1' then
					next_state <= send_channel;
				end if;
			when send_channel =>
				if spi_comp_in = '1' then
					next_state <= send_dummy;
				end if;
			when send_dummy =>
				if spi_comp_in = '1' then
					next_state <= send_gain;
				end if;
			when send_gain =>
				if spi_comp_in = '1' then
					next_state <= send_shutdown;
				end if;
			when send_shutdown =>
				if spi_comp_in = '1' then
					next_state <= send_data;
				end if;
			when send_data =>
				if spi_comp_in = '1' and done = '1' then
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

	spi_comp <= spi_comp_in;

	--Outside of different signal names, all the code below is the same as from Lab 1

	-- spi_cnt used to generate the SPI clock signal and to control the timing of
  	-- the state changes in the FSM. The spi_cnt should only be active during
  	-- transmission to reduce unnecessary switching.
  	spi_cnt_proc : process (clk)
  	begin
    		if rising_edge(clk) then
      			if reset = '1' then
       	 			spi_cnt <= 0;
      			else
        			case cur_state is
          			when idle =>
            				null;
          			when others =>
					if spi_cnt = SPI_PERIOD-2 then
						spi_comp_in <= '1';
					else
						spi_comp_in <= '0';
					end if;

            				if spi_cnt = SPI_PERIOD-1 then
              					spi_cnt <= 0;
            				else
              					spi_cnt <= spi_cnt + 1;
            				end if;
        			end case;
      			end if;
    		end if;
  	end process spi_cnt_proc;

  	-- Process to control the generation of the SPI clock. The SPI clock should
  	-- only be active during transmission to reduce unnecessary switching.
  	spi_clock_proc : process (clk)
  	begin
    		if rising_edge(clk) then
      			if reset = '1' then
        			dac_sck <= '0';
      			else
        			case cur_state is
          			when idle =>
            				dac_sck <= '0';
          			when others =>
            				if spi_cnt >= SPI_PERIOD/2-1 and spi_cnt < SPI_PERIOD-1 then
              					dac_sck <= '1';
            				else
              					dac_sck <= '0';
            				end if;
        			end case;
      			end if;
    		end if;
  	end process spi_clock_proc;
end architecture;
		
