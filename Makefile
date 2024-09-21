# Makefile for IbexDemoSystem simulation

# Load user-configurable settings
include Makefile.include

DEFAULT_VMEM_PATH = ram.vmem

RTL_DIR := $(RTL_DIR_REF)
RTL_FILE := $(RTL_FILE_REF)
TOP_MODULE := $(TOP_MODULE_REF)
VSIM_MEM_OBJ_PATH := $(VSIM_MEM_OBJ_PATH_REF)
RESULT_DIR := $(RESULT_DIR_REF)
OUTPUT_NAME := $(OUTPUT_NAME_REF)

RED = \033[31m
GREEN = \033[32m
YELLOW = \033[33m
RESET = \033[0m

# Target
all_test: clean update_test update_ram simulate
all_ref: clean update_ram simulate

clean:
	@echo "$(YELLOW)[MAKE] Cleaning previous simulation...$(RESET)"
	-rm -r work $(RESULT_DIR)

update_test:
	$(eval RTL_DIR = $(RTL_DIR_TEST))
	$(eval RTL_FILE = $(RTL_FILE_TEST))
	$(eval TOP_MODULE = $(TOP_MODULE_TEST))
	$(eval VSIM_MEM_OBJ_PATH = $(VSIM_MEM_OBJ_PATH_TEST))
	$(eval RESULT_DIR = $(RESULT_DIR_TEST))
	$(eval OUTPUT_NAME = $(OUTPUT_NAME_TEST))

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
	@echo ""
	@echo "$(YELLOW)Usage for Reference Design:$(GREEN) make all_ref [<parameter>=<value>] [<parameter>=<value>] ...$(RESET)"
	@echo "$(YELLOW)Usage for Test Design:     $(GREEN) make all_test [<parameter>=<value>] [<parameter>=<value>] ...$(RESET)"
	@echo "$(RED)Test Design must be configured in Makefile.include first$(RESET)"
	@echo ""
	@echo "$(YELLOW)List of $(GREEN)<parameter>$(YELLOW):$(RESET)"
	@echo "\tVMEM_PATH (default: $(VMEM_PATH)) (this parameter will permanently overwrite $(DEFAULT_VMEM_PATH))"
	@echo "\tSIMULATION_TIME (default: $(SIMULATION_TIME))"
	@echo ""
	@echo "$(RED)Note that the RAM's content must be put in $(DEFAULT_VMEM_PATH)$(RESET)"
	@echo "$(RED)$(DEFAULT_VMEM_PATH) will be automatically updated by $(VMEM_PATH) when run 'make all_ref' or 'make all_test'$(RESET)"
	@echo "$(YELLOW)Alternatively, you can set the default value for those parameters in Makefile.include$(RESET)"

.PHONY: all clean update_ram simulate help
