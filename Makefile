ASM = gpasm
SRC = src/pulseforge.asm
OUT = build/pulseforge.hex

all: $(OUT)

$(OUT): $(SRC)
	mkdir -p build
	$(ASM) -p p16f877a -o $(OUT) $(SRC)

clean:
	rm -rf build
.PHONY: all clean
