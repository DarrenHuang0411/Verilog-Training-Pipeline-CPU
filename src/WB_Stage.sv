module WB_Stage (
    input   wire  reg_Ctrl,
    input   wire [32-1:0] WB_rd_dir,//lw-->1
    input   wire [32-1:0] WB_rd_DM,//r_format-->0
    output  reg [32-1:0] WB_rd_data
);

wire    WB_Mux_Ctrl;

////WB_Mux////
assign  WB_Mux_Ctrl =   reg_Ctrl;
assign  WB_rd_data  =   (WB_Mux_Ctrl) ? WB_rd_dir : WB_rd_DM;   

endmodule
