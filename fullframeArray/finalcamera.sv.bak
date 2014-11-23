module final_project_fpga(input logic clk, href,
								  input logic [7:0] digital,
								  output logic xclk, 
								  output logic [15:0] pixel);
	// assign xclk to 40 Mhz clk
	assign xclk = clk; // comb_logic
	
	read_y_cr_cb read_y_cr_cb(xclk, href, digital, pixel);
	
endmodule

module read_y_cr_cb(input logic pclk, href, 
						  input logic [7:0] digital,
						  output logic [15:0] pixel);
						  
						  logic [15:0] d = 16'b0;
						  logic en = 1'b1;
						  // Read a byte when pclk rises and when href = 1
						  always_ff @(posedge pclk)
						  begin
								if (href) 
								begin
									d[7:0] <= digital[7:0];
									d[15:8] <= d[7:0];
									en <= !en;
									if (en) pixel <= d;
								end
						  end 
endmodule
		


		
module xyCoord #(parameter HMAX   = 10'd800,
                           VMAX   = 10'd525, 
									HSTART = 10'd152,
									WIDTH  = 10'd640,
									VSTART = 10'd37,
									HEIGHT = 10'd480)
						  (input  logic       pclk, href, vref, 
							output logic [9:0] x, y);

  logic [9:0] hcnt, vcnt;
  logic       oldhsync;
  
  // counters for horizontal and vertical positions
  always @(posedge pclk) begin
    if (hcnt >= HMAX) hcnt = 0;
    else hcnt++;
	 if (href & ~oldhsync) begin // start of hsync; advance to next row
	   if (vcnt >= VMAX) vcnt = 0;
      else vcnt++;
    end
    oldhsync = href;
  end
  
  // determine x and y positions
  assign x = hcnt - HSTART;
  assign y = vcnt - VSTART;
end module			
					

byte [19:0][19:0] A;
module makeArray(input logic [9:0] x, y
						input logic [8:0] pixel,
						output logic [19:0][19:0] Array);
		always_comb
			begin
				if (x < 20 && y < 20)
					A[x][y] = pixel;
			end
		end
endmodule  