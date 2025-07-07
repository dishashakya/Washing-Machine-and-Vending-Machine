`timescale 1ns / 1ps

module vending_machine_tb();
reg clk, rst;
reg cold_drink_i, dairymilk_i, biscuits_i, redbull_i, chocolated_i;
reg [8:0] money_i;
wire cold_drink_o, dairymilk_o, biscuits_o, redbull_o, chocolate_o, insufficient_money_o, money_invalid_o;
wire [8:0] return_change_o;
    vending_machine_fsm dut (.clk(clk),
        .rst(rst),
        .cold_drink_i(cold_drink_i), 
        .dairymilk_i(dairymilk_i), 
        .biscuits_i(biscuits_i),
        .redbull_i(redbull_i), 
        .chocolated_i(chocolated_i),
        .money_i(money_i), 
        .cold_drink_o(cold_drink_o), 
        .dairymilk_o(dairymilk_o), 
        .biscuits_o(biscuits_o), 
        .redbull_o(redbull_o), 
        .chocolate_o(chocolate_o), 
        .insufficient_money_o(insufficient_money_o), 
        .return_change_o(return_change_o),
        .money_invalid_o(money_invalid_o)
        ); 
        
        initial begin
            clk =0;
            forever #5 clk = ~clk;
        end
        initial begin
  
            rst = 0;
            {cold_drink_i, dairymilk_i, biscuits_i, redbull_i, chocolated_i} = 5'b00000;
            money_i = 9'd0;
            #20;  
    
            rst = 1;
            #20;  
            rst = 0;
            #10;
            rst = 1;
            {cold_drink_i, dairymilk_i, biscuits_i, redbull_i, chocolated_i} = 5'b10010;  // Select cold drink and redbull
            money_i = 9'd100;  
            #45;  
    
            
            {cold_drink_i, dairymilk_i, biscuits_i, redbull_i, chocolated_i} = 5'b01100;  // Select dairymilk and biscuits
            money_i = 9'd50;
            #45;
            
            {cold_drink_i, dairymilk_i, biscuits_i, redbull_i, chocolated_i} = 5'b00000;  // Select dairymilk and biscuits
            money_i = 9'd50;
            #45;
    
            {cold_drink_i, dairymilk_i, biscuits_i, redbull_i, chocolated_i} = 5'b00001;  // Select chocolate
            money_i = 9'd100;  
            #45;
            
            {cold_drink_i, dairymilk_i, biscuits_i, redbull_i, chocolated_i} = 5'b10010;
            money_i = 9'd100; #45;
            
            {cold_drink_i, dairymilk_i, biscuits_i, redbull_i, chocolated_i} = 5'b01101;
            money_i = 9'd100; #45;
            
            {cold_drink_i, dairymilk_i, biscuits_i, redbull_i, chocolated_i} = 5'b10100;
            money_i = 9'd50; #45;
            
            {cold_drink_i, dairymilk_i, biscuits_i, redbull_i, chocolated_i} = 5'b10100;
            money_i = 9'd107; #45;
            
            rst = 0;  
            #20;
            $finish;
        end
endmodule

