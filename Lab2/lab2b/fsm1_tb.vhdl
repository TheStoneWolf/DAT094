-- DAT094, lab2b
-- 
-- Initial test bench for fsm1. 
-- Intended to be extended by students.
--
-- / ljs Sep 11 2023 

library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm1_tb is
end entity fsm1_tb;

architecture arch of fsm1_tb is

  -- settings
  -- 
  constant THE_WIDTH : natural                              := 12;
  constant TESTVEC   : std_logic_vector(THE_WIDTH downto 1) := "101001011010";

  -- component declarations
  -- 
  component fsm1 is
    generic (WIDTH : natural range 1 to 16);
    port (d      : in  std_logic_vector(width - 1 downto 0);
          clk    : in  std_logic;
          enable : in  std_logic;
          reset  : in  std_logic;
          load   : in  std_logic;
          start  : in  std_logic;
          shout  : out std_logic;
          done   : out std_logic);
  end component fsm1;

  -- signal declarations
  -- 
  signal d      : std_logic_vector(THE_WIDTH downto 1);
  signal clk    : std_logic := '1';
  signal enable : std_logic;
  signal reset  : std_logic;
  signal load   : std_logic;
  signal start  : std_logic;
  signal shout  : std_logic;
  signal done   : std_logic;

begin

  fsm1_inst : component fsm1
    generic map (WIDTH => THE_WIDTH)
    port map (d      => d,
              clk    => clk,
              enable => enable,
              reset  => reset,
              load   => load,
              start  => start,
              shout  => shout,
              done   => done);

  -- clock generation 
  clk_proc : process
  begin
    wait for 5 ns;
    clk <= not(clk);
  end process clk_proc;

  -- enable generation 
  enable_proc : process
  begin
    enable <= '1';
    wait for 10 ns;
    enable <= '0';
    wait for 490 ns;
  end process enable_proc;

  d <= TESTVEC;

  reset <= '0',
           '1' after 50 ns,
           '0' after 250 ns;

  load <= '0',
          '1' after 350 ns,
          '0' after 550 ns;

  start <= '0',
           '1' after 850 ns,
           '0' after 1050 ns;

  test_proc : process
  begin
    wait for 200 ns;
    assert (reset = '1')
      report "no reset"
      severity warning;
    assert (done = '1')
      report "done not set"
      severity warning;
    assert (s = '0')
      report "s not 0"
      severity warning;

    wait for 310 ns;
    assert (load = '1')
      report "no load"
      severity warning;

    wait for 500 ns;
    assert (start = '1')
      report "no start"
      severity warning;

    wait for 10000 ns;

    -- halt testbench 
    report "Testbench finished!" severity failure;

  end process test_proc;

end architecture arch;

