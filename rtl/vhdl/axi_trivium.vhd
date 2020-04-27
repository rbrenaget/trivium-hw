library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_trivium is
	generic (
		-- Users to add parameters here
        C_TRV_BLOCK_SIZE : integer range 1 to 64 := 32;
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 5;

		-- Parameters of Axi Slave Bus Interface S00_AXIS
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 32;

		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_FIFO_DEPTH   : integer   := 256;
		C_M00_AXIS_FIFO_WIDTH   : integer   := 32;
		C_M00_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M00_AXIS_START_COUNT	: integer	:= 32
	);
	port (
		-- Users to add ports here
        
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic;

		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_aclk	: in std_logic;
		m00_axis_aresetn	: in std_logic;
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
		m00_axis_tstrb	: out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m00_axis_tlast	: out std_logic;
		m00_axis_tready	: in std_logic
	);
end axi_trivium;

architecture arch_imp of axi_trivium is

	-- component declaration
	component axi_trivium_S00_AXI is
		generic (
            C_S_AXI_DATA_WIDTH	: integer	:= 32;
            C_S_AXI_ADDR_WIDTH	: integer	:= 5
		);
		port (
            -- Users to add ports here
            S_AXI_TRV_STATUS   : in std_logic_vector(15 downto 0);
            S_AXI_TRV_CONFIG   : out std_logic_vector(15 downto 0);
            S_AXI_TRV_N_BLOCKS : out std_logic_vector(31 downto 0);
            S_AXI_TRV_KEY      : out std_logic_vector(79 downto 0);
            S_AXI_TRV_IV       : out std_logic_vector(79 downto 0);
            -- User ports ends
            S_AXI_ACLK	: in std_logic;
            S_AXI_ARESETN	: in std_logic;
            S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
            S_AXI_AWVALID	: in std_logic;
            S_AXI_AWREADY	: out std_logic;
            S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
            S_AXI_WVALID	: in std_logic;
            S_AXI_WREADY	: out std_logic;
            S_AXI_BRESP	: out std_logic_vector(1 downto 0);
            S_AXI_BVALID	: out std_logic;
            S_AXI_BREADY	: in std_logic;
            S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
            S_AXI_ARVALID	: in std_logic;
            S_AXI_ARREADY	: out std_logic;
            S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_RRESP	: out std_logic_vector(1 downto 0);
            S_AXI_RVALID	: out std_logic;
            S_AXI_RREADY	: in std_logic
		);
	end component axi_trivium_S00_AXI;

	component axi_trivium_M00_AXIS is
		generic (
		    C_M_AXIS_FIFO_DEPHT : integer := 256;
		    C_M_AXIS_FIFO_WIDTH : integer := 32;
            C_M_AXIS_TDATA_WIDTH : integer := 32;
            C_M_START_COUNT	: integer := 32
		);
		port (
            -- Users to add ports here
            M_AXIS_TRV_INIT_START : in std_logic;
            M_AXIS_TRV_READY      : in std_logic;
            M_AXIS_TRV_DONE       : in std_logic;
            M_AXIS_TRV_KEYSTREAM  : in std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
            M_AXIS_FIFO_CNT       : out std_logic_vector(31 downto 0);
            -- User ports ends
            M_AXIS_ACLK	: in std_logic;
            M_AXIS_ARESETN	: in std_logic;
            M_AXIS_TVALID	: out std_logic;
            M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
            M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
            M_AXIS_TLAST	: out std_logic;
            M_AXIS_TREADY	: in std_logic
		);
	end component axi_trivium_M00_AXIS;
	
	component trivium_module is
        generic (
            C_BLOCK_SIZE : integer range 1 to 64 := 32
        );
        port (
            TRV_CLK        : in std_logic;
            TRV_RST        : in std_logic;
            TRV_INIT_START : in std_logic;
            TRV_START      : in std_logic;
            TRV_N_BLOCKS   : in std_logic_vector(31 downto 0);
            TRV_KEY        : in std_logic_vector(79 downto 0);
            TRV_IV         : in std_logic_vector(79 downto 0);
            TRV_INIT_DONE  : out std_logic;
            TRV_READY      : out std_logic;
            TRV_DONE       : out std_logic;
            TRV_KEYSTREAM  : out std_logic_vector(C_BLOCK_SIZE-1 downto 0)
        );
    end component trivium_module;
    
    signal trv_clk        : std_logic := '0';
	signal trv_rst        : std_logic := '0';
	signal trv_init_start : std_logic := '0';
	signal trv_start      : std_logic := '0';
	signal trv_n_blocks   : std_logic_vector(31 downto 0);
	signal trv_key        : std_logic_vector(79 downto 0);
	signal trv_iv         : std_logic_vector(79 downto 0);
	signal trv_init_done  : std_logic := '0';
	signal trv_ready      : std_logic := '0';
	signal trv_done       : std_logic := '0';
	signal trv_keystream  : std_logic_vector(C_TRV_BLOCK_SIZE-1 downto 0);
	
	signal trv_started : std_logic := '0';
	
	signal trv_config : std_logic_vector(15 downto 0) := (others => '0');
	signal trv_status : std_logic_vector(15 downto 0) := (others => '0');
	
	signal fifo_cnt : std_logic_vector(31 downto 0);
	
	type state is (IDLE, INIT, INIT_DONE, START, WAIT_FIFO);
	signal current_state : state := IDLE;
	
begin

-- Instantiation of Axi Bus Interface S00_AXI
axi_trivium_S00_AXI_inst : axi_trivium_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    S_AXI_TRV_STATUS => trv_status,
	    S_AXI_TRV_CONFIG => trv_config,
	    S_AXI_TRV_N_BLOCKS => trv_n_blocks,
	    S_AXI_TRV_KEY => trv_key,
	    S_AXI_TRV_IV => trv_iv,
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

---- Instantiation of Axi Bus Interface M00_AXIS
axi_trivium_M00_AXIS_inst : axi_trivium_M00_AXIS
	generic map (
	    C_M_AXIS_FIFO_DEPHT => C_M00_AXIS_FIFO_DEPTH,
	    C_M_AXIS_FIFO_WIDTH => C_M00_AXIS_FIFO_WIDTH,
		C_M_AXIS_TDATA_WIDTH => C_M00_AXIS_TDATA_WIDTH,
		C_M_START_COUNT	=> C_M00_AXIS_START_COUNT
	)
	port map (
	    M_AXIS_TRV_INIT_START => trv_init_start,
	    M_AXIS_TRV_READY => trv_ready,
	    M_AXIS_TRV_DONE => trv_done,
	    M_AXIS_TRV_KEYSTREAM => trv_keystream,
	    M_AXIS_FIFO_CNT => fifo_cnt,
		M_AXIS_ACLK	=> m00_axis_aclk,
		M_AXIS_ARESETN	=> m00_axis_aresetn,
		M_AXIS_TVALID	=> m00_axis_tvalid,
		M_AXIS_TDATA	=> m00_axis_tdata,
		M_AXIS_TSTRB	=> m00_axis_tstrb,
		M_AXIS_TLAST	=> m00_axis_tlast,
		M_AXIS_TREADY	=> m00_axis_tready
	);

-- Add user logic here
---- Instantiation of Trvium module
trivium_module_inst : trivium_module
    generic map (
        C_BLOCK_SIZE => C_TRV_BLOCK_SIZE
    )
    port map (
        TRV_CLK        => trv_clk,
        TRV_RST        => trv_rst,
        TRV_INIT_START => trv_init_start,
        TRV_START      => trv_start,
        TRV_N_BLOCKS   => trv_n_blocks,
        TRV_KEY        => trv_key,
        TRV_IV         => trv_iv,
        TRV_INIT_DONE  => trv_init_done,
        TRV_READY      => trv_ready,
        TRV_DONE       => trv_done,
        TRV_KEYSTREAM  => trv_keystream
    );
    
    -- Assign clock and reset for trivium module
    trv_clk <= s00_axi_aclk;
    trv_rst <= '1' when (s00_axi_aresetn = '0') else '0';
    
    -- Assign configuration
    trv_init_start <= '1' when (current_state = INIT) else '0';
    trv_start      <= '1' when (current_state = START) else '0';
    
    -- Assign status
    trv_status <= (15 downto 2 => '0') & trv_started & trv_init_done;
    
    process (s00_axi_aclk)
        variable initialized : std_logic := '0';
    begin
        if (rising_edge(s00_axi_aclk)) then
            if (s00_axi_aresetn = '0') then
                current_state <= IDLE;
                initialized := '0';
                trv_started <= '0';
            else
                case (current_state) is
                    when IDLE =>
                        if (trv_config(0) = '1') then
                            current_state <= INIT;
                            initialized := '0';
                            trv_started <= '0';
                        elsif (trv_config(1) = '1' and initialized = '1') then
                            current_state <= WAIT_FIFO;
                        else 
                            trv_started <= '0';
                        end if;
                    when INIT =>
                        current_state <= INIT_DONE;
                    when INIT_DONE =>
                        if (trv_config(0) = '0') then
                            current_state <= IDLE;
                            initialized := '1';
                        end if;
                    when WAIT_FIFO =>
                        if (trv_config(0) = '1') then
                            current_state <= INIT;
                            initialized := '0';
                            trv_started <= '0';
                        elsif (C_M00_AXIS_FIFO_DEPTH - unsigned(fifo_cnt) >= unsigned(trv_n_blocks)) then
                            current_state <= START;
                        end if;
                    when START =>
                        current_state <= IDLE;
                        trv_started <= '1';
                end case;
            end if;
        end if;
    end process;
    
-- User logic ends

end arch_imp;
