`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2021 07:31:55 PM
// Design Name: 
// Module Name: Control_Center_V2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ControlCenter_HWACF_V2 #(parameter CLK_FREQ = 256,parameter DATA_SIZE=8,parameter USE_LED=1,parameter ACQ_LED=1,parameter MAXCNTSIZE=28)(
    input clk,
    input [DATA_SIZE-1:0] cpuData,
    input newDataReceived,
    input rst,
    input cntFinished,
    output reg read_fifo,
    output trigReset,
    output enableAcq,
    output initTx,
    output LED,
    output [MAXCNTSIZE-1:0] maxCnt,
    output acquiringLED
    );

    reg [7:0] code;
    reg nDR_d, nDR_q;
    reg trigReset_d, trigReset_q;
    reg enableAcq_d,enableAcq_q;
    reg LED_d, LED_q;
    reg initTx_d,initTx_q;
    reg cntFinished_d,cntFinished_q;
    reg [MAXCNTSIZE-1:0] maxCnt_d,maxCnt_q;
    assign trigReset = trigReset_q;
    assign enableAcq = (enableAcq_q && (!cntFinished_q));
    assign acquiringLED = cntFinished_q;
    assign LED = LED_q;
    assign initTx = initTx_q;
    assign maxCnt = maxCnt_q;
    
    always @(posedge clk)begin
        if (rst) begin
            nDR_d <=0;
            nDR_q <=0;
        end else begin
            code <= cpuData;
            nDR_d <= newDataReceived;
        end
            nDR_q <= nDR_d;  
     end
     
     
     always @(posedge clk)begin
        if (rst) begin
            cntFinished_q<=0;
            trigReset_d<=0;
            trigReset_q<=0;
            enableAcq_q<=0;
            enableAcq_d<=0;
            initTx_d<=0;
            initTx_q<=0;
            maxCnt_d <= 0;
            LED_q <=0;
            LED_d <=0;
            read_fifo <= 1'b0;
        end else begin            
            cntFinished_d <= cntFinished;
            if (nDR_q==1) begin
                case(code)
                1: //reset counters, clear FIFO, all data initalized
                begin
                    trigReset_d <= 1;
                    enableAcq_d <= 0;
                    enableAcq_q <= 0;
                    LED_d <=0;
                    LED_q <= 0;
                    initTx_d <=0;
                    initTx_q <=0;
                 end
                10: // start acquisition
                    begin
                        enableAcq_d <= 1;
                end
                20: // LED on
                begin   
                    LED_d = 1;
                    end
                30: // LED off
                    begin
                        LED_d = 0;
                    end 
                50: //Send last data burst
                    begin
                        initTx_d <=1;
                    end
                60: //0.25 s acquisition
                    begin
                        maxCnt_d <= 250000*CLK_FREQ;
                    end
                65: //0.5 s acquisition
                    begin 
                        maxCnt_d <=500000*CLK_FREQ;
                    end
                        
                70: //1 s acquisition
                    begin
                        maxCnt_d <= 1000000*CLK_FREQ;
                    end
                75://3 s acquisition
                    begin
                        maxCnt_d <=3000000*CLK_FREQ;
                    end
                80://10 s acquisition
                    begin  
                        maxCnt_d<=10000000*CLK_FREQ;
                    end
                85://30 s acqusition
                    begin
                        maxCnt_d<=30000000*CLK_FREQ;
                    end
                90://100 s acquisition
                    begin
                        maxCnt_d<=100000000*CLK_FREQ;
                    end
                95: //300 s acquisition
                begin
                    maxCnt_d<=300000*CLK_FREQ;
                end
                100://1000 s acquisition
                    begin
                        maxCnt_d<=1000000*CLK_FREQ;
                    end
                105: //Indefinite acqusition
                    begin
                        maxCnt_d<=0; //condition for indefinite acquisition
                    end
                
                110: //stop indefinite acqusitiion
                    begin
                        enableAcq_d<=0; //end infinite loop acquisition
                     end
               
                115: // start reading FIFO
                    begin
                        read_fifo <= 1'b1;     
                    end         
                       
                120: // stop reading FIFO
                    begin
                        read_fifo <= 1'b0;
                    end
                             
                default: 
                    begin
                        trigReset_d <= 0;
                        enableAcq_d <= 0;
                        initTx_d <=0;
                        read_fifo <= 1'b0;
                        LED_d <= 1'b0; 
                    end
                    
                endcase               
           end else begin   //End New Data Received, cond for no new data
           initTx_d <= 0; //Don't request last data 
        end //End no new data received condition
      //update flipflops
       trigReset_q <= trigReset_d;
       enableAcq_q <= enableAcq_d; 
       maxCnt_q <= maxCnt_d;
       LED_q <= LED_d;
       initTx_q <= initTx_d;
       cntFinished_q <= cntFinished_d;
       end //End rst condition

   end //End always block
endmodule
