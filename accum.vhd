-- Quartus Prime VHDL Template
-- Signed Multiply-Accumulate

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accum is

	generic
	(
		DATA_WIDTH : natural := 16
	);

	port 
	(
		a		   : in signed((DATA_WIDTH-1) downto 0);
		clk		   : in std_logic;
		enable		: in std_logic;
		sload	   : in std_logic;
		accum_out    : out signed ((DATA_WIDTH-1) downto 0)
	);

end entity;

architecture rtl of accum is

	-- Declare registers for intermediate values
	signal a_reg : signed ((DATA_WIDTH-1) downto 0) := (others => '0');
	signal adder_out : signed ((DATA_WIDTH-1) downto 0) :=(others => '0');
	signal old_result : signed ((DATA_WIDTH-1) downto 0);
	

begin

	process (clk, sload)
	type S_type is (RW, Prcs);
	variable state : S_type :=RW;

	begin
		old_result <= adder_out;
		if (sload = '1') then
			-- Clear the accumulated data
			old_result <= (others => '0');
            adder_out <= (others => '0');
			state := RW;
		elsif (rising_edge(clk)) then
			case state is
			when RW => 
			a_reg <= a;
			if (enable = '1') then
			adder_out <= old_result + a_reg;
			state := Prcs;
			end if;
			when Prcs =>
			if (enable ='0') then
			state := RW;
			end if;
			when others =>
			state := RW;
			end case;
			
		end if;
	end process;
accum_out <= adder_out;
	
end rtl;
