################################################################################
# Timer IP 64-bit (Advance) – Simulation Makefile
# Tool : Questa Intel FPGA Edition (vlog / vsim / vcover)
# Usage: make TESTNAME=<testcase_name> all        # build + run
#        make TESTNAME=<testcase_name> all_cov    # build + run with coverage
#        make gen_cov                             # merge + exclude + report
################################################################################

TESTNAME     ?= reg_init_chk
TB_NAME      ?= test_bench
RADIX        ?= decimal
REGRESS_LIST ?= pat.list

#==============================================================================
all: build run

all_wave: build run wave

all_cov: build_cov run_cov

#-- Build (no coverage) -------------------------------------------------------
build:
	mkdir -p log
	cp -rf ../testcases/$(TESTNAME).v run_test.v
	vlib work
	vmap work work
	vlog -f compile.f | tee compile.log

#-- Build (with coverage) -----------------------------------------------------
build_cov:
	mkdir -p log
	cp -rf ../testcases/$(TESTNAME).v run_test.v
	vlib work
	vmap work work
	vlog +cover=bcesft -f compile.f

#-- Run -----------------------------------------------------------------------
run:
	vsim -debugDB -l $(TESTNAME).log -voptargs=+acc -assertdebug \
	     -c $(TB_NAME) -do "log -r /*;run -all;"
	cp $(TESTNAME).log ./log
	mv $(TESTNAME).log sim.log

#-- Run with coverage ---------------------------------------------------------
run_cov:
	vsim -coverage -l $(TESTNAME).log -c $(TB_NAME) \
	     -voptargs="+cover=bcesft" -assertdebug \
	     -do "coverage save -onexit $(TESTNAME).ucdb; log -r /*;run -all"
	cp $(TESTNAME).log ./log

#-- Waveform ------------------------------------------------------------------
wave:
	vsim -i -view vsim.wlf \
	     -do "add wave vsim:/$(TB_NAME)/*; radix -$(RADIX)" &

#-- Merge + exclude + report --------------------------------------------------
gen_cov:
	mkdir -p coverage
	rm -f IP.ucdb IP_excl.ucdb
	vcover merge IP.ucdb *.ucdb
	vsim -viewcov IP.ucdb -do "\
	  coverage exclude -scope /test_bench -code bcest;\
	  coverage exclude -scope /test_bench/dut/u_register -code c -linerange 58-58;\
	  coverage exclude -scope /test_bench/dut/u_register -code c -linerange 68-68;\
	  coverage exclude -scope /test_bench/dut/u_apb_slave -code e;\
	  coverage exclude -scope /test_bench/dut/u_register -code bc;\
	  coverage exclude -scope /test_bench/dut -code t;\
	  coverage exclude -scope /test_bench/dut/u_register -code e;\
	  coverage save IP_excl.ucdb;\
	  exit"
	vcover report IP_excl.ucdb \
	       -output coverage/summary_report.txt
	vcover report -zeros -details -code bcesft -annotate -All -codeAll \
	       IP_excl.ucdb -output coverage/detail_report.txt

#-- HTML report ---------------------------------------------------------------
gen_html:
	mkdir -p coverage
	vcover merge IP.ucdb *.ucdb
	vcover report -zeros -details -code bcesft \
	       -annotate -testhitdataAll -html IP.ucdb

#-- Clean ---------------------------------------------------------------------
clean:
	rm -rf work vsim.dbg *.ini *.log *.wlf transcript *.ucdb run_test.v

#-- Help ----------------------------------------------------------------------
help:
	@echo ""
	@echo "****************************************"
	@echo "** make clean      : clean compiled data"
	@echo "** make build      : build the design"
	@echo "** make build_cov  : build with coverage"
	@echo "** make run        : run simulation"
	@echo "** make run_cov    : run with coverage"
	@echo "** make all        : build + run"
	@echo "** make all_cov    : build + run (cov)"
	@echo "** make wave       : open waveform"
	@echo "** make gen_cov    : merge + report"
	@echo "** make gen_html   : html coverage report"
	@echo "****************************************"
	@echo ""
