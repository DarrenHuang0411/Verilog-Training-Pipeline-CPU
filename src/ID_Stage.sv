`include "./ID_RegFile.sv"
`include "./ControlUnit.sv"
`include "./ID_ImmGe.sv"

module ID_Stage (
    input   wire clk, rst,
//------------------ I/O ------------------//
  //------------ Control Unit ------------//
    output  wire    [`OP_CODE -1:0]     opcode,
    input   wire    [`DATA_WIDTH -1:0]  instr,
    
    output  wire    [2:0]               ALU_Ctrl_op,
    output  wire    [4:0]               regf_rs1_addr,
    output  wire    [4:0]               regf_rs2_addr,


    output  wire    [4:0]               rs2_addr,

    output  wire    [4:0]               regf_rs1_addr,
    output  wire [4:0]              rd_addr,
    input   wire [`DATA_WIDTH -1:0] rd_data,
    output  wire [`DATA_WIDTH -1:0] rs1_data,
    output  wire [`DATA_WIDTH -1:0] rs2_data,

    output   wire [2:0] funct3,
    output   wire [6:0] funct7,
);








//ControlUnit --> Immediate_Generator
wire [2:0] ImmGe;

//------------------- Control_Unit -------------------//
    ControlUnit ControlUnit_inst(
        .opcode(opcode),
        .ALU_Ctrl_op(ALU_Ctrl_op),
        .Imm_type(ImmGe)
    );

//------------------ Register File -------------------//
    ID_RegFile  ID_RegFile_inst(
        .clk(clk), .rst(rst),
        .reg_write(reg_write),//Ctrl

        .rs1_addr(rs1_data), 
        .rs2_addr(rs1_data), 
        .rs1_data(rs2_data),
        .rs2_data(rs2_data)
    );

//Immediate_Generator

endmodule
