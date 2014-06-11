// --------------------------------------------------------------------
// Sistemas Digitales Programables
// Curso 2013 - 2014
// --------------------------------------------------------------------
// Nombre del archivo: contador8bitsparam.v
//
// Descripcion: Este codigo Verilog implementa un contador de 8 bits parametrizable con
// la siguiente funcionalidad de sus entradas y salidas:
// 1. R, bus de 8 bits para la carga en paralelo
// 2. reset, Reset activo a nivel bajo sincrono.
// 3. clock, Reloj activo por flanco de subida.
// 4. enable, Si esta a nivel alto la cuenta avanza un paso (hacia delante o hacia detras)
// 5. load, activo a nivel bajo, carga los datos de R en Q
// 6. modo, si modo==1, avanza hacia delante, si modo==0, en sentido contrario
// 7. Q, Bus de n bits que almacena las salidas
// 8. TC, Señal de final de cuenta, es uno cuando el contador llega al final del modulo
//
// --------------------------------------------------------------------
// Version: V1.0 | Fecha Modificacion: 11/0/2014
//
// Autor: Dario Alandes Codina
// Ordenador de trabajo: DISE13 
// Compartido con: Joan Bono Aguilar
// --------------------------------------------------------------------


module contadorh(DEN, HD,COUNT, clock);

parameter fin_cuenta=1056, bp=216, fp=1016; //El parametro fin_cuenta es el modulo del contador
`include "MathFun.vh"
parameter n=CLogB2(fin_cuenta-1); //Esta funcion está incluida en MathFunc.vh, calcula cuantos bits
											// se necesitan para poder contar hasta fin_cuenta
input  clock;

output reg HD=1, DEN=0;
output reg [n-1:0]COUNT;




always @(posedge clock)
	begin
		if(COUNT==fin_cuenta-1)
			COUNT<=0;
		else
			COUNT<=COUNT+1'b1;
		if (COUNT==0)
			HD<=0;
		else
			HD<=1;
		if (COUNT>=bp && COUNT<fp)
			DEN<=1;
		else 
			DEN<=0;
		
end
endmodule
