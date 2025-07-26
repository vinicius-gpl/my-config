LOCAL_INSTALL=/usr

.PHONY: generate_build

generate_build:
	cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$(LOCAL_INSTALL)
	cmake --build build --config Release
	sudo cmake --install build
