/* 
--- File:    fillscreen.sv
--- Module:  fillscreen
--- Brief:   Sweeps the 160x120 VGA space, plotting every pixel in the chosen colour; asserts 'done' when complete.

--- Description:
---   Simple two-state FSM:
---     READY → waits for 'start'.
---     DRAW  → iterates vga_y from 0..118 for each vga_x 0..159, asserting vga_plot while scanning.
---   Uses 'donex' to gate end-of-column and 'first_iteration' to avoid an extra increment on the first row.

--- Interfaces:
---   Inputs : clk, rst_n, colour[2:0], start
---   Outputs: done, vga_x[7:0], vga_y[6:0], vga_colour[2:0], vga_plot

--- Author: Joey Negm
*/

module fillscreen(
     input  logic       clk, 
     input  logic       rst_n, 
     input  logic [2:0] colour,
     input  logic       start, 
     output logic       done,
     output logic [7:0] vga_x, 
     output logic [6:0] vga_y,
     output logic [2:0] vga_colour, 
     output logic       vga_plot
     );

     // --- State Machine Variable ---
     enum { READY, DRAW } state;

     // --- Internal Variables ---
     logic donex;
     logic first_iteration;

     // --- Combinational Assignments ---
     assign vga_colour = colour;

     // --- Sequential Logic ---
     always_ff @(posedge clk) begin
          if(~rst_n) begin
               state <= READY;
               vga_x           <= 8'd0;
               vga_y           <= 7'd0;
               vga_plot        <= 1'b0;
               done            <= 1'b0;
               donex           <= 1'b0;
               first_iteration <= 1'b1;
          end
          else begin
               // --- Next State Logic ---
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

               // --- State Outputs ---
               case (state)
                    READY: begin
                         vga_x    <= 8'd0;
                         vga_y    <= 7'd0;
                         vga_plot <= 1'b0;
                         done     <= 1'b0;
                         donex    <= 1'b0;
                    end

                    DRAW: begin
                         vga_plot <= 1'b1;

                         if(~donex) begin
                              if(first_iteration) begin
                                   vga_y           <= vga_y;
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
