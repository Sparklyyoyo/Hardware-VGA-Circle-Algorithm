module tb_rtl_task3();

    logic CLOCK_50;
    logic [3:0] KEY;
    logic [9:0] SW;
    logic [9:0] LEDR;
    logic [6:0] HEX0;
    logic [6:0] HEX1;
    logic [6:0] HEX2;
    logic [6:0] HEX3;
    logic [6:0] HEX4;
    logic [6:0] HEX5;
    logic [7:0] VGA_R;
    logic [7:0] VGA_G;
    logic [7:0] VGA_B;
    logic VGA_HS;
    logic VGA_VS;
    logic VGA_CLK;
    logic [7:0] VGA_X;
    logic [6:0] VGA_Y;
    logic [2:0] VGA_COLOUR;
    logic VGA_PLOT;
    logic err;

    always #1 CLOCK_50 = ~CLOCK_50;

    task3 dut(.*);

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
        
        CLOCK_50 = 1'b0;
        KEY[3] = 1'b0;
        err = 1'b0;

        #10

        KEY[3] = 1'b1;

        #300000

        if(err)
            $display("FAILED");

        else
            $display("PASSED");
        
        $stop;
    end
endmodule: tb_rtl_task3