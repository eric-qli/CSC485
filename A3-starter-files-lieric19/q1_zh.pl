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
    agr intro [clf:cl_types].
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
yi ---> (num,
         sem:(n_sem, quantity:one),
         agr:(agr, clf:_)).

liang ---> (num,
            sem:(n_sem, quantity:two),
            agr:(agr, clf:_)).

san ---> (num,
          sem:(n_sem, quantity:three),
          agr:(agr, clf:_)).

feixingyuan ---> (n,
                  sem:(pilot, quantity:_),
                  agr:(agr, clf:ge)).

feixingyuan ---> (n,
                  sem:(pilot, quantity:_),
                  agr:(agr, clf:ming)).

mao ---> (n,
          sem:(cat, quantity:_),
          agr:(agr, clf:zhi)).

hu ---> (n,
         sem:(tiger, quantity:_),
         agr:(agr, clf:tou)).

ge  ---> (cl, 
          sem:(n_sem, quantity:_), 
          agr:(agr, clf:ge)).

ming ---> (cl, 
           sem:(n_sem, quantity:_), 
           agr:(agr, clf:ming)).

zhi ---> (cl, 
          sem:(n_sem, quantity:_), 
          agr:(agr, clf:zhi)).

tou ---> (cl, 
          sem:(n_sem, quantity:_), 
          agr:(agr, clf:tou)).

zhao --->
  (v,
   agr:(agr, clf:_),
   sem:find,
   subcat:[(Obj, np), (Subj, np)]).

xia --->
  (v,
   agr:(agr, clf:_),
   sem:scare,
   subcat:[(Obj, np), (Subj, np)]).

% ======================


% Rules

% Hint: Your rules should look something like this: 

% rule_name rule
% (product_type, feature3:value3) ===>
% cat> (type1, feature1:value1),
% cat> (type2, feature2:value2).

% === Your Code Here ===

% clp ->num CL, classifier phrase, 一只
clp rule
(clp, sem:(quantity:Quant), agr:Agr) ===>
sem_head> (num, sem:(quantity:Quant)),
cat> (cl, agr:Agr).

% NP -> CLP N, classifier phrase + noun, 一只羊
np rule
(np, sem:(Sem, quantity:Quant), agr:Agr) ===>
cat> (clp, sem:(quantity:Quant), agr: Agr),
sem_head> (n, sem:Sem, agr:Agr).

%VP ->V NP, verb + noun phrase, 看见一只羊
vp rule
(vp, sem:(Sem, obj:Object_sem), agr:Agr, subcat:(Rest, [_|_])) ===>
sem_head> (v, sem:Sem, agr:Agr, subcat:[Obj|Rest]),
cat> (Obj, np, sem:Object_sem).

%S->NP VP noun phrase + verb phrase 一名学生看见一只羊
s rule
(s, agr:Agr, sem:(Sem, subj:Subject_sem, obj:Object_sem), subcat:([], Rest)) ===>
cat> (Subj, np, agr:Agr, sem:Subject_sem),
sem_head> (vp, agr:Agr, sem:(Sem, obj:Object_sem), subcat:[Subj|Rest]).

% ======================
