module hanslavehake_pipe_no_patting (
    input wire master_valid,
    input wire [31:0] master_data,
    output wire master_ready,

    output wire slave_valid,
    output wire [31:0] slave_data,
    input  wire slave_ready
    );

    assign master_ready = slave_ready;
    assign slave_valid = master_valid;
    assign slave_data  = master_data;
    
endmodule