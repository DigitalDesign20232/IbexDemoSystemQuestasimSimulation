# Makefile for IbexDemoSystem simulation

# Load user-configurable settings
include Makefile.include

TARGET := T
STANDARD := None # Value: {None, S}

DEFAULT_LOG_FILE = log
DEFAULT_VMEM_PATH = ram.vmem
DEFAULT_VMEM_LIST_DIR = vmem
DEFAULT_VMEM_STANDARD_DIR = standard_ref/reference_vmem
VMEM_LIST_PATH = $(sort $(wildcard $(DEFAULT_VMEM_LIST_DIR)/*.vmem))
VMEM_DIR ?=

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
RM := rm -r -Force -ErrorAction SilentlyContinue
MKDIR := mkdir -Force
CP := cp -ErrorAction SilentlyContinue
MV := mv -Force

CURRENT_TIME_COMMAND := cmd /c echo %date%%time%


RED = [31m
GREEN = [32m
YELLOW = [33m
RESET = [0m
else
RM := rm -rf
MKDIR := mkdir -p
CP := cp
MV := mv -f

CURRENT_TIME_COMMAND := date


RED = \033[31m
GREEN = \033[32m
YELLOW = \033[33m
RESET = \033[0m
endif

ifeq ($(TARGET),R)
MULTIPLE_RULE = update_ram simulate
else
MULTIPLE_RULE = update_test update_ram simulate
endif

ifeq ($(STANDARD),S)
VMEM_DIR = $(DEFAULT_VMEM_STANDARD_DIR)
else
VMEM_DIR = $(DEFAULT_VMEM_LIST_DIR)
endif

# Target
ifeq ($(TARGET),R)
all: clean_sim update_ram simulate
else
all: update_test clean_sim update_ram simulate
endif

ifeq ($(TARGET),R)
all_multiple: clean_sim update_vmem
else
all_multiple: update_test clean_sim update_vmem
endif
	@echo "$(YELLOW)[MAKE] Creating directory: $(CURDIR)/$(RESULT_DIR)$(RESET)"
	$(MKDIR) "$(RESULT_DIR)"
	@echo ""
	@echo "$(YELLOW)[MAKE] Simulating...$(RESET)"

	@echo "vsim -c -do \"" > sim.sh
	@./sim-command-generate.sh $(BUILD_DIR) $(TOP_MODULE) $(SIMULATION_TIME) $(VSIM_MEM_OBJ_PATH) $(RESULT_DIR) $(VMEM_DIR) >> sim.sh
	@echo "quit\"" >> sim.sh
	@chmod +x sim.sh
	@./sim.sh | grep echo
	@rm -f sim.sh
	@./get_signature_addr.sh
	
	@echo ""
	@echo "$(GREEN)[MAKE] Simulation completed!$(RESET)"
	@echo "$(GREEN)[MAKE] Simulation result saved to folder $(RESULT_DIR)/$(RESET)"
	@echo "$(YELLOW)[MAKE] See result files with command: 'ls -v $(RESULT_DIR)/'$(RESET)"
	@echo "$(YELLOW)[MAKE] See simulation wave with command: 'gtkwave $(RESULT_DIR)/<filename>.vcd'$(RESET)"
	@echo ""

ifeq ($(TARGET),R)
clean:
else
clean: update_test
endif
	@echo "$(YELLOW)[MAKE] Cleaning everything...$(RESET)"
	-$(RM) "$(BUILD_DIR)"
	-$(RM) "$(RESULT_DIR)"
	-$(RM) "$(DEFAULT_LOG_FILE)"
	@echo ""

clean_sim:
	@echo "$(YELLOW)[MAKE] Cleaning previous simulation...$(RESET)"
	-$(RM) "$(RESULT_DIR)"
	@echo ""

clean_vmem:
	@echo "$(YELLOW)[MAKE] Cleaning folder $(DEFAULT_VMEM_LIST_DIR)...$(RESET)"
	-$(RM) "$(DEFAULT_VMEM_LIST_DIR)"
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
build:
else
build: update_test
endif
	@echo "$(YELLOW)[MAKE] Cleaning directory $(CURDIR)/$(BUILD_DIR)...$(RESET)"
	-$(RM) "$(BUILD_DIR)"
	@echo ""
	@echo "$(YELLOW)[MAKE] Building simulation...$(RESET)"
	vlog -work $(BUILD_DIR) -vopt -sv -stats=none -suppress all $(RTL_FILE)
	@echo ""

simulate:
	@echo "$(YELLOW)[MAKE] Creating directory: $(CURDIR)/$(RESULT_DIR)$(RESET)"
	$(MKDIR) "$(RESULT_DIR)"

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
	$(MV) "$(OUTPUT_NAME).mem" "$(RESULT_DIR)/"
	$(MV) "$(OUTPUT_NAME).vcd" "$(RESULT_DIR)/"
	$(MV) "transcript" "$(RESULT_DIR)/"

	@echo ""
	@echo ""
	@echo "$(GREEN)[MAKE] Simulation completed!$(RESET)"
	@echo "$(GREEN)[MAKE] Simulation result saved to folder $(RESULT_DIR)/$(RESET)"
	@echo "$(YELLOW)[MAKE] See result with command: 'ls $(RESULT_DIR)'$(RESET)"
	@echo "$(YELLOW)[MAKE] See simulation wave with command: 'gtkwave $(RESULT_DIR)/$(OUTPUT_NAME).vcd'$(RESET)"
	@echo ""

update_ram:
	@echo "$(YELLOW)[MAKE] Updating RAM's content...$(RESET)"
	-$(CP) "$(VMEM_PATH)" "$(DEFAULT_VMEM_PATH)"
	@echo ""

update_vmem:
	@echo "$(YELLOW)[MAKE] Updating folder $(DEFAULT_VMEM_LIST_DIR)/...$(RESET)"
	-$(CP) -rf $(VMEM_MULTIPLE_DIR)/*.vmem "$(DEFAULT_VMEM_LIST_DIR)" 2>/dev/null
	@echo ""

verify:
ifeq ($(STANDARD),S)
	@-./verify.sh "result_test" "signature" "standard_ref/reference_output" "reference_output"
else
	@-./verify.sh "result_test" "mem" "result_ref" "mem"
endif

help:
	@echo "Opening help page..."
	@echo ""
	@echo "$(YELLOW)Usage for Reference Design:         $(GREEN) make clean build all_multiple TARGET=R [<parameter>=<value>] [<parameter>=<value>] ...$(RESET)"
	@echo "$(YELLOW)Usage for Test Design:              $(GREEN) make clean build all_multiple TARGET=T [<parameter>=<value>] [<parameter>=<value>] ...$(RESET)"
	@echo "$(RED)Test Design must be configured in Makefile.include first$(RESET)"
	@echo "$(YELLOW)To verify Test with Reference:      $(GREEN) make verify -B"
	@echo "$(YELLOW)To verify Test with Standard:       $(GREEN) make verify STANDARD=S -B"
	@echo ""
	@echo "$(YELLOW)List of $(GREEN)<parameter>$(YELLOW):$(RESET)"
	@echo "\tVMEM_PATH (default: $(VMEM_PATH)) (this parameter will permanently overwrite $(DEFAULT_VMEM_PATH))"
	@echo "\tSIMULATION_TIME (default: $(SIMULATION_TIME))"
	@echo ""
	@echo "$(RED)Note that the RAM's content must be put in $(DEFAULT_VMEM_PATH)$(RESET)"
	@echo "$(RED)$(DEFAULT_VMEM_PATH) will be automatically updated by $(VMEM_PATH) when run 'make all' or 'make all_multiple'$(RESET)"
	@echo "$(YELLOW)Alternatively, you can set the default value for those parameters in Makefile.include$(RESET)"
