`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module busqueda(clk,rst,s0,s1,s2,aux,emp,retro);
output s0,s1,s2;
output [2:0]aux;
input emp,rst,clk,retro;
reg [2:0] q;
always @(posedge clk) begin
//always @(negedge clk) begin
    if (rst)
        q = 0;
    else begin 
        q[2] = q[1];
        q[1] = q[0];
        q[0]= emp||retro;
    end    
end
assign s0 = q[0];
assign s1 = q[1];
assign s2 = q[2];
assign aux = q;
endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////7
module dec(dec_out,dec_int);
input wire [3:0] dec_int;
output reg [15:0] dec_out;
always @(dec_int) begin
case (~dec_int)
//case (dec_int)
4'h0: dec_out = 16'b0000_0000_0000_0001;
4'h1: dec_out = 16'b0000_0000_0000_0010;
4'h2: dec_out = 16'b0000_0000_0000_0100;
4'h3: dec_out = 16'b0000_0000_0000_1000;
4'h4: dec_out = 16'b0000_0000_0001_0000;
4'h5: dec_out = 16'b0000_0000_0010_0000;
4'h6: dec_out = 16'b0000_0000_0100_0000;
4'h7: dec_out = 16'b0000_0000_1000_0000;
4'h8: dec_out = 16'b0000_0001_0000_0000;
4'h9: dec_out = 16'b0000_0010_0000_0000;
4'ha: dec_out = 16'b0000_0100_0000_0000;
4'hb: dec_out = 16'b0000_1000_0000_0000;
4'hc: dec_out = 16'b0001_0000_0000_0000;
4'hd: dec_out = 16'b0010_0000_0000_0000;
4'he: dec_out = 16'b0100_0000_0000_0000;
4'hf: dec_out = 16'b1000_0000_0000_0000;
endcase
end
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module instruc(clk,rst,x,dec,inst,out);
output inst,out;
input clk,rst,x,dec;
reg q;
always @(posedge clk) begin
    if (rst)
        q= 0;
    else begin 
        q=x&dec;
    end    
end
assign out =q ;
assign inst = q;
endmodule
///////////////////////////////////////////////////////////////////////////////////////////

module SFZ(clk,rst,x,x2,dec,inst,out,sal);
output inst,out,sal;
input clk,rst,x,dec,x2;
reg q;
reg q2;
always @(posedge clk) begin
    if (rst)
        q= 0;
    else begin 
        q=x&dec;
        q2=x2&dec;
    end    
end
assign out =q ;
assign inst = q;
assign sal = q2;
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module ADI(clk,rst,x,dec,s0,s1,s2,s3,s4,aux);
output s0,s1,s2,s3,s4;
output [4:0]aux;
input clk,rst,x,dec;
reg [4:0]q;
always @(posedge clk) begin
    if (rst)
        q= 0;
    else begin
        q[4]=q[3];
        q[3]=q[2];
        q[2]=q[1];
        q[1]=q[0]; 
        q[0]=x&dec;
    end    
end
assign s0 = q[0];
assign s1 = q[1];
assign s2 = q[2];
assign s3 = q[3];
assign s4 = q[4];
assign aux = q;
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////7
module STA(clk,rst,x,dec,s0,s1,s2,aux);
output s0,s1,s2;
output [2:0]aux;
input clk,rst,x,dec;
reg [2:0]q;
always @(posedge clk) begin
    if (rst)
        q= 0;
    else begin
        q[2]=q[1];
        q[1]=q[0]; 
        q[0]=x&dec;
    end    
end
assign s0 = q[0];
assign s1 = q[1];
assign s2 = q[2];
assign aux = q;
endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
module CALL(clk,rst,x,dec,s0,s1,s2,s3,aux);
output s0,s1,s2,s3;
output [4:0]aux;
input clk,rst,x,dec;
reg [3:0]q;
always @(posedge clk) begin
    if (rst)
        q= 0;
    else begin
        q[3]=q[2];
        q[2]=q[1];
        q[1]=q[0]; 
        q[0]=x&dec;
    end    
end
assign s0 = q[0];
assign s1 = q[1];
assign s2 = q[2];
assign s3 = q[3];
assign aux = q;
endmodule
///////////////////////////////////////////////////////////////////////////////////////////////////////
module control(
//señales comunes
input emp,rst,clk,
//señales PC
output c_IPC,c_TGPRaPC,
//señales MAR
output c_TPCaMAR,c_TGPRaMAR,
////OPR
output c_TGPRaOPR,
input [3:0]c_OPR,
///GPR
output c_TMaGPR,c_TACCaGPR,c_TPCaGPR,c_IGPR,
////RAM
output c_w,c_r,
////ALU
output c_TGPRACC,c_LACC,c_LF,c_CF,c_CACC,c_IACC,c_ROR,c_ROL,
input c_F,c_Z,
//extras
output [2:0]aux,
output [15:0]ter_inst,
output stop,
output RET,
output [15:0]odec,
output TMARaPC
);
    wire q;
    wire [0:15]sdec;
    wire [0:15]sal;
    wire [0:14]itc;
    wire [0:2]s;
    wire q0;
    wire aux_stop,inst_stop;
    wire itc5;
    reg retro;
    
    wire [4:0]ADIs;
    wire [2:0]STAs;
    wire [4:0]CALLs;
    wire [4:0]ISZs;   
    wire [2:0]adda;
    wire [2:0]JMPI;
     
    //busqueda dut(.clk(clk),.rst(rst),.s0(s[0]),.s1(s[1]),.s2(s[2]),.aux(aux),.emp(emp),.retro(itc[0]|itc[1]|itc[2]|itc[3]|itc[4]|(itc[5]|itc5)|itc[6]|itc[7]|itc[8]|itc[9]|itc[10]|ADIs[4]|STAs[2]|CALLs[3]|ISZs[4]));
    busqueda dut(.clk(clk),.rst(rst),.s0(s[0]),.s1(s[1]),.s2(s[2]),.aux(aux),.emp(emp),.retro(itc[0]|itc[1]|itc[2]|itc[3]|itc[4]|(itc[5]|itc5)|itc[6]|itc[7]|adda[2]|itc[9]|JMPI[2]|ADIs[4]|STAs[2]|CALLs[4]|ISZs[4]));
    
    dec dut3(.dec_out(sdec),.dec_int(c_OPR));
    
    instruc instruccion0(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[0]),.inst(inst_stop),.out(aux_stop));
    
    instruc instruccion1(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[1]),.inst(itc[0]),.out(sal[0])); //Limp ACC
    instruc instruccion2(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[2]),.inst(itc[1]),.out(sal[1])); //Comp ACC
    instruc instruccion3(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[3]),.inst(itc[2]),.out(sal[2])); //Incr ACC
    instruc instruccion4(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[4]),.inst(itc[3]),.out(sal[3])); //Limp F
    instruc instruccion5(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[5]),.inst(itc[4]),.out(sal[4])); //Comp F
    //instruc intruccion6(.clk(clk),.rst(rst),.x(s[2]&sdec[4]),.dec(~c_F),.inst(itc[5]),.out(sal[5])); //Salta a la instruccion si F es 0
    
    //instruc intruccion6(.clk(clk),.rst(rst),.x(s[2]&(~c_F)),.dec(sdec[6]),.inst(itc[5]),.out(sal[5])); //Salta a la instruccion si F es 0
    SFZ instruccion6(.clk(clk),.rst(rst),.x(s[2]&(~c_F)),.x2(s[2]),.dec(sdec[6]),.inst(itc[5]),.out(sal[5]),.sal(itc5));
    
    instruc instruccion7(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[7]),.inst(itc[6]),.out(sal[6])); // Desplaza cicli a la derecha
    instruc instruccion8(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[8]),.inst(itc[7]),.out(sal[7])); // Desplaza cicli a la izquierda
    
    //instruc instruccion9(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[9]),.inst(itc[8]),.out(sal[8])); // ADD
    STA instruccion9(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[9]),.s0(adda[0]),.s1(adda[1]),.s2(adda[2]),.aux());    //STA

    ADI instruccion10(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[10]),.s0(ADIs[0]),.s1(ADIs[1]),.s2(ADIs[2]),.s3(ADIs[3]),.s4(ADIs[4]),.aux()); //ADI
    
    STA instruccion11(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[11]),.s0(STAs[0]),.s1(STAs[1]),.s2(STAs[2]),.aux());    //STA
    
    instruc instruccion12(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[12]),.inst(itc[9]),.out(sal[9])); //JMP
    
    //CALL instruccion13(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[13]),.s0(CALLs[0]),.s1(CALLs[1]),.s2(CALLs[2]),.s3(CALLs[3]),.aux());
    ADI instruccion13(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[13]),.s0(CALLs[0]),.s1(CALLs[1]),.s2(CALLs[2]),.s3(CALLs[3]),.s4(CALLs[4]),.aux());
    
    //instruc instruccion14(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[14]),.inst(itc[10]),.out(sal[10]));//RET :C
    STA instruccion14(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[14]),.s0(JMPI[0]),.s1(JMPI[1]),.s2(JMPI[2]),.aux()); //JMPI[]
    
    ADI instruccion15(.clk(clk),.rst(rst),.x(s[2]),.dec(sdec[15]),.s0(ISZs[0]),.s1(ISZs[1]),.s2(ISZs[2]),.s3(ISZs[3]),.s4(ISZs[4]),.aux()); //ISZ
///Salidas
assign ter_inst=sal;
assign stop=aux_stop; //instruccion 0
//señales PC
assign c_IPC=s[1]|(itc[5])|(ISZs[3]&c_Z)|CALLs[4];
assign c_TGPRaPC=itc[9]|JMPI[2];
//señales MAR
assign c_TPCaMAR=s[0];
//assign c_TGPRaMAR=ADIs[0]|ADIs[2]|STAs[0]|ISZs[0]|CALLs[0];
assign c_TGPRaMAR=ADIs[0]|ADIs[2]|STAs[0]|ISZs[0]|CALLs[0]|adda[0]|JMPI[0];
////OPR
assign c_TGPRaOPR=s[2];
///GPR
//assign c_TMaGPR=s[1]|ADIs[1]|ADIs[3]|ISZs[1];
assign c_TMaGPR=s[1]|ADIs[1]|ADIs[3]|ISZs[1]|adda[1]|JMPI[1];
assign c_TACCaGPR=STAs[1];
assign c_TPCaGPR=|CALLs[1];
assign c_IGPR=ISZs[2];
////RAM
assign c_w=STAs[2]|ISZs[3]|CALLs[3];
assign c_r=s[1]|ADIs[1]|ADIs[3]|ISZs[1]|adda[1]|JMPI[1];
////ALU
//assign c_TGPRACC=itc[8]|ADIs[4];
assign c_TGPRACC=adda[2]|ADIs[4];
assign c_LACC=itc[0];
assign c_LF=itc[3];
assign c_CF=itc[4];
assign c_CACC=itc[1];
assign c_IACC=itc[2];
assign c_ROR=itc[6];
assign c_ROL=itc[7];    
assign odec=sdec;
assign RET=itc[10];
assign TMARaPC=CALLs[2]; 
endmodule