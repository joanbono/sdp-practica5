// --------------------------------------------------------------------
// Sistemas Digitales Programables
// Curso 2013 - 2014
// --------------------------------------------------------------------
// Nombre del archivo: LCD_SYNC.v
//
// Descripcion: Este codigo Verilog consigue mostrar un caracter en el centro de la pantalla VGA y tiene
// la siguiente funcionalidad de sus entradas y salidas:
// 1. CLOCK_50: El reloj que utilizaremos como punto de partida para crear todas las señales de sincronismo
// 2. R,G,B: Colores que seran mostrados por pantalla
// 4. HD,VD,DEN,NCLK: Señales de sincronismo para habilitar la VGA
// 5. GRESTin/GREST: Reset de la pantalla, controlado por el switch 0
// 6. fila,columna: Contador de filas y columnas en la region visible
//
// --------------------------------------------------------------------
// Version: V1.0 | Fecha Modificacion: 11/0/2014
//
// Autor: Dario Alandes Codina
// Ordenador de trabajo: DISE13 
// Compartido con: Joan Bono Aguilar
// --------------------------------------------------------------------

module LCD_SYNC(CLOCK_50,HD,VD,GREST, GRESTin, NCLK,DEN,fila,columna);

`include "MathFun.vh"
parameter fch=1056, bph=216, fph=1016, fcv=526, bpv=35, fpv=515;
parameter ch=CLogB2(fch-1), cv=CLogB2(fcv-1), chb=CLogB2(fph-bph-1), cvb=CLogB2(fpv-bpv-1);

input CLOCK_50, GRESTin,NCLK;

output HD,VD, GREST,DEN;
output reg [chb-1:0]columna;
output reg [cvb-1:0]fila;

wire denh, denv;
wire [ch-1:0]counth;
wire [cv-1:0]countv;

//Asignamos el SW0 a GRESTin para controlar el reset con el interruptor
assign GREST=GRESTin;

//Utilizamos este modulo para sacar un reloj a 25MHz


//Llamamos al contador horizontal y nos devuelve HD, denh y conth
contadorh #(.fin_cuenta(fch), .bp(bph), .fp(fph))conth (. clock(NCLK), .HD(HD), .DEN(denh), .COUNT(counth));

//Llamamos al contador vertical y nos devuelve VD, denv y countv
contadorv #(.fin_cuenta(fcv), .bp(bpv), .fp(fpv))contv(. clock(NCLK), .VD(VD), .COUNT(countv), .DEN(denv), .HD(HD));

//DEN será 1 cuando denh Y denv sean 1
assign DEN=denh & denv;

//Creamos fila y columna, unos contadores que nos indican la posicion en la pantalla visible
always @(NCLK) 
	begin
		if(counth<bph || counth>fph) columna<=0;
		else columna<=(counth-bph-1);

		if(countv<bpv || countv>fpv) fila<=0;
		else fila<=(countv-bpv-1);
	end

endmodule
