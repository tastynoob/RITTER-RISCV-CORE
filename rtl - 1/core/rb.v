`include "defines.v"




//写回模块
//这里需要进行修改
module RB (
    input wire i_clk,
    input wire i_rst_n,
    
    //ex写
    input wire[4:0] i_rd_addr1,
    input wire[31:0] i_rd_data1,
    //mem写
    input wire[4:0] i_rd_addr2,
    input wire[31:0] i_rd_data2,

    output wire[4:0] o_rd_addr,
    output wire[31:0] o_rd_data

);



    assign o_rd_addr = i_rd_addr1 | i_rd_addr2;
    assign o_rd_data = (|i_rd_addr1) ? i_rd_data1 : i_rd_data2 ;
    







    
endmodule