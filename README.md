# Trivium - Hardware Implementation

## Tools requirement

I advise you to use a virtualenv for Python packages installations.

### VHDL Simulation with `ghdl`

```bash
$ git clone https://github.com/ghdl/ghdl
$ cd ghdl/
$ ./configure --prefix=/usr/local
# Make to have gcc-ada or gcc-gnat installed
$ make
$ sudo make install
```
### Wave viewer with `gtkwave`

```bash
# I can install this one from my distribution package manager :o
$ sudo zypper install gtkwave
```

### Cosimulation with `cocotb`

```bash
$ pip install cocotb
```

### Additionnal Python packages

```bash
$ pip install pytrivium
```