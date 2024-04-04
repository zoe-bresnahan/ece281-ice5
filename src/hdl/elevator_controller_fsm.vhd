--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2018 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : MooreElevatorController.vhd
--| AUTHOR(S)     : Capt Phillip Warner, Capt Dan Johnson, Capt Brian Yarbrough, ***YourName***
--| CREATED       : 03/2018 Last Modified on 06/24/2020
--| DESCRIPTION   : This file implements the ICE5 Basic elevator controller (Moore Machine)
--|
--|  The system is specified as follows:
--|   - The elevator controller will traverse four floors (numbered 1 to 4).
--|   - It has two external inputs, i_up_down and i_stop.
--|   - When i_up_down is active and i_stop is inactive, the elevator will move up 
--|			until it reaches the top floor (one floor per clock, of course).
--|   - When i_up_down is inactive and i_stop is inactive, the elevator will move down 
--|			until it reaches the bottom floor (one floor per clock).
--|   - When i_stop is active, the system stops at the current floor.  
--|   - When the elevator is at the top floor, it will stay there until i_up_down 
--|			goes inactive while i_stop is inactive.  Likewise, it will remain at the bottom 
--|			until told to go up and i_stop is inactive.  
--|   - The system should output the floor it is on (1 - 4) as a four-bit binary number.
--|   - i_reset synchronously puts the FSM into state Floor 2.
--|
--|		Inputs:   i_clk     --> elevator clk
--|				  i_reset   --> reset signal
--|				  i_stop	--> signal tells elevator to stop moving
--|				  i_up_down	--> signal controls elavotor 1=up, 0=down
--|
--|		Outputs:  o_floor (3:0)	--> 4-bit signal  indicating elevator's floor
--|  
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std, unisim
--|    Files     : None
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity elevator_controller_fsm is
    Port ( i_clk     : in  STD_LOGIC;
           i_reset   : in  STD_LOGIC;
           i_stop    : in  STD_LOGIC;
           i_up_down : in  STD_LOGIC;
           o_floor   : out STD_LOGIC_VECTOR (3 downto 0)		   
		 );
end elevator_controller_fsm;


-- Write the code in a similar style as the Lesson 19 ICE (stoplight FSM version 2)
architecture Behavioral of elevator_controller_fsm is

    -- Below you create a new variable type! You also define what values that 
    -- variable type can take on. Now you can assign a signal as 
    -- "sm_floor" the same way you'd assign a signal as std_logic
	-- how would you modify this to go up to 15 floors?
	type sm_floor is (s_floor1, s_floor2, s_floor3, s_floor4);
	
	-- Here you create variables that can take on the values defined above. Neat!	
	signal f_Q, f_Q_next: sm_floor := s_floor2;

begin

	-- CONCURRENT STATEMENTS ------------------------------------------------------------------------------
	-- Next State Logic
    f_Q_next <= s_floor1 when (f_Q = s_floor1 and i_up_down = '0') else --cant go below bottom floor
                -- going up
                s_floor2 when (f_Q = s_floor1 and i_up_down = '1') else
                s_floor3 when (f_Q = s_floor2 and i_up_down = '1') else
                s_floor4 when (f_Q = s_floor3 and i_up_down = '1') else
                --cant go above the top floor
                s_floor4 when (f_Q = s_floor4 and i_up_down = '1') else
                
                -- going down
                s_floor3 when (f_Q = s_floor4 and i_up_down = '0') else
                s_floor2 when (f_Q = s_floor3 and i_up_down = '0') else
                s_floor1 when (f_Q = s_floor2 and i_up_down = '0') else
                f_Q; -- default case
  
	-- Output logic
    with f_Q select
        o_floor <= "0001" when s_floor1,
                   "0011" when s_floor3,
                   "0100" when s_floor4,
                   "0010" when others; -- default is floor 2
	
	-------------------------------------------------------------------------------------------------------
	
	-- PROCESSES ------------------------------------------------------------------------------------------	
	-- State memory ------------
	register_proc : process (i_clk)
    begin
         -- synchronous reset
--        if (rising_edge(i_clk)) and  i_reset = '1' then
--            f_Q <= s_floor2;
--        -- if elevator is enabled, advance floors
--        elsif (rising_edge(i_clk)) and i_stop = '1' then
--            f_Q <= f_Q_next;
--        -- if not enabled, stay at current floor
--        elsif (rising_edge(i_clk)) and i_stop = '0' then
--            f_Q <= f_Q;

        --easier way to do the same as above   
        if rising_edge(i_clk) then
            if i_reset = '1' then
            --go to floor 2
                f_Q <= s_floor2;
            elsif i_stop = '0' then
            --move floors
                f_Q <= f_Q_next;
            else
            --stay on same floor
                f_Q <= f_Q;
            end if;
        end if;
        
	end process register_proc;	
	
	-------------------------------------------------------------------------------------------------------
	
	



end Behavioral;

