`include "./IF_PC.sv"
`include "./SRAM_wrapper.sv"

module IF_Stage (
    input   wire clk, rst,
    //F_BranchCtrl
    input   wire    [1:0]               Branch_Ctrl,
    input   wire    [`DATA_WIDTH -1:0]  pc_mux_rs1,
    input   wire    [`DATA_WIDTH -1:0]  pc_mux_imm,
    
    //F_HazardCtrl
    input   wire                        PC_write,
    output  reg     [`DATA_WIDTH -1:0]  O_PC,

    //instr_mux
    input   logic   [`DATA_WIDTH -1:0]  IM_instr,
    input   logic                       instr_flush_sel,
    output  logic   [`DATA_WIDTH -1:0]  IF_instr_out
);

////wire////
wire    [`DATA_WIDTH -1:0] PC_4;    //F_Mux1
reg     [`DATA_WIDTH -1:0] PC_in;   //F_PC
//F_IM



//------------------- pc+4 adder --------------------//
    assign PC_4 = O_PC + 32'd4;

//------------------ Branch_pc_mux ------------------//
    always @(Branch_Ctrl) begin
        case (Branch_Ctrl)
            2'd0 : PC_in = pc_mux_imm_rs1;
            2'd1 : PC_in = pc_mux_imm; 
            2'd2 : PC_in = PC_4;
            default: PC_in = 32'd0;
        endcase     
    end

//------------------ pc_counter ------------------//
    IF_PC IF_PC_inst(
        .clk(clk), .rst(rst),//glo_ctrl
        .PC_write(PC_write),//Ctrl
        .I_PC(PC_in), .O_PC(O_PC) // I/O  
    );

//---------------- instr_flush_mux ----------------//
    assign  IF_instr_out    =   (instr_flush_sel) ? 32'd0 : IM_instr;

endmodule
