// --------------------------------------------------------------------
// Sistemas Digitales Programables
// Curso 2013 - 2014
// --------------------------------------------------------------------
// Nombre del archivo: juegocartas.v
//
// Descripcion: Este codigo Verilog implementa un juego de cartas con las siguientes entradas y salidas:
// 	Este código implementa las entradas y salidas de ADC_CONTROL.v y LCD_SYNC.v
//		Los controles de entrada y salida del juego serían:
// 2. SW[0]: Resetea el juego para volver a empezar (1: Juego activo / 0: Reset)
// 4. El display de 7 segmentos muestra la coordenada donde se ha pulsado
// 5. LEDG[2:0]: Muestra las parejas hechas (LEDG[0]: pareja verde, LED[1]:pareja azul, LEDG[2]: pareja roja)
// 6. LEDG[7:3]: Muestra el estado en el que se encuentra la máquina (LEDG[3]:estado 0, LEDG[4]:estado 1, LEDG[5]:estado 2, LEDG[6]:estado 3, LEDG[7]:estado 4)
// 7. LEDR[5:0]: Muestra las cartas destapadas
// 8. LEDR[11:6]: Muestra la primera carta destapadas
// 9. LEDR[17:12]: Muestra la segunda carta destapada
// --------------------------------------------------------------------
// Version: V1.0 | Fecha Modificacion: 11/0/2014
//
// Autor: Dario Alandes Codina
// Ordenador de trabajo: DISE13 
// Compartido con: Joan Bono Aguilar
// --------------------------------------------------------------------

module juegocartas(LEDR,LEDG,GRESTin,CLOCK_50,R,G,B, HD,VD,GREST,DEN,NCLK,iRST_n,oADC_DIN,oADC_DCLK,oADC_CS,iADC_DOUT,iADC_BUSY,iADC_PENIRQ_n,HEX7, HEX6, HEX5, HEX2, HEX1, HEX0, HEX3, HEX4);
`timescale 10000000000000000 ns / 100 ps
parameter fch=1056, bph=216, fph=1016, fcv=526, bpv=35, fpv=515;
`include "MathFun.vh"
parameter ch=CLogB2(fch-1), cv=CLogB2(fcv-1), chb=CLogB2(fph-bph-1), cvb=CLogB2(fpv-bpv-1);


input CLOCK_50, GRESTin;
input     iRST_n;
input     iADC_DOUT;
input     iADC_PENIRQ_n;
input     iADC_BUSY;

output HD,VD, GREST,DEN;
output NCLK;

output     oADC_DIN;
output     oADC_DCLK;
output    oADC_CS;
output [6:0] HEX7, HEX6, HEX5, HEX2, HEX1, HEX0,HEX3 = 7'b1111111, HEX4 = 7'b1111111;
output [17:0] LEDR;
output reg[7:0] R=8'b11111111,G=8'b11111111,B=8'b11111111;
output reg [7:0] LEDG;


wire mux_out;
wire [chb-1:0]columna;
wire [cvb-1:0]fila;
wire [7:0] salrom;
wire [8:0] entrada;
wire [11:0] oX_COORD;
wire [11:0] oY_COORD;
wire TC2, TCvictoria;

parameter [5:0] dir=6'b000001;
parameter S0 = 0, S1 = 1, S2=2, S3=3, S4=4;
parameter[5:0] pareja0=6'b100001, pareja1=6'b011000, pareja2=6'b000110;


reg [4:0]state=S0; 
reg [3:0] cuenta=4'b0000;
reg espera=1'b0, victoria=1'b0, venga=1'b0, pasando=1'b0, principio=1'b1;
reg [5:0] tocado=6'b000000, tocadoaux=6'b000000, tocadoaux2=6'b000000;
reg [5:0] destapado=6'b000000, borrar=6'b000000;
reg [5:0] destapadoaux=6'b000000;
reg [2:0] pareja=3'b000;

pll_ltm pll_ltm_inst (.inclk0 (CLOCK_50),.c0 (NCLK));

LCD_SYNC#(.fch(fch), .bph(bph), .fph(fph), .fcv(fcv), .bpv(bpv), .fpv(fpv))
   (.GRESTin(GRESTin),.NCLK(NCLK),.fila(fila),.columna(columna), .HD(HD), .VD(VD), .GREST(GREST),.DEN(DEN));

ADC_CONTROL (.iCLK(CLOCK_50),.iRST_n(iRST_n),.oADC_DIN(oADC_DIN),.oADC_DCLK(oADC_DCLK),.oADC_CS(oADC_CS),.iADC_DOUT(iADC_DOUT),.iADC_BUSY(iADC_BUSY),.iADC_PENIRQ_n(iADC_PENIRQ_n),
    .oTOUCH_IRQ(oTOUCH_IRQ),.oX_COORD(oX_COORD),.oY_COORD(oY_COORD), .NCLK(NCLK));

traductor(.entrada(oX_COORD[11:8]), .sal(HEX2), .reloj(NCLK));
traductor(.entrada(oX_COORD[7:4]), .sal(HEX1), .reloj(NCLK));
traductor(.entrada(oX_COORD[3:0]), .sal(HEX0), .reloj(NCLK));
traductor(.entrada(oY_COORD[11:8]), .sal(HEX7), .reloj(NCLK));
traductor(.entrada(oY_COORD[7:4]), .sal(HEX6), .reloj(NCLK));
traductor(.entrada(oY_COORD[3:0]), .sal(HEX5), .reloj(NCLK));

//Determina que carta se toca, cuando no se está tocando ninguna (oADC_CS=0) se pone a 0
//	oX_COORD   12'h000  -->     12'hFFF
// 				   --------------
// oY_COORD	 	  |      |      |
// 12'h000       |      |      |
//  	  |        |-------------|
//  	  |        |      |      |
//  	  V        |      |      |
//  	           |-------------|
//  	           |      |      |
// 12'hFFF       |      |      |
//  	           --------------
always@(posedge NCLK)
begin
 if(principio==1'b1) tocado <= 6'b000000;
 if (oX_COORD<=12'h250 && oX_COORD>12'h110 && oY_COORD<=12'h5a0 && oY_COORD>12'h400) tocado[1]<=1'b1;
 else if (oX_COORD<=12'h250 && oX_COORD>12'h110 && oY_COORD<=12'h810 && oY_COORD>12'h750) tocado[3]<=1'b1;
 else if (oX_COORD<=12'h250 && oX_COORD>12'h110 && oY_COORD<=12'hbb0 && oY_COORD>12'h960) tocado[5]<=1'b1;
 if (oX_COORD<=12'h630 && oX_COORD>12'h350 && oY_COORD<=12'h5a0 && oY_COORD>12'h400) tocado[0]<=1'b1;
 else if (oX_COORD<=12'h630 && oX_COORD>12'h350 && oY_COORD<=12'h810 && oY_COORD>12'h750) tocado[2]<=1'b1;
 else if (oX_COORD<=12'h630 && oX_COORD>12'h350 && oY_COORD<=12'hbb0 && oY_COORD>12'h960) tocado[4]<=1'b1;
 
 if(oX_COORD==12'h000 && oY_COORD==12'h000) tocado <= 6'b000000;
 if(!GRESTin || !oADC_CS) tocado <= 6'b000000;
end


contador8bitsparam  #(.fin_cuenta(25000000))seg ( .clock (NCLK), .reset (1'b1), .enable (espera), .load (1'b1), .modo (1'b1), .TC (TC2));

contador8bitsparam  #(.fin_cuenta(25000000))contvict ( .clock (NCLK), .reset (1'b1), .enable (1'b1), .load (1'b1), .modo (1'b1), .TC (TCvictoria));

always @ (posedge NCLK) 
begin
  if (!GRESTin)
  begin
	state <= S0;
	pareja<=0;
	tocadoaux<=6'b000000;
	destapadoaux<=6'b000000;
	victoria<=0;
  end
  else
   case (state) //synopsis full_case
    S0:
     begin
			if(principio==1'b1) 
			begin 
				principio<=1'b0; 
				state <= S0;
				pareja<=0;
				tocadoaux<=6'b000000;
				destapadoaux<=6'b000000;
				victoria<=0;
			end
			else
			begin
				if ( ^(tocado)==1'b1 && (tocado&destapado)==0) 
				begin 
					tocadoaux<=tocado; 
					pasando=1'b1; 
				end
				if(pasando)
				begin
					venga<=1'b0;
					espera<=1'b1;
				if(TC2) 
				begin 
					espera<=1'b0; 
					venga<=1'b1; 
				end
				if(venga)
				begin
					pasando=1'b0;
					state <= S1;
				end
			end
			else
				state <= S0;
		end
     end
    S1:
     begin
			if(tocado>0 && tocado!=tocadoaux && (tocado&destapado)==0 )begin tocadoaux2<=tocado; pasando=1'b1; end
			if(pasando)
			begin
				destapadoaux=(tocado|tocadoaux);
				if(destapadoaux===pareja0)
				begin
					pasando<=1'b0;
					pareja[0]<=1'b1;
					state <= S2;
				end
				else if(destapadoaux===pareja1)
				begin
					pasando<=1'b0;
					pareja[1]<=1'b1;
					state <= S2;
				end
				else if(destapadoaux===pareja2)
				begin
					pasando<=1'b0;
					pareja[2]<=1'b1;
					state <= S2;
				end
				else
				begin
					pasando<=1'b0;
					state <= S3;
				end
			end
     end
    S2:
     begin
			if(pareja==3'b111)
				state <= S4;
			else
			begin
				venga<=1'b0;
				espera<=1'b1;
				if(TC2) begin espera<=1'b0; venga<=1'b1; end
				if(venga)
				begin
					tocadoaux<=0;
					tocadoaux2<=0;
					state <= S0;
				end
			end
     end
    S3:
     begin
			venga<=1'b0;
			espera<=1'b1;
			if(TC2) begin espera<=1'b0; venga<=1'b1; end
			if(venga)
			begin
				tocadoaux<=0;
				tocadoaux2<=0;
				state <= S0;
			end
     end
    S4: victoria <= 1'b1;
   endcase
 end
 
 
 
 always @ (posedge NCLK)//(state or tocado or GRESTin)
 begin
   if (!GRESTin)
   begin
   destapado[5:0]<=borrar[5:0];
   end
   else
   begin
   case (state)
    S0:
     begin
	  if(principio==1'b1)
	  begin
	  destapado[5:0]<=borrar[5:0];
	  end
	  else
	  begin
			if(pareja==3'b000)
			 destapado[5:0]<=(tocadoaux);
			if(pareja==3'b001) destapado[5:0]<=(tocadoaux|pareja0);
			else if(pareja==3'b010) destapado[5:0]<=(tocadoaux|pareja1);
			else if(pareja==3'b011) destapado[5:0]<=(tocadoaux|pareja0|pareja1);
			else if(pareja==3'b100) destapado[5:0]<=(tocadoaux|pareja2);
			else if(pareja==3'b101) destapado[5:0]<=(tocadoaux|pareja0|pareja2);
			else if(pareja==3'b110) destapado[5:0]<=(tocadoaux|pareja1|pareja2);
			else if(pareja==3'b111) destapado[5:0]<=(tocadoaux|pareja1|pareja2|pareja0);
	  end
	  end
    S1:
     begin
      if(pareja==3'b000)
       destapado[5:0]<=(tocadoaux|destapado[5:0]);
      if(pareja==3'b001) destapado[5:0]=(tocadoaux|pareja0);
      else if(pareja==3'b010) destapado[5:0]<=(tocadoaux|pareja1);
      else if(pareja==3'b011) destapado[5:0]<=(tocadoaux|pareja0|pareja1);
      else if(pareja==3'b100) destapado[5:0]<=(tocadoaux|pareja2);
      else if(pareja==3'b101) destapado[5:0]<=(tocadoaux|pareja0|pareja2);
      else if(pareja==3'b110) destapado[5:0]<=(tocadoaux|pareja1|pareja2);
      else if(pareja==3'b111) destapado[5:0]<=(tocadoaux|pareja1|pareja2|pareja0);
     end
    S2:
     begin
      if(pareja==3'b000)
       destapado[5:0]<=(destapado[5:0]);
      if(pareja==3'b001) destapado[5:0]=(pareja0);
      else if(pareja==3'b010) destapado[5:0]<=(pareja1);
      else if(pareja==3'b011) destapado[5:0]<=(pareja0|pareja1);
      else if(pareja==3'b100) destapado[5:0]<=(pareja2);
      else if(pareja==3'b101) destapado[5:0]<=(pareja0|pareja2);
      else if(pareja==3'b110) destapado[5:0]<=(pareja1|pareja2);
      else if(pareja==3'b111) destapado[5:0]<=(pareja1|pareja2|pareja0);
     end
    S3:
     begin
		if(pareja==3'b000)
			destapado[5:0]<=(tocadoaux|tocadoaux2|destapado[5:0]);
		if(pareja==3'b001) destapado[5:0]=(tocadoaux|tocadoaux2|pareja0);
		else if(pareja==3'b010) destapado[5:0]<=(tocadoaux|tocadoaux2|pareja1);
		else if(pareja==3'b011) destapado[5:0]<=(tocadoaux|tocadoaux2|pareja0|pareja1);
		else if(pareja==3'b100) destapado[5:0]<=(tocadoaux|tocadoaux2|pareja2);
		else if(pareja==3'b101) destapado[5:0]<=(tocadoaux|tocadoaux2|pareja0|pareja2);
		else if(pareja==3'b110) destapado[5:0]<=(tocadoaux|tocadoaux2|pareja1|pareja2);
		else if(pareja==3'b111) destapado[5:0]<=(tocadoaux|tocadoaux2|pareja1|pareja2|pareja0);
		end
   endcase
   end
 end
always @(posedge NCLK)
begin
if (TCvictoria)
	cuenta=cuenta+1;
if (cuenta ==15) cuenta=0;
end
always@(posedge NCLK)

begin
 if(victoria==0)
 begin
 if(columna>=10'd0 && columna<=10'd250)
 begin
  if(fila<=9'd230)
  begin
	if(destapado[0]) begin R<=8'h00; G<=8'hFF; B<=8'h00; end
	else begin R<=8'hFF; G<=8'h9F; B<=8'h9F; end
  
  end
  else if(fila>=9'd250)
  begin
  
	
		if(destapado[1]) begin R<=8'hFF; G<=8'h00; B<=8'h00; end
		else begin R<=8'hFF; G<=8'h9F; B<=8'h9F; end
 end
 end
 else if(columna>=10'd270 && columna<=10'd520)
 begin 
  if(fila<=9'd230)
  begin
  
  
	if(destapado[2]) begin R<=8'hFF; G<=8'h00; B<=8'h00; end
	else begin R<=8'hFF; G<=8'h9F; B<=8'h9F; end
 
	
  end
  else if(fila>=9'd250)
  begin
 
	if(destapado[3]) begin R<=8'h00; G<=8'h00; B<=8'hFF; end
	else begin R<=8'hFF; G<=8'h9F; B<=8'h9F; end
  
	
  end
 end
 else if(columna>=10'd540 && columna<=10'd799)
 begin
  if(fila<=9'd230)
  begin
  
  
	if(destapado[4]) begin R<=8'h00; G<=8'h00; B<=8'hFF; end
	else begin R<=8'hFF; G<=8'h9F; B<=8'h9F; end
  
	
 end
  else if(fila>=9'd250)
  begin
	if(destapado[5]) begin R<=8'h00; G<=8'hFF; B<=8'h00; end
	else begin R<=8'hFF; G<=8'h9F; B<=8'h9F; end
	
  end
 end
 else
 begin
  R<=8'd00000000; G<=8'b00000000; B<=8'b00000000;
 end
 end
 else if (victoria==1)
 case (cuenta)
	1: begin R=8'd11111111; G=8'b00000000; B=8'b11111111; end
   2: begin R=8'd11111111; G=8'b11111111; B=8'b00000000; end 
	3: begin R=8'd00000000; G=8'b00000000; B=8'b11111111; end
	4: begin R=8'd11111111; G=8'b00000000; B=8'b11111111; end
   5: begin R=8'd11111111; G=8'b11111111; B=8'b00000000; end 
	6: begin R=8'd00000000; G=8'b00000000; B=8'b11111111; end
	7: begin R=8'd11111111; G=8'b00000000; B=8'b11111111; end
   8: begin R=8'd11111111; G=8'b11111111; B=8'b00000000; end 
	9: begin R=8'd00000000; G=8'b00000000; B=8'b11111111; end
	10: begin R=8'd11111111; G=8'b00000000; B=8'b11111111; end
   11: begin R=8'd11111111; G=8'b11111111; B=8'b00000000; end 
	12: begin R=8'd00000000; G=8'b00000000; B=8'b11111111; end
	13: begin R=8'd11111111; G=8'b00000000; B=8'b11111111; end
   14: begin R=8'd11111111; G=8'b11111111; B=8'b00000000; end 
	15: begin R=8'd00000000; G=8'b00000000; B=8'b11111111; end
endcase
end




always @(state)
begin
	if(state==0)LEDG[7:3]=5'b00001;
	if(state==1)LEDG[7:3]=5'b00010;
	if(state==2)LEDG[7:3]=5'b00100;
	if(state==3)LEDG[7:3]=5'b01000;
	if(state==4)LEDG[7:3]=5'b10000;
	LEDG[2:0]<=pareja[2:0];
end
assign LEDR[5:0]=destapado[5:0];
assign LEDR[11:6]=tocadoaux[5:0];
assign LEDR[17:12]=tocadoaux2[5:0];

 
endmodule
