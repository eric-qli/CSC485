% Student name: NAME
% Student number: NUMBER
% UTORid: ID

% This code is provided solely for the personal and private use of students
% taking the CSC485H/2501H course at the University of Toronto. Copying for
% purposes other than this use is expressly prohibited. All forms of
% distribution of this code, including but not limited to public repositories on
% GitHub, GitLab, Bitbucket, or any other online platform, whether as given or
% with any changes, are expressly prohibited.

% Authors: Ken Shi, Jingcheng Niu and Gerald Penn

% All of the files in this directory and all subdirectories are
% Copyright (c) 2025 University of Toronto

:- ale_flag(pscompiling, _, parse_and_gen).
:- ensure_loaded(csc485).
lan(zh).
question(q1).

% Type Feature Structure

% Do not modify lines 25-39.
bot sub [category, sem, agr, cl_types, list].
    sem sub [n_sem, v_sem].
        n_sem sub [pilot, tiger, cat] intro [quantity:quantity].
        v_sem sub [find, scare] intro [subj:sem, obj:sem].

    cl_types sub [ge, ming, zhi, tou].

    category sub [nominal, verbal] intro [agr:agr, sem:sem].
        nominal sub [n, np, clp, num, cl] intro [sem:n_sem].
        verbal sub [v, vp, s] intro [sem:v_sem, subcat:list].

    quantity sub [one, two, three].

    list sub [e_list, ne_list].
        ne_list intro [hd:bot, tl:list].

    % Define the type `agr` for agreement.

    % Hint: it should look something like this: 
    % agr intro [your_agr_feature_1:your_agr_type_1, ...].
    %     your_agr_type_1 sub [...].
    %     ...

    % === Your Code Here ===
    agr intro [num:number].

    number sub [sg, pl].
    % ======================


% Specifying the semantics for generation.
% Do not modify.
semantics sem1.
sem1(sem:S, S) if true.

% Lexicon

% Hint: Your lexical entries should look something like this: 
% token ---> (type,
%    feature_name_1:feature_type_1,
%    feature_name_2:feature_type_2, ...). 

% === Your Code Here ===

feixingyuan --->
  (n,
   agr:agr,
   sem:pilot).

hu --->
  (n,
   agr:agr,
   sem:tiger).

mao --->
  (n,
   agr:agr,
   sem:cat).

ge --->
  (cl,
   agr:agr,
   sem:n_sem).

ming --->
  (cl,
   agr:agr,
   sem:n_sem).

zhi --->
  (cl,
   agr:agr,
   sem:n_sem).

tou --->
  (cl,
   agr:agr,
   sem:n_sem).

zhao --->
  (v,
   agr:agr,
   sem:(find, subj:SubjSem, obj:ObjSem),
   subcat:(ne_list,
           hd:(np, sem:SubjSem),
           tl:(ne_list,
               hd:(np, sem:ObjSem),
               tl:e_list))).

xia --->
  (v,
   agr:agr,
   sem:(scare, subj:SubjSem, obj:ObjSem),
   subcat:(ne_list,
           hd:(np, sem:SubjSem),
           tl:(ne_list,
               hd:(np, sem:ObjSem),
               tl:e_list))).

yi --->
  (num,
   agr:agr,
   sem:(n_sem, quantity:one)).

er --->
  (num,
   agr:agr,
   sem:(n_sem, quantity:two)).

san --->
  (num,
   agr:agr,
   sem:(n_sem, quantity:three)).

% ======================


% Rules

% Hint: Your rules should look something like this: 

% rule_name rule
% (product_type, feature3:value3) ===>
% cat> (type1, feature1:value1),
% cat> (type2, feature2:value2).

% === Your Code Here ===

% CLP -> CL N
cl_n_clp rule
(clp, agr:Agr, sem:Sem) ===>
  cat> (cl, agr:Agr),
  cat> (n,  agr:Agr, sem:Sem).

% NP -> NUM CLP
num_clp_np rule
(np, agr:Agr, sem:Sem) ===>
  cat> (num, agr:Agr),
  cat> (clp, agr:Agr, sem:Sem).

% NP -> N
n_np rule
(np, agr:Agr, sem:Sem) ===>
  cat> (n, agr:Agr, sem:Sem).

% VP -> V NP
v_np_vp rule
(vp, agr:Agr, sem:Sem) ===>
  cat> (v, agr:Agr, sem:Sem),
  cat> (np, agr:_).

% S -> NP VP
np_vp_s rule
(s, agr:Agr, sem:Sem) ===>
  cat> (np, agr:Agr),
  cat> (vp, agr:Agr, sem:Sem).

% ======================
