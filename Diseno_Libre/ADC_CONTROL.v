// --------------------------------------------------------------------
// Sistemas Digitales Programables
// Curso 2013 - 2014
// --------------------------------------------------------------------
// Nombre del archivo: LCD_SYNC.v
//
// Descripcion: Este codigo Verilog sirve para gestionar una conexión serie con un convertidor analógico digital:
//     iCLK,   Reloj de entrada al sistema de 50 Mhz
//		iRST_n,  Reset del convertidor , 
//		oADC_DIN,  datos que se envian a el convertidor para solicitar las coordenadas.
//		oADC_DCLK, reloj de salida que controla el convertidor ADC.
//		oADC_CS,   señal de enable, activa a nivel alto.
//		iADC_DOUT, señal serie para recibir las coordenadas 
//		iADC_PENIRQ_n, señal de disparo, activa a nivel bajo, que inicia la comunicación.	
//		oX_COORD, salida de la coordenada x
//		oY_COORD,  salida de la coordenada y
//    iADC_BUSY, oTOUCH_IRQ,

// CLOCK_50: El reloj que utilizaremos como punto de partida para crear todas las señales de sincronismo
// 2. R,G,B: Colores que seran mostrados por pantalla
// 4. HD,VD,DEN,NCLK: Señales de sincronismo para habilitar la VGA
// 5. GREST: por defecto ==1
// 6. fila,columna: Contador de filas y columnas en la region visible
//
// --------------------------------------------------------------------
// Version: V1.0 | Fecha Modificacion: 11/0/2014
//
// Autor: Dario Alandes Codina
// Ordenador de trabajo: DISE13 
// Compartido con: Joan Bono Aguilar
// --------------------------------------------------------------------

module ADC_CONTROL(
					iCLK,
					iRST_n,
					oADC_DIN,
					oADC_DCLK,
					oADC_CS,
					iADC_DOUT,
					iADC_BUSY,
					iADC_PENIRQ_n,
					oTOUCH_IRQ,
					oX_COORD,
					oY_COORD,
					NCLK
					);

parameter SYSCLK_FRQ	= 25000000;
parameter ADC_DCLK_FRQ	= 1000000;
parameter ADC_DCLK_CNT	= SYSCLK_FRQ/(ADC_DCLK_FRQ*2);

input					iCLK;
input					iRST_n;
input					iADC_DOUT;
input					iADC_PENIRQ_n;
input					iADC_BUSY;
output reg				oADC_DIN;
output reg				oADC_DCLK;
output reg				oADC_CS;
output					oTOUCH_IRQ;
output reg	[11:0]	oX_COORD;
output reg	[11:0]	oY_COORD;
input 					NCLK;
reg	[1:0]state;
parameter S0 = 0, S1 = 1 ;
reg [11:0] oX_Aux, oY_Aux;
wire [11:0] oX_Aux1, oY_Aux1;
wire [11:0] oX_Aux2, oY_Aux2;
wire [11:0] oX_Aux3, oY_Aux3;
wire TC,TC2;
reg idea;
reg espera;
reg [6:0]count=0;
reg ultimo=1'b0;
parameter [7:0] X=8'b10010010, Y=8'b11010010;

 //Creamos el reloj del sistema a 25MHz

contador8bitsparam #(.fin_cuenta(40))cont ( .clock (NCLK), .reset (1'b1), .enable (oADC_CS), .load (1'b1), .modo (1'b1), .TC (TC));

contador8bitsparam #(.fin_cuenta(10000000))cont2 ( .clock (NCLK), .reset (1'b1), .enable (ultimo), .load (1'b1), .modo (1'b1), .TC (TC2));

	always@(posedge NCLK)													
begin																			
	
	if (oADC_CS==1'b0 && iADC_PENIRQ_n==1'b0 && espera==1'b0) 
		begin oADC_CS=1'b1; ultimo=1'b0; 
		end		
	else if (ultimo && oADC_CS==1'b1) 
		begin oADC_CS=1'b0; oADC_DCLK=1'b0; espera=1'b1;
		end		
																		
	if (TC2==1'b1)
     	espera=1'b0;
	if(TC==1'b1)																
	begin
		oADC_DCLK=!oADC_DCLK;  		//Creamos en ADC_DCLK										
		if(count==79)
		begin 
		count=0; 
		idea=1;
		ultimo=1'b1; 
		end		//Creamos el contador de semiciclos	
		else 
		begin
		idea=0;
		count=count+1'b1;
		end
	end																		
						end
//Bloque para controlar ADC_DIN
always@(posedge NCLK)
begin
	case(count)
		0:oADC_DIN=X[7];
		1:oADC_DIN=X[7];
		2:oADC_DIN=X[6];
		3:oADC_DIN=X[6];
		4:oADC_DIN=X[5];
		5:oADC_DIN=X[5];
		6:oADC_DIN=X[4];
		7:oADC_DIN=X[4];
		8:oADC_DIN=X[3];
		9:oADC_DIN=X[3];
		10:oADC_DIN=X[2];
		11:oADC_DIN=X[2];
		12:oADC_DIN=X[1];
		13:oADC_DIN=X[1];
		14:oADC_DIN=X[0];
		15:oADC_DIN=X[0];
					
		32:oADC_DIN=Y[7];
		33:oADC_DIN=Y[7];
		34:oADC_DIN=Y[6];
		35:oADC_DIN=Y[6];
		36:oADC_DIN=Y[5];
		37:oADC_DIN=Y[5];
		38:oADC_DIN=Y[4];
		39:oADC_DIN=Y[4];
		40:oADC_DIN=Y[3];
		41:oADC_DIN=Y[3];
		42:oADC_DIN=Y[2];
		43:oADC_DIN=Y[2];
		44:oADC_DIN=Y[1];
		45:oADC_DIN=Y[1];
		46:oADC_DIN=Y[0];
		47:oADC_DIN=Y[0];
	default oADC_DIN=0;
	endcase
end

//Bloque para recibir ADC_DOUT
always @(posedge NCLK)
if(TC)
	case(count)
		18:oX_Aux[11]=iADC_DOUT;
		20:oX_Aux[10]=iADC_DOUT;
		22:oX_Aux[9]=iADC_DOUT;
		24:oX_Aux[8]=iADC_DOUT;
		26:oX_Aux[7]=iADC_DOUT;
		28:oX_Aux[6]=iADC_DOUT;
		30:oX_Aux[5]=iADC_DOUT;
		32:oX_Aux[4]=iADC_DOUT;
		34:oX_Aux[3]=iADC_DOUT;
		36:oX_Aux[2]=iADC_DOUT;
		38:oX_Aux[1]=iADC_DOUT;
		40:oX_Aux[0]=iADC_DOUT;
			
		50:oY_Aux[11]=iADC_DOUT;
		52:oY_Aux[10]=iADC_DOUT;
		54:oY_Aux[9]=iADC_DOUT;
		56:oY_Aux[8]=iADC_DOUT;
		58:oY_Aux[7]=iADC_DOUT;
		60:oY_Aux[6]=iADC_DOUT;
		62:oY_Aux[5]=iADC_DOUT;
		64:oY_Aux[4]=iADC_DOUT;
		66:oY_Aux[3]=iADC_DOUT;
		68:oY_Aux[2]=iADC_DOUT;
		70:oY_Aux[1]=iADC_DOUT;
		72:oY_Aux[0]=iADC_DOUT;
	endcase

	always@(posedge NCLK)
	begin
	if(oADC_CS)
	begin
	oX_COORD=oX_Aux;
	oY_COORD=oY_Aux;
	end
//	else
//	begin
//	oX_COORD<=0;
//	oY_COORD<=0;
//	end
	end
	
//registrodes(.dato (oX_Aux), .reset(1'b1),.clock(NCLK), .enable(oADC_CS),.Q (oX_Aux1));
//registrodes(.dato (oX_Aux1), .reset(1'b1),.clock(NCLK), .enable(oADC_CS),.Q (oX_Aux2));
//registrodes(.dato (oX_Aux1), .reset(1'b1),.clock(NCLK), .enable(oADC_CS),.Q (oX_COORD));
//registrodes(.dato (oY_Aux), .reset(1'b1),.clock(NCLK), .enable(oADC_CS),.Q (oY_Aux1));
//registrodes(.dato (oY_Aux1), .reset(1'b1),.clock(NCLK), .enable(oADC_CS),.Q (oY_Aux2));
//registrodes(.dato (oY_Aux1), .reset(1'b1),.clock(NCLK), .enable(oADC_CS),.Q (oY_COORD));
endmodule
