CXX=g++
CC=gcc
AS=nasm
LIB=lib
INCLUDE=include
BUILDOUT=build
TESTS=tests
SRC=src
OBJ=$(BUILDOUT)/loader_demo

.PHONY: all clean
.PHONY: build
.PHONY: test

all: $(OBJ)

$(BUILDOUT)/loader.o: $(SRC)/loader.cc
	$(warning $(CXX) -std=c++11 -c $< -o $@  )
	$(CXX) -std=c++11 -c $< -o $@  
hello.bin: $(TESTS)/hello.s
	$(AS) -f bin -o $(TESTS)/hello.bin $(TESTS)/hello.s
loader_demo: $(BUILDOUT)/loader.o $(SRC)/loader_demo.cc
	$(CXX) -std=c++11 -o $(BUILDOUT)/loader_demo \
		$(SRC)/loader_demo.cc \
		$(BUILDOUT)/loader.o \
		-lbfd -I /usr/local/include \
		-L /usr/local/lib \
		-lyaml-cpp
heapcheck.so: $(SRC)/heapcheck.c
	$(CC) -o $(BUILDOUT)/heapcheck.so -fPIC -shared -D_GNU_SOURCE $< -e DoCheck 
elfinject: $(SRC)/elfinject.c
	$(CC) -o $(BUILDOUT)/elfinject -O2 $(SRC)/elfinject.c -lelf
test_heapcheck: $(BUILDOUT)/heapcheck.so
	$(CC) -o $(TESTS)/heapoverflow -O2 -fno-builtin $(TESTS)/heapoverflow.c
	LD_PRELOAD=$(BUILDOUT)/heapcheck.so $(TESTS)/heapoverflow 13 `perl -e 'print "a" x 0x100'`
test_elfinject: $(BUILDOUT)/elfinject $(TESTS)/hello.bin
	@cp /bin/ls ./test
	@$(BUILDOUT)/elfinject ./test hello.bin ".injected" 0x800000 0
	@./test | grep "hello world!" > /dev/null
	#@rm -f ./test
	@echo "******* ALL TESTS PASSED *******"
test: 
	make test_heapcheck
	@echo "******* ALL TESTS PASSED *******"
clean:
	rm -f $(OBJ) *.o

