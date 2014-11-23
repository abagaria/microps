module final_project_fpga(input logic clk, href, vref,
								  input logic [7:0] digital,
								  output logic xclk, 
								  output logic [15:0] pixel);
	logic [1:0] counter = 2'b0;
	always_ff @(posedge clk)
	begin
		xclk <= (counter < 2'b01) ? 1'b1 : 1'b0;
		
		counter <= (counter == 2'b01) ? 2'b0 : (counter + 2'b1);
	end
	read_y_cr_cb read_y_cr_cb(xclk, href, vref, digital, pixel);
	
endmodule

module read_y_cr_cb(input logic pclk, href, vref, 
						  input logic [7:0] digital,
						  output logic [15:0] pixel);
						  
						  logic [15:0] d = 16'b0;
						  logic en = 1'b1;
						  // Read a byte when pclk rises and when href = 1
						  always_ff @(posedge pclk)
						  begin
								if (href & ~vref) 
								begin
									d[7:0] <= digital[7:0];
									d[15:8] <= d[7:0];
									en <= !en;
									if (en) pixel <= d;
								end
								//else pixel[15:0] <= 16'hff00;
						  end 
endmodule
		