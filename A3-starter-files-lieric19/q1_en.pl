% Student name: Eric Li
% Student number: 1007654307
% UTORid: lieric19

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
lan(en).
question(q1).

% Type Feature Structure

% Do not modify lines 25-37.
bot sub [category, sem, agr, list].
    sem sub [n_sem, v_sem].
        n_sem sub [pilot, tiger, cat] intro [quantity:quantity].
        v_sem sub [find, scare] intro [subj:sem, obj:sem].

    category sub [nominal, verbal] intro [agr:agr, sem:sem].
        nominal sub [n, np, det, num] intro [sem:n_sem].
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
    number sub [singular, plural].
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
a ---> (det,
        sem:(quantity:one),
        agr:(num:singular)).

one ---> (num,
          sem:(quantity:one),
          agr:(num:singular)).

two ---> (num,
          sem:(quantity:two),
          agr:(num:plural)).

three ---> (num,
            sem:(quantity:three),
            agr:(num:plural)).

pilot ---> (n,
            sem:(pilot, quantity:_),
            agr:(num:singular)).

pilots ---> (n,
             sem:(pilot, quantity:_),
             agr:(num:plural)).

tiger ---> (n,
            sem:(tiger, quantity:_),
            agr:(num:singular)).

tigers ---> (n,
             sem:(tiger, quantity:_),
             agr:(num:plural)).

cat ---> (n,
          sem:(cat, quantity:_),
          agr:(num:singular)).

cats ---> (n,
           sem:(cat, quantity:_),
           agr:(num:plural)).

find ---> (v,
           agr:num:plural,
           sem:find,
           subcat:[(Obj, np), (Subj, np)]).

finds ---> (v,
            agr:num:singular,
            sem:find,
            subcat:[(Obj, np), (Subj, np)]).

found ---> (v,
            agr:num:_,
            sem:find,
            subcat:[(Obj, np), (Subj, np)]).

scare ---> (v,
            agr:num:plural,
            sem:scare,
            subcat:[(Obj, np), (Subj, np)]).

scares ---> (v,
             agr:num:singular,
             sem:scare,
             subcat:[(Obj, np), (Subj, np)]).

scared ---> (v,
             agr:num:_,
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

% NP -> Det N
det_n_np rule
(np, agr:Agr, sem:Sem) ===>
  cat> (det, agr:Agr),
  cat> (n, agr:Agr, sem:Sem).


% NP -> Num N
num_n_np rule
(np, agr:Agr, sem:Sem) ===>
  cat> (num, agr:Agr),
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
