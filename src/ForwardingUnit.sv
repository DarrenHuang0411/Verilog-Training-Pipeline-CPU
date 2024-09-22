module ForwardingUnit (
    
    input   logic   [4:0]   ID_rs1_addr,
    input   logic   [4:0]   ID_rs2_addr,
    input   logic   [4:0]   EXE_rd_addr,
    input   logic   [4:0]   MEM_rd_addr,

    input   wire            EXE_MEM_fwd_write,
    input   wire            MEM_WB_fwd_write,

    output  reg     [1:0]   FWD_rs1_sel,
    output  reg     [1:0]   FWD_rs2_sel,
    output  reg     [1:0]   FWD_rs1_FP_sel,
    output  reg     [1:0]   FWD_rs2_FP_sel
);
    
//------------------- parameter -------------------//    


//------------------- data -------------------//
    always_comb begin
        if      (EXE_MEM_fwd_write && (EXE_rd_addr == ID_rs1_addr))
            FWD_rs1_sel     =   2'b01;
            FWD_rs1_FP_sel  =   2'b01;
        else if (MEM_WB_fwd_write  && (MEM_rd_addr == ID_rs1_addr))
            FWD_rs1_sel     =   2'b10;
            FWD_rs1_FP_sel  =   2'b10;
        else
            FWD_rs1_sel     =   2'b00;
            FWD_rs1_FP_sel  =   2'b00;
    end

    always_comb begin
        if      (EXE_MEM_fwd_write && (EXE_rd_addr == ID_rs2_addr))
            FWD_rs2_sel     =   2'b01;
            FWD_rs2_FP_sel  =   2'b01;          
        else if (MEM_WB_fwd_write  && (MEM_rd_addr == ID_rs2_addr))
            FWD_rs2_sel     =   2'b10;
            FWD_rs2_FP_sel  =   2'b10;          
        else
            FWD_rs2_sel     =   2'b00;       
            FWD_rs2_FP_sel  =   2'b00;          
    end
endmodule
