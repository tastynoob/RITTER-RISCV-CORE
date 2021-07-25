`include "defines.v"


//用于数据打一拍
module gen_dff #(
    parameter DW = 32)(

    input wire i_clk,
    input wire i_rst_n,

    input wire en,

    input wire[DW-1:0] din,

    output wire[DW-1:0] qout

    );

    reg[DW-1:0] qout_r;

    initial begin
        qout_r=0;
    end

    always @ (posedge i_clk or negedge i_rst_n) begin
        if (i_rst_n == `rst) begin
            qout_r <= {DW{1'b0}};
        end 
        else if (en == `en) begin
            qout_r <= din;
        end
    end

    assign qout = qout_r;

endmodule