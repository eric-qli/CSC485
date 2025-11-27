:- compile_gram('q2_zh.pl').
:- ale_flag(another,_,inf),translate_gen(zh,((s),sem:(take),logic:(forall,bind:(qvar,A0),body:(imply,lhs:(app,args:(ne_list,hd:A0,tl:(e_list)),f:(course)),rhs:(exists,bind:(qvar,A1),body:(and,lhs:(app,args:(ne_list,hd:A1,tl:(e_list)),f:(student)),rhs:(app,args:(ne_list,hd:A1,tl:(ne_list,hd:A0,tl:(e_list))),f:(take)))))))),halt.
:- delete_file('/h/u5/c1/00/zhaoy239/csc485/A3/./.trale_user_cmd_hippo_62712.pl',[ignore]).
