EXEC = ./miniCompiler
ICG = cd ICG && make
TOKEN = cd Token_Generator && make
CLEAN_ICG = cd ICG && make clean
CLEAN_TOKEN = cd Token_Generator && make clean

all:
	$(ICG) && cd .. && $(TOKEN)

run_icg:
	cd ICG && $(EXEC)

run_token:
	cd Token_Generator && $(EXEC)

clean:
	rm icg.txt quad.txt symbol_table.txt tokens.txt && $(CLEAN_ICG) && cd .. && $(CLEAN_TOKEN)