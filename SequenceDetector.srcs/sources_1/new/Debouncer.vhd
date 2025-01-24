library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Debouncer is
  Port (
        clk : in std_logic; -- input slow clock
        input : in std_logic;  -- input button
        output : out std_logic -- output button
  );
end Debouncer;

architecture Behavioral of Debouncer is
    signal delay1, delay2, delay3 : std_logic := '0'; --for shifting the input
    signal pulse : std_logic := '0'; -- output pulse
begin
    process(clk, input)
    begin
        if rising_edge(clk) then --Shift the input on every clock edge
            delay1 <= input;
            delay2 <= delay1;
            delay3 <= delay2;
            
            if (delay2 = '1' and delay3 = '0') then -- Give output on second edge
                pulse <= '1';
            else
                pulse <= '0';
            end if;
        end if;
    end process;
 
    output <= pulse;
end Behavioral;