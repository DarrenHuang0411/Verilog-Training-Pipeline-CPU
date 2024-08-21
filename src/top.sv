`include "../include/def.sv"
`include "IF_Stage.sv"
`include "ID_Stage.sv"
`include "WB_Stage.sv"
`include "SRAM_wrapper.sv"

module top (
    input clk,
    input rst
);
    
//To_Dif_Module
//
wire [`DATA_WIDTH -1:0] WB_rd_data;

// (temp.) IF_OUT
wire [`DATA_WIDTH -1:0] IF_2_reg;

////IF_Stage
IF_Stage Inst1(
    .clk(clk), .rst(rst),
    .Branch_Ctrl(2'd2),
    .pc_mux_rs1(0),
    .pc_mux_imm(0),
    .PC_write(0),
    .instr_sel(0),
    .instr_out(IF_2_reg)
);

SRAM_wrapper IM1(
    .CK(clk), .CS(1'b1),
    .DI(O_PCPC), .DO(instr)
);

SRAM_wrapper DM1(
    .CK(clk), .CS(1'b1),
    .DI(O_PCPC), .DO(instr)
);

////IF_ID_stage
//(temp.)register

////ID_Stage

ID_Stage Inst3(
    .clk(clk), .rst(rst),

    // .opcode(),
    .rd_addr(WB_rd_data)
);

////MEM_WB_reg


////WB_Stage
reg [`DATA_WIDTH -1:0] MEM_WB_rd_dir;
reg [`DATA_WIDTH -1:0] MEM_WB_rd_DM;

WB_Stage Inst9(
    .reg_Ctrl(),
    .WB_rd_dir(MEM_WB_rd_dir),
    .WB_rd_DM(MEM_WB_rd_DM),
    .WB_rd_data(WB_rd_data)
);

endmodule
