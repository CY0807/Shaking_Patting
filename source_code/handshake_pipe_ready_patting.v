module handshake_pipe_ready_patting (
    input wire clk,
    input wire rst_n,

    input wire master_valid,
    input wire [31:0] master_data,
    output wire master_ready,

    output wire slave_valid,
    output wire [31:0] slave_data,
    input wire slave_ready
    );
	
	//1. 在 Master 端握手成功后保持住 valid+data:		
    //2. 在 Slave 端握手成功后使master的 valid+data 直达slave：
	// 其优先级高于保持
		
	wire shake_master = master_valid & master_ready; // 握手信号
	wire shake_slave = slave_valid & slave_ready;
	wire store_data = shake_master & ~shake_slave; // 保持数据使能信号 
	
    reg ready_reg;
	reg valid_reg;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ready_reg <= 1'b0;
        end
        else begin
            ready_reg <= slave_ready | ( (~valid_reg)&(~store_data) );
        end
    end
    	
	reg [31:0] data_reg;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_reg <= 32'd0;
        end
        else if(store_data)begin
            data_reg <= master_data; 
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            valid_reg <= 1'b0;
        end
		else if(shake_slave) begin
			valid_reg <= 1'b0;
		end
        else if(shake_master) begin
            valid_reg <= 1'b1;
        end
    end

    assign slave_data   = valid_reg ? data_reg : master_data;
    assign slave_valid  = valid_reg ? 1'b1 : master_valid; 
    assign master_ready = ready_reg;
endmodule





