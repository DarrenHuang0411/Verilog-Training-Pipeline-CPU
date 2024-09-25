//------------------------- File Info -------------------------//

//------------------------ Environment ------------------------//
`define minus_abs(a,b) ((a>=b) ? a-b : b-a)

module EXE_FP_ALU (
//Ctrl
    input   wire [4:0] FP_ALU_ctrl,
//I/O
    input   wire [`DATA_WIDTH -1:0] rs1,
    input   wire [`DATA_WIDTH -1:0] rs2,
    output  wire [`DATA_WIDTH -1:0] ALU_FP_out //(check whether 32 bit)
    //output  
    //output  reg  zeroflag
);
//------------------------- parameter -------------------------//    
    reg     [`DATA_WIDTH -1:0]  FPU_rs1;
    reg     [`DATA_WIDTH -1:0]  FPU_rs2;    
    wire    [`DATA_WIDTH -1:0]  significand_rs1;
    wire    [`DATA_WIDTH -1:0]  significand_rs2;
    wire    [5:0]               shift;
    wire    [`DATA_WIDTH -1:0]  significand_rs2_s;

    wire                        signed_out;
    wire    [`EXP -1:0]         exp_out;
    wire    [`FRACTION -1:0]    fract_out;
    
    reg                         ALU_real_type;
    wire    [`DATA_WIDTH :0]    significand_add;
    reg     [`EXP -1:0]         exp_add; 
    reg     [`FRACTION -1:0]    fract_add;

    //------------------Float Point ---------------------------// 
    localparam  [4:0]   ALU_FP_add  =   5'd22,
                        ALU_FP_sub  =   5'd23;                        

//------------------------- Basic -------------------------//
    always_comb begin
        if (rs1[30:0] >= rs2[30:0]) begin
            FPU_rs1 = rs1;
            FPU_rs2 = rs2;            
        end 
        else begin
            FPU_rs1 = rs2;
            FPU_rs2 = rs1;           
        end
    end

    assign  significand_rs1     =   (FPU_rs1[30:23] == 0) ? {1'b0, FPU_rs1[22:0], 8'd0} : {1'b1, FPU_rs1[22:0], 8'd0};    
    assign  significand_rs2     =   (FPU_rs1[30:23] == 0) ? {1'b0, FPU_rs2[22:0], 8'd0} : {1'b1, FPU_rs2[22:0], 8'd0}; 
    assign  shift               =   `minus_abs(rs1[30:23],rs2[30:23]);
    assign  significand_rs2_s   =   significand_rs2 >> shift;

    assign  signed_out          =   FPU_rs1[31];
    assign  exp_out             =   (ALU_real_type) ? exp_add   : 8'b0;//exp_sub;
    assign  fract_out           =   (ALU_real_type) ? fract_add : 23'b0;//fract_sub; 
    assign  ALU_FP_out          =   {signed_out,exp_out, fract_out};

    // //Exception flag sets 1 if either one of the exponent is 255.
    // //assign Exception = (&operand_a[30:23]) | (&operand_b[30:23]);
//------------------------- Operation type -------------------------//
    //rs1 is fixed larger than rs2 
    always_comb begin
        case (FP_ALU_ctrl)
            ALU_FP_add: ALU_real_type   =   !(FPU_rs1[31] ^ FPU_rs2[31]);
            ALU_FP_sub: ALU_real_type   =   FPU_rs1[31] ^ FPU_rs2[31];
            default:    ALU_real_type   =   !(FPU_rs1[31] ^ FPU_rs2[31]);
        endcase
    end
//-------------------------- Addition --------------------------------//
    assign  significand_add    =    significand_rs1 + significand_rs2_s; //32 bit
    
    always_comb begin
        if(significand_add[32]) begin
            exp_add     =   FPU_rs1[30:23] + 1'b1;
            fract_add   =   significand_add[31:9];
        end
        else begin
            exp_add     =   FPU_rs1[30:23];
            fract_add   =   significand_add[30:8];            
        end
    end

endmodule
