CXX=g++
CC=gcc
LIB=lib
INCLUDE=include
BUILDOUT=build
TESTS=tests
SRC=src
OBJ=$(BUILDOUT)/loader_demo

.PHONY: all clean
.PHONY: build

all: $(OBJ)

$(BUILDOUT)/loader.o: $(SRC)/loader.cc
	$(warning $(CXX) -std=c++11 -c $< -o $@  )
	$(CXX) -std=c++11 -c $< -o $@  
	
loader_demo: $(BUILDOUT)/loader.o $(SRC)/loader_demo.cc
	$(CXX) -std=c++11 -o $(BUILDOUT)/loader_demo \
		$(SRC)/loader_demo.cc \
		$(BUILDOUT)/loader.o \
		-lbfd -I /usr/local/include \
		-L /usr/local/lib \
		-lyaml-cpp
heapcheck.so: $(SRC)/heapcheck.c
	$(CC) -o $(BUILDOUT)/heapcheck.so -fPIC -shared -D_GNU_SOURCE $< -ldl
test_heapcheck: $(BUILDOUT)/heapcheck.so
	$(CC) -o $(TESTS)/heapoverflow -O2 -fno-builtin $(TESTS)/heapoverflow.c
	LD_PRELOAD=$(BUILDOUT)/heapcheck.so $(TESTS)/heapoverflow 13 `perl -e 'print "a" x 0x100'`
clean:
	rm -f $(OBJ) *.o

