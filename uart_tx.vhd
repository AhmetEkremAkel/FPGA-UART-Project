library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_tx is
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
end uart_tx;



architecture Behavioral of uart_tx is



type state_s is (S_IDLE, S_START, S_DATA, S_STOP);

signal state : state_s := S_IDLE;

signal timer                     : integer   := 0;
signal timerlim                  : integer   := clk_freq / baudrate;
signal timerthic                 : std_logic := '0';
signal timer_run                 : std_logic := '0';
signal data_2                    : std_logic_vector (7 downto 0) := (others => '0');
signal bitcounter                : integer   := 0;
signal bitcounter_lim            : integer   := 8;
signal stopbit_counter           : integer   := 0;
signal stopbit_counter_lim       : integer   := stopbit;


begin

P_MAIN : process(clk) begin
if(rising_edge(clk)) then
    
    case state is

        when S_IDLE =>
            tx_o <= '1';
            tx_done_o <= '0';
            timerthic <= '0';
            
            if (send_data = '1') then
                state <= S_START;
                timer_run <= '1';
                tx_o <= '0';

            end if;
        

        when S_START =>
            
            timerthic <= '0';
            if (timerthic = '1') then
                state <= S_DATA;
                data_2 <= data;
                timerthic <= '0';
                timer_run <= '1';
            end if;
            

        when S_DATA =>
            
            tx_o <= data_2(0);
            if(bitcounter = bitcounter_lim) then
                tx_o <= '1';
                state <= S_STOP;
                timer_run <= '1';
                timerthic <= '0';
            else
                if (timerthic = '1') then
                    bitcounter <= bitcounter + 1;

                    data_2(6 downto 0) <= data_2(7 downto 1);
                    tx_o <= data_2(0);
                    timerthic <= '0';
                    timer_run <= '1';
                end if;
            end if;

        when S_STOP =>


            bitcounter <= 0;
            
            if(stopbit_counter = stopbit_counter_lim)then
                tx_done_o <= '1';
                tx_o <= '1';
                state <= S_IDLE;
                stopbit_counter <= 0;
                timerthic <= '0';
            else
                if (timerthic = '1') then
                    stopbit_counter <= stopbit_counter + 1;
                    timerthic <= '0';
                end if;
            end if;

            timer_run <= '1';
            


    end case;
    
    if(timer_run = '1') then

        if(timer = timerlim) then

            timerthic <= '1';
            timer <= 0;
            timer_run <= '0';

        else
            timer <= timer + 1;
        end if;
    end if;
    
end if;
end process;


end Behavioral;
