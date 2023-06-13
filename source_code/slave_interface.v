module slave_interface (
    input wire clk,
    input wire rst_n,

    // output signals
    output wire [31:0] o_slave_data,
    output wire o_slave_en,
    input wire i_slave_busy,

    // signals between master and slave
    input wire i_slave_valid,
    input wire [31:0] i_slave_data,
    output wire o_slave_ready
);

    wire shake = i_slave_valid & o_slave_ready;
    assign o_slave_en = shake;
    assign o_slave_data = i_slave_data;
	
    reg i_slave_busy_reg; // 用于保证ready对齐时钟沿
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            i_slave_busy_reg <= 1'b0;
        end
        else begin
            i_slave_busy_reg <= i_slave_busy;
        end
    end
	
	assign o_slave_ready = i_slave_busy_reg;
 
endmodule