module apb_slave (
    input  clk, rst_n,
    input  psel, penable, pwrite,
    input  [11:0] paddr,
    input  [31:0] pwdata,
    input  [3:0]  pstrb,
    output [31:0] prdata,
    output pready, pslverr,
    output wr_en, rd_en,
    output [11:0] addr,
    output [31:0] wdata,
    output [3:0]  byte_en,
    input  [31:0] rdata,
    input  wr_err
);
    reg r_setup, r_ready;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_setup <= 1'b0;
            r_ready <= 1'b0;
        end else begin
            r_setup <= psel & ~penable;
            r_ready <= psel & penable & r_setup & ~r_ready;
        end
    end
    assign pready  = r_ready;
    assign wr_en   = r_ready & pwrite;
    assign rd_en   = r_ready & ~pwrite;
    assign pslverr = r_ready & wr_err;
    assign addr    = paddr;
    assign wdata   = pwdata;
    assign byte_en = pstrb;
    assign prdata  = rd_en ? rdata : 32'h0;
endmodule
