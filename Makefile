# Makefile for IbexDemoSystem simulation

# Load user-configurable settings
include Makefile.include

TARGET := T

DEFAULT_VMEM_PATH = ram.vmem
DEFAULT_VMEM_LIST_DIR = vmem
VMEM_LIST_PATH = $(sort $(wildcard $(DEFAULT_VMEM_LIST_DIR)/*.vmem))

BUILD_DIR_TEST := work_test
BUILD_DIR_REF := work_ref

BUILD_DIR := $(BUILD_DIR_REF)
RTL_DIR := $(RTL_DIR_REF)
RTL_FILE := $(RTL_FILE_REF)
TOP_MODULE := $(TOP_MODULE_REF)
VSIM_MEM_OBJ_PATH := $(VSIM_MEM_OBJ_PATH_REF)
RESULT_DIR := $(RESULT_DIR_REF)
OUTPUT_NAME := $(OUTPUT_NAME_REF)

ifeq ($(OS),Windows_NT)
SHELL := powershell.exe

RED = [31m
GREEN = [32m
YELLOW = [33m
RESET = [0m
else

RED = \033[31m
GREEN = \033[32m
YELLOW = \033[33m
RESET = \033[0m
endif

# Target
all_multiple: $(VMEM_LIST_PATH)

ifeq ($(TARGET),R)
MULTIPLE_RULE = update_ram simulate
else
MULTIPLE_RULE = update_test update_ram simulate
endif

define process_vmem
$(1):
	@echo "$(YELLOW)[MAKE] Running simulation: $(1)...$(RESET)"
	@$$(MAKE) $(MULTIPLE_RULE) VMEM_PATH=$(1) OUTPUT_NAME_REF=$(basename $(notdir $(1)))> /dev/null TARGET=$(2)
endef

# Generate rules for each .vmem file
$(foreach vmem_file,$(VMEM_LIST_PATH),$(eval $(call process_vmem,$(vmem_file),$(TARGET))))

ifeq ($(TARGET),R)
all: clean_sim update_ram simulate
else
all: update_test clean_sim update_ram simulate
endif


clean_sim:
	@echo "$(YELLOW)[MAKE] Cleaning previous simulation...$(RESET)"
	-rm -rf $(RESULT_DIR)
	@echo ""

update_test:
	$(eval BUILD_DIR = $(BUILD_DIR_TEST))
	$(eval RTL_DIR = $(RTL_DIR_TEST))
	$(eval RTL_FILE = $(RTL_FILE_TEST))
	$(eval TOP_MODULE = $(TOP_MODULE_TEST))
	$(eval VSIM_MEM_OBJ_PATH = $(VSIM_MEM_OBJ_PATH_TEST))
	$(eval RESULT_DIR = $(RESULT_DIR_TEST))
	$(eval OUTPUT_NAME = $(OUTPUT_NAME_TEST))

ifeq ($(TARGET),R)
build_simulation:
else
build_simulation: update_test
endif
	@echo "$(YELLOW)[MAKE] Cleaning directory $(CURDIR)/$(BUILD_DIR)...$(RESET)"
	-rm -rf $(BUILD_DIR)
	@echo ""
	@echo "$(YELLOW)[MAKE] Building simulation...$(RESET)"
	vsim -c -do " \
	vlog -work $(BUILD_DIR) -vopt -sv -stats=none -suppress all $(RTL_FILE); \
	quit"
	@echo ""

simulate:
	@echo "$(YELLOW)[MAKE] Creating directory: $(CURDIR)/$(RESULT_DIR)$(RESET)"
	-mkdir -p $(RESULT_DIR)

	@echo ""
	@echo ""
	@echo "$(YELLOW)[MAKE] Running simulation...$(RESET)"
	vsim -c -do " \
	vsim -c $(BUILD_DIR).$(TOP_MODULE) -voptargs=+acc; \
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
	@echo ""

update_ram:
	@echo "$(YELLOW)[MAKE] Updating RAM's content...$(RESET)"
	-cp $(VMEM_PATH) $(DEFAULT_VMEM_PATH)
	@echo ""

help:
	@echo "Opening help page..."
	@echo ""
	@echo "$(YELLOW)Usage for Reference Design:$(GREEN) make all TARGET=R [<parameter>=<value>] [<parameter>=<value>] ...$(RESET)"
	@echo "$(YELLOW)Usage for Test Design:     $(GREEN) make all TARGET=T [<parameter>=<value>] [<parameter>=<value>] ...$(RESET)"
	@echo "$(RED)Test Design must be configured in Makefile.include first$(RESET)"
	@echo ""
	@echo "$(YELLOW)List of $(GREEN)<parameter>$(YELLOW):$(RESET)"
	@echo "\tVMEM_PATH (default: $(VMEM_PATH)) (this parameter will permanently overwrite $(DEFAULT_VMEM_PATH))"
	@echo "\tSIMULATION_TIME (default: $(SIMULATION_TIME))"
	@echo ""
	@echo "$(RED)Note that the RAM's content must be put in $(DEFAULT_VMEM_PATH)$(RESET)"
	@echo "$(RED)$(DEFAULT_VMEM_PATH) will be automatically updated by $(VMEM_PATH) when run 'make all_ref' or 'make all_test'$(RESET)"
	@echo "$(YELLOW)Alternatively, you can set the default value for those parameters in Makefile.include$(RESET)"

# .PHONY: all all_ref all_test clean update_ram simulate update_ref help
