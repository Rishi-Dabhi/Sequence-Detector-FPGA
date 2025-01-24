library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ClockDivider is
    Port (
        clk_in : in  std_logic; -- Input clock (100 MHz)
        clk_out : out std_logic -- Output divided clock
    );
end ClockDivider;

architecture Behavioral of ClockDivider is
    signal counter : unsigned(22 downto 0) := (others => '0'); -- 23-bit counter
    signal clk_div : std_logic := '0';

    -- Define the division factor
    constant DIV_FACTOR : unsigned(22 downto 0) := to_unsigned(5000000, 23); 
begin

    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if counter = DIV_FACTOR - 1 then
                counter <= (others => '0'); -- Reset counter
                clk_div <= not clk_div; -- Toggle the output clock
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    clk_out <= clk_div; --Output
end Behavioral;
