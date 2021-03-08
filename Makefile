prog: lex.yy.c jecode.tab.c  symbole_table.c symbole_table.h utilities.c utilities.h quadruples.c quadruples.h
	gcc lex.yy.c jecode.tab.c  symbole_table.c utilities.c quadruples.c -ll -ly -o prog

lex.yy.c: jecode.l 
	flex jecode.l
jecode.tab.c: jecode.y
	bison -d jecode.y

code: prog code.jc
	./prog < code.jc
code_with_errors: prog code_with_errors.jc
	./prog < code_with_errors.jc

clean: 
	rm -rf lex.yy.c jecode.tab.c jecode.tab.h prog quadruplets.txt

