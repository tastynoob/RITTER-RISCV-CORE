`include "defines.v"


//重写写回模块


module TOP (
    input wire i_clk,
    input wire i_rst_n,


    //ibus
    output wire[31:0] o_ibus_addr,
    input wire[31:0] i_ibus_data,
    output wire o_ibus_req,
    input wire i_ibus_rsp,

    //dbus
    output wire[31:0] o_dbus_addr,//dbus访问地址,连入ex_mem:ex_data
    input wire[31:0] i_dbus_rdata,//dbus读入的数据
    output wire[31:0] o_dbus_wdata,//dbus写入的数据
    output wire[3:0] o_dbus_sel,
    output wire o_dbus_we,
    output wire o_dbus_req,
    input wire i_dbus_rsp

);


    
    
    wire ctrl_jump_flag;
    wire ctrl_ex_busy;
    wire ctrl_if_stop;
    wire ctrl_if_flush;
    wire ctrl_id_stop;
    wire ctrl_id_flush;
    wire ctrl_opc_load;

    wire[4:0] id_ex_rs1_addr_regs;
    wire[4:0] id_ex_rs2_addr_regs;

    wire[4:0] mem_rb_rd_addr;

    CTRL ctrl(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        
        .i_jump_flag(ctrl_jump_flag),
        .i_ex_busy(ctrl_ex_busy),

        // .i_id_rs1_addr(id_ex_rs1_addr_regs),
        // .i_id_rs2_addr(id_ex_rs2_addr_regs),
        // .i_rb_rd_addr(mem_rb_rd_addr),
        .i_opc_load(ctrl_opc_load),

        .o_if_stop(ctrl_if_stop),
        .o_if_flush(ctrl_if_flush),
        
        .o_id_stop(ctrl_id_stop),
        .o_id_flush(ctrl_id_flush)
    );


    wire[31:0] if_iaddr_if_id,if_idata_if_id;
    //此处是ex模块输出
    wire[31:0] ex_result;

    IF if_(
    /*系统时钟，复位*/
        //时钟信号
        .i_clk(i_clk),
        //复位信号
        .i_rst_n(i_rst_n),
    /*pc写*/
        //pc写
        .i_pc_we(ctrl_jump_flag),
        .i_pc_wdata(ex_result),
    /*pipe控制*/
        .i_pipe_stop(ctrl_if_stop),
    /*ibus*/
        //ibus读取地址
        .o_ibus_addr(o_ibus_addr),
        //ibus读取数据
        .i_ibus_data(i_ibus_data),
        //ibus请求信号
        .o_ibus_req(o_ibus_req),
        //ibus响应信号
        .i_ibus_rsp(i_ibus_rsp),
    /*传递给if_id*/
        //传递给下级流水线的ibus地址
        .o_iaddr(if_iaddr_if_id),
        //传递给下级流水线的ibus数据
        .o_idata(if_idata_if_id)

    );



    wire[31:0] if_id_iaddr_id;
    wire[31:0] if_id_idata_id;

    IF_ID if_id(
        /*系统时钟，复位*/
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        
    /*pipe控制*/

        //流水线暂停
        .i_pipe_stop(ctrl_if_stop),
        //流水线冲刷
        .i_pipe_flush(ctrl_if_flush),
        
    /*if模块输入*/
        //上级输入的指令地址
        .i_iaddr(if_iaddr_if_id),
        //ibus输出的指令数据,
        .i_idata(if_idata_if_id),

    /*传递给id模块*/

        //传递给下级的指令地址
        .o_iaddr(if_id_iaddr_id),
        //输出的指令数据
        .o_idata(if_id_idata_id)
    );

    wire[`decinfo_wigth:0] id_dec_data_id_ex;
    wire[4:0] id_rd_addr1,
                id_rd_addr2,
                id_rs1_addr_id_ex,
                id_rs2_addr_id_ex;

    wire[31:0] id_imm_data_id_ex;
    wire[11:0] id_csr_addr_id_ex;//csr寄存器组读地址

    wire id_opc_load;

    ID id(
    /*系统时钟，复位*/
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
    /*if_id模块传递*/
        //上级传递下来的指令地址
        .i_iaddr(if_id_iaddr_id),
        .i_idata(if_id_idata_id),
    /*传递给ID_EX*/
        //解码出的具体指令
        .o_dec_data(id_dec_data_id_ex),
        //csr地址
        .o_csr_addr(id_csr_addr_id_ex),
        //rd寄存器写地址
        .o_rd_addr1(id_rd_addr1),
        .o_rd_addr2(id_rd_addr2),
        //rs1读地址
        .o_rs1_addr(id_rs1_addr_id_ex),
        //rs2读地址
        .o_rs2_addr(id_rs2_addr_id_ex),
        //立即数
        .o_imm_data(id_imm_data_id_ex),
        .o_opc_load(id_opc_load)

    );

    
    wire[4:0] id_ex_rd_addr1;
    wire[4:0] id_ex_rd_addr2;

    wire[31:0] id_ex_imm_data_ex;
    wire[31:0] id_ex_iaddr_ex;
    wire[`decinfo_wigth:0] id_ex_dec_data;
    wire[11:0] id_ex_csr_addr_csrs;

    ID_EX id_ex(
    /*系统时钟，复位*/
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
    /*pipe控制*/
        .i_pipe_stop(ctrl_id_stop),
        //流水线冲刷
        .i_pipe_flush(ctrl_id_flush),
    /*ID模块传入*/
        /**/
        .i_dec_data(id_dec_data_id_ex),
        .i_csr_addr(id_csr_addr_id_ex),
        .i_rd_addr1(id_rd_addr1),
        .i_rd_addr2(id_rd_addr2),
        .i_rs1_addr(id_rs1_addr_id_ex),
        .i_rs2_addr(id_rs2_addr_id_ex),
        .i_imm_data(id_imm_data_id_ex),
        .i_opc_load(id_opc_load),
        //这里时if_id传入的pc值
        .i_iaddr(if_id_iaddr_id),
    /*传递给EX模块*/
        .o_dec_data(id_ex_dec_data),
        .o_csr_addr(id_ex_csr_addr_csrs),
        .o_rd_addr1(id_ex_rd_addr1),
        .o_rd_addr2(id_ex_rd_addr2),
        //这里连接regs模块
        .o_rs1_addr(id_ex_rs1_addr_regs),
        //这里连接regs模块
        .o_rs2_addr(id_ex_rs2_addr_regs),
        .o_imm_data(id_ex_imm_data_ex),
        .o_opc_load(ctrl_opc_load),
        .o_iaddr(id_ex_iaddr_ex)
    );

    //此处是rb模块连线
    wire[4:0] rb_rd_addr;
    wire[31:0] rb_rd_data;

    wire[31:0] regs_rs1_data;
    wire[31:0] resg_rs2_data;
    //寄存器组
    REGS regs(
        /*系统时钟，复位*/
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),

        .i_rs1_addr(id_ex_rs1_addr_regs),
        .i_rs2_addr(id_ex_rs2_addr_regs),
        //rd写地址
        .i_rd_waddr(rb_rd_addr),
        //rd写数据
        .i_rd_wdata(rb_rd_data),

        .o_rs1_rdata(regs_rs1_data),
        .o_rs2_rdata(resg_rs2_data)
    );

    wire[31:0] csrs_csr_data_ex;
    wire[31:0] ex_csr_newdata_csrs;

    CSRS csrs(
        /*系统时钟，复位*/
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_csr_addr(id_ex_csr_addr_csrs),

        .o_csr_data(csrs_csr_data_ex),

        .i_we(id_ex_dec_data[`decinfo_wcsr]),

        .i_csr_newdata(ex_csr_newdata_csrs)
    );


    wire ex_jump_flag;
    //wire[31:0] ex_result;
    wire[31:0] ex_rd_data;
    //执行单元
    EX ex(
    /*系统时钟，复位*/
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
    /*id_ex传入*/
        .i_dec_data(id_ex_dec_data),
        .i_imm_data(id_ex_imm_data_ex),
        .i_iaddr(id_ex_iaddr_ex),
    /*regs读取到的*/
        //读取的rs1
        .i_rs1_data(regs_rs1_data),
        //读取的rs2
        .i_rs2_data(resg_rs2_data),
    /*csrs读取*/
        .i_csr_data(csrs_csr_data_ex),

        .o_csr_newdata(ex_csr_newdata_csrs),
    /*pipe控制*/

        //pc跳转标志
        .o_jump_flag(ctrl_jump_flag),

        //执行模块忙碌...
        .o_busy(ctrl_ex_busy),

    /*连接下级流水线*/
        //需要写入的rd值,直接连接regs
        .o_rd_data(ex_rd_data),

        //跳转地址，访存读写地址,同时连接if模块和ex_mem模块
        .o_result(ex_result)
    );

    wire[4:0] ex_mem_rd_addr1;
    wire[4:0] ex_mem_rd_addr2;

    wire[31:0] ex_mem_ex_data;
    wire[31:0] ex_mem_rd_data;
    wire[31:0] ex_mem_rs2_data;
    wire[`decinfo_wigth : 0] ex_mem_dec_data; 

    EX_MEM ex_mem(
    /*系统时钟，复位*/
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
    /*pipe控制*/


    /*上级流水线传入*/

        .i_rd_addr1(id_ex_rd_addr1),
        .i_rd_addr2(id_ex_rd_addr2),

        //需要写rd寄存器的值
        .i_rd_data(ex_rd_data),

        .i_dec_data(id_ex_dec_data),//连接id_ex模块
        .i_rs2_data(resg_rs2_data),//连接regs模块
        .i_ex_data(ex_result),
    /*传递给下级流水线*/

        .o_rd_addr1(ex_mem_rd_addr1),
        .o_rd_addr2(ex_mem_rd_addr2),

        .o_rd_data(ex_mem_rd_data),//连接regs

        .o_dec_data(ex_mem_dec_data),//连接mem

        //访存时，需要读取rs2寄存器的值
        .o_rs2_data(ex_mem_rs2_data),

        //ex计算结果,作为访存地址使用
        .o_ex_data(ex_mem_ex_data)

    );


    //访存地址
    assign o_dbus_addr = ex_mem_ex_data;
    wire[4:0] mem_rd_addr;
    wire[31:0] mem_rd_data;
    MEM mem(
    /*系统时钟，复位*/
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
    /*上级模块输入*/
        .i_dbus_re(ex_mem_dec_data[`decinfo_rdbus]),
        .i_dbus_we(ex_mem_dec_data[`decinfo_wdbus]),
        .i_func3(ex_mem_dec_data[`decinfo_func3]),

        //从rs2读入的数据
        .i_rs2_data(ex_mem_rs2_data),

        //.i_rd_data(ex_mem_rd_data),
    
    /*连接mem_rb模块*/
        //从dbus读出的值或ex运算结果，写入rd寄存器
        .o_rd_wdata(mem_rd_data),

    /*下面是连接dbus总线*/

        //dbus读写位选择,这里是4位
        .o_dbus_sel(o_dbus_sel),
        //dbus写使能
        .o_dbus_we(o_dbus_we),
        //dbus读数据
        .i_dbus_rdata(i_dbus_rdata),
        //dbus写数据
        .o_dbus_wdata(o_dbus_wdata),

        //dbus访问信号
        .o_dbus_req(o_dbus_req),
        //dbus应答信号
        .i_dbus_rsp(i_dbus_rsp)
    );

    
    wire[31:0] mem_rb_rd_data;

    MEM_RB mem_rb(
        /*系统时钟，复位*/
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),

        .i_rd_addr(ex_mem_rd_addr2),
        .i_rd_data(mem_rd_data),

        .o_rd_addr(mem_rb_rd_addr),
        .o_rd_data(mem_rb_rd_data)
    );



    //写回使用的rd_addr数据得用2条线
    RB rb(
        /*系统时钟，复位*/
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),

        //
        .i_rd_addr1(ex_mem_rd_addr1),
        .i_rd_data1(ex_mem_rd_data),

        .i_rd_addr2(mem_rb_rd_addr),
        .i_rd_data2(mem_rb_rd_data),

        .o_rd_addr(rb_rd_addr),
        .o_rd_data(rb_rd_data)
    );






    
endmodule

















