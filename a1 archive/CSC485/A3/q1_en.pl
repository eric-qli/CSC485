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

:- ale_flag(pscompiling, _, parse_and_gen).
:- ensure_loaded(csc485).
lan(en).
question(q1).

% Type Feature Structure
% Do not modify lines 25-37.
bot sub [cat, sem, agr, list].
    sem sub [n_sem, v_sem].
        n_sem sub [student, wolf, sheep] intro [quantity:quantity].
        v_sem sub [chase, see] intro [subj:sem, obj:sem].

    cat sub [nominal, verbal] intro [agr:agr, sem:sem].
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
a ---> (det, sem:(quantity:one), agr:(num:singular)).
one ---> (num, sem:(quantity:one), agr:(num:singular)).
two ---> (num, sem:(quantity:two), agr:(num:plural)).
three ---> (num, sem:(quantity:three), agr:(num:plural)).
student ---> (n, sem:(student,quantity:_), agr:(num:singular)).
students ---> (n, sem:(student,quantity:_), agr:(num:plural)).
wolf ---> (n, sem:(wolf, quantity:_), agr:(num:singular)).
wolves ---> (n, sem:(wolf, quantity:_), agr:(num:plural)).
sheep ---> (n, sem:(sheep, quantity:_), agr:(num:_)).

see ---> (v, agr:num:plural, sem:see, 
    subcat:[(Obj, np), (Subj, np)]).
sees ---> (v, agr:num:singular, sem:see, 
    subcat: [(Obj, np), (Subj, np)]).
saw ---> (v, agr:num:_, sem:see, 
    subcat: [(Obj, np), (Subj, np)]).

chase ---> (v, agr:num:plural, sem:chase, 
    subcat: [(Obj, np), (Subj, np)]).
chases ---> (v, agr:num:singular, sem:chase, 
    subcat: [(Obj, np), (Subj, np)]).
chased ---> (v, agr:num:_, sem:chase, 
    subcat: [(Obj, np), (Subj, np)]).

% ======================

% Rules
% Hint: Your rules should look something like this: 
% rule_name rule
% (product_type, feature3:value3) ===>
% cat> (type1, feature1:value1),
% cat> (type2, feature2:value2).
% === Your Code Here ===
% NP → Det N: combining a Determiner (Det) with a Noun (N)
np_det rule
(np, agr:Agr, sem:(Sem, quantity:Quant)) ===>
cat> (det, agr:Agr, sem:(quantity:Quant)),
sem_head> (n, agr:Agr, sem:Sem).


% NP → Num N: Numeral (Num) is combined with a Noun (N)
np_num rule
(np, agr:Agr, sem:(Sem, quantity:Quant)) ===>
cat> (num, agr:Agr, sem:(quantity:Quant)),
sem_head> (n, agr:Agr, sem:Sem).


% VP → V NP : Verb (V) followed by a Noun Phrase (NP)
vp rule
(vp, agr:Agr, sem:(Sem, obj:Object_sem), subcat:(Rest, [_|_])) ===>
sem_head> (v, agr:Agr, sem:Sem, subcat:[Obj|Rest]),
cat> (Obj, np, sem:Object_sem).

% S → NP VP : Noun Phrase (NP) followed by a Verb Phrase (VP).
s rule
(s, agr:Agr, sem:(Sem, subj:Subject_sem, obj:Object_sem), subcat:([], Rest)) ===>
cat> (Subj, np, agr:Agr, sem:Subject_sem),
sem_head> (vp, agr:Agr, sem:(Sem, obj:Object_sem), subcat:[Subj|Rest]).
% ======================
