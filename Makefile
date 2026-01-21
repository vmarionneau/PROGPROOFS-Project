
#WHY3=/home/andrei/prj/why3-master/bin/why3
WHY3=why3

default:
	@echo 'type `make <target>` where <target> is either ide, replay, test or doc'

ide:
	${WHY3} ide dpll.mlw

replay:
	${WHY3} replay dpll

test:
	${WHY3} extract -D ocaml64 dpll.mlw -o dpll.ml
	ocamlbuild -pkg unix -pkg zarith test_dpll.native
	sh ./check ./test_dpll.native

unit_test:
	${WHY3} extract -D ocaml64 dpll_unit.mlw -o dpll.ml
	ocamlbuild -pkg unix -pkg zarith test_dpll.native
	sh ./check ./test_dpll.native

doc:
	${WHY3} doc dpll.mlw
	${WHY3} session html dpll

