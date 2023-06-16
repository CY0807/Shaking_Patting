
module SimTop (
    input wire clk,
    input wire rst_n,

    output wire master_req,
    input wire [31:0] master_data,
    input wire master_busy,
	
    output wire slave_en,
    output wire [31:0] slave_data,
    input wire slave_busy
);
    
    wire [31:0] master_data_pipe, pipe_data_slave;
    wire master_valid_pipe, pipe_valid_slave; 
    wire master_ready_pipe, pipe_ready_slave;
    
    master_interface master_interface_inst(
        .clk(clk),
        .rst_n(rst_n),

    //input signals
        .i_master_data(master_data),
        .i_master_busy(master_busy),
        .o_master_req (master_req),

    // signals to slave
        .o_master_data (master_data_pipe),
        .o_master_valid(master_valid_pipe),
        .i_master_ready(master_ready_pipe)
    );
	
	// 1. no patting
    // handshake_pipe_no_patting handshake_pipe_inst (
	
	// 2. valid patting
	 handshake_pipe_valid_patting handshake_pipe_inst (
	
	// 3. ready patting
	// handshake_pipe_ready_patting handshake_pipe_inst (
	
	// 4. both patting
	// handshake_pipe_both_patting handshake_pipe_inst (
	    .clk(clk),
		.rst_n(rst_n),
		
        .master_valid(master_valid_pipe),
        .master_data (master_data_pipe ),
        .master_ready(master_ready_pipe),
        
        .slave_valid(pipe_valid_slave),
        .slave_data (pipe_data_slave ),
        .slave_ready(pipe_ready_slave)
    );


    slave_interface slave_interface_inst (
        .clk(clk),
        .rst_n(rst_n),


    // output signals
        .o_slave_data(slave_data),
        .o_slave_en  (slave_en  ),
        .i_slave_busy(slave_busy),

    // signals between master and slave interfaces
        .i_slave_valid(pipe_valid_slave),
        .i_slave_data (pipe_data_slave ),
        .o_slave_ready(pipe_ready_slave)
    );
endmodule