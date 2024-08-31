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
    wire [`DATA_WIDTH -1:0] WB_rd_data;

    // (temp.) IF_OUT
    wire [`DATA_WIDTH -1:0] IF_2_reg;
    //////////////////////////////////////////////////
    wire    [1:0]               BC_IF_branch_sel;
    wire    [`DATA_WIDTH -1:0]  EXE_IF_ALU_o;
    wire    [`DATA_WIDTH -1:0]  EXE_IF_pc_imm;
    wire                        HAZ_IF_pc_w;
    wire                        HAZ_IF_instr_flush;
    ///////////////////////////////////////////////////
    wire            zeroflag;

//------------------- Stage Reg -------------------//
  //IF-ID Register
    reg [`DATA_WIDTH -1:0]  IF_ID_instr;

  //------------- ID-EXE Register --------------//
    //------------- Ctrl sig reg -------------//
      reg [2:0]             ID_EXE_ALU_Ctrl_op;
      reg [1:0]             ID_EXE_branch_signal;
      //reg [];
      reg                   ID_EXE_pc_mux; // final --> EXE

    reg [`DATA_WIDTH -1:0]  ID_EXE_pc_in;
    reg [`DATA_WIDTH -1:0]  ID_EXE_rs1;
    reg [`DATA_WIDTH -1:0]  ID_EXE_rs2;
    reg [`FUNCTION_3 -1:0]  ID_EXE_function3;
    reg [`FUNCTION_7 -1:0]  ID_EXE_function7;
    reg [`DATA_WIDTH -1:0]  ID_EXE_imm;
 
  //------------- EXE-MEM Register --------------//
    //------------- Ctrl sig reg -------------//
        reg                 EXE_MEM_rd_sel;         //final --> MEM
        reg                 EXE_MEM_DMread_sel;
        reg                 EXE_MEM_DMwrite_sel;
        reg                 EXE_MEM_data_sel;       //final --> WB

    reg [`DATA_WIDTH -1:0]  EXE_MEM_PC;
    reg [`DATA_WIDTH -1:0]  EXE_MEM_ALU_o;
    reg [`DATA_WIDTH -1:0]  EXE_MEM_rs2_data;
    wire [`DATA_WIDTH -1:0] MEM_DM_Din;

    //------------- MEM-WB Register --------------//
      //------------- Ctrl sig reg -------------//
        reg                 MEM_WB_data_sel; //final --> WB

    reg [`DATA_WIDTH -1:0]  MEM_WB_rd_dir;
    wire [`DATA_WIDTH -1:0] DM_MEM_Dout;
    reg [`DATA_WIDTH -1:0]  MEM_WB_rd_DM;

//------------------- IF_Stage -------------------//
    IF_Stage IF_Stage_inst(
        .clk(clk), .rst(rst),
        .Branch_Ctrl      (BC_IF_branch_sel),
        .pc_mux_imm_rs1   (EXE_IF_ALU_o),
        .pc_mux_imm       (EXE_IF_pc_imm),
        .PC_write         (HAZ_IF_pc_w),
        .O_PC,
        .IM_instr,
        .instr_flush_sel  (HAZ_IF_instr_flush),
        .IF_instr_out     (IF_ID_instr)
    );

    SRAM_wrapper IM1(
        .CK(clk), .CS(rst),
        .OE(1'b1),
        .WEB(1'b1),
        .A(),
        .DI(),
        .DO()
    );

//------------------- ID_Stage -------------------//
    ID_Stage ID_Stage_inst(
        .clk(clk), .rst(rst),
        .opcode         (IF_ID_instr[6:0]),
        .ALU_Ctrl_op    (ID_EXE_ALU_Ctrl_op),

    //input   wire [:] rd_addr;
        .rs1_addr       (IF_ID_instr[19:15]),
        .rs2_addr       (IF_ID_instr[24:20]),
        .rd_addr        (),
        .rd_data        (),
        .rs1_data       (ID_EXE_rs1),
        .rs2_data       (ID_EXE_rs2),
        .funct3         (ID_EXE_function3),
        .funct7         (ID_EXE_function7)
    );

//------------------- EXE_Stage -------------------//
    EXE_Stage EXE_Stage(
        .ALU_op         (ID_EXE_ALU_Ctrl_op),
      //control Signal 
        .pc_mux_sel     (ID_EXE_pc_mux),
        .ForwardA       (0),
        .ForwardB       (0),//revise

      //Data
        .PC_EXE_in      (ID_EXE_pc_in),
        .EXE_rs1        (ID_EXE_rs1),
        .EXE_rs2        (ID_EXE_rs2),
        .WB_data,
        .EXE_imm        (ID_EXE_imm), 
        .EXE_function_3 (ID_EXE_function3),
        .EXE_function_7 (ID_EXE_function7),
        .EXE_PC_imm     (EXE_IF_pc_imm),

        .pc_sel_o       (EXE_MEM_PC),
        .zeroflag       (zeroflag),
        .ALU_o          (EXE_MEM_ALU_o),
        .ALU_o_2_immrs1 (EXE_IF_ALU_o)
    );

//------------------- MEM_Stage -------------------//

    MEM_Stage (
        .clk(),  
        .rst(), 
        //----------------- Ctrl sig reg ----------------------//
        .MEM_rd_sel       (EXE_MEM_rd_sel),
        .MEM_DMread_sel   (), 
        .MEM_DMwrite_sel  (),
        //----------------------- MEM_I/O -----------------------//
        .MEM_pc           (EXE_MEM_PC),
        .MEM_ALU          (EXE_MEM_ALU_o),
        //------------------------ Data ------------------------//  
        .EXE_funct3       (),
        .EXE_rs2_data     (),     
        .MEM_rd_data      (EXE_MEM_rs2_data),

        //------------------------- DM -------------------------//    
        .chip_select      (),
        //------------------------- SW -------------------------// 
        .w_eb             (),
        .DM_in            (MEM_DM_Din),

        //------------------------- LW -------------------------//     
        .DM_out           (DM_MEM_Dout),
        .DM_out_2_reg     (MEM_WB_rd_DM)
    );

    SRAM_wrapper DM1(
        .CK(clk), .CS(1'b1),
        .OE (DM_read_enable),
        .WEB(DM_write_enable),
        .A  (EXE_MEM_ALU_o)
        .DI (MEM_DM_Din), 
        .DO (DM_MEM_Dout)
    );

//------------------- WB_Stage -------------------//
    WB_Stage WB_Stage_inst(
        .data_sel   (MEM_WB_data_sel),

        .WB_rd_dir  (MEM_WB_rd_dir),
        .WB_rd_DM   (MEM_WB_rd_DM),
        .WB_rd_data (WB_rd_data)
    );

//--------------- Branch Control -----------------//
    Branch_Ctrl Branch_Ctrl_inst(
        .zeroflag       (zeroflag),
        .branch_signal  (ID_EXE_branch_signal),
        .branch_sel     (BC_IF_branch_sel)
    );
//---------------- Hazard Control -----------------//
    Hazard_Ctrl Hazard_Ctrl_inst(
        .branch_sel,
        .EXE_read,

        .ID_rs1_addr,
        .ID_rs2_addr,
        .EXE_rd_addr,

        .pc_write         (HAZ_IF_pc_w),  
        .instr_flush      (HAZ_IF_instr_flush),
        .IF_ID_reg_write,
        .ctrl_sig_flush


    );


//--------------- Forwarding Unit -----------------//

endmodule
