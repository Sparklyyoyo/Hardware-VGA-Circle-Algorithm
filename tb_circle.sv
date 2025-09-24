module tb_rtl_circle();

    logic clk;
    logic rst_n;
    logic [2:0] colour;
    logic [7:0] centre_x;
    logic [6:0] centre_y;
    logic [7:0] radius;
    logic start;
    logic done;
    logic [7:0] vga_x;
    logic [6:0] vga_y;
    logic [2:0] vga_colour;
    logic vga_plot;
    logic err;

    always #5 clk = ~clk;

    circle dut(.*);

    enum { READY, PREP, OCT_1, OCT_2, OCT_3, OCT_4, OCT_5, OCT_6, OCT_7, OCT_8, CALC, DONE, ERROR } tb_state;

    task check;

        input logic [3:0] out;
        input logic [3:0] expected_output;

        begin
            if(out !== expected_output) begin
                $error("Error: Output is %b, Expected Output is %b", out, expected_output);
                err = 1'b1;
            end
        end
    endtask

    initial begin
        
        clk = 1'b1;
        rst_n = 1'b0;
        err = 1'b0;

        #10

        check(dut.state, READY);
        colour = 3'b100;
        radius = 8'd10;
        centre_x = 8'd80;
        centre_y = 7'd60;
        start = 1'b1;
        rst_n = 1'b1;

        #10;

        check(dut.state, PREP);
        check(vga_colour, 4);

        #192190;

        start = 1'b0;
        check(done, 1'b1);

        #10

        check(done, 1'b0);
        check(vga_plot, 1'b0);

        if(err)
            $display("FAILED");

        else
            $display("PASSED");
        
        $stop;
    end

endmodule: tb_rtl_circle