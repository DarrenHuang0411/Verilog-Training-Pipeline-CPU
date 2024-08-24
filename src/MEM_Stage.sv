module MEM_Stage (
    input   wire      MEM_rd_sel,
    input   wire  [:] MEM_pc,
    input   wire  [`DATA_WIDTH -1:0] MEM_ALU,

    output  wire  [:] MEM_DMread_sel,
    output  wire  [:] MEM_DMwrite_sel,
    output  wire  [:] MEM_rd_data
);
    
    wire [:] MEM_rd_src;


    assign  MEM_rd_data = (MEM_rd_sel) ? MEM_pc : MEM_ALU;  

endmodule
