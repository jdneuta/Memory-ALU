library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rw_96x8_sync is
    port (
        address  : in  std_logic_vector(6 downto 0);
        data_in  : in  std_logic_vector(7 downto 0);
        write    : in  std_logic;
        clock    : in  std_logic;
        data_out : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of rw_96x8_sync is
    type ram_type is array (0 to 95) of std_logic_vector(7 downto 0);
    signal ram : ram_type := (others => (others => '0'));
begin
    process(clock)
    begin
        if rising_edge(clock) then
            if write = '1' then
                ram(to_integer(unsigned(address))) <= data_in;
            end if;
            data_out <= ram(to_integer(unsigned(address)));
        end if;
    end process;
end architecture;
