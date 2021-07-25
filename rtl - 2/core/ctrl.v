







//跳转控制、流水线控制、寄存器读写控制
module CTRL (
    input wire i_clk,
    input wire i_rst_n,
    
    input wire i_jump_flag,
    input wire i_ex_busy,


    // input wire[4:0] i_id_rs1_addr,
    // input wire[4:0] i_id_rs2_addr,
    // input wire[4:0] i_rb_rd_addr,
    //如果是load指令，则暂停流水线，直到load指令执行完毕
    //暂停3个时钟
    input wire i_opc_load,

    output wire o_if_stop,
    output wire o_if_flush,
    
    output wire o_id_stop,
    output wire o_id_flush

);
    
    
    
    
    //wire clash = (|i_rb_rd_addr) ? ((i_rb_rd_addr == i_id_rs1_addr) | (i_rb_rd_addr == i_id_rs2_addr)) : 0;


    reg[2:0] is_opc_load;

    initial begin
        is_opc_load <= 0;
    end

    always @(negedge i_clk) begin
        case (is_opc_load)
            3'd0:begin
                is_opc_load <= i_opc_load ? 3'd1 : 0;//id_ex
            end
            3'd1: begin
                is_opc_load <= 3'd2;//ex_mem
            end
            3'd2: begin
                is_opc_load <= 3'd0; //mem_rb
            end
            3'd3: begin
                is_opc_load <= 3'd0;
            end
            3'd4: begin
                is_opc_load <= 3'd0;
            end
        endcase
    
        
    end
    
    assign o_if_stop = i_ex_busy | (|is_opc_load) | i_opc_load;
    assign o_if_flush = i_jump_flag ;
    

    
    assign o_id_stop = i_ex_busy | (|is_opc_load) | i_opc_load;
    assign o_id_flush = i_jump_flag | (|is_opc_load) | i_opc_load;


endmodule





















