`include "defines.v"

module CSRS (
    input wire i_clk,
    input wire i_rst_n,
    input wire[11:0] i_csr_addr,

    output wire[31:0] o_csr_data,

    input wire i_we,
    input wire[31:0] i_csr_newdata
);


    //读写权限位
    //00、01、10：可读可写
    //11：只读
    wire[1:0] addr1 = i_csr_addr[11:10];
    //访问权限位
    //00:user csr
    //01:super csr
    //10:hyper csr
    //11:machine csr
    wire[1:0] addr2 = i_csr_addr[9:8];
    //基地址
    wire[7:0] addr3 = i_csr_addr[7:0];



    reg[31:0] csrs[9:0];

    generate
        genvar i;
        for(i=0;i<10;i=i+1)begin
            initial begin
                csrs[i] = 0;
            end 
        end
    endgenerate


    //上次读csr地址
    wire[11:0] csr_last_addr;
    wire csr_we_last;
 
    always @(negedge i_clk or negedge i_rst_n) begin
        if(i_rst_n==`rst)begin
            
        end
        else if(csr_we_last==`en)begin
            csrs[csr_last_addr] = i_csr_newdata;
        end
        
    end

    assign o_csr_data = csrs[i_csr_addr];




    wire[31:0] csr0 = csrs[0];
    wire[31:0] csr1 = csrs[1];
    wire[31:0] csr2 = csrs[2];
    wire[31:0] csr3 = csrs[3];
    wire[31:0] csr4 = csrs[4];
    wire[31:0] csr5 = csrs[6];





    gen_dff#(12)addr_dff(i_clk,i_rst_n,1'b1,i_csr_addr,csr_last_addr);
    gen_dff#(1)we_dff(i_clk,i_rst_n,1'b1,i_we,csr_we_last);



endmodule