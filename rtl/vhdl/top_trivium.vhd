----------------------------------------------------------------------------------
-- Engineer: Romain Brenaget
-- 
-- Create Date: 04.04.2020 
-- Design Name: 
-- Module Name: top_trivium - Behavioral
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

library WORK;
use WORK.TRIVIUM_PACKAGE.all;


entity top_trivium is
    Generic (
        G_OUTPUT_SIZE : integer range 1 to 64 := 32
    );
    Port (
        TRV_CLK       : in std_logic;
        TRV_RST       : in std_logic;
        TRV_START     : in std_logic;
        TRV_PAUSE     : in std_logic;
        TRV_KEY       : in std_logic_vector(1 to 80);
        TRV_IV        : in std_logic_vector(1 to 80);
        TRV_READY     : out std_logic;
        TRV_KEYSTREAM : out std_logic_vector(G_OUTPUT_SIZE-1 downto 0)
    );
end entity;


architecture Behavioral of top_trivium is
    
    signal s_initialization     : std_logic := '0';
    signal s_fsm_generate_keystream : std_logic := '0';
    signal s_engine_generate_keystream : std_logic := '0';

begin
    
    trivium_fsm_inst : trivium_fsm 
        generic map (
            G_OUTPUT_SIZE => G_OUTPUT_SIZE
        )
        port map (
            clk                => TRV_CLK,
            rst                => TRV_RST,
            start              => TRV_START,
            pause              => TRV_PAUSE,
            initialization     => s_initialization,
            generate_keystream => s_fsm_generate_keystream
        );
    
    trivium_engine_inst : trivium_engine 
        generic map (
            G_OUTPUT_SIZE => G_OUTPUT_SIZE
        )
        port map (
            clk                => TRV_CLK,
            rst                => TRV_RST,
            initialization     => s_initialization,
            generate_keystream => s_engine_generate_keystream,
            key                => TRV_KEY,
            iv                 => TRV_IV,
            ready              => TRV_READY,
            zi                 => TRV_KEYSTREAM
        );

        s_engine_generate_keystream <= '0' when (TRV_PAUSE = '1' or s_fsm_generate_keystream = '0') else 
                                       '1' when (TRV_PAUSE = '0' and s_fsm_generate_keystream = '1');

end architecture Behavioral;