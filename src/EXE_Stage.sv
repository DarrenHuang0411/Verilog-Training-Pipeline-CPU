`include "./EXE_ALU_Ctrl.sv"
`include "./EXE_ALU.sv"

module EXE_Stage (
    input   wire [`DATA_WIDTH -1:0] PC_EXE_in,
    //control Signal 
    input   wire [1:0] ForwardA,
    input   wire [1:0] ForwardB,

    //Data
    input   wire [`DATA_WIDTH -1:0] EXE_rs1,
    input   wire [`DATA_WIDTH -1:0] WB_data,
    input   wire [`DATA_WIDTH -1:0] EXE_rs2,
    input   wire [`DATA_WIDTH -1:0] EXE_imm, 
    input   wire [`DATA_WIDTH -1:0] EXE_function_3,
    input   wire [`DATA_WIDTH -1:0] EXE_function_7,


    output  reg PC2E_M_reg,
    output  reg zeroflag,
    output  reg  [`DATA_WIDTH -1:0] ALU_o
);

//<------------------- parameter ------------------->

reg [`DATA_WIDTH -1:0] Mux2_ALU;
reg [`DATA_WIDTH -1:0] Mux3_ALU;
reg [`DATA_WIDTH -1:0] Mux4_ALU;

////Adder1////
assign  Add1_Mux1   =   PC_EXE_in   +    EXE_imm;

////Adder2////
assign  Add2_Mux1   =   PC_EXE_in   +   32'd4;

////Mux1////
assign  PC2E_M_reg   =   ()  ?   Add1_Mux1   :   Add2_Mux1;

////Mux2/// (RS1_data)
    always_comb begin 
        case (2'd0) //(ForwardA)
            2'd0:   Mux2_ALU    =  EXE_rs1;
            2'd1:   Mux2_ALU    =  32'd0; 
            2'd2:   Mux2_ALU    =  32'd0;
            default: Mux2_ALU    =  32'd0; 
        endcase    
    end

////Mux3/// (RS2_data)
    always_comb begin 
        case (2'd0) //(ForwardA)
            2'd0:   Mux3_ALU    =  EXE_rs2;
            2'd1:   Mux3_ALU    =   32'd0;
            2'd2:   Mux3_ALU    =   32'd0;
            default: Mux3_ALU    =  32'd0; 
        endcase    
    end

////Mux4-->imm_sel
    assign  Mux4_rs2 =  (rs2_sel) ? Mux3_ALU : EXE_imm; //(ALU_sel)

//------------------------- EXE_ALU -------------------------//
    EXE_ALU Inst2(
        .ALU_Ctrl(),
        .rs1(Mux2_ALU), 
        .rs2(Mux4_ALU),
        .ALU_out(ALU_out), 
        .zeroflag(zeroflag)
    );

//------------------------- EXE_ALU_Ctrl -------------------------//
    EXE_ALU_Ctrl EXE_ALU_Ctrl_inst(
        .ALU_op(),
        .FUNCTION_3(),
        .FUNCTION_7(),
        .ALU_ctrl()
    );

endmodule
