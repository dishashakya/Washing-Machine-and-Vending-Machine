`timescale 1ns / 1ps

module washing_machine_tb();
    reg clk, rst,coin_deposit_i,double_wash_i, spin_interrupt_i;
    wire done_o, off_interrupt_o;
    washing_machine_fsm dut (.clk(clk),.rst(rst),.coin_deposit_i(coin_deposit_i),.double_wash_i(double_wash_i),.spin_interrupt_i(spin_interrupt_i),.done_o(done_o), .off_interrupt_o(off_interrupt_o));
       initial begin
         clk =0;
         forever #5 clk = ~clk;
        end
     initial begin
        rst = 0;
        coin_deposit_i = 0;
        double_wash_i =0;
        spin_interrupt_i=0;
        // Reset the system
        #10 rst = 1;
        #10 rst = 0;
        #10 rst = 1;
        
        // Apply test vectors (8-bit sequence for parity check)
        #5 coin_deposit_i = 1;   double_wash_i = 0; //changed // bit 3
        #50;
        // Wait for the parity to settle
        #5 coin_deposit_i = 0;  // bit 1
        #10;  // bit 2
        #20 coin_deposit_i =1;
        #10 double_wash_i = 0; //changed // bit 3  // bit 4
        // Wait for the parity to settle
        #10; spin_interrupt_i=1; 
        #20 coin_deposit_i = 0;  // bit 1
         #30 spin_interrupt_i=0; coin_deposit_i = 1;  // bit 1
        // for try module double_wash_i = 1; #10;
        double_wash_i = 1; #30;//for normal module

        #50 coin_deposit_i = 1;  // bit 1

        #20 double_wash_i = 0;  // bit 4
        #10 spin_interrupt_i=0; #10;
        // Wait for the parity to settle

        #250;
        // Check final parity value
        $stop;  // Stop the simulation
    end
endmodule

