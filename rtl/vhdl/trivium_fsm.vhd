----------------------------------------------------------------------------------
-- Engineer: Romain Brenaget
-- 
-- Create Date: 04.04.2020 
-- Design Name: 
-- Module Name: trivium_engine - Behavioral
-- Project Name: 
-- Target Devices: 
-- Description: 
--  
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity trivium_fsm is
    Generic (
        G_OUTPUT_SIZE : integer range 1 to 64 := 32
    );
    Port (
        clk : in std_logic;
        rst : in std_logic;
        start : in std_logic;
        pause : in std_logic;
        initialization : out std_logic;
        generate_keystream : out std_logic
    );
end trivium_fsm;


architecture Behavioral of trivium_fsm is

    constant output_size : integer range 0 to 63 := G_OUTPUT_SIZE;

    type States is (S_IDLE, S_INIT, S_GEN_KEYSTREAM, S_PAUSE);
    signal current_state : States := S_IDLE;

    signal cnt : natural := 0;

begin

    process (clk, rst)
        variable flag_init : std_logic := '0';
    begin

        if (rst = '1') then
            -- Resets FSM
            current_state <= S_IDLE;
            cnt <= 0;
            initialization <= '0';
            generate_keystream <= '0';
            flag_init := '0';
        elsif (clk'event and clk = '1') then
            -- FSM management
            case current_state is 
                when S_IDLE =>
                    -- Sleeping, waiting for a start signal
                    if (start = '1' and pause = '0') then
                        if (flag_init = '0') then
                            initialization <= '1';
                            flag_init := '1';
                            current_state <= S_INIT;
                        else
                            generate_keystream <= '1';
                            current_state <= S_GEN_KEYSTREAM;
                        end if;
                    end if;
            
                when S_INIT =>
                    -- Loads key & iv, and initializes LFSRs
                    if (cnt = (1152-output_size)) then
                        generate_keystream <= '1';
                        initialization <= '0';
                        cnt <= 0;
                        current_state <= S_GEN_KEYSTREAM;
                    elsif (flag_init = '1') then
                        cnt <= cnt + output_size;
                    end if;

                when S_GEN_KEYSTREAM =>
                    -- Generation of the key steram
                    if (pause = '1') then
                        generate_keystream <= '0';
                        current_state <= S_PAUSE;
                    end if;

                when S_PAUSE =>
                    -- Handles key stream generation halt
                    if (pause = '0') then
                        generate_keystream <= '1';
                        current_state <= S_GEN_KEYSTREAM;
                    end if;
        end if;

    end process;

end Behavioral;