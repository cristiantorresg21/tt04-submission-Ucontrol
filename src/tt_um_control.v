module tt_um_control (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches for clk_selector and pattern_sel
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 LEDs
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled, not used circuit can be turned off when pattern_sel = 0
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    assign uio_oe=0;
	assign uio_out=0;
	assign uo_out[7:4]=0;
    control dut (.clk(ui_in[6]), .rst(ui_in[5]), .ini(ui_in[4]), .ent(ui_in[3:0]), .sal(uo_out[3:0]));
endmodule

module control(clk, rst, ini, ent, sal);
input clk, rst, ini;
output [3:0]sal;
input [3:0]ent;
reg [3:0]q;
reg [3:0]q2;
always @(negedge clk) begin
    if (rst)
        q <= 0;
    else if (ini) begin
        q2 <= ent;
        q <= 0;
    end
    else if (q2==q)
            q<=q2;
        else
            q <= q + 1; 
end
assign sal=q;
endmodule
