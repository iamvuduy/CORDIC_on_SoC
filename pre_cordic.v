module pre_cordic (
    input wire mode,
    input wire signed [31:0] data_in_x,
    input wire signed [31:0] data_in_y,
    input wire signed [31:0] data_in_z,
    output wire signed [31:0] x_pre,
    output wire signed [31:0] y_pre,
    output wire signed [31:0] angle_pre
);
    localparam signed [31:0] K_GAIN = 32'sh26DD3B6A;

    wire [1:0] sel = {data_in_y[31], data_in_x[31]};

    reg signed [31:0] x_reg;
    reg signed [31:0] y_reg;
    reg signed [31:0] angle_reg;

    always @* begin
        if (mode == 1'b0) begin
            // Rotation pre-processing (from pre_rodation)
            if (data_in_z[31] == 1'b0) begin
                case (data_in_z[29:28])
                    2'b00: begin
                        x_reg = K_GAIN;
                        y_reg = 32'sd0;
                        angle_reg = data_in_z;
                    end
                    2'b01: begin
                        x_reg = 32'sd0;
                        y_reg = K_GAIN;
                        angle_reg = data_in_z - 32'sh10000000;
                    end
                    2'b10: begin
                        x_reg = -K_GAIN;
                        y_reg = 32'sd0;
                        angle_reg = data_in_z - 32'sh20000000;
                    end
                    2'b11: begin
                        x_reg = 32'sd0;
                        y_reg = -K_GAIN;
                        angle_reg = data_in_z - 32'sh30000000;
                    end
                    default: begin
                        x_reg = K_GAIN;
                        y_reg = 32'sd0;
                        angle_reg = data_in_z;
                    end
                endcase
            end else begin
                case (data_in_z[29:28])
                    2'b00: begin
                        x_reg = K_GAIN;
                        y_reg = 32'sd0;
                        angle_reg = data_in_z - 32'shC0000000;
                    end
                    2'b01: begin
                        x_reg = 32'sd0;
                        y_reg = K_GAIN;
                        angle_reg = data_in_z + 32'sh30000000;
                    end
                    2'b10: begin
                        x_reg = -K_GAIN;
                        y_reg = 32'sd0;
                        angle_reg = data_in_z + 32'sh20000000;
                    end
                    2'b11: begin
                        x_reg = K_GAIN;
                        y_reg = 32'sd0;
                        angle_reg = data_in_z;
                    end
                    default: begin
                        x_reg = K_GAIN;
                        y_reg = 32'sd0;
                        angle_reg = data_in_z;
                    end
                endcase
            end
        end else begin
            // Vectoring pre-processing (from pre_vectoring)
            case (sel)
                2'b00: begin
                    x_reg = data_in_x;
                    y_reg = data_in_y;
                    angle_reg = 32'sd0;
                end
                2'b01: begin
                    x_reg = data_in_y;
                    y_reg = -data_in_x;
                    angle_reg = 32'sh10000000;
                end
                2'b10: begin
                    x_reg = data_in_x;
                    y_reg = data_in_y;
                    angle_reg = 32'sh40000000;
                end
                2'b11: begin
                    x_reg = -data_in_x;
                    y_reg = -data_in_y;
                    angle_reg = 32'sh20000000;
                end
                default: begin
                    x_reg = data_in_x;
                    y_reg = data_in_y;
                    angle_reg = 32'sd0;
                end
            endcase
        end
    end

    assign x_pre = x_reg;
    assign y_pre = y_reg;
    assign angle_pre = angle_reg;
endmodule
