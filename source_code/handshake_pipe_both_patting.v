module handshake_pipe_both_patting (
    input wire clk,
    input wire rst_n,

    input  wire master_valid,
    input  wire [31:0] master_data,
    output wire master_ready,

    output wire slave_valid,
    output wire [31:0] slave_data,
    input  wire slave_ready
    );

    reg ready_reg;
    reg valid_reg;
    reg [31:0] data0_reg, data1_reg;
	reg [1:0] cnt_reg = 0;
	
	wire shake_master = master_valid & master_ready;
	wire shake_slave = slave_valid & slave_ready;

    always@(posedge clk or negedge rst_n) begin
	    if(!rst_n) begin
		    cnt_reg <= 2'd0;
		end
		else if(shake_master & shake_slave) begin
		    cnt_reg <= cnt_reg;
			data1_reg <= master_data;
		end
	    else if(shake_master) begin
		    cnt_reg <= cnt_reg + 1;
			if(cnt_reg == 0) begin
			    data1_reg <= master_data;
			end
			else begin
			    data0_reg <= master_data;
			end
		end
		else if(shake_slave) begin
		    cnt_reg <= cnt_reg - 1;
			if(cnt_reg == 2) begin
			    data1_reg <= data0_reg;
			end
		end
	end
	
	always@(posedge clk) begin
	    ready_reg <= slave_ready;
	end
	
	// cnt_reg = 1时两者才能并发，类似于conflict free fifo
	assign master_ready = ready_reg & (cnt_reg<2);
	assign slave_valid = cnt_reg>0;
	assign slave_data = data1_reg;
    
endmodule