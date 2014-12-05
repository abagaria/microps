module final_project_fpga(input logic clk, href, vref,
								  input logic [7:0] digital,
								  output logic xclk, 
								  output logic [15:0] pixel,
								  output logic [14:0] wraddr,
								  output logic wren,
								  input logic capture);
								  
	logic [1:0] counter = 2'b0;
	logic [1:0] counter2 = 2'b0;

	//logic [19:0] captureCount = 19'b0;
	
	logic dataclk;
	// TODO: give it 40Mhz 
	// two rams, each buffered row, one writing the other reading
	// three rams, each with a status -> smearing
	// interlace - display every other line
	// expand it, write every row but only read every other row and expand the image
	
	always_ff @(posedge clk)
	begin
		xclk <= (counter < 2'b01) ? 1'b1 : 1'b0;
		
		counter <= (counter == 2'b01) ? 2'b0 : 2'b1;
	end
	
	always_ff @(posedge xclk)
	begin
		dataclk <= (counter2 < 2'b01) ? 1'b1 : 1'b0;
		
		counter2 <= (counter2 == 2'b01) ? 2'b0 : 2'b1;
	end
	
	read_y_cr_cb read_y_cr_cb(xclk, href, vref, digital, pixel);
	
	camera_controller cam_cont(dataclk, href, vref, wraddr, wren); //, capture, captureCount
	

		
endmodule

module camera_controller #(parameter HMAX   = 10'd640,
                                 VMAX   = 10'd480, 
											HSTART = 10'd152,
											WIDTH  = 10'd160,
											VSTART = 10'd37,
											HEIGHT = 10'd120)
								 (input logic dataclk, href, vref,
								  output logic [14:0] wraddr,
								  output logic wren);
								  //input logic capture,
								  //output logic [19:0] captureCount
			
			  //logic [9:0] hcnt, vcnt;
			  logic       oldhref;
			  logic 		  firstVref;
			  logic [9:0] x, y;

			  // counters for horizontal and vertical positions
			  always_ff @(posedge dataclk) begin
				  // use href and vref to determine x and y, 
					if (vref) begin
						y <= 1'b0;
						x <= 1'b0;
						firstVref <= 1'b1;
					end
					
					else if (href && ~oldhref) begin // the row is over and a new one is staring and we increment row and set column to zero
						x <= 1'b0;
						y <= firstVref ? 1'b0:(y + 1'b1);
						firstVref <= 1'b0;
					end
					
					else if (href) begin 
						x <= x + 1'b1;
					end
					
					oldhref <= href;
					//if (capture)
					//captureCount <= 20'd307200;
					//else if (captureCount > 1'b0)
					//	captureCount <= captureCount - 1'b1;

				end
					
			  assign wren = (x < WIDTH && y < HEIGHT); // && captureCount > 1'b0);			
			  assign wraddr = wren ? {x[7:0], y[6:0]} : 15'b0;
								 
endmodule
								 
								
								
								
module read_y_cr_cb(input logic pclk, href, vref, 
						  input logic [7:0] digital,
						  output logic [15:0] pixel);
						  
						  logic [7:0] d1 = 8'b0;
						  logic [7:0] d2 = 8'b0;
						  logic en = 1'b1;
						  // Read a byte when pclk rises and when href = 1
						  always_ff @(posedge pclk)
						  begin
								if (href & ~vref) 
								begin
									d1 <= digital;
									d2 <= d1;
									en <= !en;
									if (en) pixel <= {d2, d1};
									//pixel <= 16'hAAAA;
								end
						  end 
endmodule
		