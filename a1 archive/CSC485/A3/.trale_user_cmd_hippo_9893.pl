:- compile_gram('q1_en.pl').
:- ale_flag(another,_,inf),translate_gen(en,((s),sem:(v_sem,obj:sem,subj:sem))),halt.
:- delete_file('/h/u5/c1/00/zhaoy239/csc485/A3/./.trale_user_cmd_hippo_9893.pl',[ignore]).
