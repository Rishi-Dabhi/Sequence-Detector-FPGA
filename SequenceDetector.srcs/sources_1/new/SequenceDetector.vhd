library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SequenceDetector is
    Port(clk : in std_logic;
        btnc : in std_logic;
        btnd : in std_logic;
        btnl : in std_logic;
        btnu : in std_logic;
        btnr : in std_logic;
        led : out std_logic_vector(7 downto 0)
    );
end SequenceDetector;

architecture Behavioral of SequenceDetector is
    type STATES is (Four, One, One2, Two, Three); --FSM states
    signal current_state, next_state: STATES;
    signal clk_slow: std_logic; 
    signal d, l, u, r, c: std_logic; -- debounced buttons
    signal led_reg: std_logic_vector(7 downto 0) := (others => '0'); -- driving LED
    signal input_count: integer range 0 to 10 := 0; --button count
    signal sequence_detected: std_logic := '0';
    signal flash : std_logic :='0';
    
    component ClockDivider is
        Port (clk_in : in  std_logic; clk_out : out std_logic);
    end component;
    
    component Debouncer is
        Port (clk : in std_logic; input : in std_logic; output : out std_logic);
    end component;
    
begin
    -- Initialisation
    ClockDivider_inst : ClockDivider Port map (clk_in => clk, clk_out => clk_slow);

    Debouncer_d : Debouncer Port map (clk => clk_slow, input => btnd, output => d);
    Debouncer_l : Debouncer Port map (clk => clk_slow, input => btnl, output => l);
    Debouncer_u : Debouncer Port map (clk => clk_slow, input => btnu, output => u);
    Debouncer_r : Debouncer Port map (clk => clk_slow, input => btnr, output => r);
    Debouncer_c : Debouncer Port map (clk => clk_slow, input => btnc, output => c);


process(clk_slow, c)
    begin
        if c = '1' then -- Async Reset
            current_state <= Four;
            next_state <= Four;
            sequence_detected <= '0';
            input_count <= 0;
        elsif rising_edge(clk_slow) and (input_count < 10) then
            current_state <= next_state;
            if d = '1' or l = '1' or u = '1' or r = '1' then -- Triggered when a button is pressed
                input_count <= input_count + 1; -- increment
                
                case current_state is -- State transition logic 
                    when Four =>
                        if r = '1' then
                            next_state <= One;
                        else
                            next_state <= Four;
                        end if;
                    when One =>
                        if d = '1' then
                            next_state <= One2;
                        elsif r = '1' then
                            next_state <= One;
                        else
                            next_state <= Four;
                        end if;
                    when One2 =>
                        if d = '1' then
                            next_state <= Two;
                        elsif r = '1' then
                            next_state <= One;
                        else
                            next_state <= Four;
                        end if;
                    when Two =>
                        if l = '1' then
                            next_state <= Three;
                        elsif r = '1' then
                            next_state <= One;
                        else
                            next_state <= Four;
                        end if;
                    when Three =>
                        if u = '1' then
                            sequence_detected <= '1'; -- Sequence Detected Succesfully
                        elsif r = '1' then
                            next_state <= One;
                        else
                            next_state <= Four;
                        end if;
                end case;
            end if;
        end if;
    end process;


process(clk_slow, c)
    begin
        if c = '1' then --Async Reset
            led_reg <= (others => '0');
        elsif rising_edge(clk_slow) then
            if sequence_detected = '1' then -- Flash LEDs
                if flash = '0' then
                    led_reg <= (others => '1');
                    flash <= '1';
                elsif flash = '1' then
                    led_reg <= (others => '0');
                    flash <= '0';
                end if;
            elsif input_count >= 10 then -- Show Zig-Zag Pattern
                if flash = '0' then
                    led_reg <= "10101010";
                    flash <= '1';
                elsif flash = '1' then
                    led_reg <= "01010101";
                    flash <= '0';
                end if;
            end if;
        end if;
    end process;

led <= led_reg; --Drives output LEDs

end Behavioral;