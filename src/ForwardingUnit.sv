module ForwardingUnit (
    
    input   logic [4:0]   ID_rs1_addr,
    input   logic [4:0]   ID_rs2_addr,

    input   wire          EXE_MEM_fwd_write,
    input   wire          MEM_WB_fwd_write,

    output  reg [1:0]     FWD_rs1_sel,
    output  reg [1:0]     FWD_rs2_sel
);
    
//------------------- parameter -------------------//    


//------------------- data -------------------//

    if      (EXE_MEM_fwd_write && )
        FWD_rs1_sel
    else if (MEM_WB_fwd_write && )
        FWD_rs1_sel
    else
        FWD_rs1_sel

endmodule
