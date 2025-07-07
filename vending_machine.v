`timescale 1ns / 1ps

module vending_machine_fsm(
input clk, rst,
input [8:0] money_i,
input cold_drink_i, dairymilk_i, biscuits_i, redbull_i, chocolated_i,
output reg cold_drink_o, dairymilk_o, biscuits_o, redbull_o, chocolate_o, insufficient_money_o, money_invalid_o,
output reg [8:0] return_change_o
);
 reg [2:0] next_state, pr_state;
 reg items_dispense;
 reg [8:0] required_money;
 reg is_valid_money; 
 wire select_product;
parameter idle=3'b000, product_selection = 3'b001, coin_selection = 3'b010, dispense_item=3'b011, insufficient_money= 3'b100, invalid_money=3'b101;
parameter cost_colddrink = 8'd10, cost_dairymilk = 8'd45, cost_biscuits = 8'd5, cost_redbull =8'd75, cost_imp_choco =8'd135;
     always @(posedge clk or negedge rst) begin
            if (!rst) begin
                pr_state <= idle; 
                return_change_o <=5'd0;
                money_invalid_o <=0;
                {cold_drink_o, dairymilk_o, biscuits_o, redbull_o, chocolate_o, insufficient_money_o} = 6'b0;
            end else begin
                pr_state <= next_state;
            end
        end
   
   
   
    assign select_product = (cold_drink_i | dairymilk_i | biscuits_i | redbull_i | chocolated_i);
    
     always @(*) begin
        is_valid_money = 0;  
        if (money_i >= 5) begin     
            if ((money_i == 100) || (money_i == 50 ) || (money_i == 20 ) || (money_i == 10 ) || (money_i ==5 )) begin
                is_valid_money = 1; 
            end
        end
    end


    
    always @(*) begin
        next_state = pr_state;
        case (pr_state) 
            idle: begin 
                next_state <= (select_product)? product_selection: idle ;
                items_dispense<=0;
                return_change_o<=0;
                 money_invalid_o<=0;
                required_money<=9'd0;
                {cold_drink_o, dairymilk_o, biscuits_o, redbull_o, chocolate_o, insufficient_money_o} = 6'b0;
                end
            product_selection: begin
            next_state <= (money_i) ? coin_selection: product_selection;
                if (cold_drink_i)
                required_money = required_money + cost_colddrink;
                if (dairymilk_i)
                required_money = required_money + cost_dairymilk;
                if (biscuits_i)
                required_money = required_money + cost_biscuits;
                if (redbull_i)
                required_money = required_money + cost_redbull;
                if (chocolated_i)
                required_money = required_money + cost_imp_choco;
                else 
                required_money = required_money; 
            end
            coin_selection: begin
                next_state <= (is_valid_money==0)? invalid_money:(((money_i) >= (required_money))) ? dispense_item: insufficient_money ;
            end
            dispense_item:begin
                next_state <= idle;
                return_change_o = (money_i) - (required_money);
                    if (cold_drink_i)
                    cold_drink_o=1;
                    if (dairymilk_i)
                    dairymilk_o=1;
                    if (biscuits_i)
                    biscuits_o=1;
                    if (redbull_i)
                    redbull_o=1;
                    if (chocolated_i)
                    chocolate_o=1; 
            end
            invalid_money: begin
                next_state <= idle;
                return_change_o <= money_i;
                money_invalid_o<=1;
            end
            insufficient_money: begin 
                next_state <= idle;
                return_change_o <= money_i;
                insufficient_money_o <= 1;
                end
            default: next_state <= idle;
        endcase 
    end

endmodule


