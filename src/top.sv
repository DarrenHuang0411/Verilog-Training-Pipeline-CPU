`include "../include/def.sv"
`include "IF_Stage.sv"
`include "ID_Stage.sv"
`include "EXE_Stage.sv"
`include "MEM_Stage.sv"
`include "WB_Stage.sv"
`include "SRAM_wrapper.sv"

module top (
    input clk,
    input rst
);

//------------------- parameter -------------------//    
    //To_Dif_Module
    //
    wire [`DATA_WIDTH -1:0] WB_rd_data;

    // (temp.) IF_OUT
    wire [`DATA_WIDTH -1:0] IF_2_reg;

    reg [`DATA_WIDTH -1:0] MEM_WB_rd_dir;
    reg [`DATA_WIDTH -1:0] MEM_WB_rd_DM;

    //EXE--> IF//
    wire    [`DATA_WIDTH -1:0]  EXE_IF_pc_imm;

    wire    [`DATA_WIDTH -1:0]  ALU_o;
    //
    wire            zeroflag;
    wire    [1:0]   branch_sel;

//------------------- Stage Reg -------------------//
    //IF-ID Register
    reg [`DATA_WIDTH -1:0]  IF_ID_instr;
    //ID-EXE Register
    reg [2:0]               ID_EXE_ALU_Ctrl_op;
    reg [1:0]               ID_EXE_branch_signal;

    reg [`FUNCTION_3 -1:0]  ID_EXE_function3;
    reg [`FUNCTION_7 -1:0]  ID_EXE_function7;
    //EXE-MEM Register
    reg [`DATA_WIDTH -1:0]  EXE_MEM_data;
    //MEM-WB Register
    reg [`DATA_WIDTH -1:0]  MEM_WB_LW_Dout;

//------------------- IF_Stage -------------------//
    IF_Stage IF_Stage_inst(
        .clk(clk), .rst(rst),
        .Branch_Ctrl(branch_sel),
        .pc_mux_imm_rs1(ALU_o),
        .pc_mux_imm(EXE_IF_pc_imm),
        .PC_write(0),
        .instr_sel(0),
        .instr_out(IF_ID_instr)
    );

    SRAM_wrapper IM1(
        .CK(clk),
        .CS(rst),
        .OE(DM_read_enable),
        .WEB(DM_write_enable),
        .A,
        .DI,
        .DO
    );

//------------------- ID_Stage -------------------//
    ID_Stage ID_Stage_inst(
        .clk(clk), .rst(rst),

        .opcode(IF_ID_instr[6:0]),
        .ALU_Ctrl_op(ID_EXE_ALU_Ctrl_op),
        .rd_addr(WB_rd_data)
    );

//------------------- EXE_Stage -------------------//
    EXE_Stage EXE_Stage(
        .PC_EXE_in,
        .ALU_op(ID_EXE_ALU_Ctrl_op),
        //control Signal 
        .ForwardA,
        .ForwardB,

        //Data
        .EXE_rs1,
        .WB_data,
        .EXE_rs2,
        .EXE_imm, 
        .EXE_function_3(ID_EXE_function3),
        .EXE_function_7(ID_EXE_function7),
        .EXE_PC_imm(EXE_IF_pc_imm),

        .PC2E_M_reg,
        .zeroflag(zeroflag),
        .ALU_o(ALU_o)

    );

//------------------- MEM_Stage -------------------//
    
    SRAM_wrapper DM1(
        .CK(clk), .CS(1'b1),
        .DI(O_PCPC), 
        .DO(MEM_WB_Dout)
    );

//------------------- WB_Stage -------------------//
    WB_Stage WB_Stage_inst(
        .reg_Ctrl(),
        .WB_rd_dir(MEM_WB_rd_dir),
        .WB_rd_DM(MEM_WB_rd_DM),
        .WB_rd_data(WB_rd_data)
    );

//--------------- Branch Control -----------------//
    Branch_Ctrl Branch_Ctrl_inst(
        .zeroflag(zeroflag),
        .branch_signal(ID_EXE_branch_signal),
        .branch_sel(branch_sel)
    );
//--------------- Forwarding Unit -----------------//

endmodule
