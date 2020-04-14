----------------------------------------------------------------------------------
-- Engineer: Romain Brenaget
-- 
-- Create Date: 04.04.2020 
-- Design Name: 
-- Package Name: trivium_package
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


package trivium_package is

    component trivium_fsm is
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
    end component;

    component trivium_engine is
        Generic (
            G_OUTPUT_SIZE : integer range 1 to 64 := 32
        );
        Port (
            clk : in std_logic;
            rst : in std_logic;
            initialization : in std_logic;
            generate_keystream : in std_logic;
            pause : in std_logic;
            key : in std_logic_vector(1 to 80);
            iv : in std_logic_vector(1 to 80);
            ready : out std_logic;
            zi : out std_logic_vector(0 to G_OUTPUT_SIZE-1)
        );
    end component;

end trivium_package;