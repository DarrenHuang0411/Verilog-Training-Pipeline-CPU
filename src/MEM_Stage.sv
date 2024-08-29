module MEM_Stage (
    input   wire                        clk,  
    input   wire                        rst, 
    //----------------------- reg_in -----------------------//
    input   logic                       MEM_rd_sel,
    input   logic                       MEM_DMread_sel,
    input   logic                       MEM_DMwrite_sel,

    input   wire  [:]                   MEM_pc,
    input   wire  [`DATA_WIDTH -1:0]    MEM_ALU,




    input   logic [`DATA_WIDTH -1:0]    EXE_ALU_o,
    input   wire  [`FUNCTION_3 -1:0]    EXE_funct3,

    output  wire  [:] MEM_rd_data,

    //DM
    output  logic                       DM_addr,
    input   wire  [`DATA_WIDTH -1:0]    DM_out,


    output  logic                       chip_select,
    output  logic [4:0]                 w_eb,


    output  wire  [`DATA_WIDTH -1:0]    MEM_DM_out
);
    
    wire [:] MEM_rd_src;

//----------------------- rd_sel -----------------------//
    assign  MEM_rd_data = (MEM_rd_sel) ? MEM_pc : MEM_ALU;

    assign  chip_select = MEM_DMread_sel | MEM_DMread_sel;

//------------------- SW_data_output -------------------//
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            DM_addr
        end 
        else begin
            
        end
    end

//------------------------ SW -------------------------//
    //---------------------- En -----------------------//
    always_comb begin
        //active low
        w_eb    =   4'b1111;
        if(MEM_DMread_sel && (!MEM_DMwrite_sel))
            case (EXE_funct3)
                3'b000:   w_eb[EXE_ALU_o[1:0]] = 1'b0;//SB 
                3'b001:   w_eb[] = 2'b0;    //SH
                3'b010:   w_eb  =   4'b0000; //SW
                default:  w_eb  =   4'b0000;
            endcase
    end
    //--------------------- Data ----------------------//
    always_comb begin
        if(MEM_DMread_sel && (!MEM_DMwrite_sel))
            case (EXE_funct3)
                //active low
                3'b000:   w_eb[EXE_ALU_o[]] = 1'b0;//SB 
                3'b001:   w_eb[] = 2'b0;//SH
                3'b010:   w_eb  =   4'b0000; //SW
                default: 
            endcase
    end



//----------------------- LW_data ----------------------//
    assign  MEM_DM_out  =   DM_out;




endmodule
