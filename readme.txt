-Le projet a été fait sur Mac Os Catalina et devrait marcher sur linux
-Le fichier code.jc contient un code bien écrit dans le langage jeCode. 
-Le fichier code_with_errors.jc contient un code avec des erreurs dans le langage jeCode.

Pour les tester:
a)Si vous avez installer make pour le fichier Makefile, lancez les commandes dans cet ordre
    1)make
    Pour tester code.jc,lancez cette commande
        2)make code
    Pour tester code_with_errors.jc,lancez cette commande
        2)make code_with_errors
    Pour revenir à l'état initial du projet,lancez cette commande
    3)make clean

b) Si vous n'avez pas installez make pour le fichier Makefile, lancez les commandes suivantes:
    1)bison -d jecode.y
    2)flex jecode.l
    3)gcc lex.yy.c jecode.tab.c symbole_table.c linked_list_identifier.c utilities.c -ll -ly  -o prog
    Pour tester code.jc,lancez cette commande
        4)./prog < code.jc  
    Pour tester code_with_errors.jc,lancez cette commande
        4)./prog < code_with_errors.jc  
    Pour revenir à l'état initial du projet,lancez cette commande
    5)rm -rf lex.yy.c jecode.tab.c jecode.tab.h prog
