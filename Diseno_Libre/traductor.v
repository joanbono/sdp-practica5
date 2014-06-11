module traductor (entrada,sal,reloj);

input reloj;
input [3:0] entrada;
reg[6:0] salida;
output reg [6:0] sal;
always@(posedge reloj)
begin
	case(entrada)
		4'b0000:salida=7'b0111111;//0
		4'b0001:salida=7'b0000110;//1
		4'b0010:salida=7'b1011011;//2
		4'b0011:salida=7'b1001111;//3
		4'b0100:salida=7'b1100110;//4
		4'b0101:salida=7'b1101101;//5
		4'b0110:salida=7'b1111101;//6
		4'b0111:salida=7'b0000111;//7
		4'b1000:salida=7'b1111111;//8
		4'b1001:salida=7'b1101111;//9
		4'b1010:salida=7'b1110111;//a
		4'b1011:salida=7'b1111100;//b
		4'b1100:salida=7'b0111001;//c
		4'b1101:salida=7'b1011110;//d
		4'b1110:salida=7'b1111011;//e
		4'b1111:salida=7'b1110001;//f
		default salida=7'b1111111;//default 0
		endcase

		sal=~salida;
		
		end
endmodule
