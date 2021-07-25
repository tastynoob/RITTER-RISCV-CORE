`include "defines.v"
/*


下降沿，i总线数发生变化


*/




//取指模块
module IF (
    //时钟信号
    input wire i_clk,
    //复位信号
    input wire i_rst_n,

/*分割线*/
    //pc写
    input wire i_pc_we,
    input wire[31:0] i_pc_wdata,

    input wire i_pipe_stop,
/*分割线*/

//下面连接ibus总线

    //ibus读取地址
    output wire[31:0] o_ibus_addr,
    //ibus读取数据
    input wire[31:0] i_ibus_data,
    //ibus请求信号
    output reg o_ibus_req,
    //ibus响应信号
    input wire i_ibus_rsp,

/*分割线*/

//下面是传递下一级流水线

    //传递给下级流水线的ibus地址
    output wire[31:0] o_iaddr,


    //传递给下级流水线的ibus数据
    output wire[31:0] o_idata


);

    reg[31:0] pc;//pc寄存器
    reg[31:0] pc_prev;



    initial begin
        pc = 32'h0;
        pc_prev=0;

        o_ibus_req = `dis;
    end


    wire valid = i_ibus_rsp & (~i_pipe_stop) ;

    
    always @(posedge i_clk or negedge i_rst_n) begin

        if(i_rst_n == `rst)begin//复位
            pc <= 32'h0;
            o_ibus_req <= `dis;
        end
        else if(valid)begin
            pc <= (i_pc_we==`en) ? i_pc_wdata : (pc+4);
            
            pc_prev<=pc;

        end
        else if(i_pipe_stop) begin

        end

        //发送ibus访问请求
        o_ibus_req <= `en;
    end


    //将pc打一拍发送给下级流水线
    //gen_dff#(32)pc_dff(i_clk,i_rst_n,valid,pc,o_iaddr);


    assign o_iaddr = pc;

    assign o_ibus_addr = pc;

    assign o_idata = (i_ibus_rsp & (~i_pc_we)) ?  i_ibus_data : `inst_nop;

    
endmodule





//取指与译码模块之间的隔离模块
module IF_ID (
    input wire i_clk,
    input wire i_rst_n,
    
/*分割线*/

    //流水线暂停
    input wire i_pipe_stop,
    //流水线冲刷
    input wire i_pipe_flush,

    
/*分割线*/
    //上级输入的指令地址
    input wire[31:0] i_iaddr,
    
    //ibus输出的指令数据,
    input wire[31:0] i_idata,

/*分割线*/

    //传递给下级的指令地址
    output reg[31:0] o_iaddr,
    //输出的指令数据
    output reg[31:0] o_idata

);


    wire en =  (~i_pipe_stop | i_pipe_flush);



    initial begin
        o_iaddr<=0;
        o_idata<=0;
    end


    always @(posedge i_clk or negedge i_rst_n) begin
        if(i_rst_n == `rst)begin
            o_iaddr <= 32'b0;
            o_idata <= `inst_nop;
        end
        else if(en == `en)begin

            o_iaddr <= (i_pipe_flush == `en) ? 32'h0 : i_iaddr;
            o_idata <= (i_pipe_flush == `en) ? `inst_nop : i_idata;
           
        end
    end




    
endmodule