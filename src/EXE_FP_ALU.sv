//------------------------- File Info -------------------------//

//------------------------ Environment ------------------------//

//

module EXE_FP_ALU (
//Ctrl
    input   wire [4:0] FP_ALU_ctrl,
//I/O
    input   wire [`DATA_WIDTH -1:0] rs1,
    input   wire [`DATA_WIDTH -1:0] rs2,
    output  reg  [`DATA_WIDTH -1:0] ALU_FP_out //(check whether 32 bit)
    //output  
    //output  reg  zeroflag
);
//------------------------- parameter -------------------------//    
    localparam  [4:0]   ALU_add =   5'd0,
                        ALU_sub =   5'd1,
                        ALU_sll =   5'd2,
                        ALU_slt =   5'd3,
                        ALU_sltu=   5'd4,
                        ALU_xor =   5'd5,
                        ALU_srl =   5'd6,
                        ALU_sra =   5'd7,
                        ALU_or  =   5'd8,
                        ALU_and =   5'd9,
    //---------------------- mult -----------------------------// 
                        ALU_mul     =   5'd10,
                        ALU_mulh    =   5'd11,
                        ALU_mulhsu  =   5'd12,
                        ALU_mulhu   =   5'd13,

                        ALU_jalr    =   5'd14, 
    //----------------------- beq -----------------------------// 
                        ALU_beq     =   5'd15,
                        ALU_bne     =   5'd16,
                        ALU_blt     =   5'd17,
                        ALU_bge     =   5'd18,
                        ALU_bltu    =   5'd19,       
                        ALU_bgeu    =   5'd20,

                        ALU_imm     =   5'd21,
    //------------------Float Point -----------------------------// 
                        ALU_FP_add  =   5'd22,
                        ALU_FP_sub  =   5'd23;                        

    // wire signed [`DATA_WIDTH -1:0] s_rs1;
    // wire signed [`DATA_WIDTH -1:0] s_rs2;
    // wire        [`DATA_WIDTH -1:0] R_add;
    // wire signed [`MULT_DATA_WIDTH -1:0] Mult_rd_ss;
    // wire signed [`MULT_DATA_WIDTH -1:0] Mult_rd_su;
    // wire        [`MULT_DATA_WIDTH -1:0] Mult_rd_uu;

    // // assign R_add        =   rs1 +   rs2;
    // // assign s_rs1        =   rs1; //deal with the previous stage
    // // assign s_rs2        =   rs2;
    // // assign Mult_rd_ss   =   s_rs1 * s_rs2;
    // // assign Mult_rd_su   =   s_rs1 * $signed({1'b0, rs2}); // mult_s*u
    // // assign Mult_rd_uu   =   rs1 * rs2;

    assign  signed_rs1      =   ;
    assign  signed_rs2      =   ;
    assign  exp_rs1         =   ;
    assign  exp_rs2         =   ;
    assign  fraction_rs1    =   ;
    assign  fraction_rs2    =   ;

     signed_out             =    new_signed_rs1;
     exp_out_temp1          =    new_exp_rs1;
    assign  ALU_FP_out      =    {signed_out,exp_fraact_out} : {};

    // //Exception flag sets 1 if either one of the exponent is 255.
    // //assign Exception = (&operand_a[30:23]) | (&operand_b[30:23]);


    function [`EXP :0] abs_exp_diff;
        input [`EXP -1:0] rs1_exp;
        input [`EXP -1:0] rs2_exp;
        begin
            if (rs1_exp >= rs2_exp) begin
                abs_exp_diff    =   rs1_exp - rs2_exp;
            end 
            else begin
                abs_exp_diff    =   rs2_exp - rs1_exp;    
            end
        end       
    endfunction

//------------------------
    always_comb begin
        unique if (abs_exp_diff(rs1[30:23], rs2[30:23]) == 0)
            change_flag ==  0;
        else 
    end


//------------------------- Basic -------------------------//
    always_comb begin
        case (ALU_ctrl)
            ALU_FP_add: signed_out  =   new_signed_rs1;
            ALU_FP_sub: signed_out  =   (change_flag) ? !(new_signed_rs1) : new_signed_rs1
            default:    signed_out  =   new_signed_rs1;
        endcase  
    end
endmodule
