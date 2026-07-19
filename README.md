# I2C-Master-Slave-Controller
RTL implementation of an I2C Master-Slave Controller in Verilog HDL featuring START/STOP generation, ACK/NACK handling, repeated START, multi-byte read/write transactions, open-drain SDA interface, and behavioral verification in Vivado.

# I2C Master-Slave Controller in Verilog HDL

## Overview

This project presents a complete RTL implementation of the Inter-Integrated Circuit (I2C) communication protocol using Verilog HDL. The design includes both an I2C Master and an I2C Slave communicating through an open-drain bidirectional SDA bus with a generated SCL clock.

The controller supports multi-byte write and read transactions, repeated START conditions, ACK/NACK handling, and protocol verification using behavioral simulation in Xilinx Vivado.

---

## Features

- I2C Master Controller
- I2C Slave Controller
- Open-Drain SDA Interface
- Clock Divider for SCL Generation
- START Condition
- STOP Condition
- Repeated START
- ACK/NACK Detection and Generation
- 7-bit Slave Address Detection
- Multi-byte Write Transaction
- Multi-byte Read Transaction
- FSM-Based Protocol Control
- Behavioral Simulation and Verification

---

## Project Structure

```
rtl/
│── i2c_master.v
│── i2c_slave.v
│── clock_divider_I2C.v
│── top_i2c.v

tb/
│── tb_I2C.v


```

---

## Protocol Flow

### Write Transaction

```
START
↓
Address + Write
↓
ACK
↓
Data Byte 1
↓
ACK
↓
Data Byte 2
↓
ACK
```

### Read Transaction

```
Repeated START
↓
Address + Read
↓
ACK
↓
Data Byte 1
↓
Master ACK
↓
Data Byte 2
↓
Master NACK
↓
STOP
```

---

## Modules

| Module | Description |
|---------|-------------|
| clock_divider_I2C | Generates SCL from the system clock |
| i2c_master | Implements the I2C Master protocol |
| i2c_slave | Implements the I2C Slave protocol |
| top_i2c | Integrates the complete design |
| tb_I2C | Behavioral testbench |

---

## Concepts Implemented

- RTL Design
- Finite State Machines (FSM)
- Bidirectional (`inout`) Interfaces
- Open-Drain Communication
- Shift Registers
- Address Decoder
- Bit and Byte Counters
- Clock Division
- Multi-byte Data Transfer
- Protocol Verification

---

## Tools Used

- Verilog HDL
- Xilinx Vivado
- Behavioral Simulation

---

## Future Enhancements

- Clock Stretching
- Multi-Slave Support


---

## Author

**T. Sathwik**

B.Tech in Electronics and Communication Engineering

Interests: RTL Design • Processor Design • ASIC Design • Digital Systems
