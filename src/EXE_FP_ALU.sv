//------------------------- File Info -------------------------//

//------------------------ Environment ------------------------//
`define minus_abs(a,b) ((a>=b) ? a-b : b-a)
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
    //------------------Float Point -----------------------------// 
    localparam  [4:0]   ALU_FP_add  =   5'd22,
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

    ''''''''''''''''''''''''''''''''''''''''
        rs1[30:0] >= rs2[30:0]

            FPU_rs1 = rs1;
            FPU_rs2 = rs2;
        else
            FPU_rs1 = rs2;
            FPU_rs2 = rs1;
    ''''''''''''''''''''''''''''''''''''''''
     
     exp_out_temp1          =    FPU_rs1[30:23];

    assign  significand_rs1 =   () ? {1'b1, FPU_rs1[22:0]} : {1'b0, FPU_rs1[22:0]};    
    assign  significand_rs2 =   {1'b1, FPU_rs2[22:0]};   
    assign  shift           =    minus_abs(rs1[30:23],rs2[30:23]);

    assign  signed_out             =    new_signed_rs1;
    assign  exp_out         =     () ? :  exp_out_temp1;
    assign  ALU_FP_out      =    {signed_out,exp_fraact_out} : {};

    // //Exception flag sets 1 if either one of the exponent is 255.
    // //assign Exception = (&operand_a[30:23]) | (&operand_b[30:23]);


//------------------------
    always_comb begin
        unique if (abs_exp_diff(rs1[30:23], rs2[30:23]) == 0)
            change_flag ==  0;
        else 
    end


//------------------------- Basic -------------------------//
    always_comb begin
        case (ALU_ctrl)
            ALU_FP_add: begin
                
            end
        
            signed_out  =   new_signed_rs1;
            ALU_FP_sub: begin
                
            end
            
            
            signed_out  =   (change_flag) ? !(new_signed_rs1) : new_signed_rs1
            default:    signed_out  =   new_signed_rs1;
        endcase  
    end
endmodule
