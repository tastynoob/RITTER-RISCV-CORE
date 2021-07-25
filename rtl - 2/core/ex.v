`include "defines.v"




//初步测试没问题
module EX (
    input wire i_clk,
    input wire i_rst_n,

    input wire[`decinfo_wigth:0] i_dec_data,

    input wire[31:0] i_csr_data,

    output wire[31:0] o_csr_newdata,

    //读取的rs1
    input wire[31:0] i_rs1_data,
    //读取的rs2
    input wire[31:0] i_rs2_data,
    //读取的imm立即数
    input wire[31:0] i_imm_data,
    //ibus地址
    input wire[31:0] i_iaddr,

/**/

    //pc跳转标志
    output wire o_jump_flag,
    

    //执行模块忙碌...
    output wire o_busy,

    //rd写数据
    output wire[31:0] o_rd_data,

    //连接下级流水线
    //执行结果输出,提供给访存模块
    output wire[31:0] o_result//pc跳转地址，访存读写地址

);

    wire i_add;
    wire i_sub;
    wire i_slt;// 小于
    wire i_sltu;
    wire i_xor;
    wire i_or;
    wire i_and;
    wire i_sll;
    wire i_srl;
    wire i_sra;

    //如果是branch有条件跳转指令，则转化为alu计算
    wire opc_branch = i_dec_data[`decinfo_branch];
    //如果是强制跳转指令
    wire opc_jal = i_dec_data[`decinfo_jal];
    //如果是内存读写指令
    wire opc_mem = i_dec_data[`decinfo_rdbus] | i_dec_data[`decinfo_wdbus];
    //如果要写csr寄存器
    wire opc_csr = i_dec_data[`decinfo_wcsr];
    wire[2:0] func3 = i_dec_data[`decinfo_func3];
    wire[6:0] func7 = i_dec_data[`decinfo_func7];

    wire inst_beq = (func3 == 3'b000);
    wire inst_bne = (func3 == 3'b001);
    wire inst_blt = (func3 == 3'b100);
    wire inst_bge = (func3 == 3'b101);
    wire inst_bltu = (func3 == 3'b110);
    wire inst_bgeu = (func3 == 3'b111);


    assign i_add = opc_mem ? 1 : 
                opc_branch ? 0 : 
                ((func3 == `func_add_sub) & (func7 == `func7_add));

    assign i_sub = opc_mem ? 0 : 
                opc_branch ? (inst_beq | inst_bne) : 
                ((func3 == `func_add_sub) & (func7 == `func7_sub));
                
    assign i_slt = opc_mem ? 0 : 
                opc_branch ? (inst_blt | inst_bge) : 
                (func3 == `func_slt);

    assign i_sltu = opc_mem ? 0 : 
                opc_branch ? (inst_bltu | inst_bgeu) : 
                (func3 == `func_sltu);

    assign i_xor = opc_mem ? 0 :  
                opc_branch ? 0 : 
                (func3 == `func_xor);

    assign i_or = opc_mem ? 0 : 
                opc_branch ? 0 : 
                (func3 == `func_or);

    assign i_and = opc_mem ? 0 : 
                opc_branch ? 0 : 
                (func3 == `func_and);

    assign i_sll = opc_mem ? 0 : 
                opc_branch ? 0 : 
                (func3 == `func_sll);

    assign i_srl = opc_mem ? 0 : 
                opc_branch ? 0 : 
                ((func3 == `func_srl_sra) & (func7 == `func7_srl));

    assign i_sra = opc_mem ? 0 : 
                opc_branch ? 0 : 
                ((func3 == `func_srl_sra) & (func7 == `func7_sra));






    wire[2:0] alu_e;

    assign alu_e = i_dec_data[`decinfo_pc:`decinfo_alu];

    //是否选择立即数作为alu_b输入
    wire[31:0] alu_b = alu_e[1] ? i_imm_data : i_rs2_data;

    wire[31:0] result;
    wire[31:0] jump_addr;

    wire finish;
    assign o_busy = ~finish;
    ALU alu(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),

        .i_add(i_add),
        .i_sub(i_sub),
        .i_slt(i_slt),
        .i_sltu(i_sltu),
        .i_xor(i_xor),
        .i_or(i_or),
        .i_and(i_and),
        .i_sll(i_sll),
        .i_srl(i_srl),
        .i_sra(i_sra),
        //alu使能
        .i_en(alu_e[0]),

        //pc是否参与计算
        .i_c_e(alu_e[2]),

        .A(i_rs1_data),

        .B(alu_b),

        .C(i_iaddr),

        .Y(result),

        .o_finish(finish)
    );


    wire is_zero = (result==0);
    wire[31:0] jump_addr_branch = i_iaddr + i_imm_data;
    //分支跳转地址
    assign jump_addr = (inst_beq | inst_bge | inst_bgeu) ? (is_zero?jump_addr_branch:0) : 
                        (inst_bne|inst_blt|inst_bltu) ? (is_zero?0:jump_addr_branch):0;

    //跳转标志
    assign o_jump_flag = opc_jal |  
                (opc_branch ? ((inst_beq | inst_bge | inst_bgeu) ? (is_zero?1:0) : 
                        (inst_bne|inst_blt|inst_bltu) ? (is_zero?0:1) : 0) : 0);


    //如果是强制跳转，rd = pc + 4;
    //否则正常输出计算结果
    assign o_rd_data = opc_jal ? (i_iaddr + 4) : result;



    //如果是强制跳转，则跳转地址就为alu输出
    assign o_result = opc_jal ? result :
                        opc_branch ? jump_addr :
                        result;


    wire[31:0] csr_new;
    assign csr_new = opc_csr ? (
                        (func3 == `func_csrrw) ? i_rs1_data :
                        (func3 == `func_csrrs) ? i_csr_data | i_rs1_data :
                        (func3 == `func_csrrc) ? i_csr_data & (~i_rs1_data):
                        (func3 == `func_csrrsi)? i_csr_data | (~i_imm_data):
                        (func3 == `func_csrrci)? i_csr_data & (~i_imm_data):
                        i_csr_data
                        ) : i_csr_data;




    //将csr_new 打一拍发送给csr寄存器组
    gen_dff#(32)csr_dff(i_clk,i_rst_n,1,csr_new,o_csr_newdata);

    
endmodule








module EX_MEM (
    input wire i_clk,
    input wire i_rst_n,


    input wire[4:0] i_rd_addr1,
    input wire[4:0] i_rd_addr2,

    input wire[31:0] i_rd_data,
    input wire[`decinfo_wigth:0] i_dec_data,
    input wire[31:0] i_rs2_data,
    input wire[31:0] i_ex_data,

    output reg[4:0] o_rd_addr1,
    output reg[4:0] o_rd_addr2,
    output reg[31:0] o_rd_data,
    output reg[`decinfo_wigth:0] o_dec_data,
    output reg[31:0] o_rs2_data,
    output reg[31:0] o_ex_data

);
    wire en = 1'b1;

    initial begin
        o_rd_addr1 <= 0;
        o_rd_addr2 <= 0;
        o_rd_data <= 0;
        o_dec_data <= 0;
        o_rs2_data <=0;
        o_ex_data <= 0;
    end


    always @(posedge i_clk or negedge i_rst_n) begin
        if(i_rst_n == `rst)begin
            o_rd_addr1 <= 0;
            o_rd_addr2 <= 0;
            o_rd_data <= 0;
            o_dec_data <= 0;
            o_rs2_data <=0;
            o_ex_data <= 0;
        end
        else if (en)begin
            o_rd_addr1 <= i_rd_addr1;
            o_rd_addr2 <= i_rd_addr2;
            o_rd_data <= i_rd_data;
            o_dec_data <= i_dec_data;
            o_rs2_data <= i_rs2_data;
            o_ex_data <= i_ex_data;
        end
    end




endmodule