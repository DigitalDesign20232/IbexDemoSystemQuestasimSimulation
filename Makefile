# Makefile for IbexDemoSystem simulation

# Load user-configurable settings
include Makefile.include

RESULT_DIR = result

RED = \033[31m
GREEN = \033[32m
YELLOW = \033[33m
RESET = \033[0m

# Target
all: clean simulate

clean:
	@echo "$(YELLOW)[MAKE] Cleaning previous simulation...$(RESET)"
	-rm -r work $(RESULT_DIR)

simulate:
	@echo ""
	@echo "$(YELLOW)[MAKE] Creating directory: $(CURDIR)/$(RESULT_DIR)$(RESET)"
	-mkdir $(RESULT_DIR)

	@echo ""
	@echo ""
	@echo "$(YELLOW)[MAKE] Running simulation...$(RESET)"
	vsim -c -do " \
	vlog -work work -vopt -sv -stats=none -suppress all $(RTL_FILE); \
	vsim -c work.$(TOP_MODULE) -voptargs=+acc; \
	log -r /*; \
	run $(SIMULATION_TIME); \
	mem save -o $(OUTPUT_MEM_FILE) -f mti -data hex -addr decimal -wordsperline 1 $(VSIM_MEM_OBJ_PATH); \
	quit"

	mv $(OUTPUT_MEM_FILE) *.wlf transcript $(RESULT_DIR)/

	@echo ""
	@echo ""
	@echo "$(GREEN)[MAKE] Simulation completed!$(RESET)"
	@echo "$(YELLOW)[MAKE] See result with commands: 'ls result'$(RESET)"

help:
	@echo "Opening help page..."
	@echo "$(GREEN)Usage:$(RESET) make all [PARAMETER=VALUE][PARAMETER=VALUE]..."
	@echo ""
	@echo "$(YELLOW)List of available Parameters:$(RESET)"
	@echo "\tRTL_FILE (default: $(RTL_FILE))"
	@echo "\tTOP_MODULE (default: $(TOP_MODULE))"
	@echo "\tVSIM_MEM_OBJ_PATH (default: $(VSIM_MEM_OBJ_PATH))"
	@echo "\tOUTPUT_MEM_FILE (default: $(OUTPUT_MEM_FILE))"
	@echo "\tSIMULATION_TIME (default: $(SIMULATION_TIME))"
	@echo ""
	@echo "$(RED)Note that the RAM's content must be put in ram.vmem$(RESET)"
	@echo "$(YELLOW)Alternatively, you can set the default value for those parameters in Makefile.include$(RESET)"

.PHONY: all clean simulate help
