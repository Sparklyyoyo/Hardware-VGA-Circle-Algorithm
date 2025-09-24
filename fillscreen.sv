module fillscreen(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic done,
                  output logic [7:0] vga_x, output logic [6:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);
     
     enum { READY, DRAW } state;
     logic donex;
     logic first_iteration;
     assign vga_colour = colour;

     always_ff @(posedge clk) begin

          if(~rst_n) begin
               state <= READY;
               vga_x <= 8'd0;
               vga_y <= 7'd0;
               vga_plot <= 1'b0;
               done <= 1'b0;
               donex = 1'b0;
               first_iteration <= 1'b1;
          end

          else begin
               
               case (state)
                    READY: begin
                         
                         if(start)
                              state = DRAW;

                         else
                              state = READY;
                    end

                    DRAW: begin
                         
                         if(~start)
                              state = READY;
                         
                         else
                              state = DRAW;
                    end

                    default: state = READY;
               endcase

               case (state)
                    READY: begin
                         vga_x <= 8'd0;
                         vga_y <= 7'd0;
                         vga_plot <= 1'b0;
                         done <= 1'b0;
                         donex = 1'b0;
                    end 

                    DRAW: begin
                         
                         vga_plot <= 1'b1;

                         if(~donex) begin
                              
                              if(first_iteration) begin
                                   vga_y <= vga_y;
                                   first_iteration <= 1'b0;
                              end

                              else
                                   vga_y <= vga_y + 1;
                                   

                              if(vga_y === 7'd118)
                                   donex <= 1'd1;
                         end
                         
                         else if(vga_x < 8'd159) begin
                              
                              vga_x <= vga_x + 1'd1;
                              vga_y <= 7'd0;
                              donex <= 1'b0;
                         end

                         else begin
                              vga_plot <= 1'b0;
                              done <= 1'b1;
                         end
                    end

                    default: begin
                         vga_x <= 8'dx;
                         vga_y <= 7'dx;
                         vga_plot <= 1'bx;
                         done <= 1'bx;
                    end
               endcase
          end
     end
endmodule
