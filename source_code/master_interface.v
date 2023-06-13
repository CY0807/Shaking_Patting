module master_interface (   
    input wire clk,
    input wire rst_n,

    //input signals
    input wire [31:0] i_master_data,
	input wire i_master_busy,
    output wire o_master_req, // 规定data比req信号慢一怕, 若当拍有busy信号，req无效，需重新拉高

    // signals to slave
    output wire [31:0] o_master_data,
    output wire o_master_valid,
    input wire i_master_ready
);

    wire shake = i_master_ready & o_master_valid;
	reg req_reg;
	always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
		    req_reg <= 1'b1;
		end
		else if(i_master_busy & (shake | req_reg)) begin
		    req_reg <= 1'b1;
		end
		else begin
		    req_reg <= 1'b0;
		end
    end	
	assign o_master_req = shake | req_reg;
	
	reg o_master_valid_reg;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
		    o_master_valid_reg <= 1'b0;
		end
		else begin
		    if(o_master_req & (~i_master_busy)) begin
				o_master_valid_reg <= 1'b1;
			end
			else if(shake) begin
				o_master_valid_reg <= 1'b0;
			end
		end
    end	
	assign o_master_data = i_master_data;
	assign o_master_valid = o_master_valid_reg;

endmodule




