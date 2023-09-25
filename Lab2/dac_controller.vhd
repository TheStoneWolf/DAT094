library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity dac_controller is
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

architecture dac_controller_arch of dac_controller is

	component fsm1 is
    	generic (WIDTH : natural range 1 to 16);
    	port (	d      		: in  std_logic_vector(width - 1 downto 0);
          	clk    		: in  std_logic;
          	reset  		: in  std_logic;
          	load   		: in  std_logic;
          	start  		: in  std_logic;
		spi_comp	: in  std_logic;
         	shout  		: out std_logic;
          	done  		: out std_logic);
  	end component fsm1;

	component fsm2 is
	generic ( SPI_PERIOD : integer);
    	port (	clk 	: in std_logic;
		reset 	: in std_logic;
		enable	: in std_logic;
		done	: in std_logic;
		channel	: in std_logic;
		gain    : in std_logic;
        	shutdown: in std_logic;
		load	: out std_logic;
		start	: out std_logic;
		shout	: out std_logic;
		dac_cs	: out std_logic;
		busy	: out std_logic;
		dac_sck	: out std_logic;
		spi_comp: out std_logic);
  	end component;

	constant SCK_PERIOD_DIV : integer := integer(ceil(CLK_FREQ/SPI_FREQ));
	constant data_width : integer := 12;

	signal done : STD_LOGIC;
	signal load : STD_LOGIC;
	signal start : STD_LOGIC;
	signal spi_comp_in : STD_LOGIC;
	signal shout_1 : STD_LOGIC;
	signal shout_2 : STD_LOGIC;
begin

	fsm1_inst : fsm1 generic map(data_width)
	port map(data, clk, rst, load, start, spi_comp_in, shout_1, done);

	fsm2_inst : fsm2 generic map(SCK_PERIOD_DIV)
	port map(clk, rst, enable, done, channel, gain, shutdown, load, start, shout_2, dac_cs, busy, dac_sck, spi_comp_in);

	dac_sdi <= shout_1 or shout_2; --Since the FSMs do not "shout" simultaneously, they can share the output data wire.

end architecture;
