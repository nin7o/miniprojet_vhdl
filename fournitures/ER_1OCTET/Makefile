GHDL=ghdl
GHDLFLAGS=-fsynopsys --std=08
MODULES=\
    er_1octet.o \
	test_er_1octet_simple.o \
	test_er_1octet_automate.o

TIME1=1us
PLOT1=output1

TIME2=1us
PLOT2=output2

all: test1

test1: $(MODULES)
	$(GHDL) -e test_er_1octet1
	$(GHDL) -r $(GHDLFLAGS) test_er_1octet1 \
	--stop-time=${TIME1} \
	--vcd=${PLOT1}.vcd
       
test2: $(MODULES)
	$(GHDL) -e test_er_1octet2
	$(GHDL) -r $(GHDLFLAGS) test_er_1octet2 \
	--stop-time=${TIME2} \
	--vcd=${PLOT2}.vcd

# Object file depends on source
%.o: %.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

clean:
	echo "Cleaning up..."
	$(GHDL) --remove $(GHDLFLAGS)
#	rm -f ${PLOT}.vcd
