EXEC = ./miniCompiler
ICG = cd ICG && make
TOKEN = cd Token_Generator && make
CLEAN_ICG = cd ICG && make clean
CLEAN_TOKEN = cd Token_Generator && make clean
RUN_ICG = cd ICG && ./miniCompiler
RUN_TOKEN = cd Token_Generator && ./miniCompiler
RUN_OPT = python Optimization.py

all:
	$(ICG) && cd .. && $(TOKEN)

run_icg:
	cd ICG && $(EXEC)

run_token:
	cd Token_Generator && $(EXEC)

run:
	$(RUN_ICG) && cd .. && $(RUN_TOKEN) && cd .. && $(RUN_OPT)

clean:
	rm *.txtm && $(CLEAN_ICG) && cd .. && $(CLEAN_TOKEN)