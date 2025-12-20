module counter
(
clk,rst,mode,load,data_in,
data_out
);

input wire clk;
input wire rst,mode,load;
input wire [3:0] data_in;
output reg [3:0] data_out;

always@(posedge clk)
begin
	if(rst==1'b1) //reset
	begin
		data_out <= 4'b0000;
	end
	else
	begin
		if(load==1'b1) //loading_data
		begin
			data_out <= data_in;
		end
		else
		begin
			if(mode==1'b1) //up_counter
			begin
				if(data_out==4'b1011) //mod-12
				begin
					data_out <= 4'b0000;
				end
				else
				begin
					data_out <= data_out + 4'b0001;
				end
			end			
			else //down_counter
			begin
				if(data_out==4'b0000) //mod-12
				begin
					data_out <= 4'b1011;
				end
				else
				begin
					data_out <= data_out - 4'b0001;
				end
			end
		end
	end
end

endmodule
