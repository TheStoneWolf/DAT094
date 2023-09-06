-- DAT094 - Lab 1b
--
-- Simplified DAC controller without the LDAC signal.
--
-- Author:  Erik Börjeson
-- Date:    2023-08-28
-- Version: 1.0
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity dac_controller is
  generic (CLK_FREQ : real := 100.0e6;
           SPI_FREQ : real := 20.0e6);
  port (clk      : in  std_logic;
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
end entity dac_controller;

architecture dac_controller_arch of dac_controller is

  -- Constant declarations (we can use math_real here, as the constant is
  -- calculated during synthesis)
  constant SCK_PERIOD_DIV : integer := integer(ceil(CLK_FREQ/SPI_FREQ));

  -- Type declarations
  type state_type is (idle,
                      send_channel,
                      send_dummy,
                      send_gain,
                      send_shutdown,
                      send_data11,
                      send_data10,
                      send_data9,
                      send_data8,
                      send_data7,
                      send_data6,
                      send_data5,
                      send_data4,
                      send_data3,
                      send_data2,
                      send_data1,
                      send_data0);

  -- Signal declarations
  signal current_state : state_type;
  signal next_state    : state_type;

  signal counter : integer range 0 to SCK_PERIOD_DIV-1;

  signal channel_reg  : std_logic;
  signal gain_reg     : std_logic;
  signal shutdown_reg : std_logic;
  signal data_reg     : std_logic_vector(11 downto 0);
  
begin

  -- Registers to store the input values. Used to protect from changing input
  -- data during transmission.
  input_registers_proc : process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        channel_reg  <= '0';
        gain_reg     <= '0';
        shutdown_reg <= '0';
        data_reg     <= (others => '0');
      elsif enable = '1' and current_state = idle then
        channel_reg  <= channel;
        gain_reg     <= gain;
        shutdown_reg <= shutdown;
        data_reg     <= data;
      end if;
    end if;
  end process input_registers_proc;

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

  -- FSM state register
  state_change_proc : process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        current_state <= idle;
      else
        current_state <= next_state;
      end if;
    end if;
  end process state_change_proc;

  -- FSM next state
  next_state_proc : process (current_state, enable, counter)
  begin
    next_state <= current_state;
    case current_state is
      when idle =>
        if enable = '1' then
          next_state <= send_channel;
        end if;
      when send_channel =>
        if counter = SCK_PERIOD_DIV-1 then
          next_state <= send_dummy;
        end if;
      when send_dummy =>
        if counter = SCK_PERIOD_DIV-1 then
          next_state <= send_gain;
        end if;
      when send_gain =>
        if counter = SCK_PERIOD_DIV-1 then
          next_state <= send_shutdown;
        end if;
      when send_shutdown =>
        if counter = SCK_PERIOD_DIV-1 then
          next_state <= send_data11;
        end if;
      when send_data11 =>
        if counter = SCK_PERIOD_DIV-1 then
          next_state <= send_data10;
        end if;
      when send_data10 =>
        if counter = SCK_PERIOD_DIV-1 then
          next_state <= send_data9;
        end if;
      when send_data9 =>
        if counter = SCK_PERIOD_DIV-1 then
          next_state <= send_data8;
        end if;
      when send_data8 =>
        if counter = SCK_PERIOD_DIV-1 then
          next_state <= send_data7;
        end if;
      when send_data7 =>
        if counter = SCK_PERIOD_DIV-1 then
          next_state <= send_data6;
        end if;
      when send_data6 =>
        if counter = SCK_PERIOD_DIV-1 then
          next_state <= send_data5;
        end if;
      when send_data5 =>
        if counter = SCK_PERIOD_DIV-1 then
          next_state <= send_data4;
        end if;
      when send_data4 =>
        if counter = SCK_PERIOD_DIV-1 then
          next_state <= send_data3;
        end if;
      when send_data3 =>
        if counter = SCK_PERIOD_DIV-1 then
          next_state <= send_data2;
        end if;
      when send_data2 =>
        if counter = SCK_PERIOD_DIV-1 then
          next_state <= send_data1;
        end if;
      when send_data1 =>
        if counter = SCK_PERIOD_DIV-1 then
          next_state <= send_data0;
        end if;
      when send_data0 =>
        if counter = SCK_PERIOD_DIV-1 then
          next_state <= idle;
        end if;
    end case;
  end process next_state_proc;

  -- FSM output 
  outputs_proc : process (current_state, channel_reg, gain_reg, shutdown_reg, data_reg)
  begin
    case current_state is
      when idle =>
        busy    <= '0';
        dac_cs  <= '1';
        dac_sdi <= '0';
      when send_channel =>
        busy    <= '1';
        dac_cs  <= '0';
        dac_sdi <= channel_reg;
      when send_dummy =>
        busy    <= '1';
        dac_cs  <= '0';
        dac_sdi <= '0';
      when send_gain =>
        busy    <= '1';
        dac_cs  <= '0';
        dac_sdi <= gain_reg;
      when send_shutdown =>
        busy    <= '1';
        dac_cs  <= '0';
        dac_sdi <= shutdown_reg;
      when send_data11 =>
        busy    <= '1';
        dac_cs  <= '0';
        dac_sdi <= data_reg(11);
      when send_data10 =>
        busy    <= '1';
        dac_cs  <= '0';
        dac_sdi <= data_reg(10);
      when send_data9 =>
        busy    <= '1';
        dac_cs  <= '0';
        dac_sdi <= data_reg(9);
      when send_data8 =>
        busy    <= '1';
        dac_cs  <= '0';
        dac_sdi <= data_reg(8);
      when send_data7 =>
        busy    <= '1';
        dac_cs  <= '0';
        dac_sdi <= data_reg(7);
      when send_data6 =>
        busy    <= '1';
        dac_cs  <= '0';
        dac_sdi <= data_reg(6);
      when send_data5 =>
        busy    <= '1';
        dac_cs  <= '0';
        dac_sdi <= data_reg(5);
      when send_data4 =>
        busy    <= '1';
        dac_cs  <= '0';
        dac_sdi <= data_reg(4);
      when send_data3 =>
        busy    <= '1';
        dac_cs  <= '0';
        dac_sdi <= data_reg(3);
      when send_data2 =>
        busy    <= '1';
        dac_cs  <= '0';
        dac_sdi <= data_reg(2);
      when send_data1 =>
        busy    <= '1';
        dac_cs  <= '0';
        dac_sdi <= data_reg(1);
      when send_data0 =>
        busy    <= '1';
        dac_cs  <= '0';
        dac_sdi <= data_reg(0);
    end case;
  end process outputs_proc;

end architecture dac_controller_arch;
