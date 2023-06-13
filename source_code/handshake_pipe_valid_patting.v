module handshake_pipe_valid_patting (
    input wire clk,
    input wire rst_n,

    input  wire master_valid,
    input  wire [31:0] master_data,
    output wire master_ready,

    output wire slave_valid,
    output wire [31:0] slave_data,
    input  wire slave_ready
    );
	
	// master端握手后，在 pipe 模块中保持住 valid和data 直到 slave 端也握手成功

    assign master_ready = slave_ready | ~valid_reg; // master端ready初始值为高
    assign slave_data   = data_reg   ;
    assign slave_valid  = valid_reg  ;
	
	assign shake_master = master_valid & master_ready;
	assign shake_slave = slave_valid & slave_ready;

    reg valid_reg;
    reg [31:0] data_reg;
	
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            valid_reg <= 1'b0;
        end
        else if(shake_master) begin
            valid_reg <= 1'b1;
        end
        else if(shake_slave) begin
			valid_reg <= 1'b0;
		end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_reg <= 32'd0;
        end
        else if(shake_master)begin
            data_reg <= master_data; 
        end
    end
    
endmodule