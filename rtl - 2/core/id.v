`include "defines.v"








//译码模块
module ID (
    input wire i_clk,
    input wire i_rst_n,

    //解码出的具体指令
    output wire[`decinfo_wigth:0] o_dec_data,
    //csr地址
    output wire[11:0] o_csr_addr,

    //rd寄存器写地址
    output wire[4:0] o_rd_addr1,
    output wire[4:0] o_rd_addr2,
    //rs1读地址
    output wire[4:0] o_rs1_addr,

    //rs2读地址
    output wire[4:0] o_rs2_addr,

    //立即数
    output wire[31:0] o_imm_data,
    
    //如果是opc_load指令，那么则暂停取指直到opc_load执行完毕
    output wire o_opc_load,


/*分割线*/
    //上级传递下来的指令地址
    input wire[31:0] i_iaddr,
    input wire[31:0] i_idata
);


    assign inst_o = i_idata;

    // 取出指令中的每一个域
    wire[6:0] opc = i_idata[6:0];
    wire[2:0] func = i_idata[14:12];
    wire[6:0] func7 = i_idata[31:25];
    wire[4:0] rd = i_idata[11:7];
    wire[4:0] rs1 = i_idata[19:15];
    wire[4:0] rs2 = i_idata[24:20];
    wire[11:0] type_i_imm_11_0 = i_idata[31:20];
    wire[6:0] type_s_imm_11_5 = i_idata[31:25];
    wire[4:0] type_s_imm_4_0 = i_idata[11:7];
    wire[6:0] type_b_imm_12_10_5 = i_idata[31:25];
    wire[4:0] type_b_imm_4_1_11 = i_idata[11:7];
    wire[19:0] type_u_imm_31_12 = i_idata[31:12];
    wire[19:0] type_j_imm_31_12 = i_idata[31:12];

    // 指令opc域的取值
    wire opc_lui = (opc == `opc_lui);
    wire opc_auipc = (opc == `opc_auipc);
    wire opc_jal = (opc == `opc_jal);
    wire opc_jalr = (opc == `opc_jalr);
    wire opc_branch = (opc == `opc_branch);
    wire opc_load = (opc == `opc_load);
    wire opc_store = (opc == `opc_store);
    wire opc_opimm = (opc == `opc_opimm);
    wire opc_op = (opc == `opc_op);
    wire opc_fence = (opc == `opc_fence);
    wire opc_system = (opc == `opc_system);

    // 指令func域的取值
    wire func_000 = (func == 3'b000);
    wire func_001 = (func == 3'b001);
    wire func_010 = (func == 3'b010);
    wire func_011 = (func == 3'b011);
    wire func_100 = (func == 3'b100);
    wire func_101 = (func == 3'b101);
    wire func_110 = (func == 3'b110);
    wire func_111 = (func == 3'b111);

    // 指令func7域的取值
    wire func7_0000000 = (func7 == 7'b0000000);
    wire func7_0100000 = (func7 == 7'b0100000);
    wire func7_0000001 = (func7 == 7'b0000001);

    // I类型指令imm域的取值
    wire type_i_imm_000000000000 = (type_i_imm_11_0 == 12'b000000000000);
    wire type_i_imm_000000000001 = (type_i_imm_11_0 == 12'b000000000001);

/*********************************************************/
    // 译码出具体指令
    /*j*/
    wire inst_lui = opc_lui;
    wire inst_auipc = opc_auipc;
    wire inst_jal = opc_jal;
    wire inst_jalr = opc_jalr & func_000;
    /*branch*/
    wire inst_beq = opc_branch & func_000;
    wire inst_bne = opc_branch & func_001;
    wire inst_blt = opc_branch & func_100;
    wire inst_bge = opc_branch & func_101;
    wire inst_bltu = opc_branch & func_110;
    wire inst_bgeu = opc_branch & func_111;
    /*load*/
    wire inst_lb = opc_load & func_000;
    wire inst_lh = opc_load & func_001;
    wire inst_lw = opc_load & func_010;
    wire inst_lbu = opc_load & func_100;
    wire inst_lhu = opc_load & func_101;
    /*store*/
    wire inst_sb = opc_store & func_000;
    wire inst_sh = opc_store & func_001;
    wire inst_sw = opc_store & func_010;
    /*opimm*/
    wire inst_addi = opc_opimm & func_000;
    wire inst_slti = opc_opimm & func_010;
    wire inst_sltiu = opc_opimm & func_011;
    wire inst_xori = opc_opimm & func_100;
    wire inst_ori = opc_opimm & func_110;
    wire inst_andi = opc_opimm & func_111;
    wire inst_slli = opc_opimm & func_001 & func7_0000000;
    wire inst_srli = opc_opimm & func_101 & func7_0000000;
    wire inst_srai = opc_opimm & func_101 & func7_0100000;
    /*op*/
    wire inst_add = opc_op & func_000 & func7_0000000;
    wire inst_sub = opc_op & func_000 & func7_0100000;
    wire inst_sll = opc_op & func_001 & func7_0000000;
    wire inst_slt = opc_op & func_010 & func7_0000000;
    wire inst_sltu = opc_op & func_011 & func7_0000000;
    wire inst_xor = opc_op & func_100 & func7_0000000;
    wire inst_srl = opc_op & func_101 & func7_0000000;
    wire inst_sra = opc_op & func_101 & func7_0100000;
    wire inst_or = opc_op & func_110 & func7_0000000;
    wire inst_and = opc_op & func_111 & func7_0000000;
    /*fence*/
    wire inst_fence = opc_fence & func_000;
    wire inst_fencei = opc_fence & func_001;
    /*system*/
    wire inst_ecall = opc_system & func_000 & type_i_imm_000000000000;
    wire inst_ebreak = opc_system & func_000 & type_i_imm_000000000001;
    wire inst_csrrw = opc_system & func_001;
    wire inst_csrrs = opc_system & func_010;
    wire inst_csrrc = opc_system & func_011;
    wire inst_csrrwi = opc_system & func_101;
    wire inst_csrrsi = opc_system & func_110;
    wire inst_csrrci = opc_system & func_111;

    /*M拓展*/
    wire inst_mul = opc_op & func_000 & func7_0000001;
    wire inst_mulh = opc_op & func_001 & func7_0000001;
    wire inst_mulhsu = opc_op & func_010 & func7_0000001;
    wire inst_mulhu = opc_op & func_011 & func7_0000001;
    wire inst_div = opc_op & func_100 & func7_0000001;
    wire inst_divu = opc_op & func_101 & func7_0000001;
    wire inst_rem = opc_op & func_110 & func7_0000001;
    wire inst_remu = opc_op & func_111 & func7_0000001;
/*********************************************************/

    // 指令中的立即数
    wire[31:0] inst_u_type_imm = {i_idata[31:12], 12'b0};
    wire[31:0] inst_j_type_imm = {{12{i_idata[31]}}, i_idata[19:12], i_idata[20], i_idata[30:21], 1'b0};
    wire[31:0] inst_b_type_imm = {{20{i_idata[31]}}, i_idata[7], i_idata[30:25], i_idata[11:8], 1'b0};
    wire[31:0] inst_s_type_imm = {{20{i_idata[31]}}, i_idata[31:25], i_idata[11:7]};
    wire[31:0] i_idata_type_imm = {{20{i_idata[31]}}, i_idata[31:20]};
    //csr zimm
    wire[31:0] inst_csr_type_imm = {27'h0, i_idata[19:15]};
    wire[31:0] inst_shift_type_imm = {27'h0, i_idata[24:20]};



    //立即数选择
    assign o_imm_data = (opc_lui | opc_auipc) ? inst_u_type_imm :
                        (opc_jal) ? inst_j_type_imm :
                        (opc_jalr | opc_load) ? i_idata_type_imm :
                        (opc_branch) ? inst_b_type_imm :
                        (opc_store) ? inst_s_type_imm :
                        (opc_opimm) ? 
                        ((inst_slli | inst_srli | inst_srai) ? inst_shift_type_imm : i_idata_type_imm) :
                        (inst_ecall | inst_ebreak) ? i_idata_type_imm ://这里把ecall和ebreak的后12位当作立即数处理
                        0;

    //csr寄存器地址
    assign o_csr_addr = opc_system ? i_idata_type_imm : 0;



    // 是否需要写rd寄存器
    wire access_rd =    opc_lui     |
                        opc_auipc   |
                        opc_jal     |
                        opc_jalr    |
                        opc_opimm   |
                        opc_op      |
                        opc_system;
    assign o_rd_addr1 = access_rd ? rd: 5'h0;
    assign o_rd_addr2 = opc_load ? rd:5'd0;

    // 是否需要访问rs1寄存器
    wire access_rs1 =   opc_jalr    |
                        opc_branch  |
                        opc_load    |
                        opc_store   |
                        opc_opimm   |
                        opc_op      |
                        inst_csrrw  |
                        inst_csrrs  |
                        inst_csrrc;
    assign o_rs1_addr = access_rs1 ? rs1: 5'h0;


    // 是否需要访问rs2寄存器
    wire access_rs2 = opc_branch    |
                        opc_store   |
                        opc_op;
    assign o_rs2_addr = access_rs2? rs2: 5'h0;




    //是否需要进行数学计算
    //这个标志貌似可有可无
    assign o_dec_data[`decinfo_alu] = opc_lui | opc_auipc | opc_jal | opc_jalr | opc_branch | opc_load | opc_store | opc_opimm | opc_op;

    //alu b位是否选择立即数
    assign o_dec_data[`decinfo_b] = opc_lui | opc_auipc | opc_jal | opc_jalr | opc_load | opc_store | opc_opimm;

    //alu pc是否参与计算,是否是jal等跳转指令
    assign o_dec_data[`decinfo_pc] = opc_auipc | opc_jal ;

    //是否是条件分支指令
    assign o_dec_data[`decinfo_branch] = opc_branch;

    //是否需要强制跳转
    assign o_dec_data[`decinfo_jal] = opc_jal | opc_jalr;

    //是否需要读内存
    assign o_dec_data[`decinfo_rdbus] = opc_load;
    //是否需要写内存
    assign o_dec_data[`decinfo_wdbus] = opc_store;


    //是否要读写csr寄存器
    assign o_dec_data[`decinfo_wcsr] = opc_system & (~(inst_ecall | inst_ebreak));



    assign o_dec_data[`decinfo_func3] = (opc_lui | opc_auipc | opc_jal) ? 0 : func;
    assign o_dec_data[`decinfo_func7] = (inst_slli | inst_srli | inst_srai | opc_op) ? func7 : 0;


    assign o_opc_load = opc_load;
    
endmodule







module ID_EX (
    input wire i_clk,
    input wire i_rst_n,
    //流水线暂停
    input wire i_pipe_stop,
    //流水线冲刷
    input wire i_pipe_flush,

    /**/
    input wire[`decinfo_wigth:0] i_dec_data,
    input wire[11:0] i_csr_addr,
    input wire[4:0] i_rd_addr1,
    input wire[4:0] i_rd_addr2,
    input wire[4:0] i_rs1_addr,
    input wire[4:0] i_rs2_addr,
    input wire[31:0] i_imm_data,
    input wire i_opc_load,
    input wire[31:0] i_iaddr,

    output reg[`decinfo_wigth:0] o_dec_data,
    output reg[11:0] o_csr_addr,
    output reg[4:0] o_rd_addr1,
    output reg[4:0] o_rd_addr2,
    output reg[4:0] o_rs1_addr,
    output reg[4:0] o_rs2_addr,
    output reg[31:0] o_imm_data,
    output reg o_opc_load,
    output reg[31:0] o_iaddr

    
);
    wire en = (~i_pipe_stop) | i_pipe_flush;


    wire[`decinfo_wigth:0] dec_data= i_pipe_flush ? 0 : i_dec_data;
    wire[11:0] csr_addr= i_pipe_flush ? 0 : i_csr_addr;
    wire[4:0] rd_addr1= i_pipe_flush ? 0 : i_rd_addr1;
    wire[4:0] rd_addr2= i_pipe_flush ? 0 : i_rd_addr2;
    wire[4:0] rs1_addr= i_pipe_flush ? 0 : i_rs1_addr;
    wire[4:0] rs2_addr= i_pipe_flush ? 0 : i_rs2_addr;
    wire[31:0] imm_data= i_pipe_flush ? 0 : i_imm_data;
    wire opc_load= i_pipe_flush ? 0 : i_opc_load;
    wire[31:0] iaddr = i_pipe_flush ? 0 : i_iaddr;




    initial begin
        o_dec_data <=  0 ;
        o_csr_addr <=0;
        o_rd_addr1<= 0;
        o_rd_addr2<= 0;
        o_rs1_addr <= 0 ;
        o_rs2_addr <= 0 ;
        o_imm_data <= 0 ;
        o_opc_load <= 0;
        o_iaddr <= 0 ;
    end
    

    always @(posedge i_clk or negedge i_rst_n) begin
        if(i_rst_n == `rst)begin
            o_dec_data <=  0 ;
            o_csr_addr <=0;
            o_rd_addr1 <=  0 ;
            o_rs1_addr <=  0 ;
            o_rs2_addr <=  0 ;
            o_imm_data <= 0 ;
            o_opc_load <= 0;
            o_iaddr <= 0 ;
        end
        else if(en == `en)begin
            o_dec_data <= dec_data;
            o_csr_addr <= csr_addr;
            o_rd_addr1 <= rd_addr1;
            o_rd_addr2 <= rd_addr2;
            o_rs1_addr <= rs1_addr;
            o_rs2_addr <= rs2_addr;
            o_imm_data <= imm_data;
            o_opc_load <= opc_load;
            o_iaddr <= iaddr;
        end
    end


    
endmodule











