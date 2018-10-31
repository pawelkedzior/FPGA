--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:36:49 08/26/2016
-- Design Name:   
-- Module Name:   E:/Pliki/PONG/Test.vhd
-- Project Name:  PONG
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: PONG
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY Test IS
END Test;
 
ARCHITECTURE behavior OF Test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PONG
    PORT(
         VGA_R : OUT  std_logic_vector(3 downto 0);
         VGA_G : OUT  std_logic_vector(3 downto 0);
         VGA_B : OUT  std_logic_vector(3 downto 0);
         VGA_HSYNC : OUT  std_logic;
         VGA_VSYNC : OUT  std_logic;
         WS : IN  std_logic;
         PN : IN  std_logic;
         PD : IN  std_logic;
         ZA : IN  std_logic;
         CLK_50MHZ : IN  std_logic;
         RESET : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal WS : std_logic := '0';
   signal PN : std_logic := '0';
   signal PD : std_logic := '0';
   signal ZA : std_logic := '0';
   signal CLK_50MHZ : std_logic := '0';
   signal RESET : std_logic := '0';

 	--Outputs
   signal VGA_R : std_logic_vector(3 downto 0);
   signal VGA_G : std_logic_vector(3 downto 0);
   signal VGA_B : std_logic_vector(3 downto 0);
   signal VGA_HSYNC : std_logic;
   signal VGA_VSYNC : std_logic;

   -- Clock period definitions
   constant CLK_50MHZ_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PONG PORT MAP (
          VGA_R => VGA_R,
          VGA_G => VGA_G,
          VGA_B => VGA_B,
          VGA_HSYNC => VGA_HSYNC,
          VGA_VSYNC => VGA_VSYNC,
          WS => WS,
          PN => PN,
          PD => PD,
          ZA => ZA,
          CLK_50MHZ => CLK_50MHZ,
          RESET => RESET
        );

   -- Clock process definitions
   CLK_50MHZ_process :process
   begin
		CLK_50MHZ <= '0';
		wait for CLK_50MHZ_period/2;
		CLK_50MHZ <= '1';
		wait for CLK_50MHZ_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for 10 ms;

      -- insert stimulus here 

      wait;
   end process;

END;
