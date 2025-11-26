library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity alu_test_top is
    port(
        SW    : in  std_logic_vector(15 downto 0);  -- SW[15:8] = A, SW[7:0] = B
        KEY   : in  std_logic_vector(1 downto 0);   -- KEY0 = 1 => SUMA, KEY0 = 0 => RESTA
        HEX0  : out std_logic_vector(6 downto 0);
        HEX1  : out std_logic_vector(6 downto 0);
        HEX2  : out std_logic_vector(6 downto 0);
        HEX3  : out std_logic_vector(6 downto 0);
        LEDR  : out std_logic_vector(3 downto 0)    -- NZVC (Negativo, Cero, Overflow, Carry)
    );
end alu_test_top;

architecture rtl of alu_test_top is

    signal A     : std_logic_vector(7 downto 0);
    signal B     : std_logic_vector(7 downto 0);
    signal op    : std_logic;
    signal R     : std_logic_vector(7 downto 0);
    signal flags : std_logic_vector(3 downto 0);

begin

    A  <= SW(15 downto 8);
    B  <= SW(7 downto 0);
    op <= KEY(0);

    alu_inst : entity work.alu_8bit
        port map(
            A      => A,
            B      => B,
            op_sub => op,
            Result => R,
            NZVC   => flags
        );

    -- Mostrar resultado en HEX (R)
    hex0_inst: entity work.systemd_hex port map(A => R(3 downto 0), D0 => HEX0);
    hex1_inst: entity work.systemd_hex port map(A => R(7 downto 4), D0 => HEX1);

    -- Mostrar A y B en HEX
    hex2_inst: entity work.systemd_hex port map(A => A(3 downto 0), D0 => HEX2);
    hex3_inst: entity work.systemd_hex port map(A => B(3 downto 0), D0 => HEX3);

    -- Flags NZVC en LEDs (NZVC(3 downto 0))
    LEDR <= flags;

end architecture;
