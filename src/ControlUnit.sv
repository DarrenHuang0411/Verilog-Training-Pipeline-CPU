

module ControlUnit (
    input   logic   [6:0] opcode,
    
    output  logic   [2:0] ALU_Ctrl_op,
    output  logic   [2:0] Imm_type, 
    //Control Signal 
    output  logic         ALU_rs2_sel,
    output  logic         pc_sel,
    
    output  logic         DM_read,
    output  logic         DM_write, 
    output  logic   [1:0] branch_signal

);

//parameter
    //Type
    localparam [2:0]    R_type      =   3'b000,
                        I_type      =   3'b001,
                        ADD_type    =   3'b010,// I, S, U(AUIPC), J_type
                        I_JAL_type  =   3'b011,
                        B_type      =   3'b100,
                        U_LUI_type  =   3'b101;
    //Imm
    localparam  [2:0]   Imm_I       =   3'b000,
                        Imm_S       =   3'b001,
                        Imm_B       =   3'b010,
                        Imm_U       =   3'b011,
                        Imm_J       =   3'b100;
    //branch_type
    localparam [1:0]    N_Branch    =   2'b00,
                        JAL_Branch  =   2'b01,
                        B_Branch    =   2'b10,
                        J_Branch    =   2'b11;

//logic
    always_comb begin 
        case (opcode)
            //R-type
            7'b0110011: begin
                ALU_Ctrl_op     =   R_type;
                Imm_type        =   Imm_I; //don't care

                ALU_rs2_sel     =   1'b1; // 1: rs2 (default), 0: Imm
                pc_sel          =   1'b0;
                branch_signal   =   N_Branch;
            end
            //I-type - LW/LB/LH/LHU/LBU
            7'b0000011: begin
                ALU_Ctrl_op     =   ADD_type;
                Imm_type        =   Imm_I;

                ALU_rs2_sel     =   1'b0; // 1: rs2 (default), 0: Imm 
                pc_sel          =   1'b0;
                branch_signal   =   N_Branch;                           
            end
            //I-type
            7'b0010011: begin
                ALU_Ctrl_op     =   I_type;
                Imm_type        =   Imm_I;

                ALU_rs2_sel     =   1'b0; // 1: rs2 (default), 0: Imm
                branch_signal   =   N_Branch;
            end
            //I-type - JALR
            7'b1100111: begin
                ALU_Ctrl_op     =   I_JAL_type;
                Imm_type        =   Imm_I;          

                ALU_rs2_sel     =   1'b0; // 1: rs2 (default), 0: Imm
                branch_signal   =   JAL_Branch;
            end
            //S-type
            7'b0100011: begin
                ALU_Ctrl_op     =   ADD_type; 
                Imm_type        =   Imm_S;

                ALU_rs2_sel     =   1'b0; // 1: rs2 (default), 0: Imm 
                branch_signal   =   JAL_Branch;                             
            end
            //B-type
            7'b1100011: begin
                ALU_Ctrl_op     =   B_type; 
                Imm_type        =   Imm_B;

                ALU_rs2_sel     =   1'b1; // 1: rs2 (default), 0: Imm
                branch_signal   =   B_Branch;                
            end
            //U-type - AUIPC
            7'b0010111: begin
                ALU_Ctrl_op =   ADD_type;
                Imm_type    =   Imm_U;

                ALU_rs2_sel =   1'b0; // 1: rs2 (default), 0: Imm                   
            end
            //U-type - LUI
            7'b0110111: begin
                ALU_Ctrl_op =   U_LUI_type;
                Imm_type    =   Imm_U;

                ALU_rs2_sel =   1'b0; // 1: rs2 , 0: Imm (default)    
            end
            //J-type
            7'b1101111: begin
                ALU_Ctrl_op =   ADD_type;
                Imm_type    =   Imm_I;

                ALU_rs2_sel =   1'b0; // 1: rs2 , 0: Imm (default)                  
            end
            default: begin //don't care
                ALU_Ctrl_op =   ADD_type;
                Imm_type    =   Imm_I;     

                ALU_rs2_sel =   1'b0; // 1: rs2 , 0: Imm (default)                     
            end
        endcase
    end

endmodule
