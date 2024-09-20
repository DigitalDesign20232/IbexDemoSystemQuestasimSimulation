# Makefile for IbexDemoSystem simulation

# Load user-configurable settings
include Makefile.include

RESULT_DIR = result
DEFAULT_VMEM_PATH = ram.vmem

RED = \033[31m
GREEN = \033[32m
YELLOW = \033[33m
RESET = \033[0m

# Target
all: clean update_ram simulate

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
	vcd file $(OUTPUT_NAME).vcd; \
	vcd add -r /*; \
	run $(SIMULATION_TIME); \
	vcd flush; \
	vcd off; \
	mem save -o $(OUTPUT_NAME).mem -f mti -data hex -addr decimal -wordsperline 1 $(VSIM_MEM_OBJ_PATH); \
	quit"
	
	@echo ""
	@echo "$(YELLOW)[MAKE] Moving simulation results to $(CURDIR)/$(RESULT_DIR)$(RESET)"
	-mv $(OUTPUT_NAME).mem $(OUTPUT_NAME).vcd transcript $(RESULT_DIR)/

	@echo ""
	@echo ""
	@echo "$(GREEN)[MAKE] Simulation completed!$(RESET)"
	@echo "$(GREEN)[MAKE] Simulation result saved to folder $(RESULT_DIR)/$(RESET)"
	@echo "$(YELLOW)[MAKE] See result with command: 'ls $(RESULT_DIR)'$(RESET)"
	@echo "$(YELLOW)[MAKE] See simulation wave with command: 'gtkwave $(RESULT_DIR)/$(OUTPUT_NAME).vcd'$(RESET)"
	
update_ram:
	@echo ""
	@echo "$(YELLOW)[MAKE] Updating RAM's content...$(RESET)"
	-mv $(VMEM_PATH) $(DEFAULT_VMEM_PATH)

help:
	@echo "Opening help page..."
	@echo "Usage:$(GREEN) make all [PARAMETER=VALUE] [PARAMETER=VALUE]...$(RESET)"
	@echo ""
	@echo "$(YELLOW)List of available Parameters:$(RESET)"
	@echo "\tRTL_FILE (default: $(RTL_FILE))"
	@echo "\tTOP_MODULE (default: $(TOP_MODULE))"
	@echo "\tVSIM_MEM_OBJ_PATH (default: $(VSIM_MEM_OBJ_PATH))"
	@echo "\tOUTPUT_NAME (default: $(OUTPUT_NAME))"
	@echo "\tVMEM_PATH (default: $(VMEM_PATH))"
	@echo "\tSIMULATION_TIME (default: $(SIMULATION_TIME))"
	@echo ""
	@echo "$(RED)Note that the RAM's content must be put in ram.vmem$(RESET)"
	@echo "$(RED)To update ram content, run command: $(GREEN)'make update_ram VMEM_PATH=<path/to/vmem/file>'$(RESET)"
	@echo "$(YELLOW)Alternatively, you can set the default value for those parameters in Makefile.include$(RESET)"

.PHONY: all clean update_ram simulate help
