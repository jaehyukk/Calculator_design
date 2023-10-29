    module test(clock_50m, pb, fnd_s, fnd_d, temp_result);
    
    // input output
    input clock_50m;
    input [15:0] pb;
    output reg [5:0] fnd_s;
    output reg [7:0] fnd_d;
    
    // clock
    reg [15:0] npb;
    reg [31:0] init_counter;
    reg sw_clk;
    reg fnd_clk;
    reg [2:0] fnd_cnt;
    
    // 7-segment
    reg [4:0] set_no1;
    reg [4:0] set_no2;
    reg [4:0] set_no3;
    reg [4:0] set_no4;
    reg [4:0] set_no5;
    reg [4:0] set_no6;
    reg [6:0] seg_100000;
    reg [6:0] seg_10000;
    reg [6:0] seg_1000;
    reg [6:0] seg_100;
    reg [6:0] seg_10;
    reg [6:0] seg_1;
    
    // switch(keypad) control
    reg [15:0] pb_1st;
    reg [15:0] pb_2nd;
    reg sw_toggle;
    
    // sw_status
    reg [2:0] sw_status;
    parameter sw_idle = 0;
    parameter sw_start = 1;
    parameter sw_s1 = 2;
    parameter sw_s2 = 3;
    parameter sw_s3 = 4;
    parameter sw_s4 = 5;
    parameter sw_s5 = 6;
    parameter sw_s6 = 7;
    
    // calculation
    output reg [31:0] temp_result;
    reg [31:0] temp_operand;
    reg [2:0] input_operator;
    reg [1:0] sign_minus;
    reg [1:0] check_print;
    reg [1:0] remainder;
    reg [1:0] square;
    reg [1:0] input_minus;
    reg [1:0] pb_minus;
    reg [1:0] check_err;
    reg [1:0] of;
    
    // initial
    initial begin
        sw_status <= sw_idle;
        sw_toggle <= 0;
        npb <= 'h0000;
        pb_1st <= 'h0000;
        pb_2nd <= 'h0000;
        set_no1 <= 18;
        set_no2 <= 18;
        set_no3 <= 18;
        set_no4 <= 18;
        set_no5 <= 18;
        set_no6 <= 18;      
        input_operator <= 0;
        sign_minus <= 0;
        check_print <= 0;
        square <= 0;
        remainder <= 0;
        input_minus <= 0;
        pb_minus <= 0;
        check_err <= 0;
        of <= 0;
    end
    
    // clock divider
    always begin
        npb <= ~pb;                                       
        sw_clk <= init_counter[20];                           
        fnd_clk <= init_counter[16];                        
    end
    
    // clock_50m. clock counter
    always @(posedge clock_50m) begin
        init_counter <= init_counter + 1;
    end
    
    always @(posedge sw_clk) begin
        pb_2nd <= pb_1st;
        pb_1st <= npb;
        
        if (pb_2nd == 'h0000 && pb_1st != pb_2nd) begin // button pressed
            sw_toggle <= 1;
        end

        if(of==0 && check_print==1) begin
          if (temp_result >=0 && temp_result < 10) begin
            if (sign_minus==0) begin
                set_no1 <= 20;
                set_no2 <= 20; 
                set_no3 <= 20; 
                set_no4 <= 20; 
                set_no5 <= 20; 
                set_no6 <= temp_result; 
            end
            else begin
                set_no1 <= 20; 
                set_no2 <= 20; 
                set_no3 <= 20; 
                set_no4 <= 20; 
                set_no5 <= 21; // signed
                set_no6 <= temp_result; 
            end
            end

            if (temp_result >=10 && temp_result < 100) begin
            if(sign_minus==0) begin
                set_no1 <= 20;
                set_no2 <= 20;
                set_no3 <= 20;
                set_no4 <= 20; 
                set_no5 <= temp_result/10;
                set_no6 <= temp_result%10; 
            end
            else begin
                set_no1 <= 20;
                set_no2 <= 20; 
                set_no3 <= 20; 
                set_no4 <= 21; // signed
                set_no5 <= temp_result/10;
                set_no6 <= temp_result%10;
            end
            end
        
            if (temp_result >=100 && temp_result < 1000) begin
            if(sign_minus==0) begin
                set_no1 <= 20; 
                set_no2 <= 20; 
                set_no3 <= 20;
                set_no4 <= temp_result/100;
                set_no5 <= (temp_result%100)/10; 
                set_no6 <= (temp_result%10); 
            end
            else begin
                set_no1 <= 20;
                set_no2 <= 20; 
                set_no3 <= 21; // signed
                set_no4 <= temp_result/100; 
                set_no5 <= (temp_result%100)/10; 
                set_no6 <= (temp_result%10);
            end
            end
        
            if (temp_result >=1000 && temp_result < 10000) begin
            if (sign_minus==0) begin
                set_no1 <= 20;
                set_no2 <= 20;
                set_no3 <= temp_result/1000;
                set_no4 <= (temp_result%1000)/100;
                set_no5 <= (temp_result%100)/10;
                set_no6 <= (temp_result%10);
            end
            else begin
                set_no1 <= 20;
                set_no2 <= 21; // sign
                set_no3 <= temp_result/1000;
                set_no4 <= (temp_result%1000)/100;
                set_no5 <= (temp_result%100)/10;
                set_no6 <= (temp_result%10);
            end
            end
        
            if (temp_result >=10000 && temp_result < 100000) begin
            if(sign_minus==0) begin
                set_no1 <= 20;
                set_no2 <= temp_result/10000;
                set_no3 <= (temp_result%10000)/1000;
                set_no4 <= (temp_result%1000)/100;
                set_no5 <= (temp_result%100)/10;
                set_no6 <= (temp_result%10);
            end
            else begin
                set_no1 <= 21; // signed
                set_no2 <= temp_result/10000;
                set_no3 <= (temp_result%10000)/1000;
                set_no4 <= (temp_result%1000)/100;
                set_no5 <= (temp_result%100)/10;
                set_no6 <= (temp_result%10);
            end
            end
            
            if (temp_result >=100000 && temp_result < 1000000) begin
                set_no1 <= temp_result/100000;
                set_no2 <= (temp_result%100000)/10000;
                set_no3 <= (temp_result%10000)/1000;
                set_no4 <= (temp_result%1000)/100;
                set_no5 <= (temp_result%100)/10; 
                set_no6 <= (temp_result%10); 
            end
            if (temp_result >=1000000) begin
                set_no1 <= 20; // 
                set_no2 <= 20; // 
                set_no3 <= 16; //E
                set_no4 <= 17; //r
                set_no5 <= 17; //r 
                set_no6 <= 20; // 
                of <= 1;
            end                           
            check_print <= 0;
            sw_status <= sw_start;
        end
        
        if (sw_toggle == 1 && pb_1st == pb_2nd) begin //unpressed
            sw_toggle <= 0;

            if(input_minus==0)begin            
                case (pb_1st)
        
                    'h0100: begin
                        pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            sw_status <= sw_s1;
                            set_no6 <=1;
                            temp_operand <= 1;
                         
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= set_no6;
                            set_no6 <= 1;
                            temp_operand <= set_no6*10+1;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 1;
                            temp_operand <= set_no5*100+set_no6*10+1;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 1;
                            temp_operand <= set_no4*1000+
                            set_no5*100+set_no6*10+1;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 1;
                            temp_operand <= set_no3*10000+set_no4*1000+
                            set_no5*100+set_no6*10+1;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= set_no2;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 1;
                            temp_operand <= set_no2*100000+set_no3*10000+
                            set_no4*1000+set_no5*100+set_no6*10+1;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0200: begin //2
                    pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            sw_status <= sw_s1;
                            set_no6 <=2;
                            temp_operand <= 2;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= set_no6;
                            set_no6 <= 2;
                            temp_operand <= set_no6*10+2;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 2;
                            temp_operand <= set_no5*100+set_no6*10+2;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 2;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+2;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 2;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+2;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= set_no2;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 2;
                            temp_operand <= set_no2*100000+set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+2;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0400: begin
                        pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            sw_status <= sw_s1;
                            set_no6 <=3;
                            temp_operand <= 3;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= set_no6;
                            set_no6 <= 3;
                            temp_operand <= set_no6*10+3;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 3;
                            temp_operand <= set_no5*100+set_no6*10+3;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 3;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+3;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 3;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+3;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= set_no2;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 3;
                            temp_operand <= set_no2*100000+set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+3;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0008: begin //+
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin  //twice + error
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;
                            sw_status <= sw_idle;
                        end
                        default : begin
                        sw_status <= sw_start;
                        input_operator <= 1;
                        set_no1 <= 20;
                        set_no2 <= 20;
                        set_no3 <= 20;
                        set_no4 <= 20;
                        set_no5 <= 20;
                        set_no6 <= 20;
                        
                            if(input_operator==0) begin
                            temp_result <= temp_operand;
                            temp_operand <=0;
                            end
                            
                            if(input_operator==1) begin
                                if(input_minus==1) begin
                                    if(sign_minus==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                            end
                                
                            if(input_operator==2) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999)begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand-temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus ==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end      
                            end
                            if(input_operator==3) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end                     
                            end
                            
                            if(input_operator==4) begin
                                if(temp_operand == 0) begin
                                    sw_status <= sw_idle;
                                    set_no1 <= 20;
                                    set_no2 <= 20;
                                    set_no3 <= 16;
                                    set_no4 <= 17;
                                    set_no5 <= 17;
                                    set_no6 <= 20;
                                    of <= 1;
                                end
                                else begin
                                    if(input_minus==0) begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=0;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                        end
                                    end
                                    else begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=1;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                        end
                                    end
                                end                 
                            end

                            if(input_operator==5) begin
                                if(sign_minus==0) begin
                                temp_result<=temp_result%temp_operand;
                                sign_minus<=0;
                                input_minus<=0;
                                end
                                else begin
                                    if(temp_result%temp_operand==0)begin
                                    temp_result<=0;
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                    else begin
                                    temp_result<=temp_operand-(temp_result%temp_operand);
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                end                       
                            end                    
                        end
                    endcase
                    end

                    'h0010: begin 
                        pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            sw_status <= sw_s1;
                            set_no6 <=4;
                            temp_operand <= 4;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= set_no6;
                            set_no6 <= 4;
                            temp_operand <= set_no6*10+4;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 4;
                            temp_operand <= set_no5*100+set_no6*10+4;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 4;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+4;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 4;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+4;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= set_no2;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 4;
                            temp_operand <= set_no2*100000+set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+4;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0020: begin
                        pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            sw_status <= sw_s1;
                            set_no6 <=5;
                            temp_operand <= 5;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= set_no6;
                            set_no6 <= 5;
                            temp_operand <= set_no6*10+5;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 5;
                            temp_operand <= set_no5*100+set_no6*10+5;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 5;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+5;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 5;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+5;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= set_no2;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 5;
                            temp_operand <= set_no2*100000+set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+5;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0040: begin
                        pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            sw_status <= sw_s1;
                            set_no6 <=6;
                            temp_operand <= 6;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= set_no6;
                            set_no6 <= 6;
                            temp_operand <= set_no6*10+6;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 6;
                            temp_operand <= set_no5*100+set_no6*10+6;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 6;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+6;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 6;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+6;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= set_no2;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 6;
                            temp_operand <= set_no2*100000+set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+6;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0080: begin //-
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            input_minus <= 1;
                            sw_status <= sw_s1;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 21;
                        end
                        
                        default : begin
                        sw_status <= sw_start;
                        input_operator <= 2;
                        pb_minus <= 1;
                        set_no1 <= 20;
                        set_no2 <= 20;
                        set_no3 <= 20;
                        set_no4 <= 20;
                        set_no5 <= 20;
                        set_no6 <= 20;
                        
                            if(input_operator==0) begin
                            temp_result <= temp_operand;
                            temp_operand <=0;
                            end
                            
                            if(input_operator==1) begin
                                if(input_minus==1) begin
                                    if(sign_minus==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                            end
                                
                            if(input_operator==2) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999)begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand-temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus ==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end      
                            end
                            if(input_operator==3) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end                     
                            end
                            
                            if(input_operator==4) begin
                                if(temp_operand==0) begin
                                    sw_status <= sw_idle;
                                    set_no1 <= 20;
                                    set_no2 <= 20;
                                    set_no3 <= 16;
                                    set_no4 <= 17;
                                    set_no5 <= 17;
                                    set_no6 <= 20;
                                    of <= 1;
                                end
                                else begin
                                    if(input_minus==0) begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=0;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                        end
                                    end
                                    else begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=1;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                        end
                                    end    
                                end             
                            end

                            if(input_operator==5) begin
                                if(sign_minus==0) begin
                                temp_result<=temp_result%temp_operand;
                                sign_minus<=0;
                                input_minus<=0;
                                end
                                else begin
                                    if(temp_result%temp_operand==0)begin
                                    temp_result<=0;
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                    else begin
                                    temp_result<=temp_operand-(temp_result%temp_operand);
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                end                       
                            end
                            
                            if(input_operator==6) begin
                            temp_result <= temp_operand*temp_operand;
                            end                    
                            
                            end
                    endcase
                    end
                    'h0001: begin 
                        pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            sw_status <= sw_s1;
                            set_no6 <=7;
                            temp_operand <= 7;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= set_no6;
                            set_no6 <= 7;
                            temp_operand <= set_no6*10+7;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 7;
                            temp_operand <= set_no5*100+set_no6*10+7;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 7;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+7;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 7;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+7;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= set_no2;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 7;
                            temp_operand <= set_no2*100000+set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+7;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0002: begin
                        pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            sw_status <= sw_s1;
                            set_no6 <=8;
                            temp_operand <= 8;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= set_no6;
                            set_no6 <= 8;
                            temp_operand <= set_no6*10+8;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 8;
                            temp_operand <= set_no5*100+set_no6*10+8;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 8;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+8;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 8;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+8;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= set_no2;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 8;
                            temp_operand <= set_no2*100000+set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+8;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0004: begin
                        pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            sw_status <= sw_s1;
                            set_no6 <=9;
                            temp_operand <= 9;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= set_no6;
                            set_no6 <= 9;
                            temp_operand <= set_no6*10+9;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 9;
                            temp_operand <= set_no5*100+set_no6*10+9;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 9;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+9;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 9;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+9;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= set_no2;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 9;
                            temp_operand <= set_no2*100000+set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+9;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0800: begin //*
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                                if(square==1) begin
                                    input_operator <=6;
                                    set_no1 <= 20;
                                    set_no2 <= 20;
                                    set_no3 <= 20;
                                    set_no4 <= 20;
                                    set_no5 <= 20;
                                    set_no6 <= 20;
                                end
                                else begin
                                    if(check_err==1)begin
                                    square <= 1;
                                    sw_status <= sw_start;
                                    set_no1 <= 20;
                                    set_no2 <= 20;
                                    set_no3 <= 20;
                                    set_no4 <= 20;
                                    set_no5 <= 20;
                                    set_no6 <= 20;  
                                    end	
                                    else begin
                                    sw_status <= sw_idle;
                                    set_no1 <= 20;
                                    set_no2 <= 20;
                                    set_no3 <= 16;
                                    set_no4 <= 17;
                                    set_no5 <= 17;
                                    set_no6 <= 20;
                                    of <= 1;  
                                    end						
                                    
                                end
                        end
                        
                        default : begin
                                square <= 1;
                                sw_status <= sw_start;
                                input_operator <= 3;
                                set_no1 <= 20;
                                set_no2 <= 20;
                                set_no3 <= 20;
                                set_no4 <= 20;
                                set_no5 <= 20;
                                set_no6 <= 20;
                                
                            if(input_operator==0) begin
                            temp_result <= temp_operand;
                            temp_operand <=0;
                            end
                            
                            if(input_operator==1) begin
                                if(input_minus==1) begin
                                    if(sign_minus==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                            end
                                
                            if(input_operator==2) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999)begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand-temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus ==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end      
                            end
                            if(input_operator==3) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end                     
                            end
                            
                            if(input_operator==4) begin
                                if(temp_operand==0) begin
                                    sw_status <= sw_idle;
                                    set_no1 <= 20;
                                    set_no2 <= 20;
                                    set_no3 <= 16;
                                    set_no4 <= 17;
                                    set_no5 <= 17;
                                    set_no6 <= 20;
                                    of <= 1;
                                end
                                else begin
                                    if(input_minus==0) begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=0;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                        end
                                    end
                                    else begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=1;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                        end
                                    end      
                                end           
                            end

                            if(input_operator==5) begin
                                if(sign_minus==0) begin
                                temp_result<=temp_result%temp_operand;
                                sign_minus<=0;
                                input_minus<=0;
                                end
                                else begin
                                    if(temp_result%temp_operand==0)begin
                                    temp_result<=0;
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                    else begin
                                    temp_result<=temp_operand-(temp_result%temp_operand);
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                end                       
                            end                    
                                                
                        end
                    endcase
                    end
                    'h1000: begin   // enter
                    case (sw_status)
                        sw_idle: begin
                            sw_status <= sw_start;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                        if(input_operator==6) begin
                            temp_result <= temp_result*temp_result;
                            sw_status <= sw_s1;
                            sign_minus <= 0;
                            check_print <= 1; 
                            end  
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        default: begin
                            check_print <= 1;
                            input_operator <= 0;
                            check_err <= 1;
                            if(input_operator==0) begin
                            temp_result <= temp_operand;
                            end
                            
                            if(input_operator==1) begin  
                                if(input_minus==1) begin
                                    if(sign_minus==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                            end
                                
                            if(input_operator==2) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999)begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand-temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus ==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end      
                            end
                            if(input_operator==3) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end                     
                            end
                            
                            if(input_operator==4) begin
                                if(temp_operand==0) begin
                                    sw_status <= sw_idle;
                                    set_no1 <= 20;
                                    set_no2 <= 20;
                                    set_no3 <= 16;
                                    set_no4 <= 17;
                                    set_no5 <= 17;
                                    set_no6 <= 20;
                                    of <= 1;
                                end
                                else begin
                                    if(input_minus==0) begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=0;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                        end
                                    end
                                    else begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=1;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                        end
                                    end 
                                end                
                            end

                            if(input_operator==5) begin
                                if(sign_minus==0) begin
                                temp_result<=temp_result%temp_operand;
                                sign_minus<=0;
                                input_minus<=0;
                                end
                                else begin
                                    if(temp_result%temp_operand==0)begin
                                    temp_result<=0;
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                    else begin
                                    temp_result<=temp_operand-(temp_result%temp_operand);
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                end                       
                            end
                        end
                    endcase
                    end
                    'h2000: begin
                        pb_minus <= 0;
                        case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            sw_status <= sw_s1;
                            set_no6 <=0;
                            temp_operand <= 0;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= set_no6;
                            set_no6 <= 0;
                            temp_operand <= set_no6*10+0;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 0;
                            temp_operand <= set_no5*100+set_no6*10+0;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 0;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+0;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 0;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+0;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= set_no2;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 0;
                            temp_operand <= set_no2*100000+set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+0;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end                              
                    'h4000: begin // clr
                    sw_status <= sw_idle;
                    set_no1 <= 20;
                    set_no2 <= 20;
                    set_no3 <= 20;
                    set_no4 <= 20;
                    set_no5 <= 20;
                    set_no6 <= 20;      
                    input_operator <= 0;
                    sign_minus <= 0;
                    check_print <= 0;
                    square <= 0;
                    remainder <= 0;
                    input_minus <= 0;
                    pb_minus <= 0;
                    check_err <= 0;
                    of <= 0;
                    end
                    
                    'h8000: begin // /
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            if(remainder==1) begin
                            input_operator <=5;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                            end
                            else begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;
                            sw_status <= sw_idle;
                            end
                        end
                        
                        default : begin
                        remainder <= 1;
                        sw_status <= sw_start;
                        input_operator <= 4;
                        set_no1 <= 20;
                        set_no2 <= 20;
                        set_no3 <= 20;
                        set_no4 <= 20;
                        set_no5 <= 20;
                        set_no6 <= 20;
                        
                            if(input_operator==0) begin
                            temp_result <= temp_operand;
                            temp_operand <=0;
                            end
                            
                            if(input_operator==1) begin 
                                if(input_minus==1) begin
                                    if(sign_minus==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                            end
                                
                            if(input_operator==2) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999)begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand-temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus ==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end      
                            end
                            if(input_operator==3) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end                     
                            end
                            
                            if(input_operator==4) begin
                                if(temp_operand==0) begin
                                    sw_status <= sw_idle;
                                    set_no1 <= 20;
                                    set_no2 <= 20;
                                    set_no3 <= 16;
                                    set_no4 <= 17;
                                    set_no5 <= 17;
                                    set_no6 <= 20;
                                end
                                else begin
                                    if(input_minus==0) begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=0;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                        end
                                    end
                                    else begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=1;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                        end
                                    end         
                                end        
                            end

                            if(input_operator==5) begin
                                if(sign_minus==0) begin
                                temp_result<=temp_result%temp_operand;
                                sign_minus<=0;
                                input_minus<=0;
                                end
                                else begin
                                    if(temp_result%temp_operand==0)begin
                                    temp_result<=0;
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                    else begin
                                    temp_result<=temp_operand-(temp_result%temp_operand);
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                end                       
                            end                  
                            
                            end
                    endcase
            

                    end
                endcase
            end
            //minus part input_minus==1
            else begin
                case (pb_1st) // each button
                
                    'h0100: begin
                        pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;

                        end
                        sw_start: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;
                            sw_status <= sw_idle;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= 21;
                            set_no6 <= 1;
                            temp_operand <= 1;
                            input_minus <= 1;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= 21;
                            set_no5 <= set_no6;
                            set_no6 <= 1;
                            temp_operand <= set_no6*10+1;
                            input_minus <= 1;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= 21;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 1;
                            temp_operand <= set_no5*100+set_no6*10+1;
                            input_minus <= 1;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= 21;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 1;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+1;
                            input_minus <= 1;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= 21;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 1;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+1;
                            input_minus <= 1;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0200: begin //2
                    pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;
                            sw_status <= sw_idle;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= 21;
                            set_no6 <= 2;
                            temp_operand <= 2;
                            input_minus <= 1;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= 21;
                            set_no5 <= set_no6;
                            set_no6 <= 2;
                            temp_operand <= set_no6*10+2;
                            input_minus <= 1;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= 21;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 2;
                            temp_operand <= set_no5*100+set_no6*10+2;
                            input_minus <= 1;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= 21;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 2;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+2;
                            input_minus <= 1;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= 21;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 2;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+2;
                            input_minus <= 1;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0400: begin
                        pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;
                            sw_status <= sw_idle;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= 21;
                            set_no6 <= 3;
                            temp_operand <= 3;
                            input_minus <= 1;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= 21;
                            set_no5 <= set_no6;
                            set_no6 <= 3;
                            temp_operand <= set_no6*10+3;
                            input_minus <= 1;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= 21;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 3;
                            temp_operand <= set_no5*100+set_no6*10+3;
                            input_minus <= 1;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= 21;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 3;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+3;
                            input_minus <= 1;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= 21;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 3;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+3;
                            input_minus <= 1;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0008: begin //+
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin  //twice + error
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;
                            of <= 1;
                        end
                        default : begin
                        sw_status <= sw_start;
                        input_operator <= 1;
                        set_no1 <= 20;
                        set_no2 <= 20;
                        set_no3 <= 20;
                        set_no4 <= 20;
                        set_no5 <= 20;
                        set_no6 <= 20;
                        
                            if(input_operator==0) begin
                            temp_result <= temp_operand;
                            temp_operand <=0;
                            sign_minus <= input_minus;
                            input_minus<=0;
                            end
                            
                            if(input_operator==1) begin
                                if(input_minus==1) begin
                                    if(sign_minus==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                            end
                                
                            if(input_operator==2) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999)begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand-temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus ==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end      
                            end
                            if(input_operator==3) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end                     
                            end
                            
                            if(input_operator==4) begin
                                if(temp_operand ==0) begin
                                    sw_status <= sw_idle;
                                    set_no1 <= 20;
                                    set_no2 <= 20;
                                    set_no3 <= 16;
                                    set_no4 <= 17;
                                    set_no5 <= 17;
                                    set_no6 <= 20;
                                    of <= 1;
                                end
                                else begin
                                    if(input_minus==0) begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=0;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                        end
                                    end
                                    else begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=1;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                        end
                                    end        
                                end         
                            end

                            if(input_operator==5) begin
                                if(sign_minus==0) begin
                                temp_result<=temp_result%temp_operand;
                                sign_minus<=0;
                                input_minus<=0;
                                end
                                else begin
                                    if(temp_result%temp_operand==0)begin
                                    temp_result<=0;
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                    else begin
                                    temp_result<=temp_operand-(temp_result%temp_operand);
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                end                       
                            end                    
                        end
                    endcase
                    end

                    'h0010: begin 
                        pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;
                            of <= 1;
                            sw_status <= sw_idle;
                            
                        end
                        sw_s1: begin
                            sw_status <= 21;
                            set_no5 <= set_no6;
                            set_no6 <= 4;
                            temp_operand <= 4;
                            input_minus <= 1;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= 21;
                            set_no5 <= set_no6;
                            set_no6 <= 4;
                            temp_operand <= set_no6*10+4;
                            input_minus <= 1;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= 21;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 4;
                            temp_operand <= set_no5*100+set_no6*10+4;
                            input_minus <= 1;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= 21;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 4;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+4;
                            input_minus <= 1;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= 21;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 4;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+4;
                            input_minus <= 1;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0020: begin
                        pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;
                            of <= 1;
                            sw_status <= sw_idle;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= 21;
                            set_no6 <= 5;
                            temp_operand <= 5;
                            input_minus <= 1;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= 21;
                            set_no5 <= set_no6;
                            set_no6 <= 5;
                            temp_operand <= set_no6*10+5;
                            input_minus <= 1;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= 21;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 5;
                            temp_operand <= set_no5*100+set_no6*10+5;
                            input_minus <= 1;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= 21;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 5;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+5;
                            input_minus <= 1;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= 21;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 5;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+5;
                            input_minus <= 1;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0040: begin
                        pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;
                            of <= 1;
                            sw_status <= sw_idle;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= 21;
                            set_no6 <= 6;
                            temp_operand <= 6;
                            input_minus <= 1;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= 21;
                            set_no5 <= set_no6;
                            set_no6 <= 6;
                            temp_operand <= set_no6*10+6;
                            input_minus <= 1;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= 21;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 6;
                            temp_operand <= set_no5*100+set_no6*10+6;
                            input_minus <= 1;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= 21;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 6;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+6;
                            input_minus <= 1;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= 21;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 6;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+6;
                            input_minus <= 1;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0080: begin //-
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            input_minus <= 1;
                            sw_status <= sw_s1;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 21;
                        end
                        
                        default : begin 
                        sw_status <= sw_start;
                        input_operator <= 2;
                        pb_minus <= 1;
                        set_no1 <= 20;
                        set_no2 <= 20;
                        set_no3 <= 20;
                        set_no4 <= 20;
                        set_no5 <= 20;
                        set_no6 <= 20;
                        
                            if(input_operator==0) begin
                            temp_result <= temp_operand;
                            temp_operand <=0;
                            sign_minus <= input_minus;                            
                            input_minus <=0;
                            end
                            
                            if(input_operator==1) begin
                                if(input_minus==1) begin
                                    if(sign_minus==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                            end
                                
                            if(input_operator==2) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999)begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand-temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus ==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end      
                            end
                            if(input_operator==3) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end                     
                            end
                            
                            if(input_operator==4) begin
                                if(temp_operand==0) begin
                                    sw_status <= sw_idle;
                                    set_no1 <= 20;
                                    set_no2 <= 20;
                                    set_no3 <= 16;
                                    set_no4 <= 17;
                                    set_no5 <= 17;
                                    set_no6 <= 20;
                                    of <= 1;
                                end
                                else begin
                                    if(input_minus==0) begin
                                        if(sign_minus==1)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=0;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                        end
                                    end
                                    else begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=1;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                        end
                                    end                
                                end 
                            end

                            if(input_operator==5) begin
                                if(sign_minus==0) begin
                                temp_result<=temp_result%temp_operand;
                                sign_minus<=0;
                                input_minus<=0;
                                end
                                else begin
                                    if(temp_result%temp_operand==0)begin
                                    temp_result<=0;
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                    else begin
                                    temp_result<=temp_operand-(temp_result%temp_operand);
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                end                       
                            end
                            
                            if(input_operator==6) begin
                            temp_result <= temp_operand*temp_operand;
                            end                    
                            
                            end
                    endcase
                    end
                    'h0001: begin 
                        pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;
                            of <= 1;
                            sw_status <= sw_idle;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= 21;
                            set_no6 <= 7;
                            temp_operand <= 7;
                            input_minus <= 1;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= 21;
                            set_no5 <= set_no6;
                            set_no6 <= 7;
                            temp_operand <= set_no6*10+7;
                            input_minus <= 1;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= 21;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 7;
                            temp_operand <= set_no5*100+set_no6*10+7;
                            input_minus <= 1;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= 21;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 7;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+7;
                            input_minus <= 1;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= 21;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 7;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+7;
                            input_minus <= 1;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0002: begin
                        pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;
                            of <= 1;
                            sw_status <= sw_idle;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= 21;
                            set_no6 <= 8;
                            temp_operand <= 8;
                            input_minus <= 1;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= 21;
                            set_no5 <= set_no6;
                            set_no6 <= 8;
                            temp_operand <= set_no6*10+8;
                            input_minus <= 1;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= 21;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 8;
                            temp_operand <= set_no5*100+set_no6*10+8;
                            input_minus <= 1;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= 21;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 8;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+8;
                            input_minus <= 1;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= 21;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 8;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+8;
                            input_minus <= 1;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0004: begin
                        pb_minus <= 0;
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;
                            of <= 1;
                            sw_status <= sw_idle;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= 21;
                            set_no6 <= 9;
                            temp_operand <= 9;
                            input_minus <= 1;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= 21;
                            set_no5 <= set_no6;
                            set_no6 <= 9;
                            temp_operand <= set_no6*10+9;
                            input_minus <= 1;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= 21;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 9;
                            temp_operand <= set_no5*100+set_no6*10+9;
                            input_minus <= 1;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= 21;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 9;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+9;
                            input_minus <= 1;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= 21;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 9;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+9;
                            input_minus <= 1;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end
                    'h0800: begin //*
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                                if(square==1) begin
                                    input_operator <=6;
                                    set_no1 <= 20;
                                    set_no2 <= 20;
                                    set_no3 <= 20;
                                    set_no4 <= 20;
                                    set_no5 <= 20;
                                    set_no6 <= 20;
                                end
                                else begin
                                    if(check_err==1)begin
                                    square <= 1;
                                    sw_status <= sw_start;
                                    set_no1 <= 20;
                                    set_no2 <= 20;
                                    set_no3 <= 20;
                                    set_no4 <= 20;
                                    set_no5 <= 20;
                                    set_no6 <= 20;  
                                    end	
                                    else begin
                                    sw_status <= sw_idle;
                                    set_no1 <= 20;
                                    set_no2 <= 20;
                                    set_no3 <= 16;
                                    set_no4 <= 17;
                                    set_no5 <= 17;
                                    set_no6 <= 20;  
                                    of <= 1;
                                    end						
                                end
                        end
                        
                        default : begin
                                square <= 1;
                                sw_status <= sw_start;
                                input_operator <= 3;
                                set_no1 <= 20;
                                set_no2 <= 20;
                                set_no3 <= 20;
                                set_no4 <= 20;
                                set_no5 <= 20;
                                set_no6 <= 20;
                        
                            if(input_operator==0) begin
                            temp_result <= temp_operand;
                            temp_operand <=0;
                            sign_minus <= input_minus;
                            input_minus <= 0;
                            end
                            
                            if(input_operator==1) begin
                                if(input_minus==1) begin
                                    if(sign_minus==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                            end
                                
                            if(input_operator==2) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999)begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand-temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus ==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end      
                            end
                            if(input_operator==3) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end                     
                            end
                            
                            if(input_operator==4) begin
                                if(temp_operand==0) begin
                                    sw_status <= sw_idle;
                                    set_no1 <= 20;
                                    set_no2 <= 20;
                                    set_no3 <= 16;
                                    set_no4 <= 17;
                                    set_no5 <= 17;
                                    set_no6 <= 20;
                                    of <= 1;
                                end
                                else begin
                                    if(input_minus==0) begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=0;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                        end
                                    end
                                    else begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=1;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                        end
                                    end              
                                end   
                            end

                            if(input_operator==5) begin
                                if(sign_minus==0) begin
                                temp_result<=temp_result%temp_operand;
                                sign_minus<=0;
                                input_minus<=0;
                                end
                                else begin
                                    if(temp_result%temp_operand==0)begin
                                    temp_result<=0;
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                    else begin
                                    temp_result<=temp_operand-(temp_result%temp_operand);
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                end                       
                            end                    
                                                
                        end
                    endcase
                    end
                    'h1000: begin   // enter
                    case (sw_status)
                        sw_idle: begin
                            sw_status <= sw_start;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                        if(input_operator==6) begin
                            temp_result <= temp_result*temp_result;
                            sw_status <= sw_s1;
                            sign_minus <= 0;
                            check_print <= 1; 
                            end  
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        default: begin
                            check_print <= 1;
                            input_operator <= 0;
                            check_err <= 1;
                            if(input_operator==0) begin
                            temp_result <= temp_operand;
                            input_minus <= 0;
                            end
                            
                            if(input_operator==1) begin
                                if(input_minus==1) begin
                                    if(sign_minus==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                            end
                                
                            if(input_operator==2) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999)begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand-temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        if(temp_result==temp_operand)begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus ==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end      
                            end
                            if(input_operator==3) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end                     
                            end
                            
                            if(input_operator==4) begin
                                if(temp_operand==0) begin
                                    sw_status <= sw_idle;
                                    set_no1 <= 20;
                                    set_no2 <= 20;
                                    set_no3 <= 16;
                                    set_no4 <= 17;
                                    set_no5 <= 17;
                                    set_no6 <= 20;
                                    of <= 1;
                                end
                                else begin
                                    if(input_minus==0) begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=0;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                        end
                                    end
                                    else begin
                                        if(sign_minus==0)begin
                                            if(temp_result<temp_operand)begin
                                                temp_result<=temp_result/temp_operand;
                                                sign_minus<=0;
                                                input_minus<=0;
                                            end
                                            else begin
                                                temp_result<=temp_result/temp_operand;
                                                sign_minus<=1;
                                                input_minus<=0;  
                                            end
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                        end
                                    end         
                                end        
                            end

                            if(input_operator==5) begin
                                if(sign_minus==0) begin
                                temp_result<=temp_result%temp_operand;
                                sign_minus<=0;
                                input_minus<=0;
                                end
                                else begin
                                    if(temp_result%temp_operand==0)begin
                                    temp_result<=0;
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                    else begin
                                    temp_result<=temp_operand-(temp_result%temp_operand);
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                end                       
                            end
                        end
                    endcase
                    end
                    'h2000: begin
                        pb_minus <= 0;
                        case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;
                            of <= 1;
                            sw_status <= sw_idle;
                            
                        end
                        sw_s1: begin
                            sw_status <= sw_s2;
                            set_no5 <= 21;
                            set_no6 <= 0;
                            temp_operand <= 0;
                            input_minus <= 1;
                            
                        end
                        sw_s2: begin
                            sw_status <= sw_s3;
                            set_no4 <= 21;
                            set_no5 <= set_no6;
                            set_no6 <= 0;
                            temp_operand <= set_no6*10+0;
                            input_minus <= 1;
                            
                        end
                        sw_s3: begin
                            sw_status <= sw_s4;
                            set_no3 <= 21;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 0;
                            temp_operand <= set_no5*100+set_no6*10+0;
                            input_minus <= 1;
                            
                        end
                        sw_s4: begin
                            sw_status <= sw_s5;
                            set_no2 <= 21;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 0;
                            temp_operand <= set_no4*1000+set_no5*100+set_no6*10+0;
                            input_minus <= 1;
                            
                        end
                        sw_s5: begin
                            sw_status <= sw_s6;
                            set_no1 <= 21;
                            set_no2 <= set_no3;
                            set_no3 <= set_no4;
                            set_no4 <= set_no5;
                            set_no5 <= set_no6;
                            set_no6 <= 0;
                            temp_operand <= set_no3*10000+set_no4*1000+set_no5*100+set_no6*10+0;
                            input_minus <= 1;
                            
                        end
                        sw_s6: begin
                            sw_status <= sw_idle;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;                     
                            
                        end
                    endcase
                    end                              
                    'h4000: begin // clr
                    sw_status <= sw_idle;
                    set_no1 <= 20;
                    set_no2 <= 20;
                    set_no3 <= 20;
                    set_no4 <= 20;
                    set_no5 <= 20;
                    set_no6 <= 20;      
                    input_operator <= 0;
                    sign_minus <= 0;
                    check_print <= 0;
                    square <= 0;
                    remainder <= 0;
                    input_minus <= 0;
                    pb_minus <= 0;
                    check_err <= 0;
                    of <= 0;
                    end
                    
                    'h8000: begin // /
                    case (sw_status)
                        sw_idle: begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                        end
                        sw_start: begin
                            if(remainder==1) begin
                            input_operator <=5;
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 20;
                            set_no4 <= 20;
                            set_no5 <= 20;
                            set_no6 <= 20;
                            end
                            else begin
                            set_no1 <= 20;
                            set_no2 <= 20;
                            set_no3 <= 16;
                            set_no4 <= 17;
                            set_no5 <= 17;
                            set_no6 <= 20;
                            of <= 1;
                            sw_status <= sw_idle;
                            end
                        end
                        
                        default : begin
                        remainder <= 1;
                        sw_status <= sw_start;
                        input_operator <= 4;
                        set_no1 <= 20;
                        set_no2 <= 20;
                        set_no3 <= 20;
                        set_no4 <= 20;
                        set_no5 <= 20;
                        set_no6 <= 20;
                        
                            if(input_operator==0) begin
                            temp_result <= temp_operand;
                            temp_operand <=0;
                            sign_minus <= input_minus;
                            input_minus <= 0;
                            end
                            
                            if(input_operator==1) begin
                                if(input_minus==1) begin
                                    if(sign_minus==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                            end
                                
                            if(input_operator==2) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result+temp_operand>999999)begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand-temp_result;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus ==0)begin
                                        if(temp_result<temp_operand)begin
                                        temp_result <= temp_operand - temp_result;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                        else begin
                                        temp_result <= temp_result - temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result+temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result + temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end      
                            end
                            if(input_operator==3) begin
                                if(input_minus==1)begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                end
                                else begin
                                    if(sign_minus==0)begin
                                        if(temp_result*temp_operand>999999) begin //plus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 0;
                                        input_minus <= 0;
                                        end
                                    end
                                    else begin
                                        if(temp_result*temp_operand>99999) begin //minus overflow
                                        set_no1 <= 20;
                                        set_no2 <= 20;
                                        set_no3 <= 16;
                                        set_no4 <= 17;
                                        set_no5 <= 17;
                                        set_no6 <= 20;
                                        of <= 1;
                                        sw_status <= sw_idle;
                                        end
                                        else begin
                                        temp_result <= temp_result * temp_operand;
                                        sign_minus <= 1;
                                        input_minus <= 0;
                                        end
                                    end
                                end                     
                            end
                            
                            if(input_operator==4) begin
                                if(temp_operand==0) begin
                                    sw_status <= sw_idle;
                                    set_no1 <= 20;
                                    set_no2 <= 20;
                                    set_no3 <= 16;
                                    set_no4 <= 17;
                                    set_no5 <= 17;
                                    set_no6 <= 20;
                                    of <= 1;
                                end
                                else begin
                                    if(input_minus==0) begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=0;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=1;
                                            input_minus<=0;
                                            end
                                        end
                                    end
                                    else begin
                                        if(sign_minus==0)begin
                                        temp_result<=temp_result/temp_operand;
                                        sign_minus<=1;
                                        input_minus<=0;
                                        end
                                        else begin
                                            if(temp_result%temp_operand==0)begin
                                            temp_result<=temp_result/temp_operand;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                            else begin
                                            temp_result<=temp_result/temp_operand+1;
                                            sign_minus<=0;
                                            input_minus<=0;
                                            end
                                        end
                                    end       
                                end          
                            end

                            if(input_operator==5) begin
                                if(sign_minus==0) begin
                                temp_result<=temp_result%temp_operand;
                                sign_minus<=0;
                                input_minus<=0;
                                end
                                else begin
                                    if(temp_result%temp_operand==0)begin
                                    temp_result<=0;
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                    else begin
                                    temp_result<=temp_operand-(temp_result%temp_operand);
                                    sign_minus<=0;
                                    input_minus<=0;
                                    end
                                end                       
                            end                  
                            
                            end
                    endcase
            

                    end
                endcase
            end
        end
    end
    
    
    // 7-segment
    always @(set_no1) begin
        case (set_no1)
            0: seg_100000 <= 'b0011_1111;
            1: seg_100000 <= 'b0000_0110;
            2: seg_100000 <= 'b0101_1011;
            3: seg_100000 <= 'b0100_1111;
            4: seg_100000 <= 'b0110_0110;
            5: seg_100000 <= 'b0110_1101;
            6: seg_100000 <= 'b0111_1101;
            7: seg_100000 <= 'b0000_0111;
            8: seg_100000 <= 'b0111_1111;
            9: seg_100000 <= 'b0110_0111;
            10: seg_100000 <= 'b0111_1000;
            11: seg_100000 <= 'b0111_0011;
            12: seg_100000 <= 'b0111_0111;
            13: seg_100000 <= 'b0111_1100;
            14: seg_100000 <= 'b0011_1001;
            15: seg_100000 <= 'b0101_1110;
            16: seg_100000 <= 'b0111_1001;
            17: seg_100000 <= 'b0101_0000;
            18: seg_100000 <= 'b0100_0000;
            19: seg_100000 <= 'b0101_0100;
            21: seg_100000 <= 'b0100_0000; // minus
            default: seg_100000 <= 'b0000_0000;
        endcase
    end
    always @(set_no2) begin
        case (set_no2)
            0: seg_10000 <= 'b0011_1111;
            1: seg_10000 <= 'b0000_0110;
            2: seg_10000 <= 'b0101_1011;
            3: seg_10000 <= 'b0100_1111;
            4: seg_10000 <= 'b0110_0110;
            5: seg_10000 <= 'b0110_1101;
            6: seg_10000 <= 'b0111_1101;
            7: seg_10000 <= 'b0000_0111;
            8: seg_10000 <= 'b0111_1111;
            9: seg_10000 <= 'b0110_0111;
            10: seg_10000 <= 'b0111_1000;
            11: seg_10000 <= 'b0111_0011;
            12: seg_10000 <= 'b0111_0111;
            13: seg_10000 <= 'b0111_1100;
            14: seg_10000 <= 'b0011_1001;
            15: seg_10000 <= 'b0101_1110;
            16: seg_10000 <= 'b0111_1001;
            17: seg_10000 <= 'b0101_0000;
            18: seg_10000 <= 'b0100_0000;
            19: seg_10000 <= 'b0101_0100;
            21: seg_10000 <= 'b0100_0000; // minus
            default: seg_10000 <= 'b0000_0000;
        endcase
    end
    always @(set_no3) begin
        case (set_no3)
            0: seg_1000 <= 'b0011_1111;
            1: seg_1000 <= 'b0000_0110;
            2: seg_1000 <= 'b0101_1011;
            3: seg_1000 <= 'b0100_1111;
            4: seg_1000 <= 'b0110_0110;
            5: seg_1000 <= 'b0110_1101;
            6: seg_1000 <= 'b0111_1101;
            7: seg_1000 <= 'b0000_0111;
            8: seg_1000 <= 'b0111_1111;
            9: seg_1000 <= 'b0110_0111;
            10: seg_1000 <= 'b0111_1000;
            11: seg_1000 <= 'b0111_0011;
            12: seg_1000 <= 'b0111_0111;
            13: seg_1000 <= 'b0111_1100;
            14: seg_1000 <= 'b0011_1001;
            15: seg_1000 <= 'b0101_1110;
            16: seg_1000 <= 'b0111_1001;
            17: seg_1000 <= 'b0101_0000;
            18: seg_1000 <= 'b0100_0000;
            19: seg_1000 <= 'b0101_0100;
            21: seg_1000 <= 'b0100_0000; // minus
            default: seg_1000 <= 'b0000_0000;
        endcase
    end
    always @(set_no4) begin
        case (set_no4)
            0: seg_100 <= 'b0011_1111;
            1: seg_100 <= 'b0000_0110;
            2: seg_100 <= 'b0101_1011;
            3: seg_100 <= 'b0100_1111;
            4: seg_100 <= 'b0110_0110;
            5: seg_100 <= 'b0110_1101;
            6: seg_100 <= 'b0111_1101;
            7: seg_100 <= 'b0000_0111;
            8: seg_100 <= 'b0111_1111;
            9: seg_100 <= 'b0110_0111;
            10: seg_100 <= 'b0111_1000;
            11: seg_100 <= 'b0111_0011;
            12: seg_100 <= 'b0111_0111;
            13: seg_100 <= 'b0111_1100;
            14: seg_100 <= 'b0011_1001;
            15: seg_100 <= 'b0101_1110;
            16: seg_100 <= 'b0111_1001;
            17: seg_100 <= 'b0101_0000;
            18: seg_100 <= 'b0100_0000;
            19: seg_100 <= 'b0101_0100;
            21: seg_100 <= 'b0100_0000; // minus
            default: seg_100 <= 'b0000_0000;
        endcase
    end
    always @(set_no5) begin
        case (set_no5)
            0: seg_10 <= 'b0011_1111;
            1: seg_10 <= 'b0000_0110;
            2: seg_10 <= 'b0101_1011;
            3: seg_10 <= 'b0100_1111;
            4: seg_10 <= 'b0110_0110;
            5: seg_10 <= 'b0110_1101;
            6: seg_10 <= 'b0111_1101;
            7: seg_10 <= 'b0000_0111;
            8: seg_10 <= 'b0111_1111;
            9: seg_10 <= 'b0110_0111;
            10: seg_10 <= 'b0111_1000;
            11: seg_10 <= 'b0111_0011;
            12: seg_10 <= 'b0111_0111;
            13: seg_10 <= 'b0111_1100;
            14: seg_10 <= 'b0011_1001;
            15: seg_10 <= 'b0101_1110;
            16: seg_10 <= 'b0111_1001;
            17: seg_10 <= 'b0101_0000;
            18: seg_10 <= 'b0100_0000;
            19: seg_10 <= 'b0101_0100;
            21: seg_10 <= 'b0100_0000; // minus
            default: seg_10 <= 'b0000_0000;
        endcase
    end
    always @(set_no6) begin
        case (set_no6)
            0: seg_1 <= 'b0011_1111;
            1: seg_1 <= 'b0000_0110;
            2: seg_1 <= 'b0101_1011;
            3: seg_1 <= 'b0100_1111;
            4: seg_1 <= 'b0110_0110;
            5: seg_1 <= 'b0110_1101;
            6: seg_1 <= 'b0111_1101;
            7: seg_1 <= 'b0000_0111;
            8: seg_1 <= 'b0111_1111;
            9: seg_1 <= 'b0110_0111;
            10: seg_1 <= 'b0111_1000;
            11: seg_1 <= 'b0111_0011;
            12: seg_1 <= 'b0111_0111;
            13: seg_1 <= 'b0111_1100;
            14: seg_1 <= 'b0011_1001;
            15: seg_1 <= 'b0101_1110;
            16: seg_1 <= 'b0111_1001;
            17: seg_1 <= 'b0101_0000;
            18: seg_1 <= 'b0100_0000;
            19: seg_1 <= 'b0101_0100;
            21: seg_1 <= 'b0100_0000; // minus
            default: seg_1 <= 'b0000_0000;
        endcase
    end
    
    // fnd_clk. output
    always @(posedge fnd_clk) begin
        fnd_cnt <= fnd_cnt + 1;
        case (fnd_cnt)
            5: begin
                fnd_d <= seg_100000;
                fnd_s <= 'b011111;
            end   
            4: begin
                fnd_d <= seg_10000;
                fnd_s <= 'b101111;
            end
            3: begin
                fnd_d <= seg_1000;
                fnd_s <= 'b110111;
            end
            2: begin
                fnd_d <= seg_100;
                fnd_s <= 'b111011;
            end
            1: begin
                fnd_d <= seg_10;
                fnd_s <= 'b111101;
            end
            0: begin
                fnd_d <= seg_1;
                fnd_s <= 'b111110;
            end
        endcase
    end
    endmodule
