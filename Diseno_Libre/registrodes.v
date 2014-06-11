module registrodes(dato, reset, clock, enable, Q);
parameter n=12;
input clock, enable, reset;
input[11:0] dato;
output reg [n-1:0] Q;


always @(posedge clock)
begin
if(reset)
Q<=0;
if (enable)
Q<=dato;
end
endmodule
