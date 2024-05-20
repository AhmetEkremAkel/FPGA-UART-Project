library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity tb_uart_tx is
generic(
clk_freq : integer := 100_000_000;
baudrate : integer := 115200;
stopbit  : integer := 2
);
end tb_uart_tx;

architecture Behavioral of tb_uart_tx is

component uart_tx is
generic(
clk_freq : integer := 100_000_000;
baudrate : integer := 115200;
stopbit  : integer := 2
);
port(
clk                : in std_logic;
data               : in std_logic_vector(7 downto 0) ;
send_data          : in std_logic;
tx_o               : out std_logic;
tx_done_o          : out std_logic
);
end component ;

signal clk                : std_logic := '0';
signal data               : std_logic_vector(7 downto 0):= (others => '0') ;
signal send_data          : std_logic:= '0';
signal tx_o               : std_logic;
signal tx_done_o          : std_logic;


constant c_clkperiod	: time := 10 ns;


begin

DUT : uart_tx
generic map(
clk_freq => clk_freq,
baudrate => baudrate,
stopbit  => stopbit
)
port map(
clk   => clk,
data =>  data,
send_data => send_data,
tx_o  => tx_o,
tx_done_o => tx_done_o
);

P_CLKGEN : process begin

clk	<= '0';
wait for c_clkperiod/2;
clk	<= '1';
wait for c_clkperiod/2;

end process P_CLKGEN;

P_SIM : process begin

data <= x"00";
send_data <= '0';

wait for c_clkperiod*10;

data <= x"ab";
send_data <= '1';

wait for c_clkperiod;

send_data <= '0';

wait until (rising_edge(tx_done_o));

wait for c_clkperiod*10;

data <= x"10";
send_data <= '1';

wait for c_clkperiod;

send_data <= '0';

wait until (rising_edge(tx_done_o));

wait for c_clkperiod*10;

data <= x"cc";
send_data <= '1';

wait for c_clkperiod;

send_data <= '0';

wait until (rising_edge(tx_done_o));

wait for 100 ns;

assert false
report "SIM DONE"
severity failure;

end process P_SIM;

end Behavioral;
