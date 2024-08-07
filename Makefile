REBAR := rebar3

all: compile

compile:
	${REBAR} compile

clean:
	${REBAR} clean skip_deps=true
	rm -f src/mysql_parser.erl
	rm -f src/sql92_parser_int.erl
	rm -f src/sql92_scan.erl
	rm -rf _build

test:
	${REBAR} do xref, eunit, cover

.PHONY: test compile clean all
