# IBEX DEMO SYSTEM QUESTASIM SIMULATION

## **1. Quick Start**

### **1.1. Build Simulation**
- To build Simulation for Reference Design: `make build TARGET=R`
- To build Simulation for Test Design:      `make build TARGET=T`

### **1.2. Run Simulation**

- To run Reference Design from ram.vmem: `make all TARGET=R`
- To run Reference Design from vmem/*.vmem: `make all_multiple TARGET=R -B` (Require .vmem file in folder vmem/) (Currently support **Linux** only)
- To run Test Design, use `TARGET=T`. Run `make help` to configure Test Design

### **1.3. Clean everything**
- For Reference Design: `make clean_all TARGET=R`
- For Test Design:      `make clean_all TARGET=T`

## **2. Custom Configuration**

- Run `make help` and follow the instruction to start using this tool
