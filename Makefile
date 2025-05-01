all:
	nvcc -O2 -arch=sm_61 -o nbody src/main.cu src/init.cpp src/util.cpp -Iinclude

clean:
	rm -f nbody
