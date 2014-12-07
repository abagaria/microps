// vga.sv
// 20 October 2011 Karl_Wang & David_Harris@hmc.edu
// VGA driver with character generator

module vgacam(input  logic       clk, href, vref,
			  input logic [7:0] digital,
			  output logic xclk, poopen,
			  output logic       vgaclk,				// 25 MHz VGA clock
			  output logic       hsync, vsync, sync_b,	// to monitor & DAC
			  output logic [7:0] r, g, b,
			  input logic [3:0] switch,
			  input logic button);					// to video DAC
 
    pll	pll_inst (
	.areset ( areset_sig ),
	.inclk0 ( inclk0_sig ),
	.c0 ( c0_sig ),
	.locked ( locked_sig )
	);
	
  // Use a PLL to create the 25.175 MHz VGA pixel clock 
  // 25.175 Mhz clk period = 39.772 ns
  // Screen is 800 clocks wide by 525 tall, but only 640 x 480 used for display
  // HSync = 1/(39.772 ns * 800) = 31.470 KHz
  // Vsync = 31.474 KHz / 525 = 59.94 Hz (~60 Hz refresh rate)
  pll	vgapll(.inclk0(clk),	.c0(vgaclk)); 
  logic [15:0] pixel;
  // ------------------------------------------------------------------------------------
  // call the camera controller to get wraddr and wren. call final_project.. to get pixel
  logic wren;
  logic [14:0] wraddr;
  
  final_project_fpga final_project_fpga(clk, href, vref, digital, xclk, pixel, wraddr, wren, button);
  // VGA Controller 2
	 
  // generate monitor timing signals
  logic [14:0] rdaddr;
  logic rden;
  logic [15:0] q;
  vgaController vgaCont(vgaclk, hsync, vsync, sync_b, rdaddr, rden);
  	
	logic [15:0] address;
	assign address = button ? wraddr : rdaddr;
	// Instantiate RAM module from MegaFunctions
	smallram2	smallram2_inst (
		.address ( address ),
		.clock ( vgaclk ),
		.data ( pixel ),
		.wren ( button ),
		.q ( q )
	);

	assign poopen = wren;
  // user-defined module to determine pixel color
  videoGen videoGen(q, rden, switch, r, g, b);
  
endmodule

module vgaController #(parameter HMAX   = 10'd800,
                                 VMAX   = 10'd525, 
											HSTART = 10'd152,
											WIDTH  = 10'd640,
											VSTART = 10'd37,
											HEIGHT = 10'd480)
						  (input  logic       vgaclk, 
                     output logic       hsync, vsync, sync_b,
							output logic [14:0] rdaddr,
							output logic rden);

  logic [9:0] hcnt, vcnt;
  logic [9:0] x, y;
  logic       oldhsync;
    
  // counters for horizontal and vertical positions
  always @(posedge vgaclk) begin
    if (hcnt >= HMAX) hcnt = 0;
    else hcnt++;
	 if (hsync & ~oldhsync) begin // start of hsync; advance to next row
	   if (vcnt >= VMAX) vcnt = 0;
      else vcnt++;
    end
    oldhsync = hsync;
  end
  
  // compute sync signals (active low)
  assign hsync = ~(hcnt >= 10'd8 & hcnt < 10'd104); // horizontal sync
  assign vsync = ~(vcnt >= 2 & vcnt < 4); // vertical sync
  assign sync_b = hsync | vsync;

  // determine x and y positions
  assign x = (hcnt - HSTART) >> 2;
  assign y = (vcnt - VSTART) >> 2;
  
  // force outputs to black when outside the legal display area
  assign rden = (hcnt >= HSTART & hcnt < HSTART+WIDTH &
 					vcnt >= VSTART & vcnt < VSTART+HEIGHT);			
				
  assign rdaddr = rden ? {y[6:0], x[6:0]} : 15'b0;
endmodule


/*
module videoGen(input  logic [15:0] q,
					 input logic rden,
					 input logic [3:0] switch,
           		 output logic [7:0] r, g, b);
	logic [7:0] pix;
	 always_comb
		begin 

		case(switch)
			4'b0000: pix = {q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7]};
			4'b0001: pix = q[7:0];
			4'b0010: pix = q[15:8];
			4'b0100: pix = {q[8],q[9],q[10],q[11],q[12],q[13],q[14],q[15]};
			4'b1000: pix = {q[15:12], q[7:4]};
			default: pix = 8'hAA;
		endcase
	end
    assign {r, g, b} = rden ? {3{pix}} : {8'h00, 8'h00, 8'h00}; //{3{q[7:0]}}3{q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7],}

endmodule
*/



module videoGen(input  logic [15:0] q,
					 input logic rden,
					 input logic [3:0] switch,
           		 output logic [7:0] r, g, b);
    assign {r, g, b} = rden ? {3{q[0],q[1],q[2],q[3],q[4],q[5],q[6],q[7]}} : {8'h00, 8'h00, 8'h00}; //{3{q[7:0]}}
endmodule


