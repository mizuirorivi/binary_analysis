CXX=g++
CC=gcc
AS=nasm
LIB=lib
INCLUDE=include
BUILDOUT=build
TESTS=tests
SRC=src
OBJ=$(BUILDOUT)/loader_demo
TEST_HEAPCHECK_SO=$(TESTS)/test_heapcheck_so
TEST_LOADER=$(TESTS)/test_loader
TEST_ELFINJECT=$(TESTS)/test_elfinject
.PHONY: all clean
.PHONY: build
.PHONY: test

all:  loader hello.bin loader_demo heapcheck.so elfinject test_elfinject heapoverflow
loader: $(SRC)/loader.cc
	$(warning $(CXX) -std=c++11 -c $< -o $(BUILDOUT)/$@.o  )
	$(CXX) -std=c++11 -c $< -o $(BUILDOUT)/$@.o  
hello.bin: $(TEST_ELFINJECT)/hello.s
	$(AS) -f bin -o $(TEST_ELFINJECT)/hello.bin $(TEST_ELFINJECT)/hello.s
loader_demo: $(BUILDOUT)/loader.o $(SRC)/loader_demo.cc
	$(CXX) -std=c++11 -o $(BUILDOUT)/loader_demo \
		$(SRC)/loader_demo.cc \
		$(BUILDOUT)/loader.o \
		-lbfd -I /usr/local/include \
		-L /usr/local/lib \
		-lyaml-cpp
heapcheck.so: $(SRC)/heapcheck.c
	$(CC) -o $(BUILDOUT)/heapcheck.so -fPIC -shared -D_GNU_SOURCE $< 
elfinject: $(SRC)/elfinject.c
	$(CC) -o $(BUILDOUT)/elfinject -O2 $(SRC)/elfinject.c -lelf
test_elfinject: $(BUILDOUT)/elfinject $(TEST_ELFINJECT)/hello.bin
	@cp /bin/ls ./test
	@$(BUILDOUT)/elfinject ./test $(TEST_ELFINJECT)/hello.bin ".injected" 0x800000 0
	@./test | grep "hello world!" > /dev/null
	@rm -f ./test
heapoverflow: $(TEST_HEAPCHECK_SO)/heapoverflow.c
	$(CC) -o $(TEST_HEAPCHECK_SO)/heapoverflow -O2 $(TEST_HEAPCHECK_SO)/heapoverflow.c -lelf
clean:
	rm -f $(OBJ) *.o