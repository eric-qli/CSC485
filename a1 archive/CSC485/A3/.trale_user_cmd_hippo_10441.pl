:- compile_gram('q1_en.pl').
:- ale_flag(another,_,inf),translate_gen(en,((s),sem:(chase,obj:(sheep,quantity:(three)),subj:(student,quantity:(two))))),halt.
:- delete_file('/h/u5/c1/00/zhaoy239/csc485/A3/./.trale_user_cmd_hippo_10441.pl',[ignore]).
