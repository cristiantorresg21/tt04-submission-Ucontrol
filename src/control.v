module control(clk, rst, ini, enc, ent, sal);
input clk, rst, ini;
output enc;
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
