----------------------------------------------------------------------------------
-- Engineer: Romain Brenaget
-- 
-- Create Date: 15.04.2020 
-- Design Name: 
-- Module Name: trivium_module - Behavioral
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


entity trivium_module is
    generic (
        C_OUTPUT_SIZE : integer range 1 to 64 := 32
    );
    port (
        TRV_CLK       : in std_logic;
        TRV_RST       : in std_logic;
        TRV_START     : in std_logic;
        TRV_INTERRUPT : in std_logic;
        TRV_STOP      : in std_logic;
        TRV_KEY       : in std_logic_vector(79 downto 0);
        TRV_IV        : in std_logic_vector(79 downto 0);
        TRV_READY     : out std_logic;
        TRV_KEYSTREAM : out std_logic_vector(C_OUTPUT_SIZE-1 downto 0)
    );
end entity;


architecture implementation of trivium_module is

    function swap_endianness (
        data : std_logic_vector
    )
    return std_logic_vector is 
        variable result : std_logic_vector(79 downto 0); 
    begin
        for i in 0 to 9 loop
             result(((i*8)+7) downto (i*8)) := 
                data(i*8)       &
                data((i*8) + 1) &
                data((i*8) + 2) &
                data((i*8) + 3) &
                data((i*8) + 4) &
                data((i*8) + 5) &
                data((i*8) + 6) &
                data((i*8) + 7);
        end loop;
        return result;
    end;

    constant output_size : integer range 1 to 64 := C_OUTPUT_SIZE;

    signal cnt : natural := 0;
    signal started : std_logic := '0';
    signal loaded : std_logic := '0';
    signal initialized : std_logic := '0';
    signal interrupted : std_logic := '0';
    signal stopped : std_logic := '0';

begin

    process (TRV_CLK, TRV_RST, TRV_START, TRV_INTERRUPT, TRV_STOP) is
        variable lfsr_a : std_logic_vector(92 downto 0) := (others => '0');
        variable lfsr_b : std_logic_vector(83 downto 0) := (others => '0');
        variable lfsr_c : std_logic_vector(110 downto 0) := (others => '0');
        variable t1 : std_logic := '0';
        variable t2 : std_logic := '0';
        variable t3 : std_logic := '0';
        variable zi :  std_logic_vector(C_OUTPUT_SIZE-1 downto 0);
    begin

        if (TRV_START = '1') then
            started <= '1';
        end if;

        if (TRV_INTERRUPT = '1') then
            interrupted <= '1';
        else
            interrupted <= '0';
        end if;

        if (TRV_STOP = '1') then
            stopped <= '1';
            started <= '0';
            loaded <= '0';
            initialized <= '0';
        end if;

        if (rising_edge(TRV_RST)) then
            TRV_READY <= '0';
            lfsr_a := (others => '0');
            lfsr_b := (others => '0');
            lfsr_c := (others => '0');
            loaded <= '0';
            initialized <= '0';
            cnt <= 0;
        elsif (rising_edge(TRV_CLK)) then

            if (started = '1' and loaded = '0') then
                lfsr_a := (92 downto 80 => '0') & swap_endianness(TRV_KEY);
                lfsr_b := (83 downto 80 => '0') & swap_endianness(TRV_IV);
                lfsr_c := "111" & (107 downto 0 => '0');
                loaded <= '1';
            end if;

            if (interrupted = '1' or stopped = '1') then
                TRV_READY <= '0';
            end if;

            if (started = '1' and loaded = '1' and interrupted = '0') then

                if (cnt = (1152-output_size) or initialized = '1') then
                    initialized <= '1';
                    cnt <= 0;
                else
                    cnt <= cnt + output_size;
                end if;

                for i in 0 to output_size-1 loop
                    t1 := lfsr_a(65) xor lfsr_a(92);
                    t2 := lfsr_b(68) xor lfsr_b(83);
                    t3 := lfsr_c(65) xor lfsr_c(110);

                    zi(i) := t1 xor t2 xor t3;

                    t1 := t1 xor (lfsr_a(90) and lfsr_a(91)) xor lfsr_b(77);
                    t2 := t2 xor (lfsr_b(81) and lfsr_b(82)) xor lfsr_c(86);
                    t3 := t3 xor (lfsr_c(108) and lfsr_c(109)) xor lfsr_a(68);
                    
                    lfsr_a(92 downto 0) := lfsr_a(91 downto 0) & t3;
                    lfsr_b(83 downto 0) := lfsr_b(82 downto 0) & t1;
                    lfsr_c(110 downto 0) := lfsr_c(109 downto 0) & t2;
                end loop;

                if (initialized = '1') then
                    TRV_READY <= '1';
                    TRV_KEYSTREAM <= zi;
                end if;

            end if;

        end if;

    end process;

end architecture implementation;