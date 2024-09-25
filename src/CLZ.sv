

module CLZ (
    input       [23:0]  significand_in,
    output      [ 5:0]  CLZ_result
);

    significand_s16
    significand_s16_8
    significand_s16_4
    significand_s16_2  
    
      
    count_s16

    assign  CLZ_result  =   

    always_comb begin
        count_s16   =   0;
        count_s8    =   0;
        significand_s16  =   {input[15:0]}

        if ((input && 0xff_ff00) == 0) begin
           count_s16        =   16;
           if()
        end
        else if((input && 0xff_0000) == 0) begin
            count_s8        =   8;
        end 

    end

endmodule