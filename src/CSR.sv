

module CSR (
  input  clk, rst,
  input  logic    [`OP_CODE -1:0]     CSR_op,
  input  logic    [`FUNCTION_3 -1:0]  function_3,
  input  logic    [4:0]               rs1_addr,
  input  logic    [`DATA_WIDTH -1:0]  imm_csr,

  input  logic                        lw_use,
  input  logic    [1:0]               branch,
  output logic    [`DATA_WIDTH -1:0]  csr_rd_data
);

  localparam [`OP_CODE -1:0]  CSR_type  = 3'b111;

  localparam [2:0]            CSRRW     = 3'b001,
                              CSRRS     = 3'b010,
                              CSRRC     = 3'b011,
                              CSRRWI    = 3'b101,
                              CSRRSI    = 3'b110,
                              CSRRCI    = 3'b111;

  reg   [`CSR_REG_WIDTH -1 :0] csr_status_reg;
  reg   [`CSR_REG_WIDTH -1 :0] count_instret;
  reg   [`CSR_REG_WIDTH -1 :0] count_cycle;

//----------------------- count instr -----------------------// 
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count_instret   <=  0;
            count_cycle     <=  0;
        end
        else begin
            count_cycle     <=  count_cycle + 1;

            if(count_cycle >= 2) begin
              unique if(lw_use) 
                count_instret   <=  count_instret;
              else if(branch)
                count_instret   <=  count_instret - 1;
              else
                count_instret   <=  count_instret + 1;  
            end
        end
    end

//---------------------------- rd ----------------------------//
    always_comb begin
        if(|rs1_addr)
          csr_rd_data = imm_csr;
        else begin
          case (imm_csr)
            12'hc82:  csr_rd_data  =  count_instret[63:32];
            12'hc02:  csr_rd_data  =  count_instret[31:0];
            12'hc80:  csr_rd_data  =  count_cycle[63:32];
            12'hc00:  csr_rd_data  =  count_cycle[31:0];
            default:  csr_rd_data  =  32'd0;
          endcase
        end
    end

    always_ff @( posedge clk or posedge rst) begin
        if(rst)
          csr_status_reg  <=  32'd0;
        else if (|rs1_addr) begin
          case (function_3)
            CSRRW  :    csr_status_reg  <=  rs1_addr;
            CSRRS  :    csr_status_reg  <=  csr_status_reg | rs1_addr;
            CSRRC  :    csr_status_reg  <=  csr_status_reg & (~rs1_addr);
            CSRRWI :    csr_status_reg  <=  {27'd0, rs1_addr};
            CSRRSI :    csr_status_reg  <=  csr_status_reg | {27'd0, rs1_addr};
            CSRRCI :    csr_status_reg  <=  csr_status_reg | {27'd0,(~rs1_addr)};
            default:    csr_status_reg  <=  32'd0; 
          endcase                
        end
    end

endmodule