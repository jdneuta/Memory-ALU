library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.memory_types.all;

entity memory_test is
    port (
        CLOCK_50 : in  std_logic;

        SW       : in  std_logic_vector(15 downto 0);
        KEY      : in  std_logic_vector(1 downto 0);   -- KEY0=write, KEY1=reset

        HEX0     : out std_logic_vector(6 downto 0);
        HEX1     : out std_logic_vector(6 downto 0);
        HEX2     : out std_logic_vector(6 downto 0);
        HEX3     : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl of memory_test is

    signal clk       : std_logic;
    signal write     : std_logic;
    signal reset_sig : std_logic;
    signal address   : std_logic_vector(7 downto 0);
    signal data_in   : std_logic_vector(7 downto 0);
    signal data_out  : std_logic_vector(7 downto 0);

    signal port_in_dummy  : port_array := (others => (others => '0'));
    signal port_out_dummy : port_array;

begin

    clk       <= CLOCK_50;
    address   <= SW(7 downto 0);
    data_in   <= SW(15 downto 8);

    write     <= not KEY(0);   -- write activo en bajo  
    reset_sig <= not KEY(1);   -- reset activo en bajo (KEY1)


    mem_inst : entity work.memory
        port map(
            address     => address,
            data_in     => data_in,
            write       => write,
            clock       => clk,
            reset       => reset_sig,
            port_in_xx  => port_in_dummy,
            port_out_xx => port_out_dummy,
            data_out    => data_out
        );


    hex0_inst: entity work.systemd_hex port map(A => address(3 downto 0), D0 => HEX0);
    hex1_inst: entity work.systemd_hex port map(A => address(7 downto 4), D0 => HEX1);

    hex2_inst: entity work.systemd_hex port map(A => data_out(3 downto 0), D0 => HEX2);
    hex3_inst: entity work.systemd_hex port map(A => data_out(7 downto 4), D0 => HEX3);

end architecture;
