# Fixed-Point Arithmetic & Newton-Raphson Division in Verilog

This project showcases the hardware implementation of fixed-point mathematical operations - Addition, Subtraction, Multiplication and Division by **Newton Raphson Iterations**. This project bridges the gap between numerical analysis and digital logic design, demonstrating how complex floating-point algorithms can be translated into fast, resource-efficient fixed-point hardware.

## Project Overview
This project is divided into two core hardware experiments:
1. **Fundamental Fixed-Point Arithmetic:** Implementing and verifying addition, subtraction, and multiplication in Verilog using customized Q-formats, and validating against a Python reference model.
2. **Hardware Division via Reciprocation:** Implementing a high-speed division datapath. Since division is notoriously resource-heavy in hardware, this project utilizes the **Newton-Raphson iteration** to compute reciprocals, achieving quadratic convergence.

## Tech Stack & Concepts
* **Languages:** Verilog (RTL), Python (Golden Reference Modeling)
* **Data Format:** Q4.28 Fixed-Point Representation
* **Key Algorithms:** Newton-Raphson Method, Minimax Approximations
* **Hardware Concepts:** Normalization, Shift-and-Add Optimization, Precision vs. Resource Trade-offs, Quantization Error Analysis.

## Newton-Raphson Division Architecture
To execute division as $A / B$, the hardware computes $A \times (1/B)$. The reciprocal $1/B$ is found iteratively.

### 1. Normalization
To ensure the Newton-Raphson method converges predictably, the denominator is dynamically shifted (normalized) to fall within the range $[0.5, 1.0)$. 

### 2. Initial Guess Generation
The speed of convergence heavily relies on the initial guess. I explored three hardware approximations to initialize the reciprocal:
* **Unconstrained Linear Minimax:** Standard mathematical approximation.
* **Constrained Linear (Hardware Optimized):** Forces the slope to an exact power of 2 (slope = -2), allowing the hardware to replace a costly multiplier with a simple bit-shift operation!
* **Quadratic Minimax:** Uses more hardware (DSP blocks) but significantly reduces the number of iterations required to converge.

### 3. Iterative Convergence & Precision
* The hardware iterates the Newton-Raphson formula: $x_{i+1} = x_i \times (2 - B \times x_i)$.
* **Precision Floor:** The hardware datapath utilizes a **32-bit Q(4,28)** format. Simulation results show the absolute error accurately converging to $3.72 \times 10^{-9}$ (the theoretical quantization limit of $2^{-28}$), cleanly matching the Python 64-bit floating-point reference model up to the precision limit.

## Verification
The Verilog modules were rigorously tested using Python scripts. The Python models generate the ideal outputs and calculate the Mean Absolute Error (MAE) between the 64-bit floating-point math and the hardware's 32-bit fixed-point outputs, proving the structural correctness of the RTL.

---
*Developed as part of the EE2801 DSP Lab Course.*
