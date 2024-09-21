# IBEX DEMO SYSTEM QUESTASIM SIMULATION

## **1. Quick Start**

### **1.1. Build Simulation**
- To build Simulation for Reference Design: `make build_simulation TARGET=R`
- To build Simulation for Test Design:      `make build_simulation TARGET=T`

### **1.2. Run Simulation**

- To run Reference Design from ram.vmem: `make all TARGET=R`
- To run Reference Design from vmem/*.vmem: `make all_multiple TARGET=R` (Require .vmem file in folder vmem/)
- To run Test Design, use `TARGET=T`. Run `make help` to configure Test Design

## **2. Custom Configuration**

- Run `make help` and follow the instruction to start using this tool
