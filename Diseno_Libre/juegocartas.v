// --------------------------------------------------------------------
// Universitat Polit�cnica de Val�ncia
// Escuela T�cnica Superior de Ingenieros de Telecomunicaci�n
// --------------------------------------------------------------------
// Sistemas Digitales Programables
// Curso 2013 - 2014
// --------------------------------------------------------------------
// Nombre del archivo: contador8bits.v
//
// Descripción: Este código Verilog implementa un contador de 8 bits con
// la siguiente funcionalidad de sus entradas y salidas:
// 1. R, bus de 8 bits para la carga en paralelo
// 2. reset, Reset activo a nivel bajo as�ncrono.
// 3. clock, Reloj activo por flanco de subida.
// 4. enable, Si est� a nivel alto la cuenta avanza un paso (hacia delante o hacia detr�s)
// 5. load, activo a nivel bajo, carga los datos de R en Q
// 6. modo, si modo==1, avanza hacia delante, si modo==0, en sentido contrario
// 7. Q, Bus de n bits que almacena las salidas
//
// --------------------------------------------------------------------
// Version: V1.0 | Fecha Modificacion: 11/0/2014
//
// Autor: Joan Bono Aguilar
// Ordenador de trabajo: DISE13 
// Compartido con: Dario Alandes
// --------------------------------------------------------------------


module contador8bitsparam (R, reset, clock, enable, load, modo, Q, TC);
parameter fin_cuenta=256;
`include "MathFun.vh"
parameter n=CLogB2(fin_cuenta-1);

input [n-1:0] R;
input reset, clock, enable, load, modo;
output reg [n-1:0] Q=0;
output reg TC=1'b0;
integer direccion;


always @ (Q[n-1:0])
begin
if (Q[n-1:0]==fin_cuenta-1)
TC=1'b1;
else
TC=1'b0;
end 


always @(posedge clock)
begin
	if (!reset)
		Q<=0;
	else
	begin
		if (enable)
		begin
			if (modo)
				direccion=1;
			else
				direccion =-1;
			
			if (!load)
				Q<=R;
			else
			begin
				if(Q==fin_cuenta-1) Q<=0;
				else Q<=Q+direccion;	
			end
	end
	end
end
endmodule
