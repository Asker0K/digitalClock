module Counter #(
    parameter initial_value // инициализирующее число 0_1011_0111_1010_1100
)
(
    input logic reset,
    input logic clk,
	 input logic pause,
	 input logic set,

    output logic [3:0] num [5:0]
	 

);

logic [25:0] cnt;
logic [3:0] sec_e;
logic [3:0] sec_d;
logic [3:0] min_e;
logic [3:0] min_d;
logic [3:0] hour_e;
logic [3:0] hour_d;


logic [7:0]  hours;
logic [7:0]  minutes;
logic [7:0]  seconds;

logic [31:0] bcd_sec; //Регистр для перевода из двоичной системы в ДДК для секунд
logic [31:0] bcd_min; //Регистр для перевода из двоичной системы в ДДК для минут
logic [31:0] bcd_hour; //Регистр для перевода из двоичной системы в ДДК для часов

always_ff @(posedge clk or negedge reset)
begin
    if(~reset)
	 ///////////////////////////////
	 begin		 
	 cnt    <= 26'b0;
	 sec_e  <= 0;
    sec_d  <= 0;
    min_e  <= 0;
    min_d  <= 0;
    hour_e <= 0;
    hour_d <= 0;
	 num[0] <= 0;
	 num[1] <= 0;
	 num[2] <= 0;
	 num[3] <= 0;
	 num[4] <= 0;
	 num[5] <= 0;
	 end
    else if(set)
	 begin
	 ///////Перевод из секунд в формат ЧЧ:ММ:СС/////////////
	 hours <= initial_value/3600;
	 minutes <= (initial_value-hours*3600)/60;
	 seconds <= initial_value-hours*3600 - minutes*60;
	 //////////Алгоритм перевода из двоичной в ДДК систему счисления/////////////
	 bcd_sec = 32'd 0; //Инициализация нулями

	  bcd_sec[7:0] = seconds[7:0];
	  for (logic [31:0] i = 0; i < 8; i = i + 1)
	  begin //if для каждого промежутка из 4 цифр
			if (bcd_sec[15 : 12 ] > 4) //Десятки
				 begin
					  bcd_sec[15 : 12] = bcd_sec[15 : 12 ] + 4'd3;
				 end
			if (bcd_sec[11 : 8] > 4) //Единицы
				 begin
					  bcd_sec[11 : 8] = bcd_sec[11 : 8 ] + 4'd3;
				 end
			bcd_sec = bcd_sec << 1; // Сдвиг 
	  end

	 ///////////////////////////////
	 bcd_min = 32'd 0; //Инициализация нулями

	  bcd_min[7:0] = minutes[7:0];
	  for (logic [31:0] i = 0; i < 8; i = i + 1)
	  begin //if для каждого промежутка из 4 цифр
			if (bcd_min[15 : 12 ] > 4) //Десятки
				 begin
					  bcd_min[15 : 12] = bcd_min[15 : 12 ] + 4'd3;
				 end
			if (bcd_min[11 : 8 ] > 4) //Единицы
				 begin
					  bcd_min[11 : 8] = bcd_min[11 : 8 ] + 4'd3;
				 end
			bcd_min = bcd_min << 1; // Сдвиг 
	  end

	 ///////////////////////////////
	 bcd_hour = 32'd 0; //Инициализация нулями

	  bcd_hour[7:0] = hours[7:0];
	  for (logic [31:0] i = 0; i < 8; i = i + 1)
	  begin //if для каждого промежутка из 4 цифр
			if (bcd_hour[15 : 12 ] > 4) //Десятки
				 begin
					  bcd_hour[15 : 12] = bcd_hour[15 : 12 ] + 4'd3;
				 end
			if (bcd_hour[11 : 8 ] > 4) //Единицы
				 begin
					  bcd_hour[11 : 8] = bcd_hour[11 : 8 ] + 4'd3;
				 end
			bcd_hour = bcd_hour << 1; // Сдвиг 
	  end

	 ///////////////////////////////
     sec_e  <= bcd_sec[11:8];
     sec_d  <= bcd_sec[15:12];
     min_e  <= bcd_min[11:8];
     min_d  <= bcd_min[15:12];
     hour_e <= bcd_hour[11:8];
     hour_d <= bcd_hour[15:12];
	  
	 end//else if	
    else if (pause)
		cnt = cnt;
	 else	
    begin
        if( cnt[25:0] == 50000000) 
        begin
			   cnt <= 0;
            if (sec_e == 9) 
					 begin
                sec_e <=0;
                if (sec_d == 5) 
						  begin
                    sec_d <= 0;
                    if( min_e == 9) 
								begin
                        min_e <= 0;
                        if (min_d == 5) 
									 begin
                            min_d <=0;
                            if(hour_e == 3) 
										  begin
                                hour_e <= 0;
                                if( hour_d == 2) 
                                    hour_d <=0;
                                else
                                    hour_d <= hour_d +1;
										  end//if
                            else
                                hour_e <= hour_e +1;
									 end//if    
                        else
                            min_d <= min_d +1;
								end//if    
                    else
                        min_e <= min_e +1;
						  end//if    
                else
                    sec_d <= sec_d +1;
					 end//if    
            else
                sec_e <= sec_e +1;
		  end // if 
			   
        else
            cnt <= cnt + 1;

        case(cnt[15:13])
			0 :  num[0] <= hour_d;
         1 :  num[1] <= hour_e;
         2 :  num[2] <= min_d;
         3 :  num[3] <= min_e;
         4 :  num[4] <= sec_d;
         5 :  num[5] <= sec_e;
        endcase

    end//else
end // always_ff

endmodule



module Display
(
   input logic [3:0] num [5:0],
	
	output logic [6:0] seg [5:0],
	output logic [3:0] LEDs
);

// вывод на семисегментный дисплей
assign LEDs = num[5];

always_comb begin
	
	case(num[0]) //hour_d
		0: seg[0] <= 7'b1000000;
		1: seg[0] <= 7'b1111001;
		2: seg[0] <= 7'b0100100;
		3: seg[0] <= 7'b0110000;
		4: seg[0] <= 7'b0011001;
		5: seg[0] <= 7'b0010010;
		6: seg[0] <= 7'b0000010;
		7: seg[0] <= 7'b1111000;
		8: seg[0] <= 7'b0000000;
		9: seg[0] <= 7'b0010000;
		default : seg[0] <= 7'b1111111;
	endcase
	case(num[1]) //hour_e
		0: seg[1] <= 7'b1000000;
		1: seg[1] <= 7'b1111001;
		2: seg[1] <= 7'b0100100;
		3: seg[1] <= 7'b0110000;
		4: seg[1] <= 7'b0011001;
		5: seg[1] <= 7'b0010010;
		6: seg[1] <= 7'b0000010;
		7: seg[1] <= 7'b1111000;
		8: seg[1] <= 7'b0000000;
		9: seg[1] <= 7'b0010000;
		default : seg[1] <= 7'b1111111;
	endcase
	case(num[2]) //min_d
		0: seg[2] <= 7'b1000000;
		1: seg[2] <= 7'b1111001;
		2: seg[2] <= 7'b0100100;
		3: seg[2] <= 7'b0110000;
		4: seg[2] <= 7'b0011001;
		5: seg[2] <= 7'b0010010;
		6: seg[2] <= 7'b0000010;
		7: seg[2] <= 7'b1111000;
		8: seg[2] <= 7'b0000000;
		9: seg[2] <= 7'b0010000;
		default : seg[2] <= 7'b1111111;
	endcase
	case(num[3]) //min_e
		0: seg[3] <= 7'b1000000;
		1: seg[3] <= 7'b1111001;
		2: seg[3] <= 7'b0100100;
		3: seg[3] <= 7'b0110000;
		4: seg[3] <= 7'b0011001;
		5: seg[3] <= 7'b0010010;
		6: seg[3] <= 7'b0000010;
		7: seg[3] <= 7'b1111000;
		8: seg[3] <= 7'b0000000;
		9: seg[3] <= 7'b0010000;
		default : seg[3] <= 7'b1111111;
	endcase
	case(num[4]) //sec_d
		0: seg[4] <= 7'b1000000;
		1: seg[4] <= 7'b1111001;
		2: seg[4] <= 7'b0100100;
		3: seg[4] <= 7'b0110000;
		4: seg[4] <= 7'b0011001;
		5: seg[4] <= 7'b0010010;
		6: seg[4] <= 7'b0000010;
		7: seg[4] <= 7'b1111000;
		8: seg[4] <= 7'b0000000;
		9: seg[4] <= 7'b0010000;
		default : seg[4] <= 7'b1111111;
	endcase
	case(num[5]) //sec_e
		0: seg[5] <= 7'b1000000;
		1: seg[5] <= 7'b1111001;
		2: seg[5] <= 7'b0100100;
		3: seg[5] <= 7'b0110000;
		4: seg[5] <= 7'b0011001;
		5: seg[5] <= 7'b0010010;
		6: seg[5] <= 7'b0000010;
		7: seg[5] <= 7'b1111000;
		8: seg[5] <= 7'b0000000;
		9: seg[5] <= 7'b0010000;
		default : seg[5] <= 7'b1111111;
	endcase
end
endmodule
