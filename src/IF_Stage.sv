`include "./IF_PC.sv"
`include "./SRAM_wrapper.sv"

module IF_Stage (
    input   wire clk, rst,
    //F_BranchCtrl
    input   wire [1:0] Branch_Ctrl,
    input   wire [`DATA_WIDTH -1:0] pc_mux_rs1,
    input   wire [`DATA_WIDTH -1:0] pc_mux_imm,
    //F_HazardCtrl
    input   wire PC_write,
    output  reg [`DATA_WIDTH -1:0] O_PC 
);

////wire////
wire    [`DATA_WIDTH -1:0] PC_4;    //F_Mux1
reg     [`DATA_WIDTH -1:0] PC_in;   //F_PC
//F_IM

////Mux1////
always @(Branch_Ctrl) begin
    case (Branch_Ctrl)
        2'd0 : PC_in = pc_mux_rs1;
        2'd1 : PC_in = pc_mux_imm; 
        2'd2 : PC_in = PC_4;
        default: PC_in = 32'd0;
    endcase     
end

////IF_PC////
IF_PC Inst2(
    .clk(clk), .rst(rst),//glo_ctrl
    .PC_write(PC_write),//Ctrl
    .I_PC(PC_in), .O_PC(O_PC) // I/O  
);

////Adder////
assign PC_4 = O_PC + 32'd4;

endmodule
