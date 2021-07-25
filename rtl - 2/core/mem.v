
`include "defines.v"







//读写需要花费2个周期
//该模块实现输出需要请求的信号
module MEM (
    input wire i_clk,
    input wire i_rst_n,

    input wire i_dbus_re,
    input wire i_dbus_we,
    input wire[2:0] i_func3,

    //从rs2读入的数据
    input wire[31:0] i_rs2_data,

    //执行模块传入的rd_data
    //input wire[31:0] i_rd_data,
    //从dbus读出的值，写入rd寄存器
    output wire[31:0] o_rd_wdata,

    //下面是连接dbus总线

    //dbus读写位选择,这里是4位
    output wire[3:0] o_dbus_sel,
    //dbus写使能
    output wire o_dbus_we,
    //dbus读数据
    input wire[31:0] i_dbus_rdata,
    //dbus写数据
    output wire[31:0] o_dbus_wdata,

    //dbus访问信号
    output wire o_dbus_req,
    //dbus应答信号
    input wire i_dbus_rsp 



);
    //4位读写使能
    wire[3:0] dbus_e;

    wire rw_b = (i_func3[1:0] == 2'b00) ? 1 : 0;//字节读写
    wire rw_h = (i_func3[1:0] == 2'b01) ? 1 : 0;//2字节读写
    wire rw_w = (i_func3[1:0] == 2'b10) ? 1 : 0;//4字节读写
    wire rw_u = i_func3[2];//是否是无符号拓展
    
    assign dbus_e[0] = 1;
    assign dbus_e[3:1] = rw_h ? 3'b001 :
                            rw_w ? 3'b111: 0;  
    assign o_dbus_sel = (i_dbus_we | i_dbus_re) ? dbus_e :0; 

    


    //dbus请求
    assign o_dbus_req = i_dbus_re | i_dbus_we;



    //内存写数据
    assign o_dbus_wdata = i_dbus_we ? i_rs2_data : 0;

    assign o_dbus_we = i_dbus_we;
    

    assign o_rd_wdata = (i_dbus_rsp & i_dbus_re) ? 
                            (rw_b ? {{24{i_dbus_rdata[7] & (~rw_u)}},i_dbus_rdata[7:0]} :
                            rw_h ? {{16{i_dbus_rdata[15] & (~rw_u)}},i_dbus_rdata[15:0]} :
                            i_dbus_rdata) : 0;


    // reg[31:0] dbus_rdata;
    // assign o_rd_wdata = dbus_rdata;
    // initial begin
    //     dbus_rdata<=0;
    // end
    // always @(posedge i_clk or negedge i_rst_n) begin
    //     if(i_rst_n == `rst)begin
    //         dbus_rdata<=0;
    //     end
    //     else if(i_dbus_rsp & i_dbus_re)begin//如果有应答,并且需要寄存器写
    //         //需要读dbus
    //         dbus_rdata <= rw_b ? {{24{i_dbus_rdata[7] & (~rw_u)}},i_dbus_rdata[7:0]} :
    //                         rw_h ? {{16{i_dbus_rdata[15] & (~rw_u)}},i_dbus_rdata[15:0]} :
    //                         i_dbus_rdata;
    //     end
    // end




    
endmodule









//与写回的过渡模块
module MEM_RB (
    input wire i_clk,
    input wire i_rst_n,

    input wire[4:0] i_rd_addr,
    input wire[31:0] i_rd_data,
    //从dbus读取数据后，需要写入的寄存器
    output reg[4:0] o_rd_addr,
    output reg[31:0] o_rd_data
);

    initial begin
        o_rd_addr <= 0;
        o_rd_data <= 0;
    end


    always @(posedge i_clk or negedge i_rst_n) begin
        if(i_rst_n == `rst)begin
            o_rd_addr <= 0;
            o_rd_data <= 0;
        end
        else begin
            o_rd_addr <= i_rd_addr;
            o_rd_data <= i_rd_data;
        end
    end
    
endmodule





