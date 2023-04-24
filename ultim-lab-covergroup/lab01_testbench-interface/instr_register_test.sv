/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/
`timescale 1ns/1ns

module instr_register_test
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (input  logic          clk,
   output logic          load_en,
   output logic          reset_n,
   output operand_t      operand_a,
   output operand_t      operand_b,
   output opcode_t       opcode,
   output address_t      write_pointer,
   output address_t      read_pointer,
   input  instruction_t  instruction_word
  );
  parameter NUMBER_OF_TRANSACTIONS = 5;
  parameter SEED = 555;
  parameter RND_CASE = 0;
  parameter TEST_NAME = "N/A";
  int wrong = 0;
  int seed=SEED;
  result_t result;

  initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles
    reset_n        = 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge clk) load_en = 1'b1;  // enable writing to register
    repeat (NUMBER_OF_TRANSACTIONS) begin // nr tranzactii
      @(posedge clk) randomize_transaction;
      @(negedge clk) print_transaction;
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    for (int i=0; i<NUMBER_OF_TRANSACTIONS; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      if (RND_CASE == 0 || RND_CASE == 2)
        @(posedge clk) read_pointer = i;
      else
        @(posedge clk) read_pointer = $unsigned($random)%32;
      @(negedge clk) print_results;
      check_result;
    end

    @(posedge clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $display("\nRunned test %s", TEST_NAME);
    if (wrong == 0)
      $display("Result: test passed");
    else
      $display("Result: test failed");
    $finish;
  end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0;
    operand_a     <= $random(seed)%16;                 // between -15 and 15
    operand_b     <= $unsigned($random)%16;            // between 0 and 15
    opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
    if (RND_CASE == 0 || RND_CASE == 1)
       write_pointer <= temp++;
    else
      write_pointer <= $unsigned($random)%32;
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name);
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d", instruction_word.op_b);
    $display("  result = %0d\n", instruction_word.rez);
  endfunction: print_results

  function void check_result;
    result = 'x;
    unique case (instruction_word.opc)
      ZERO: result = 0;
      PASSA: result = instruction_word.op_b; // TODO: change this in order to pass tests
      PASSB: result = instruction_word.op_b;
      ADD: result = instruction_word.op_a + instruction_word.op_b;
      SUB: result = instruction_word.op_a - instruction_word.op_b;
      MULT: result = instruction_word.op_a * instruction_word.op_b;
      DIV: result = instruction_word.op_a / instruction_word.op_b;
      MOD: result = instruction_word.op_a % instruction_word.op_a;
    endcase

    if (instruction_word.rez != result)
      wrong++;
  endfunction: check_result

/* //covergroup declaration
  covergroup coverage_calc;
  cov_p1: coverpoint tbintf.operand_a
                              {
                                bins op_a_max = {15};
                                bins op_a_zero = {0};
                                bins op_a_min = {-15};
                              }
  cov_p2: coverpoint tbintf.operand_b 
                             {
                                bins op_b_max = {15};
                                bins op_b_zero = {0};
                                bins op_b_min = {-15};
                              }
  cov_p3: coverpoint tbintf.opcode; 
  endgroup
  //cg variable declaration
  coverage_calc  cov_calc;*/
  // cov_calc.sample();

endmodule: instr_register_test