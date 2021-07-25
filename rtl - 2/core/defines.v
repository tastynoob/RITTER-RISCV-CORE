




`define rst 1'b0
`define en 1'b1
`define dis 1'b0





`define decinfo_wigth (17)


/*译码出的具体指令内容


1'是否要进行运算[0]
1'alu b位是否选择立即数[1]
1'alu pc是否参与计算[2]
1'是否是条件分支指令[3]
1'是否是强制跳转[4]
1‘是否要读内存[5]
1’是否要写内存[6]
1’是否要读写csr寄存器[8]
3’func[11:9]
7‘func7[18:12]

*/

`define decinfo_alu 0
`define decinfo_b 1
`define decinfo_pc 2
`define decinfo_branch 3
`define decinfo_jal 4
`define decinfo_rdbus 5
`define decinfo_wdbus 6
`define decinfo_wcsr 7
`define decinfo_func3 10:8
`define decinfo_func7 17:11






//add x0,x0,0 == 空指令
`define inst_nop 32'h00000013

//32位指令开头
`define opc_type32        2'b11

//需要计算
//需要写rd
//alu_b位为imm
`define opc_lui         7'b0110111 // rd = imm
`define opc_auipc       7'b0010111 // rd = pc + imm
////////////////////////////////无条件跳转



`define opc_jal         7'b1101111 // rd = pc + 4; pc += imm

//需要计算
//需要写rd
//alu_b=imm
`define opc_jalr        7'b1100111 // rd = pc+4;pc= ( rs1 + imm ) & ~1;


/////////////////////////////////有条件跳转
`define opc_branch      7'b1100011
`define func_beq        3'b000 // if(rs1 == rs2) pc += imm; => if(rs1-rs2=0) 
`define func_bne        3'b001 // if(rs1 != rs2) pc += imm; => if(rs1-rs2)
`define func_blt        3'b100 // if(rs1 < rs2)             => if(rs1 < rs2)
`define func_bge        3'b101 // if(rs1 >= rs2) pc += imm; => if(!(rs1 < rs2))
`define func_bltu       3'b110 // if(rs1 <u rs2)            => if(rs1 <u rs2)
`define func_bgeu       3'b111 // if(rs1 >=u rs2)           => if(!(rs1 <u rs2))

//////////////////////////////////load加载
`define opc_load        7'b0000011
`define func_lb         3'b000
`define func_lh         3'b001
`define func_lw         3'b010
`define func_lbu        3'b100
`define func_lhu        3'b101

////////////////////////////////store储存
`define opc_store       7'b0100011
`define func_sb         3'b000
`define func_sh         3'b001
`define func_sw         3'b010

///////////////////////////////imm立即数指令
`define opc_opimm       7'b0010011
`define func_addi       3'b000
`define func_slti       3'b010
`define func_sltiu      3'b011
`define func_xori       3'b100
`define func_ori        3'b110
`define func_andi       3'b111
`define func_slli       3'b001
//特殊变种
`define func_srli_srai  3'b101
`define func7_srli      7'b0000000
`define func7_srai      7'b0100000

/////////////////////////////////op寄存器指令
`define opc_op          7'b0110011
`define func_add_sub    3'b000
`define func7_add       7'b0000000
`define func7_sub       7'b0100000
`define func_sll        3'b001
`define func_slt        3'b010
`define func_sltu       3'b011
`define func_xor        3'b100
`define func_srl_sra    3'b101
`define func7_srl       7'b0000000
`define func7_sra       7'b0100000
`define func_or         3'b110
`define func_and        3'b111

//////////////////////////////////////fence
`define opc_fence       7'b0001111
`define func_fence      3'b000
`define func_fencei     3'b001

/////////////////////////////////system系统指令
`define opc_system      7'b1110011
`define func_ecall_ebreak 3'b000
`define func12_ecall    12'b000000000000
`define func12_ebreak   12'b000000000001
`define func_csrrw      3'b001 //rd = csr,csr = rs1
`define func_csrrs      3'b010 //rd = csr,csr = csr | rs1
`define func_csrrc      3'b011 //rd = csr,csr = csr & ~rs1
`define func_csrrwi     3'b101 //rd = csr,csr = zimm
`define func_csrrsi     3'b110 //rd = csr,csr = csr | zimm
`define func_csrrci     3'b111 //rd = csr,csr = csr & ~zimm,
















