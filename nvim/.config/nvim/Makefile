SRC := $(shell fd --glob "*.fnl")
DEST := $(patsubst fnl/config/%.fnl,lua/config/%.lua,$(SRC))

all: $(DEST)

lua/config/%.lua: fnl/config/%.fnl
	fennel --compile $< > $@

list:
	@echo $(SRC)
	@echo $(DEST)
