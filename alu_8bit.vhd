library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_8bit is
    port (
        A      : in  std_logic_vector(7 downto 0);
        B      : in  std_logic_vector(7 downto 0);
        op_sub : in  std_logic;                     -- 0 = ADD, 1 = SUB
        Result : out std_logic_vector(7 downto 0);
        NZVC   : out std_logic_vector(3 downto 0)   
    );
end entity;

architecture rtl of alu_8bit is
begin

    process(A, B, op_sub)
        variable Sum_uns : unsigned(8 downto 0);
        variable A_uns   : unsigned(7 downto 0);
        variable B_uns   : unsigned(7 downto 0);
        variable B_op    : unsigned(7 downto 0);
        variable R       : std_logic_vector(7 downto 0);
        variable N_flag, Z_flag, V_flag, C_flag : std_logic;
    begin

        A_uns := unsigned(A);
        B_uns := unsigned(B);


        -- Suma o resta (complemento a 2)
		  
        if op_sub = '1' then
            -- Resta: A + (not B) + 1
            B_op := unsigned(not B);
            Sum_uns := unsigned('0' & A_uns) + unsigned('0' & B_op) + 1; -- A - B
        else
            -- Suma
            B_op := B_uns;
            Sum_uns := unsigned('0' & A_uns) + unsigned('0' & B_op);     -- A + B
        end if;

        R := std_logic_vector(Sum_uns(7 downto 0));
        Result <= R;


        -- BANDERAS

        -- N flag: bit signo (bit7)
        N_flag := R(7);

        -- Z flag: resultado = 0
        if R = x"00" then
            Z_flag := '1';
        else
            Z_flag := '0';
        end if;

        -- C flag:
		  
        if op_sub = '0' then
            C_flag := Sum_uns(8);       -- suma: carry out
        else
            C_flag := not Sum_uns(8);   -- resta: borrow = not(carry_out)
        end if;

        -- V flag (overflow)
        if op_sub = '0' then
            -- ADD overflow: if A7 = B7 and R7 /= A7
            if (A(7) = B(7)) and (R(7) /= A(7)) then
                V_flag := '1';
            else
                V_flag := '0';
            end if;
        else
            -- SUB overflow
            if (A(7) /= B(7)) and (R(7) /= A(7)) then
                V_flag := '1';
            else
                V_flag := '0';
            end if;
        end if;

        -- Asignar NZVC: NZVC(3)=N, (2)=Z, (1)=V, (0)=C
        NZVC <= N_flag & Z_flag & V_flag & C_flag;
    end process;

end architecture;
