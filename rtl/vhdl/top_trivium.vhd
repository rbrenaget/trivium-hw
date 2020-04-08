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
        clk : in std_logic;
        rst : in std_logic;
        start : in std_logic;
        n : in unsigned(31 downto 0);
        key : in std_logic_vector(1 to 80);
        iv : in std_logic_vector(1 to 80);
        ready : out std_logic;
        terminate : out  std_logic;
        keystream : out std_logic_vector(G_OUTPUT_SIZE-1 downto 0)
    );
end entity;


architecture Behavioral of top_trivium is
    
    signal s_initialization : std_logic := '0';
    signal s_generate_keystream : std_logic := '0';

begin
    
    inst_trivium_fsm : trivium_fsm generic map (G_OUTPUT_SIZE) port map (
        clk, rst, n, start, s_initialization, s_generate_keystream, terminate
    );
    
    inst_trivium_engine : trivium_engine generic map (G_OUTPUT_SIZE) port map (
        clk, rst, s_initialization, s_generate_keystream, key, iv, ready, keystream
    );

end architecture Behavioral;