MINISAT_LIBDIR = ../MiniSat-ocaml/_build

.PHONY: labyrinth all clean

all: labyrinth

labyrinth: data.ml labyrinth.ml
	ocamlopt -I $(MINISAT_LIBDIR) minisat.cmxa -o labyrinth $^

clean:
	rm -f *.cmi *.cmx *.o labyrinth
