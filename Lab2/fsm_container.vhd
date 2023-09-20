library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm_container is
	generic(CLK_FREQ : real := 100.0e6;
           	SPI_FREQ : real := 20.0e6);
  	port (	clk      : in  std_logic;
        	rst      : in  std_logic;
        	enable   : in  std_logic;
        	channel  : in  std_logic;
        	gain     : in  std_logic;
        	shutdown : in  std_logic;
        	data     : in  std_logic_vector(11 downto 0);
        	busy     : out std_logic;
        	dac_cs   : out std_logic;
        	dac_sck  : out std_logic;
        	dac_sdi  : out std_logic);

end entity;

architecture fsm_container_arch of fsm_container is

	component fsm1 is
    	generic (WIDTH : natural range 1 to 16);
    	port (	d      : in  std_logic_vector(width - 1 downto 0);
          	clk    : in  std_logic;
          	reset  : in  std_logic;
          	load   : in  std_logic;
          	start  : in  std_logic;
	  	spi_clk: in  std_logic;
         	shout  : out std_logic;
          	done   : out std_logic);
  	end component fsm1;

	component fsm2 is
    	port (	clk 	: in std_logic;
		enable	: in std_logic;
		reset 	: in std_logic;
		spi_clk	: in std_logic;
		done	: in std_logic;
		channel	: in std_logic;
		gain    : in std_logic;
        	shutdown: in std_logic;
		load	: out std_logic;
		start	: out std_logic;
		shout	: out std_logic;
		dac_cs	: out std_logic;
		busy	: out std_logic);
  	end component;

	constant SCK_PERIOD_DIV : integer := integer(ceil(CLK_FREQ/SPI_FREQ));

begin

  -- Counter used to generate the SPI clock signal and to control the timing of
  -- the state changes in the FSM. The counter should only be active during
  -- transmission to reduce unnecessary switching.
  counter_proc : process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        counter <= 0;
      else
        case current_state is
          when idle =>
            null;
          when others =>
            if counter = SCK_PERIOD_DIV-1 then
              counter <= 0;
            else
              counter <= counter + 1;
            end if;
        end case;
      end if;
    end if;
  end process counter_proc;

  -- Process to control the generation of the SPI clock. The SPI clock should
  -- only be active during transmission to reduce unnecessary switching.
  spi_clock_proc : process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        dac_sck <= '0';
      else
        case current_state is
          when idle =>
            dac_sck <= '0';
          when others =>
            if counter >= SCK_PERIOD_DIV/2-1 and counter < SCK_PERIOD_DIV-1 then
              dac_sck <= '1';
            else
              dac_sck <= '0';
            end if;
        end case;
      end if;
    end if;
  end process spi_clock_proc;

end architecture;
