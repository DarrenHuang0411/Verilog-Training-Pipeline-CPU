`include "../include/def.sv"
`include "IF_Stage.sv"
`include "ID_Stage.sv"
`include "EXE_Stage.sv"
`include "MEM_Stage.sv"
`include "WB_Stage.sv"

`include "SRAM_wrapper.sv"
`include "Branch_Ctrl.sv"
`include "Hazard_Ctrl.sv"
`include "ForwardingUnit.sv"

module top (
    input clk,
    input rst
);

//------------------- parameter -------------------//    
    // (temp.) IF_OUT
    wire    [`DATA_WIDTH -1:0]  IF_IM_pc;
    wire    [`DATA_WIDTH -1:0]  IM_IF_instr;
    //////////////////////////////////////////////////
    wire    [1:0]               BC_IF_branch_sel;
    wire    [`DATA_WIDTH -1:0]  EXE_IF_ALU_o;
    wire    [`DATA_WIDTH -1:0]  EXE_IF_pc_imm;
    wire                        HAZ_IF_pc_w;
    wire                        HAZ_IF_instr_flush;
    wire                        wire_HAZ_IF_ID_reg_write;
    wire                        wire_ctrl_sig_flush;

    wire    [1:0]               FWD_EXE_rs1_sel;
    wire    [1:0]               FWD_EXE_rs2_sel;
    ///////////////////////////////////////////////////
    wire                        EXE_Bctrl_zeroflag;
    wire                        MEM_DM_CS;

    wire    [3:0]               DM_write_enable;
//------------------- Stage Reg -------------------//
  //--------------- IF-ID Register --------------//
    reg [`DATA_WIDTH -1:0]  IF_ID_pc;
    reg [`DATA_WIDTH -1:0]  IF_ID_instr;
    wire [`DATA_WIDTH -1:0]  wire_IF_ID_pc;
    wire [`DATA_WIDTH -1:0]  wire_IF_ID_instr;

  //------------- ID-EXE Register --------------//
    reg [`DATA_WIDTH -1:0]  ID_EXE_pc_in;
    reg [`DATA_WIDTH -1:0]  ID_EXE_rs1;
    reg [`DATA_WIDTH -1:0]  ID_EXE_rs2;

    reg [`FUNCTION_3 -1:0]  ID_EXE_function3;
    reg [`FUNCTION_7 -1:0]  ID_EXE_function7;
    reg [4:0]               ID_EXE_rs1_addr;
    reg [4:0]               ID_EXE_rs2_addr;
    reg [4:0]               ID_EXE_rd_addr;
    reg [`DATA_WIDTH -1:0]  ID_EXE_imm;

    wire [`DATA_WIDTH -1:0]  wire_ID_EXE_pc_in;
    wire [`DATA_WIDTH -1:0]  wire_ID_EXE_rs1;
    wire [`DATA_WIDTH -1:0]  wire_ID_EXE_rs2;
    
    wire [`FUNCTION_3 -1:0]  wire_ID_EXE_function3    ;
    wire [`FUNCTION_7 -1:0]  wire_ID_EXE_function7    ;
    wire [4:0]               wire_ID_EXE_rs1_addr     ;
    wire [4:0]               wire_ID_EXE_rs2_addr     ;
    wire [4:0]               wire_ID_EXE_rd_addr      ;
    wire [`DATA_WIDTH -1:0]  wire_ID_EXE_imm          ;
    //------------- Ctrl sig reg -------------//
      reg [2:0]             ID_EXE_ALU_Ctrl_op;
      reg                   ID_EXE_pc_mux;          // final --> EXE
      reg                   ID_EXE_ALU_rs2_sel;
      reg [1:0]             ID_EXE_branch_signal;
      reg                   ID_EXE_rd_sel;          // final --> MEM
      reg                   ID_EXE_DM_read;         // final --> MEM
      reg                   ID_EXE_DM_write;        // final --> MEM
      reg                   ID_EXE_WB_data_sel   ;
      reg                   ID_EXE_reg_file_write;

      wire [2:0]            wire_ID_EXE_ALU_Ctrl_op  ;
      wire                  wire_ID_EXE_pc_mux       ;
      wire                  wire_ID_EXE_ALU_rs2_sel  ;
      wire [1:0]            wire_ID_EXE_branch_signal;
      wire                  wire_ID_EXE_rd_sel       ;
      wire                  wire_ID_EXE_DM_read      ;
      wire                  wire_ID_EXE_DM_write     ;
      wire                  wire_ID_EXE_WB_data_sel   ;
      wire                  wire_ID_EXE_reg_file_write;

  //------------- EXE-MEM Register --------------//
    reg [`DATA_WIDTH -1:0]  EXE_MEM_PC;
    reg [`DATA_WIDTH -1:0]  EXE_MEM_ALU_o;
    reg [`DATA_WIDTH -1:0]  EXE_MEM_rs2_data;
    reg [`FUNCTION_3 -1:0]  EXE_MEM_function_3;
    reg [4:0]               EXE_MEM_rd_addr;

    wire [`DATA_WIDTH -1:0] MEM_DM_Din;

    wire [`DATA_WIDTH -1:0]  wire_EXE_MEM_PC         ;
    wire [`DATA_WIDTH -1:0]  wire_EXE_MEM_ALU_o      ;
    wire [`DATA_WIDTH -1:0]  wire_EXE_MEM_rs2_data   ;
    wire [`DATA_WIDTH -1:0]  wire_EXE_MEM_function_3 ;
    wire [4:0]               wire_EXE_MEM_rd_addr    ;

    //------------- Ctrl sig reg -------------//
      reg                   EXE_MEM_DMread_sel;
      reg                   EXE_MEM_DMwrite_sel;
      reg                   EXE_MEM_rd_sel;         // final --> MEM
      reg                   EXE_MEM_DM_read;        // final --> MEM
      reg                   EXE_MEM_DM_write;       // final --> MEM
      reg                   EXE_MEM_data_sel;       // final --> WB
      reg                   EXE_MEM_reg_file_write; // final --> WB --> RF

      wire                  wire_EXE_MEM_DMread_sel; 
      wire                  wire_EXE_MEM_DMwrite_sel;
      wire                  wire_EXE_MEM_rd_sel;     
      wire                  wire_EXE_MEM_DM_read;    
      wire                  wire_EXE_MEM_DM_write;   
      wire                  wire_EXE_MEM_data_sel;
      wire                  wire_EXE_MEM_reg_file_write;

  //------------- MEM-WB Register  --------------//
    reg  [`DATA_WIDTH -1:0]  MEM_WB_rd_dir;
    reg  [`DATA_WIDTH -1:0]  MEM_WB_rd_DM;
    reg  [4:0]               MEM_WB_rd_addr;   
    wire [`DATA_WIDTH -1:0]  DM_MEM_Dout;

    wire [`DATA_WIDTH -1:0]  wire_MEM_WB_rd_dir;
    wire [`DATA_WIDTH -1:0]  wire_MEM_WB_rd_DM;
    wire [4:0]               wire_MEM_WB_rd_addr;   

    //------------- Ctrl sig reg -------------//
      reg                    MEM_WB_data_sel; //final --> WB
      wire                   wire_MEM_WB_data_sel;

      reg                    MEM_WB_reg_file_write;
      wire                   wire_MEM_WB_reg_file_write;
  //------------- WB wire/reg -------------------//
    wire [`DATA_WIDTH -1:0]  WB_rd_data;


//------------------- IF_Stage -------------------//
    IF_Stage IF_Stage_inst(
        .clk(clk), .rst(rst),
        .Branch_Ctrl      (BC_IF_branch_sel),
        .pc_mux_imm_rs1   (EXE_IF_ALU_o),
        .pc_mux_imm       (EXE_IF_pc_imm),
        .PC_write         (HAZ_IF_pc_w),
        .O_PC             (wire_IF_ID_pc),
        .o_pc_IM          (IF_IM_pc),              
        .IM_IF_instr      (IM_IF_instr),
        .instr_flush_sel  (HAZ_IF_instr_flush),
        .IF_instr_out     (wire_IF_ID_instr)
    );

    SRAM_wrapper IM1(
        .CK(~clk), .CS(1'b1),
        .OE(1'b1),
        .WEB(4'b1111),
        .A(IF_IM_pc[15:2]),
        .DI(32'd0),
        .DO(IM_IF_instr)
    );

//------------------- ID_Stage -------------------//
    ID_Stage ID_Stage_inst(
        .clk(clk), .rst(rst),
        
        .instr          (IF_ID_instr),
        .reg_rd_adddr   (MEM_WB_rd_addr),
        .reg_rd_data    (WB_rd_data),
        .reg_write      (MEM_WB_reg_file_write),

        .rs1_data       (wire_ID_EXE_rs1),
        .rs2_data       (wire_ID_EXE_rs2),
    //input   wire [:] rd_addr;
        .funct3         (wire_ID_EXE_function3),
        .funct7         (wire_ID_EXE_function7),
        .rs1_addr       (wire_ID_EXE_rs1_addr),
        .rs2_addr       (wire_ID_EXE_rs2_addr),
        .rd_addr        (wire_ID_EXE_rd_addr),
        .imm_o          (wire_ID_EXE_imm),

    //------------ Control Signal ------------//
        .ALU_Ctrl_op    (wire_ID_EXE_ALU_Ctrl_op),
        .EXE_pc_sel     (wire_ID_EXE_pc_mux),        //final --> exe
        .ALU_rs2_sel    (wire_ID_EXE_ALU_rs2_sel),   //final --> exe
        .branch_signal  (wire_ID_EXE_branch_signal), //final --> B ctrl 
        .MEM_rd_sel     (wire_ID_EXE_rd_sel),        //final --> mem
        .MEM_DM_read    (wire_ID_EXE_DM_read),       //final --> mem
        .MEM_DM_write   (wire_ID_EXE_DM_write),      //final --> mem
        
        .WB_data_sel    (wire_ID_EXE_WB_data_sel),
        .reg_file_write (wire_ID_EXE_reg_file_write),

        .in_pc          (IF_ID_pc),
        .out_pc         (wire_ID_EXE_pc_in)
    );

//------------------- EXE_Stage -------------------//
    EXE_Stage EXE_Stage(
      //control Signal 
        .ALU_op         (ID_EXE_ALU_Ctrl_op),
        .pc_mux_sel     (ID_EXE_pc_mux),
        .ALU_rs2_sel    (ID_EXE_ALU_rs2_sel),   //final --> exe

        .ID_EXE_rd_sel  (ID_EXE_rd_sel),
        .EXE_MEM_rd_sel (wire_EXE_MEM_rd_sel),

        .ID_EXE_DM_read (ID_EXE_DM_read), 
        .EXE_MEM_DM_read(wire_EXE_MEM_DM_read),

        .ID_EXE_DM_write (ID_EXE_DM_write), 
        .EXE_MEM_DM_write(wire_EXE_MEM_DM_write),

        .ID_EXE_WB_data_sel (ID_EXE_WB_data_sel),
        .EXE_MEM_WB_data_sel(wire_EXE_MEM_data_sel),
        
        .ID_EXE_reg_file_write (ID_EXE_reg_file_write),
        .EXE_MEM_reg_file_write(wire_EXE_MEM_reg_file_write),

        .ForwardA_sel   (FWD_EXE_rs1_sel),
        .ForwardB_sel   (FWD_EXE_rs2_sel),//revise

      //Data
        .PC_EXE_in      (ID_EXE_pc_in),
        .EXE_rs1        (ID_EXE_rs1),
        .EXE_rs2        (ID_EXE_rs2),
        .WB_rd_data     (WB_rd_data),
        .MEM_rd_data    (wire_MEM_WB_rd_dir), //Focus

        .EXE_imm        (ID_EXE_imm), 
        .EXE_function_3 (ID_EXE_function3),
        .EXE_function_7 (ID_EXE_function7),
        .ID_EXE_rd_addr (ID_EXE_rd_addr),
        
        .EXE_PC_imm     (EXE_IF_pc_imm),

        .pc_sel_o       (wire_EXE_MEM_PC),
        .zeroflag       (EXE_Bctrl_zeroflag),
        .ALU_o          (wire_EXE_MEM_ALU_o),
        .ALU_o_2_immrs1 (EXE_IF_ALU_o),
        .Mux3_ALU       (wire_EXE_MEM_rs2_data),

        .EXE_MEM_function_3 (wire_EXE_MEM_function_3),
        .EXE_MEM_rd_addr(wire_EXE_MEM_rd_addr)
    );

//------------------- MEM_Stage -------------------//
    MEM_Stage MEM_Stage_inst(
        .clk(clk),  
        .rst(rst), 
        //----------------- Ctrl sig reg ----------------------//
        .MEM_rd_sel       (EXE_MEM_rd_sel),
        .MEM_DMread_sel   (EXE_MEM_DM_read), 
        .MEM_DMwrite_sel  (EXE_MEM_DM_write),
        .EXE_MEM_WB_data_sel (EXE_MEM_data_sel),
        .EXE_MEM_reg_file_write (EXE_MEM_reg_file_write),
        .MEM_WB_data_sel  (wire_MEM_WB_data_sel),
        .MEM_WB_reg_file_write (wire_MEM_WB_reg_file_write),
        //----------------------- MEM_I/O -----------------------//
        .MEM_pc           (EXE_MEM_PC),
        .MEM_ALU          (EXE_MEM_ALU_o),
        .EXE_MEM_rd_addr  (EXE_MEM_rd_addr),
        .MEM_WB_rd_addr   (wire_MEM_WB_rd_addr),
        //------------------------ Data ------------------------//  
        .EXE_funct3       (EXE_MEM_function_3),
        .EXE_rs2_data     (EXE_MEM_rs2_data),     
        .MEM_rd_data      (wire_MEM_WB_rd_dir),

        //------------------------- DM -------------------------//    
        .chip_select      (MEM_DM_CS),
        //------------------------- SW -------------------------// 
        .w_eb             (DM_write_enable),
        .DM_in            (MEM_DM_Din),

        //------------------------- LW -------------------------//     
        .DM_out           (DM_MEM_Dout),
        .DM_out_2_reg     (wire_MEM_WB_rd_DM)
    );

    SRAM_wrapper DM1(
        .CK (~clk), 
        .CS (MEM_DM_CS),
        .OE (EXE_MEM_DM_read),
        .WEB(DM_write_enable),
        .A  (EXE_MEM_ALU_o[15:2]),
        .DI (MEM_DM_Din), 
        .DO (DM_MEM_Dout)
    );

//------------------- WB_Stage -------------------//
    WB_Stage WB_Stage_inst(
        .data_sel       (MEM_WB_data_sel),

        .WB_rd_dir      (MEM_WB_rd_dir),
        .WB_rd_DM       (MEM_WB_rd_DM),
        .WB_rd_data     (WB_rd_data)
    );

//--------------- Branch Control -----------------//
    Branch_Ctrl Branch_Ctrl_inst(
        .zeroflag       (EXE_Bctrl_zeroflag),
        .branch_signal  (ID_EXE_branch_signal),
        .branch_sel     (BC_IF_branch_sel)
    );

//---------------- Hazard Control -----------------//
    Hazard_Ctrl Hazard_Ctrl_inst(
        .branch_sel         (BC_IF_branch_sel),
        .EXE_read           (ID_EXE_DM_read),

        .ID_rs1_addr        (ID_EXE_rs1_addr),
        .ID_rs2_addr        (ID_EXE_rs2_addr),
        .EXE_rd_addr        (EXE_MEM_rd_addr),

        .pc_write           (HAZ_IF_pc_w),  
        .instr_flush        (HAZ_IF_instr_flush),
        .IF_ID_reg_write    (wire_HAZ_IF_ID_reg_write),
        .ctrl_sig_flush     (wire_ctrl_sig_flush)
    );

//--------------- Forwarding Unit -----------------//
    ForwardingUnit ForwardingUnit_inst(
       .ID_rs1_addr          (ID_EXE_rs1_addr),
       .ID_rs2_addr          (ID_EXE_rs2_addr),
       .EXE_rd_addr          (EXE_MEM_rd_addr),
       .MEM_rd_addr          (MEM_WB_rd_addr),

       .EXE_MEM_fwd_write    (EXE_MEM_reg_file_write),
       .MEM_WB_fwd_write     (MEM_WB_reg_file_write),

       .FWD_rs1_sel          (FWD_EXE_rs1_sel),
       .FWD_rs2_sel          (FWD_EXE_rs2_sel)
    );

//--------------- register_reset -----------------//
    always_ff @(posedge clk) begin
        if (rst) begin
            IF_ID_pc                <=  0;
            IF_ID_instr             <=  0;
        end 
        else begin
            if(wire_HAZ_IF_ID_reg_write) begin
                IF_ID_pc                <= wire_IF_ID_pc;
                IF_ID_instr             <= (HAZ_IF_instr_flush) ? 32'b0 : wire_IF_ID_instr;    
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            ID_EXE_pc_in            <=  0;
            ID_EXE_rs1              <=  0;   
            ID_EXE_rs2              <=  0;
            ID_EXE_function3        <=  0;
            ID_EXE_function7        <=  0;
            ID_EXE_rs1_addr         <=  0;
            ID_EXE_rs2_addr         <=  0;
            ID_EXE_rd_addr          <=  0;
            ID_EXE_imm              <=  0;
            ID_EXE_ALU_Ctrl_op      <=  0;
            ID_EXE_pc_mux           <=  0;
            ID_EXE_ALU_rs2_sel      <=  0;
            ID_EXE_branch_signal    <=  0;
            ID_EXE_rd_sel           <=  0;
            ID_EXE_DM_read          <=  0;
            ID_EXE_DM_write         <=  0;
            ID_EXE_WB_data_sel      <=  0;
            ID_EXE_reg_file_write   <=  0;
        end 
        else begin
            ID_EXE_pc_in            <= wire_ID_EXE_pc_in;
            ID_EXE_rs1              <= wire_ID_EXE_rs1;
            ID_EXE_rs2              <= wire_ID_EXE_rs2;
            ID_EXE_function3        <= wire_ID_EXE_function3    ;
            ID_EXE_function7        <= wire_ID_EXE_function7    ;
            ID_EXE_rs1_addr         <= wire_ID_EXE_rs1_addr     ;
            ID_EXE_rs2_addr         <= wire_ID_EXE_rs2_addr     ;
            ID_EXE_rd_addr          <= wire_ID_EXE_rd_addr      ;
            ID_EXE_imm              <= wire_ID_EXE_imm          ;
            ID_EXE_ALU_Ctrl_op      <= wire_ID_EXE_ALU_Ctrl_op  ;
            ID_EXE_pc_mux           <= wire_ID_EXE_pc_mux       ;
            ID_EXE_ALU_rs2_sel      <= wire_ID_EXE_ALU_rs2_sel  ;
            ID_EXE_branch_signal    <= (wire_ctrl_sig_flush) ? 1'b0 : wire_ID_EXE_branch_signal;
            ID_EXE_rd_sel           <= wire_ID_EXE_rd_sel       ;
            ID_EXE_DM_read          <= (wire_ctrl_sig_flush) ? 1'b0 : wire_ID_EXE_DM_read;
            ID_EXE_DM_write         <= (wire_ctrl_sig_flush) ? 1'b0 : wire_ID_EXE_DM_write;   
            ID_EXE_WB_data_sel      <= wire_ID_EXE_WB_data_sel  ;
            ID_EXE_reg_file_write   <= (wire_ctrl_sig_flush) ? 1'b0 : wire_ID_EXE_reg_file_write;     
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            EXE_MEM_PC                <=    0;                 
            EXE_MEM_ALU_o             <=    0;                                
            EXE_MEM_rs2_data          <=    0;                          
            EXE_MEM_function_3        <=    0;                                    
            EXE_MEM_rd_addr           <=    0;                     

            EXE_MEM_DMread_sel        <=    0;                  
            EXE_MEM_DMwrite_sel       <=    0;                   
            EXE_MEM_rd_sel            <=    0;           
            EXE_MEM_DM_read           <=    0;                  
            EXE_MEM_DM_write          <=    0;                  
            EXE_MEM_data_sel          <=    0;  
            EXE_MEM_reg_file_write    <=    0;               
        end 
        else begin
            EXE_MEM_PC                <=    wire_EXE_MEM_PC         ;                 
            EXE_MEM_ALU_o             <=    wire_EXE_MEM_ALU_o      ;                                
            EXE_MEM_rs2_data          <=    wire_EXE_MEM_rs2_data   ;                                     
            EXE_MEM_function_3        <=    wire_EXE_MEM_function_3 ;                                    
            EXE_MEM_rd_addr           <=    wire_EXE_MEM_rd_addr    ;                     

            EXE_MEM_DMread_sel        <=    wire_EXE_MEM_DMread_sel;                   
            EXE_MEM_DMwrite_sel       <=    wire_EXE_MEM_DMwrite_sel;                   
            EXE_MEM_rd_sel            <=    wire_EXE_MEM_rd_sel;                
            EXE_MEM_DM_read           <=    wire_EXE_MEM_DM_read;                      
            EXE_MEM_DM_write          <=    wire_EXE_MEM_DM_write;                     
            EXE_MEM_data_sel          <=    wire_EXE_MEM_data_sel;  
            EXE_MEM_reg_file_write    <=    wire_EXE_MEM_reg_file_write;           
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            MEM_WB_rd_dir      <=   0;     
            MEM_WB_rd_DM       <=   0; 
            MEM_WB_rd_addr     <=   0; 
            
            MEM_WB_data_sel    <=   0;   
            MEM_WB_reg_file_write   <=  0;
        end 
        else begin
            MEM_WB_rd_dir           <=   wire_MEM_WB_rd_dir;      
            MEM_WB_rd_DM            <=   wire_MEM_WB_rd_DM;       
            MEM_WB_rd_addr          <=   wire_MEM_WB_rd_addr;
            
            MEM_WB_data_sel         <=   wire_MEM_WB_data_sel; 
            MEM_WB_reg_file_write   <=   wire_MEM_WB_reg_file_write;               
        end        
    end
endmodule
