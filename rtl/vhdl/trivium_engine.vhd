----------------------------------------------------------------------------------
-- Engineer: Romain Brenaget
-- 
-- Create Date: 20.03.2020 22:55:02
-- Design Name: trivium
-- Module Name: trivium_engine - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity trivium_engine is
    Generic (
        G_OUTPUT_SIZE : integer := 1
    );
    Port (
        clk : in std_logic;
        rst : in std_logic;
        initialization : in std_logic;
        generate_keystream : in std_logic;
        key : in std_logic_vector(1 to 80);
        iv : in std_logic_vector(1 to 80);
        ready : out std_logic;
        zi : out std_logic_vector(G_OUTPUT_SIZE-1 downto 0)
    );
end trivium_engine;


architecture Behavioral of trivium_engine is

    constant output_size : integer := G_OUTPUT_SIZE-1;

begin

    process (clk, rst)
    
        variable lfsr_a : std_logic_vector(1 to 93) := (others => '0');
        variable lfsr_b : std_logic_vector(1 to 84) := (others => '0');
        variable lfsr_c : std_logic_vector(1 to 111) := (others => '0');
        variable t1 : std_logic := '0';
        variable t2 : std_logic := '0';
        variable t3 : std_logic := '0';
        variable local_vector_zi : std_logic_vector(output_size downto 0) := (others => '0');
        
    begin
    
        if (rst = '1') then
            lfsr_a := (others => '0');
            lfsr_b := (others => '0');
            lfsr_c := (others => '0');
            zi <= (others => '0'); 
            ready <= '0';
        elsif (clk'event and clk = '1') then
            if (initialization = '1') then
                lfsr_a := key & (81 to 93 => '0');
                lfsr_b := iv & (81 to 84 => '0');
                lfsr_c := (1 to 108 => '0') & "111";
            elsif (initialization = '1' or generate_keystream = '1') then

                for i in 0 to output_size loop
                    t1 := lfsr_a(66) xor lfsr_a(93);
                    t2 := lfsr_b(69) xor lfsr_b(84);
                    t3 := lfsr_c(66) xor lfsr_c(111);

                    local_vector_zi(i) := t1 xor t2 xor t3;

                    t1 := t1 xor (lfsr_a(91) and lfsr_a(92)) xor lfsr_b(78);
                    t2 := t2 xor (lfsr_b(82) and lfsr_b(83)) xor lfsr_c(87);
                    t3 := t3 xor (lfsr_c(109) and lfsr_c(110)) xor lfsr_a(69);
                    
                    lfsr_a(1 to 93) := t3 & lfsr_a(1 to 92);
                    lfsr_b(1 to 84) := t1 & lfsr_b(1 to 83);
                    lfsr_c(1 to 111) := t2 & lfsr_c(1 to 110);
                end loop;
                
            elsif (generate_keystream = '0') then
                ready <= '0';
            end if;
        end if;
    
    end process;

end Behavioral;
