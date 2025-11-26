library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package memory_types is
    type port_array is array (0 to 15) of std_logic_vector(7 downto 0);
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memory_types.all;


entity memory is
    port (
        address     : in  std_logic_vector(7 downto 0);
        data_in     : in  std_logic_vector(7 downto 0);
        write       : in  std_logic;
        clock       : in  std_logic;
        reset       : in  std_logic;  -- Reset global

        port_in_xx  : in  port_array;
        port_out_xx : buffer port_array;

        data_out    : out std_logic_vector(7 downto 0)
    );
end entity;


architecture rtl of memory is

    signal rom_out : std_logic_vector(7 downto 0);
    signal ram_out : std_logic_vector(7 downto 0);

    -- RAM interna para poder resetearla (96 bytes)
    type ram_type is array (0 to 95) of std_logic_vector(7 downto 0);
    signal ram_internal : ram_type := (others => (others => '0'));

    -- Señal temporal para port_out_xx
    signal port_out_internal : port_array := (others => (others => '0'));

begin

    -- ROM: NO SE BORRA, pero controlamos data_out en reset

    rom_inst : entity work.rom_128x8_sync
        port map (
            address  => address(6 downto 0),
            clock    => clock,
            data_out => rom_out
        );

    ram_proc : process(clock)
    begin
        if reset = '1' then
            ram_internal <= (others => (others => '0'));
        elsif rising_edge(clock) then
            if write = '1' and unsigned(address) >= 128 and unsigned(address) < 224 then
                ram_internal(to_integer(unsigned(address) - 128)) <= data_in;
            end if;
            ram_out <= ram_internal(to_integer(unsigned(address) - 128));
        end if;
    end process;


    gen_output_ports : for i in 0 to 15 generate
        process(clock, reset)
        begin
            if reset = '1' then
                port_out_xx(i) <= (others => '0');
            elsif rising_edge(clock) then
                -- ahora la dirección de escritura corresponde a 224 + i (0xE0..0xEF)
                if write = '1'
                   and address = std_logic_vector(to_unsigned(224 + i, 8)) then
                    port_out_xx(i) <= data_in;
                end if;
            end if;
        end process;
    end generate;


    process(address, rom_out, ram_out, port_in_xx, port_out_xx)
    begin
        if reset = '1' then
            data_out <= (others => '0');
        else
            if unsigned(address) < 128 then      -- 0..129 = ROM
                data_out <= rom_out;

            elsif unsigned(address) < 224 then   -- 128..223 = RAM
                data_out <= ram_out;

            elsif unsigned(address) < 240 then   -- 224..239 = PORT_OUT
                data_out <= port_out_xx(to_integer(unsigned(address) - 224));

            else                                 -- 240..255 = PORT_IN
                data_out <= port_in_xx(to_integer(unsigned(address) - 240));
            end if;
        end if;
    end process;

    
end architecture;
