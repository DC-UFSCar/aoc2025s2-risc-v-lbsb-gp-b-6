module mem (
  input         clk, we,
  input  [31:0] a, wd,
  output reg [31:0] rd,
  input   [3:0] wm);

  reg [31:0] RAM [0:255];
  reg [31:0] current_data;
  reg [31:0] new_data;

  // initialize memory with instructions or data
  initial
    $readmemh("riscv.hex", RAM);

  // Read logic
  always @(*) begin
    current_data = RAM[a[31:2]];
    
    // Extrair a parte relevante baseado no endereço
    case (a[1:0])
      2'b00: begin
        if (wm == 4'b0001) rd = {{24{current_data[7]}}, current_data[7:0]};
        else if (wm == 4'b0011) rd = {{16{current_data[15]}}, current_data[15:0]};
        else rd = current_data;
      end
      2'b01: begin
        if (wm == 4'b0001) rd = {{24{current_data[15]}}, current_data[15:8]};
        else if (wm == 4'b0011) rd = {{16{current_data[23]}}, current_data[23:8]};
        else rd = current_data;
      end
      2'b10: begin
        if (wm == 4'b0001) rd = {{24{current_data[23]}}, current_data[23:16]};
        else if (wm == 4'b0011) rd = {{16{current_data[31]}}, current_data[31:16]};
        else rd = current_data;
      end
      2'b11: begin
        if (wm == 4'b0001) rd = {{24{current_data[31]}}, current_data[31:24]};
        else rd = current_data;
      end
    endcase
  end

  // Write logic - ABORDAGEM DIRETA
  always @(posedge clk) begin
    if (we) begin
      current_data = RAM[a[31:2]];
      new_data = current_data;
      
      // Substituir apenas os bytes indicados pela máscara
      if (wm[0]) new_data[7:0]   = wd[7:0];
      if (wm[1]) new_data[15:8]  = wd[15:8]; 
      if (wm[2]) new_data[23:16] = wd[23:16];
      if (wm[3]) new_data[31:24] = wd[31:24];
      
      RAM[a[31:2]] <= new_data;
      
      // Debug
      $display("MEM WRITE: addr=%h wd=%h wm=%b old=%h new=%h", 
               a, wd, wm, current_data, new_data);
    end
  end
endmodule