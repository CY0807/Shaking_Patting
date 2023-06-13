`timescale  1ns / 1ps

module testbench();

    integer cnt_master = 0;
	integer cnt_slave = 0;
	integer cnt_max = 30; // 测试中传输数据个数

    reg clk, rst_n; 
    reg [31:0] master_data = 0;
    reg master_busy = 0;
    wire master_req;

    wire slave_en;
    wire [31:0] slave_data;
    reg slave_busy = 0;

    parameter period = 10;
	integer seed = 0;
	
	initial begin
	    clk = 0;
		forever # (period/2) clk = ~clk;
	end

    initial begin
        $display("\n***** Start	Simulation *****");
        $display("Random Seed = ", seed);
		rst_n = 0;
		# (period/2) rst_n = 1;  
    end
	
	always@(posedge clk) begin
		master_busy <= (({$random(seed)}%4) == 0);
		slave_busy <= (({$random(seed)}%4) == 0);
		if(master_req & (!master_busy)) begin
            master_data <= $random(seed);
		end
	end
	
    SimTop SimTop_inst(
        .clk(clk),
        .rst_n(rst_n),
        
        .master_busy(master_busy),
        .master_data(master_data),
        .master_req(master_req),

        .slave_en(slave_en),
        .slave_data(slave_data),
        .slave_busy(slave_busy)
    );
	
// 自动化验证部分
reg [31:0] data_master[0:99];	
reg [31:0] data_slave[0:99];
reg [7:0] timeout = 50;

// timeout
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
	    timeout <= 50;
	end
	if(timeout == 0) begin
		$display("timeout_reg Error!\n");
		$finish;
	end
	else if(cnt_master >= cnt_max || cnt_slave >= cnt_max) begin
        timeout <= timeout-1;
	end
end

// master
reg data_master_en, master_showed;

always@(posedge clk or negedge rst_n) begin
	data_master_en <= master_req && (!master_busy);
    if(!rst_n) begin
	    cnt_master = 0;
		master_showed = 0;
	end
	else if(cnt_master < cnt_max) begin
		if(data_master_en) begin
			data_master[cnt_master] <= master_data;
			cnt_master = cnt_master + 1;
		end
	end
	else if(cnt_master == cnt_max && (~master_showed)) begin
	    $display("master data:");
		for(integer i=0; i<cnt_max; i=i+1) begin
			$write("%d ", data_master[i]);
		end
		$display(" ");
		master_showed = 1;
	end
end

// slave
reg slave_showed;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
	    cnt_slave = 0;
		slave_showed = 0;
	end
	else if(cnt_slave < cnt_max) begin
		if(slave_en) begin
			data_slave[cnt_slave] <= slave_data;
			cnt_slave = cnt_slave + 1;
		end
	end
	else if(cnt_slave == cnt_max && (~slave_showed)) begin
	    $display("slave data:");
		for(integer i=0; i<cnt_max; i=i+1) begin
			$write("%d ", data_slave[i]);
		end
		$display(" ");
		slave_showed = 1;
	end
end

// check
always@(posedge clk or negedge rst_n) begin
	if(cnt_slave == cnt_max && cnt_master == cnt_max && master_showed && slave_showed) begin
		for(integer i=0; i<cnt_max; i=i+1) begin
		    if(data_master[i] != data_slave[i]) begin
			    $display("data Error!\n");
		        $finish;
			end
		end
		$display("PASS\n");
		$finish;
	end
end

endmodule





