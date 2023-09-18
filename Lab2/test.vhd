library ieee;
use ieee.std_logic_1164.all;

entity test is
	port(
	in_data : in std_logic_vector(6 downto 0);
	out_data : out std_logic_vector(5 downto 0));
end entity;

architecture test_arch of test is
	signal in_temp : std_logic_vector(6 downto 0);
begin
	in_temp <= in_data;

	out_data <= in_temp when in_temp(0) = '1' else
	in_temp(5 downto 0);

end architecture;