/* 
--- File:    top.sv
--- Module:  top
--- Brief:   Board-level top: fills the screen then draws a circle; exposes raw VGA plus X/Y/colour/plot.

--- Description:
---   Identical sequencing to 'task3', packaged as the top-level integration with the vga_adapter
---   and simple LED/HEX tie-offs. FSM selects between 'fillscreen' and 'circle' generators.

--- Interfaces:
---   Inputs : CLOCK_50, KEY[3:0], SW[9:0]
---   Outputs: LEDR[9:0], HEX0..HEX5[6:0], VGA_* signals, and passthrough X/Y/colour/plot

--- Author: Joey Negm
*/

module top(
    input  logic       CLOCK_50, 
    input  logic [3:0] KEY,
    input  logic [9:0] SW, 
    output logic [9:0] LEDR,
    output logic [6:0] HEX0, 
    output logic [6:0] HEX1, 
    output logic [6:0] HEX2,
    output logic [6:0] HEX3, 
    output logic [6:0] HEX4, 
    output logic [6:0] HEX5,
    output logic [7:0] VGA_R, 
    output logic [7:0] VGA_G, 
    output logic [7:0] VGA_B,
    output logic       VGA_HS, 
    output logic       VGA_VS,
    output logic       VGA_CLK,
    output logic [7:0] VGA_X, 
    output logic [6:0] VGA_Y,
    output logic [2:0] VGA_COLOUR, 
    output logic       VGA_PLOT
    );

    // --- FSM State Variable ---
    enum { FILL, CIRCLE, ERROR } state;

    // --- Internal Signals ---
    logic [2:0] fill_colour;
    logic [2:0] circle_colour;
    logic [2:0] VGA_fill_colour;
    logic [2:0] VGA_circle_colour;

    logic       VGA_BLANK;
    logic       VGA_SYNC;

    logic [7:0] radius;

    logic       plot_fillscreen;
    logic       start_fillscreen;
    logic       done_fillscreen;

    logic       plot_circle;
    logic       start_circle;
    logic       done_circle;

    logic [7:0] centre_x;
    logic [6:0] centre_y;

    logic [7:0] VGA_X_CIRCLE;
    logic [6:0] VGA_Y_CIRCLE;

    logic [7:0] VGA_X_FILLSCREEN;
    logic [6:0] VGA_Y_FILLSCREEN;

    logic [9:0] FB_VGA_R;
    logic [9:0] FB_VGA_G;
    logic [9:0] FB_VGA_B;

    // --- Tie-offs and Assignments ---
    assign fill_colour = 3'b000;
    assign circle_colour = 3'b010;

    assign centre_x = 8'd80;
    assign centre_y = 7'd60;

    assign radius = 8'd40;
    assign resetn = KEY[3];

    assign LEDR = '1;
    assign HEX0 = '1;
    assign HEX1 = '1;
    assign HEX2 = '1;
    assign HEX3 = '1;
    assign HEX4 = '1;
    assign HEX5 = '1;

    assign VGA_R = FB_VGA_R [9:2];
    assign VGA_G = FB_VGA_G [9:2];
    assign VGA_B = FB_VGA_B [9:2];

    // --- Instantiate Modules ---
    circle CIRCLE_dut(.clk(CLOCK_50), .rst_n(resetn), .colour(circle_colour), .centre_x(centre_x), .centre_y(centre_y), .radius(radius),
     .start(start_circle), .done(done_circle), .vga_x(VGA_X_CIRCLE), .vga_y(VGA_Y_CIRCLE), .vga_colour(VGA_circle_colour), .vga_plot(plot_circle));

    fillscreen FS(.clk(CLOCK_50), .rst_n(resetn), .colour(fill_colour), .start(start_fillscreen), .done(done_fillscreen), .vga_x(VGA_X_FILLSCREEN), .vga_y(VGA_Y_FILLSCREEN), .vga_colour(VGA_fill_colour), .vga_plot(plot_fillscreen));

    vga_adapter ADAPTER(.resetn(resetn), .clock(CLOCK_50), .colour(VGA_COLOUR), .x(VGA_X), .y(VGA_Y), .plot(VGA_PLOT), .VGA_R(FB_VGA_R), .VGA_G(FB_VGA_G), .VGA_B(FB_VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS),
    .VGA_BLANK(VGA_BLANK), .VGA_SYNC(VGA_SYNC),.VGA_CLK(VGA_CLK));

    
    // --- FSM Logic ---
    always_ff @(posedge CLOCK_50) begin
        if(~resetn) 
            state <= FILL;
        else begin
            case (state)
                FILL: begin
                    if(done_fillscreen === 1)
                        state <= CIRCLE;
                    else
                        state <= FILL;
                end

                CIRCLE:  state <= CIRCLE;
                default: state <= ERROR;
            endcase
        end
    end

    // --- Mux Logic ---
    always_comb begin
        case (state)
            FILL: begin
                VGA_PLOT         = plot_fillscreen;
                VGA_COLOUR       = fill_colour;
                VGA_X            = VGA_X_FILLSCREEN;
                VGA_Y            = VGA_Y_FILLSCREEN;
                start_fillscreen = 1'b1;
                start_circle     = 1'b0;
            end

            CIRCLE: begin
                VGA_PLOT         = plot_circle;
                VGA_COLOUR       = circle_colour;
                VGA_X            = VGA_X_CIRCLE;
                VGA_Y            = VGA_Y_CIRCLE;
                start_fillscreen = 1'b0;
                start_circle     = 1'b1;
            end

            default: begin
                VGA_PLOT         = 'x;
                VGA_COLOUR       = 'x;
                VGA_X            = 'x;
                VGA_Y            = 'x;
                start_fillscreen = 'x;
                start_circle     = 'x;
            end
        endcase
    end
endmodule