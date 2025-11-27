:- compile_gram('q1_en.pl').
:- ale_flag(another,_,inf),translate_gen(en,((s),sem:(see,obj:(wolf,quantity:(two)),subj:(student,quantity:(three))))),halt.
:- delete_file('/h/u5/c1/00/zhaoy239/csc485/A3/./.trale_user_cmd_hippo_7081.pl',[ignore]).
