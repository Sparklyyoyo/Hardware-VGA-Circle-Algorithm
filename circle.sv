module circle(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
              input logic start, output logic done,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);
     // draw the circle
     
     logic signed [7:0] offset_y;
     logic signed [8:0] offset_x;
     logic signed [8:0] crit;
     logic signed [8:0] signed_radius;
     logic signed [7:0] signed_vga_y;
     logic signed [8:0] signed_vga_x;

     enum { READY, PREP, OCT_1, OCT_2, OCT_3, OCT_4, OCT_5, OCT_6, OCT_7, OCT_8, CALC, DONE, ERROR } state;

     assign vga_colour = colour;
     assign signed_radius = radius;
   
     always_ff @(posedge clk) begin
          if(~rst_n) begin
               state <= READY;
               done <= 1'b0;
               vga_x = 8'd0;
               vga_y = 7'd0;
               vga_plot <= 1'b0;
          end
          else begin
               
               case (state)
                    READY: begin
                         
                         if(start)
                              state = PREP;
                         else
                              state = READY;
                    end
                    PREP: begin
                         
                         if(offset_y <= offset_x)
                              state = OCT_1;
                         
                         else
                              state = DONE;
                    end
                    
                    OCT_1: state = OCT_2;
                    OCT_2: state = OCT_3;
                    OCT_3: state = OCT_4;
                    OCT_4: state = OCT_5;
                    OCT_5: state = OCT_6;
                    OCT_6: state = OCT_7;
                    OCT_7: state = OCT_8;
                    OCT_8: state = CALC;
                    CALC: begin
                         if(offset_y <= offset_x)
                              state = OCT_1;
                         
                         else
                              state = DONE;
                    end
                    DONE: begin
                         
                         if(~start)
                              state = READY;
                         
                         else
                              state = DONE;
                    end
                    default: state = ERROR;
               endcase
               case (state)
                    READY: begin
                         done <= 1'b0;
                         vga_x <= 7'd0;
                         vga_y <= 7'd0;
                         vga_plot <= 1'b0;
                    end 
                    PREP: begin
                         offset_y <= 6'd0;
                         offset_x <= radius;
                         crit <= 1 - radius;
                         vga_plot = 1'b0;
                    end
                    OCT_1: begin
                         
                         signed_vga_x = centre_x + offset_x;
                         signed_vga_y = centre_y + offset_y;
                         if((signed_vga_x < 0) || (signed_vga_y < 0)) begin
                              vga_plot = 1'b0;
                              vga_x = 8'd0;
                              vga_y = 7'd0;
                         end
                         else begin
                              vga_plot = 1'b1;
                              vga_x = signed_vga_x [7:0];
                              vga_y = signed_vga_y [6:0];
                         end
                    end
                    OCT_2: begin
                         
                         signed_vga_x = centre_x + offset_y;
                         signed_vga_y = centre_y + offset_x;
                         if((signed_vga_x < 0) || (signed_vga_y < 0)) begin
                              vga_plot = 1'b0;
                              vga_x = 8'd0;
                              vga_y = 7'd0;
                         end
                         else begin
                              vga_plot = 1'b1;
                              vga_x = signed_vga_x [7:0];
                              vga_y = signed_vga_y [6:0];
                         end
                    end
                    OCT_3: begin
                         
                         signed_vga_x = centre_x - offset_x;
                         signed_vga_y = centre_y + offset_y;
                         if((signed_vga_x < 0) || (signed_vga_y < 0)) begin
                              vga_plot = 1'b0;
                              vga_x = 8'd0;
                              vga_y = 7'd0;
                         end
                         else begin
                              vga_plot = 1'b1;
                              vga_x = signed_vga_x [7:0];
                              vga_y = signed_vga_y [6:0];
                         end
                    end
                    OCT_4: begin
                         
                         signed_vga_x = centre_x - offset_y;
                         signed_vga_y = centre_y + offset_x;
                         if((signed_vga_x < 0) || (signed_vga_y < 0)) begin
                              vga_plot = 1'b0;
                              vga_x = 8'd0;
                              vga_y = 7'd0;
                         end
                         else begin
                              vga_plot = 1'b1;
                              vga_x = signed_vga_x [7:0];
                              vga_y = signed_vga_y [6:0];
                         end
                    end
                    OCT_5: begin
                         
                         signed_vga_x = centre_x - offset_x;
                         signed_vga_y = centre_y - offset_y;
                         if((signed_vga_x < 0) || (signed_vga_y < 0)) begin
                              vga_plot = 1'b0;
                              vga_x = 8'd0;
                              vga_y = 7'd0;
                         end
                         else begin
                              vga_plot = 1'b1;
                              vga_x = signed_vga_x [7:0];
                              vga_y = signed_vga_y [6:0];
                         end
                    end
                    OCT_6: begin
                         
                         signed_vga_x = centre_x - offset_y;
                         signed_vga_y = centre_y - offset_x;
                         if((signed_vga_x < 0) || (signed_vga_y < 0)) begin
                              vga_plot = 1'b0;
                              vga_x = 8'd0;
                              vga_y = 7'd0;
                         end
                         else begin
                              vga_plot = 1'b1;
                              vga_x = signed_vga_x [7:0];
                              vga_y = signed_vga_y [6:0];
                         end
                    end
                    OCT_7: begin
                         
                         signed_vga_x = centre_x + offset_x;
                         signed_vga_y = centre_y - offset_y;
                         if((signed_vga_x < 0) || (signed_vga_y < 0)) begin
                              vga_plot = 1'b0;
                              vga_x = 8'd0;
                              vga_y = 7'd0;
                         end
                         else begin
                              vga_plot = 1'b1;
                              vga_x = signed_vga_x [7:0];
                              vga_y = signed_vga_y [6:0];
                         end
                    end
                    OCT_8: begin
                         
                         signed_vga_x = centre_x + offset_y;
                         signed_vga_y = centre_y - offset_x;
                         if((signed_vga_x < 0) || (signed_vga_y < 0)) begin
                              vga_plot = 1'b0;
                              vga_x = 8'd0;
                              vga_y = 7'd0;
                         end
                         else begin
                              vga_plot = 1'b1;
                              vga_x = signed_vga_x [7:0];
                              vga_y = signed_vga_y [6:0];
                         end
                    end
                    CALC: begin
                         offset_y = offset_y + 1;
                         if(crit <= 0)
                              crit = crit + 2 * offset_y + 1;
                         else begin
                              
                              offset_x = offset_x - 1;
                              crit = crit + 2 * (offset_y - offset_x) + 1;
                         end
                    end
                    DONE: begin
                         
                         vga_plot <= 1'b0;
                         done <= 1'b1;
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