CXX=g++
OBJ=loader_demo

.PHONY: all clean

all: $(OBJ)
loader.o: ./loader.hpp
	$(CXX) -std=c++11 -c ./loader.hpp

loader_demo: loader.o loader_demo.cc
	$(CXX) -std=c++11 -o loader_demo loader_demo.cc loader.o -lbfd -I/usr/local/include -L/usr/local/lib -lyaml-cpp

clean:
	rm -f $(OBJ) *.o

