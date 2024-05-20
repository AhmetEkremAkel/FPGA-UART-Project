library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_rx is

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
end uart_rx;

architecture Behavioral of uart_rx is

type state_s is (S_IDLE, S_START, S_DATA, S_STOP);

signal state : state_s := S_IDLE;

signal timer_run        : std_logic     := '0';
signal timerlim         : integer       := clk_freq / baudrate;
signal timer            : integer       := 0;
signal timerthic        : std_logic     := '0';
signal bitcounter_lim   : integer       := data_bit_lenght;
signal bitcounter       : integer       := 0;
signal data_out_2       : std_logic_vector(7 downto 0) := (others => '0');


begin

P_MAIN: process(clk) begin

if(rising_Edge(clk)) then

    case state is
        
        when S_IDLE =>
             
             
             data_out_done <= '0';
             if(data_rx = '0') then
                timerlim <= clk_freq / (baudrate*2);
                timer_run <= '1';
                state <= S_START;
             end if;
        
        when S_START =>
        
        
            if(timerthic = '1') then
                timerlim <= clk_freq / (baudrate);
                timer_run <= '1';
                timerthic <= '0';
                state <= S_DATA;
            end if;
            
        when S_DATA =>
            
            if(bitcounter = bitcounter_lim ) then
                state <= S_STOP;
                timer_run <= '1';
                timerthic <= '0';   
                bitcounter <= 0;
                
                else
                    if(timerthic = '1') then
                    
                        if (bitcounter > -1) then
                                data_out_2(6 downto 0) <= data_out_2(7 downto 1);
                        end if;
                            
                        data_out_2(7) <= data_rx;
                        timer_run <= '1';
                        timerthic <= '0';
                        bitcounter <= bitcounter + 1;
                        
                    end if;
            end if;
            
        when S_STOP =>
            if(timerthic = '1') then
                state <= S_IDLE;
                data_out_done <= '1';
                timerthic <= '0';
                data_out <= data_out_2;
            end if;
        
        
        
        
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
