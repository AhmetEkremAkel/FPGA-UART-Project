library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
generic(
clk_freq                : integer := 100_000_000;
baudrate                : integer := 11520;
stopbit                 : integer := 2;                     --data bitlerinden sonraki '1' değerli stop bitlerinin sayisi
data_bit_lenght         : integer := 8                      --data bitlerinin uzunlugu
);
port(
clk                     : in std_logic ;
switches                : in std_logic_vector(7 downto 0);  -- Gonderilecek veri
button                  : in std_logic;                     -- veri gönderme butonu
data_rx                 : in std_logic ;                    -- Alinacak veri
tx_o                    : out std_logic;                    
leds                    : out std_logic_vector(7 downto 0)  --Alinan veriyi gösterecek ledler

);
end top;

architecture Behavioral of top is


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
end component;

component uart_rx is
generic(
clk_freq       : integer := 100_000_000;
baudrate       : integer := 115200;
data_bit_lenght: integer := 8
);
port(
clk                   : in std_logic;
data_rx               : in std_logic ;
data_out              : out std_logic_vector(7 downto 0);
data_out_done         : out std_logic
);
end component;

component debounce is
generic (
clkfreq	: integer := 100_000_000;
debtime	: integer := 1000;
initval	: std_logic	:= '0'
);
port (
clk			: in std_logic;
signal_i	: in std_logic;
signal_o	: out std_logic
);
end component;

signal button_debounced : std_logic := '0';
signal send_data_2      : std_logic := '0';
signal tx_done_o_2      : std_logic := '0';
signal button_next      : std_logic := '0';
signal rx_done_o_2      : std_logic := '0';

begin


button_i : debounce 
generic map(
clkfreq	=> clk_freq,
debtime	=> 1000,
initval	=> '0'
)
port map(
clk			=> clk,
signal_i	=> button,
signal_o	=> button_debounced
);


uart_tx_i : uart_tx
generic map(
clk_freq => clk_freq,
baudrate => baudrate,
stopbit  => stopbit
)
port map(
clk             =>   clk,
data            =>   switches ,
send_data       =>   send_data_2,
tx_o            =>   tx_o ,
tx_done_o       =>   tx_done_o_2                --verinin gönderildigi gösteren bit
);

uart_rx_i : uart_rx
generic map(
clk_freq            => clk_freq,
baudrate            => baudrate,
data_bit_lenght     => data_bit_lenght
)
port map(
clk                   => clk,
data_rx               => data_rx,
data_out              => leds,
data_out_done         => rx_done_o_2        --verinin alındıgını gösteren bit
);


process(clk) begin

button_next <= button_debounced;
if ( button_debounced = '1' and button_next = '0') then
    send_data_2 <= '1';
end if;

end process;



end Behavioral;
