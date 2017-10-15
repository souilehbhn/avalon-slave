library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accums_qsys is

	generic
	(
		DATA_WIDTH_m : natural := 16
	);
	port
		(
		clk_clk		: IN STD_LOGIC;
		addr			: IN std_logic_vector (2 downto 0);
		read_p		: IN STD_LOGIC;
		write_p		: In std_logic;
		wrdata		: IN signed((DATA_WIDTH_m-1) DOWNTO 0);
		rddata		: OUT signed((DATA_WIDTH_m-1) DOWNTO 0);
		reset			: IN std_logic
	);
	
end entity accums_qsys;

architecture rtl of accums_qsys is

	component accum is
		generic 
		(
			DATA_WIDTH : natural := DATA_WIDTH_m
		);
		port 
	( 
		
		a		   	: in signed((DATA_WIDTH-1) downto 0);
		clk		   : in std_logic;
		enable		: in std_logic;
		sload	   	: in std_logic;
		accum_out    : out signed ((DATA_WIDTH-1) downto 0)
		);
	end component accum;
	
	
	component addcum is

	generic
	(
		DATA_WIDTH : natural := DATA_WIDTH_m
	);

	port 
	(
		a		   : in signed((DATA_WIDTH-1) downto 0);
		b		   : in signed((DATA_WIDTH-1) downto 0);
		clk		   : in std_logic;
		enable		: in std_logic;
		sload	   : in std_logic;
		accum_out    : out signed ((DATA_WIDTH-1) downto 0)
	);
	end component addcum;

--signal	ready_reg						: std_logic;
signal	a_reg, b_reg: signed ((DATA_WIDTH_m-1) downto 0) := (others => '0');
signal	suma_reg, sumb_reg, sumasq_reg, sumbsq_reg, sumab_reg	: signed ((DATA_WIDTH_m-1) downto 0) := (others => '0');
signal 	enable_reg	: std_logic:='0';
signal	sload_reg	: std_logic:='0';

begin
	suma : component accum
		
		port map
			(
				a => a_reg,
				clk => clk_clk,
				enable => enable_reg,
				accum_out => suma_reg,
				sload => sload_reg
			);
			
	sumb : component accum
		
		port map
			(
				a => b_reg,
				clk => clk_clk,
				enable => enable_reg,
				accum_out => sumb_reg,
				sload => sload_reg
			);
	
	sumasq : component addcum
		
		port map
			(
				a => a_reg,
				b => a_reg,
				clk => clk_clk,
				enable => enable_reg,
				accum_out => sumasq_reg,
				sload => sload_reg
			);
			
	sumbsq : component addcum
		
		port map
			(
				a => b_reg,
				b => b_reg,
				clk => clk_clk,
				enable => enable_reg,
				accum_out => sumbsq_reg,
				sload => sload_reg
			);
	
	sumab : component addcum
		
		port map
			(
				a => a_reg,
				b => b_reg,
				clk => clk_clk,
				enable => enable_reg,
				accum_out => sumab_reg,
				sload => sload_reg
			);
			
process (clk_clk,reset)
	begin
	
	if(rising_edge(clk_clk)) then
	
	
	if(write_p = '1') then
		case addr is
			when "000" => a_reg <= wrdata; enable_reg <= '0';
			when "001" => b_reg <= wrdata; enable_reg <= '0';
			when "010" => enable_reg <= '1' ;
			when "111" => sload_reg <= '0'; enable_reg <= '0';
		-- Sequential Statement(s)
		--	when "010" => c_reg <= wrdata;
		--	when "011" => d_reg <= wrdata((DATA_WIDTH_m-1) downto 0);
		--	when "100" => if (wrdata = 0) then ready_reg <= '1'; else ready_reg <= '0'; end if;
		--	when "101" => rddata <= result_reg;
			when others => a_reg <= (others=>'0'); enable_reg <= '0';
		end case;
	end if;
	if(read_p = '1') then
		case addr is
			when "000" => rddata <=suma_reg;
			when "001" => rddata <=sumb_reg;
			when "010" => rddata <=sumasq_reg;
			when "011" => rddata <=sumbsq_reg;
			when "100" => rddata <=sumab_reg;
			when others => rddata <= (others => '0');
		end case;
	end if;
	end if;
	if (reset = '0') then
	a_reg <= (others=>'0'); b_reg <= (others=>'0'); sload_reg <= '0';
	end if;
	
end process;

end rtl;