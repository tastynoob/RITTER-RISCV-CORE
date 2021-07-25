`include "defines.v"


//执行模块需要的资源






//逻辑算数运算模块
//加减乘除
//算数右移，逻辑右移，逻辑左移
//异或，或，与，大于，小于
//
module ALU (
    input wire i_clk,
    input wire i_rst_n,

    input wire i_add,
    input wire i_sub,
    input wire i_slt,
    input wire i_sltu,
    input wire i_xor,
    input wire i_or,
    input wire i_and,
    input wire i_sll,
    input wire i_srl,
    input wire i_sra,
    //alu使能
    input wire i_en,

    //c是否参与计算
    input wire i_c_e,

    input wire[31:0] A,
    input wire[31:0] B,
    input wire[31:0] C,
    output wire[31:0] Y,

    output reg o_finish

);

    wire[31:0] o_add;
    assign o_add = A + B + (i_c_e ? C : 0);

    wire[31:0] o_sub;
    assign o_sub = A - B;

    wire[31:0] o_slt;//有符号数 小于 
    assign o_slt = (A[31] ^ B[31]) ? (A[31] ? 1 : 0) : (A[30:0] < B[30:0]);

    wire[31:0] o_sltu;//无符号 小于
    assign o_sltu = A < B;


    wire[31:0] o_xor;
    assign o_xor = A^B;

    wire[31:0] o_or;
    assign o_or = A|B;

    wire[31:0] o_and;
    assign o_and = A&B;

    wire[31:0] o_sll;
    assign o_sll = A << B;

    wire[31:0] o_srl;
    assign o_srl = A >> B;

    wire[31:0] o_sra;
    assign o_sra = A >>> B;



    assign Y = i_add ? o_add :
                i_sub ? o_sub :
                i_slt ? o_slt :
                i_sltu ? o_sltu :
                i_xor ? o_xor:
                i_or ? o_or :
                i_and ? o_and :
                i_sll ? o_sll :
                i_srl ? o_srl :
                i_sra ? o_sra : 0;

    
    wire en = i_add | i_sub | i_slt | i_sltu | i_xor | i_or | i_and | i_sll | i_srl | i_sra;

    initial begin
        o_finish = `en;
    end

    always @(posedge i_clk or negedge i_rst_n) begin
        if(i_rst_n == `rst)begin
            o_finish = `en;
        end
        else if(en) begin
            o_finish = `en;
        end
        else begin
            o_finish = `en;
        end
    end




















    
endmodule



































