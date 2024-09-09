//------------------------- File Info -------------------------//

//------------------------ Environment ------------------------//

//

module EXE_ALU (
//Ctrl
    input   wire [4:0] ALU_ctrl,
//I/O
    input   wire [`DATA_WIDTH -1:0] rs1,
    input   wire [`DATA_WIDTH -1:0] rs2,
    output  reg  [`DATA_WIDTH -1:0] ALU_out,
    //output  
    output  reg  zeroflag
);
//------------------------- parameter -------------------------//    
    localparam  [3:0]   ALU_add =   4'd0,
                        ALU_sub =   4'd1,
                        ALU_sll =   4'd2,
                        ALU_slt =   4'd3,
                        ALU_sltu=   4'd4,
                        ALU_xor =   4'd5,
                        ALU_srl =   4'd6,
                        ALU_sra =   4'd7,
                        ALU_or  =   4'd8,
                        ALU_and =   4'd9;
    
    wire [`DATA_WIDTH -1:0] s_rs1;
    wire [`DATA_WIDTH -1:0] s_rs2;
    
    assign s_rs1    =   rs1; //deal with the previous stage
    assign s_rs2    =   rs2; 
//------------------------- Basic -------------------------//
    always_comb begin
        case (ALU_ctrl)
            ALU_add:    ALU_out =   rs1 +   rs2;
            ALU_sub:    ALU_out =   rs1 -   rs2;
            ALU_sll:    ALU_out =   rs1 <<  rs2[4:0];
            ALU_slt:    ALU_out =   (s_rs1 < s_rs2) ? 1 : 0;
            ALU_sltu:   ALU_out =   (rs1 < rs2) ? 32'b1 : 32'b0;
            ALU_xor:    ALU_out =   rs1 ^   rs2;
            ALU_srl:    ALU_out =   rs1 >>  rs2[4:0];
            ALU_sra:    ALU_out =   s_rs1 >>  rs2[4:0];
            ALU_or :    ALU_out =   rs1 |   rs2;
            ALU_and:    ALU_out =   rs1 &   rs2;      
            default:    ALU_out =   32'b0;
        endcase  
    end

//----------------------- Basic_beq -----------------------//
    always_comb begin
        case (ALU_ctrl)
            ALU_beq :   zeroflag    =   (rs1 == rs2) ? 1'b1: 1'b0;
            ALU_bne :   zeroflag    =   (rs1 != rs2) ? 1'b1: 1'b0;
            ALU_blt :   zeroflag    =   (rs1 <  rs2) ? 1'b1: 1'b0;
            ALU_bge :   zeroflag    =   (rs1 >= rs2) ? 1'b1: 1'b0;
            ALU_bltu:   zeroflag    =   (rs1 <  rs2) ? 1'b1: 1'b0;
            ALU_bgeu:   zeroflag    =   (rs1 >= rs2) ? 1'b1: 1'b0;  
            default:    zeroflag    =   1'b0;
        endcase
    end

endmodule
