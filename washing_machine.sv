module washing_machine_fsm(
    input clk, rst,
    input coin_deposit_i,double_wash_i, spin_interrupt_i,
    output reg done_o,
    output reg off_interrupt_o
);
    reg [2:0] next_state, pr_state;
    reg [3:0] timer;      
    reg timer_en;   
    reg [1:0] wash_count; 
    wire T;               
    
    parameter S_coin = 3'b000, S_soak = 3'b001, S_wash = 3'b010, S_rinse = 3'b011, 
              S_spin = 3'b100, S_done = 3'b101, S_off_interrupt = 3'b110;
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            timer <= 0;
            timer_en <= 0;
        end else if (timer_en) begin
            if (timer < 2) 
                timer <= timer + 1;
            else 
                timer <= 0;  
        end else begin
            timer <= 0;  
        end
    end

assign T = (timer == 2);  


    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            done_o <= 0;
            pr_state <= S_coin; 
        end else begin
            pr_state <= next_state;
        end
    end

   // Wash cycle counter logic for double wash
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            wash_count <= 0;
        end else if (pr_state == S_wash && T) begin
            if (wash_count < 2)
                wash_count <= wash_count + 1;  // Increment wash count after each wash cycle
        end else if (pr_state != S_wash) begin
            wash_count <= 0;  
        end
    end

    always @(*) begin
        next_state = pr_state;
        case (pr_state) 
            S_coin: next_state = (coin_deposit_i) ? S_soak : S_coin;
            S_soak: next_state = (T) ? S_wash : S_soak;
            S_wash: begin
                if (T) begin
                    if (double_wash_i && wash_count < 1) 
                        next_state = S_wash;  
                    else 
                        next_state = S_rinse;  
                end else begin
                next_state = S_wash;
                end
            end
            S_rinse: next_state = (T) ? S_spin : S_rinse;  
            S_spin: next_state = (spin_interrupt_i) ? S_off_interrupt : ((T) ? S_done : S_spin);
            S_done: next_state = S_coin;  
            S_off_interrupt: next_state = S_coin;  
            default: next_state = pr_state;
        endcase 
    end


    // Timer enable signal control
    always @(pr_state or spin_interrupt_i) begin
        case (pr_state)
            S_soak, S_wash, S_rinse, S_spin : timer_en <= 1;  
            default: timer_en <= 0;
        endcase
    end
   
   
    always @(pr_state or spin_interrupt_i) begin
        if (!rst) begin
            done_o <= 0;
            off_interrupt_o <= 0;
        end else begin
            case (pr_state)
                S_done: done_o <= 1;
                S_off_interrupt: off_interrupt_o <= 1;
                default: begin
                    done_o <= 0;
                    off_interrupt_o <= 0;
                end
            endcase
        end
    end
endmodule