`include "defines.v"

module REGS (
    input wire i_clk,
    input wire i_rst_n,

    input wire[4:0] i_rs1_addr,
    input wire[4:0] i_rs2_addr,

    //rd写地址
    input wire[4:0] i_rd_waddr,
    //rd写数据
    input wire[31:0] i_rd_wdata,

    output wire[31:0] o_rs1_rdata,
    output wire[31:0] o_rs2_rdata
);


    reg[31:0] rs[31:0]; 

    assign o_rs1_rdata = (|i_rs1_addr) ? ((i_rs1_addr == i_rd_waddr) ? i_rd_wdata : rs[i_rs1_addr]) :0;

    assign o_rs2_rdata = (|i_rs2_addr) ? ((i_rs2_addr == i_rd_waddr) ? i_rd_wdata : rs[i_rs2_addr]) :0;



    generate
        genvar i;
        for(i=0;i<32;i=i+1)begin
            initial begin
                rs[i] = 0;
            end 
        end
    endgenerate


    always @(negedge i_clk or negedge i_rst_n) begin
        if(i_rst_n == `rst)begin
            
        end
        else if(|i_rd_waddr) begin
            rs[i_rd_waddr] <= i_rd_wdata;
        end
    end


   
       
    wire[31:0] r0=0;
    wire[31:0] r1=rs[1];
    wire[31:0] r2=rs[2];
    wire[31:0] r3=rs[3];
    wire[31:0] r4=rs[4];
    wire[31:0] r5=rs[5];
    wire[31:0] r6=rs[6];
    wire[31:0] r7=rs[7];
    wire[31:0] r8=rs[8];
    wire[31:0] r9=rs[9];
    wire[31:0] r10=rs[10];
    wire[31:0] r11=rs[11];
    wire[31:0] r12=rs[12];
    wire[31:0] r13=rs[13];
    wire[31:0] r14=rs[14];
    wire[31:0] r15=rs[15];
    wire[31:0] r16=rs[16];
    wire[31:0] r17=rs[17];
    wire[31:0] r18=rs[18];
    wire[31:0] r19=rs[19];
    wire[31:0] r20=rs[20];
    wire[31:0] r21=rs[21];
    wire[31:0] r22=rs[22];
    wire[31:0] r23=rs[23];
    wire[31:0] r24=rs[24];
    wire[31:0] r25=rs[25];
    wire[31:0] r26=rs[26];
    wire[31:0] r27=rs[27];
    wire[31:0] r28=rs[28];
    wire[31:0] r29=rs[29];
    wire[31:0] r30=rs[30];
    wire[31:0] r31=rs[31];






    
endmodule