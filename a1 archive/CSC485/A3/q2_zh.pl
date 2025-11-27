% Student name: Yinuo Zhao
% Student number: 1007672494
% UTORid: zhaoy239

% This code is provided solely for the personal and private use of students
% taking the CSC485H/2501H course at the University of Toronto. Copying for
% purposes other than this use is expressly prohibited. All forms of
% distribution of this code, including but not limited to public repositories on
% GitHub, GitLab, Bitbucket, or any other online platform, whether as given or
% with any changes, are expressly prohibited.

% Authors: Ken Shi, Jingcheng Niu and Gerald Penn

% All of the files in this directory and all subdirectories are:
% Copyright (c) 2024 University of Toronto

:- ensure_loaded(csc485).
:- ale_flag(pscompiling, _, parse_and_gen).
lan(zh).
question(q2).

% Type Feature Structure

% Do not modify.
bot sub [cat, sem, list, logic, gap_struct, agr].
    cat sub [gappable, agreeable, dou] intro [logic:logic, qstore:list].
        gappable sub [verbal, n, np, n_np_vp] intro [gap:gap_struct, sem:sem].
            verbal sub [vp, s, v] intro [subcat:list].

        agreeable sub [cl_agreeable, q_agreeable, n_np_vp] intro [agr:agr].
            cl_agreeable sub [cl, n] intro [agr:cl_agr].
            q_agreeable sub [np_vp, q] intro [agr:quant].

        n_np_vp sub [n, np_vp].
            np_vp sub [np, vp].

        n intro [cl:cl].
    % Chinese only
    agr sub [cl_agr, quant].
        cl_agr sub [ge, zhong].

    gap_struct sub [none, np].

    sem sub [student, course, take].

    list sub [e_list, ne_list].
        ne_list intro [hd:bot, tl:list].

    logic sub [free, scopal].
        scopal sub [lambda, quant] intro [bind:logic, body:logic].
            quant sub [exists, forall] intro [bind:qvar].
        free sub [op, app, qvar].
            op sub [and, imply] intro [lhs:logic, rhs:logic].
            app intro [f:func, args:list].
    func sub [lambda, sem].

    qs intro [l:logic, x:logic].


% Recommended implementation strategy:
% 
% 1. Implement the grammar rules for parsing.
%    At this stage, you don't need to specify the logic feature.  Make sure that
%    subcategorization and gap are properly implemented.  All the grammatical
%    sentences should get a correct parse, and all the ungrammatical ones should
%    be rejected.
% 
% 2. Implement the surface quantifier scope reading.
%    When you are confident that your syntactic rules are correct.  You can move
%    on to quantifier scope.  Specify the logic form of each lexical entry with
%    the macros provided.  Then, for the rules, implement the beta reduction rules
%    to get the surface reading.  You won't need the quantifier actions 
%    (`store`, `retrieve`, `qaction`) yet.
% 
% 3. Implement quantifier storage.
%    When you can get the correct surface readings, you can implement the
%    quantifier storage to model the ambiguity.  You will need to augment the
%    grammar rules with the quantifier actions.  Make sure that quantifier storage
%    does not break your previous progress.
% 
% 4. Evaluate with translation.
%    Translation should be the final step.  If all your previous steps are
%    correct, you should get a smooth translation.


% Lexicon

% mei: every
mei ---> (q,
    agr:forall,
    % === Your Code ===
    % logic:none,
    logic:
    @lambda(F,
        @lambda(P,
            @forall(Y, 
                @apply(F, [Y]),
                @apply(P, [Y])))),
    % === ========= ===
    qstore:[]).

% yi: one
yi ---> (q,
    agr:exists,
    % === Your Code ===
    % logic:none,
    % === ========= ===
    logic:
    @lambda(F, 
        @lambda(P, 
            @exists(Y, 
                @apply(F, [Y]),
                @apply(P, [Y])))),
    qstore:[]).

% ge: classifier
ge ---> (cl, agr:ge).

% zhong: classifier
zhong ---> (cl, agr:zhong).

% dou: the distributive operator
dou ---> dou.

% kecheng: course
kecheng ---> (n,
    agr:zhong,
    sem:(course, Course),
    % === Your Code ===
    % logic:none,
    % === ========= ===
    logic:
    @lambda(X,
        @apply(Course, [X])),
    qstore:[]).

% xuesheng: student
xuesheng ---> (n,
    agr:ge,
    sem:(student, Student),
    % === Your Code ===
    % logic:none,
    logic:
    @lambda(X, 
        @apply(Student, [X])),
    % === ========= ===
    qstore:[]).

% huishang: take
huishang ---> (v,
    sem:(take, Take),
    % === Your Code ===
    % logic:none,
    % subcat:[...], % the subcat list should not be empty
    logic:
    @lambda(Q, 
        @lambda(Z,
            @apply(Q,
                [@lambda(X, 
                    @apply(Take, [Z, X]))]))),
    subcat: [(Obj, (np,sem:course)), (Subj, (np,sem:student))],
    % === ========= ===
    qstore:[]).

% Rules

% Complete the code below.
np rule     
    % (np, ...) ===>  每个学生
    % cat> (q, ...),
    % cat> (cl, ...),
    % sem_head> (n, ...),
    % goal> ... Hint: How many goals do we have?
    % === Your Code ===
    (np, sem:Sem, logic: NewLogic, agr:Quant, gap:(none, None), qstore:NewQstore) ===>
    cat> (q, agr:Quant, logic:Log_q),
    cat> (cl, agr:CL),
    sem_head> (n, sem:Sem, agr:CL, logic:Log_n),
    goal>beta_normalize(@apply(Log_q, [Log_n]), Log_np),
    goal>qaction(Log_np, [], NewLogic, NewQstore).
    % === ========= ===

vp rule
    % (vp, ...) ===>
    % sem_head> (v, ...),
    % cat> (np, ...),  会上一种课程
    % goal> ... 
    % === Your Code ===
    (vp, sem:Sem, logic:Log_vp, agr:exists, subcat:Rest, gap:Gap, qstore:Qstore) ===>
    sem_head> (v, logic:Log_v, sem:Sem, subcat:[NP|Rest]),
    cat> (np, NP, logic:Log_np, gap:Gap, qstore:Qstore),
    goal>beta_normalize(@apply(Log_v, [Log_np]), Log_vp).
    % === ========= ===90000000000000000000000000000000000000990kmj

dou rule
    % (vp, ...) ===>
    % cat> (dou),
    % sem_head> (vp, ...).
    % === Your Code ===
    (vp, sem:Sem, agr:forall, logic:Log_vp, subcat:Sub, gap:Gap, qstore:Qstore) ===>
    cat> (dou, Dou),
    sem_head> (vp, VP, logic:Log_vp, subcat:Sub, sem:Sem, gap:Gap, qstore:Qstore).
    % === ========= ===

s rule
    % (s, ...) ===>
    % cat> (np, ...),
    % sem_head> (vp, ...),
    % sem_goal> ...,
    % goal> ... 
    % === Your Code ===
    (s, sem:Sem, logic:NewLogic, subcat:(Rest, []), gap:(none, None), qstore:NewQstore) ===>
    cat> (np, NP, logic:Log_np, agr:Agr, qstore:NPQstore),
    sem_head> (vp, VP, logic:Log_vp, sem:Sem, agr:Agr, subcat:[NP|Rest], gap:None, qstore:VPQstore),
    sem_goal> s_ch(VPQstore, VP),
    goal>dou_goal(NP, VP),
    goal>beta_normalize(@apply(Log_np, [Log_vp]), Log_s),
    goal>retrieve(VPQstore, Log_s, NewQstore, NewLogic),
    goal>is_empty(NPQstore).
    % === ========= ===

s_gap rule
    % (s, ...) ===>
    % cat> (Gap),
    % cat> (np, ...),
    % sem_head> (vp, ...),
    % goal> ... 
    % === Your Code ===
    (s, sem:Sem, logic:NewLogic, subcat:SubCat, gap:Gap, qstore:NewQstore) ===>
    cat> (Gap),
    cat> (np, logic:Log_np, NP, agr:forall, qstore:NPQstore),
    sem_head> (vp, VP, sem:Sem, logic:Log_vp, agr:forall, subcat:(Subcat,[_]), gap:Gap, qstore:VPQstore),
    sem_goal> s_ch(VPQstore, Gap),
    goal>beta_normalize(@apply(Log_np, [Log_vp]), Log_s),
    goal>retrieve(VPQstore, Log_s, NewQstore, NewLogic),
    goal>is_empty(NPQstore).
    % === ========= ===

% The empty category.
empty (np, sem:Sem, logic:Logic, qstore:QStore, agr:Agr,
    gap:(sem:Sem, logic:Logic, qstore:QStore, agr:Agr, gap:none)).


% Macros.
lambda(X, Body) macro (lambda, bind:X, body:Body).
forall(X, Restr, Body) macro (forall, bind:X, body:(imply, lhs:Restr, rhs:Body)).
exists(X, Restr, Body) macro (exists, bind:X, body:(and, lhs:Restr, rhs:Body)).
apply(F, Args) macro (app, f:F, args:Args).

% Helper goals.
append([],Xs,Xs) if true.
append([H|T1],L2,[H|T2]) if append(T1,L2,T2).
is_empty([]) if true.
dou_goal(agr:forall, agr:forall) if true.
dou_goal(agr:exists, agr:exists) if true.
s_ch(Qstore, agr:exists) if
    is_empty(Qstore).
s_ch(Qstore, agr:forall) if true.

% Beta normalization goals.
beta_normalize((lambda,Lambda),Lambda) if !,true.
beta_normalize((Input,bind:Bind,body:Body),(Output,bind:Bind,body:BetaBody)) if
    bn_quant(Input,Output),
    beta_normalize(Body,BetaBody).
beta_normalize((Input,lhs:LHS,rhs:RHS),(Output,lhs:BetaLHS,rhs:BetaRHS)) if
    bn_op(Input,Output),
    beta_normalize(LHS,BetaLHS),
    beta_normalize(RHS,BetaRHS).
beta_normalize(@apply(@lambda(X,Body),[X]),Beta) if 
    !,beta_normalize(Body,Beta).
beta_normalize((app,Apply),Apply) if true.

bn_quant(exists,exists) if true.
bn_quant(forall,forall) if true.
bn_op(and,and) if true.
bn_op(imply,imply) if true.

% Quantifier actions.
store(Logic, QStore, @lambda(F, @apply(F,[X])), 
                     [(l:Logic, x:X)|QStore]) if true.

qaction(Logic, QStore, Logic, QStore) if true.
qaction(Logic, QStore, NewLogic, NewQStore) if
    store(Logic, QStore, NewLogic, NewQStore).

retrieve((Empty, []), Logic, Empty, Logic) if true.
retrieve([(l:QLogic, x:X)|T], Logic, T, NewLogic) if 
    beta_normalize(@apply(QLogic, [@lambda(X, Logic)]), NewLogic).

% Specifying the semantics for generation.
% Do not modify this section.
semantics sem1.
sem1(logic:S, S) if true.
sem1(sem:S, S) if true.

% Some example shortcut helper functions.
rec_test :- rec([yi,ge,xuesheng,huishang,mei,zhong,kecheng]).
prect_test :- prec([yi,ge,xuesheng,huishang,mei,zhong,kecheng]).
translate_test :- translate([yi,ge,xuesheng,huishang,mei,zhong,kecheng]).
q :- halt.
r :- compile_gram(q2_zh).
