CXX=g++
LIB=./lib
INCLUDE=./include
BUILDOUT=./build
TESTS = ./tests
OBJ=$(BUILDOUT)/loader_demo
.PHONY: all clean

all: $(OBJ)

$(BUILDOUT)/loader.o: $(LIB)/loader.hpp
	$(warning $(CXX) -std=c++11 -c $< -o $@  )
	$(CXX) -std=c++11 -c $< -o $@  
	

loader_demo: $(BUILDOUT)/loader.o $(TESTS)/loader_demo.cc
	$(warning $(CXX) -std=c++11 -o $(BUILDOUT)/loader_demo $(TESTS)/loader_demo.cc $(BUILDOUT)/loader.o -lbfd -I /usr/local/include -L /usr/local/lib -lyaml-cpp)
 	#$(CXX) -std=c++11 -o $(BUILDOUT)/loader_demo $(TESTS)/loader_demo.cc $(BUILDOUT)/loader.o -lbfd -I /usr/local/include -L /usr/local/lib -lyaml-cpp
clean:
	rm -f $(OBJ) *.o

