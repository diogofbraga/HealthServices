﻿%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MiEI

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Base de Conhecimento para caracterizar um universo de discurso na área da prestação de cuidados de saúde.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: Declaracoes iniciais

:- set_prolog_flag(discontiguous_warnings,off).
:- set_prolog_flag(single_var_warnings,off).
:- set_prolog_flag(unknown,fail).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: Definicoes iniciais

:- op(900,xfy,'::').
:- dynamic utente/5.
:- dynamic servico/4.
:- dynamic consulta/5.
:- dynamic medico/4.
:- dynamic seguro/3.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado utente: IdUt,Nome,Idade,Cidade,Seguro-> {V,F}

% Invariante Estrutural:  nao permitir a insercao de conhecimento
%                         repetido

+utente(IU,_,_,_,_) :: (solucoes(IU, (utente(IU,_,_,_,_)), S),
                     comprimento(S,1)).

% Invariante Estrutural: a idade de cada utente tem de ser inteira e
%             estar no intervalo [0,120]

+utente(_,_,I,_,_) :: (integer(I),
                    I >= 0,
                    I =< 120).

% Invariante Rferencial: um utente so pode ser removido se nao existir consultas
%                       associadas a este.

-utente(ID,_,_,_,_) :: (solucoes((ID,IDS), consulta(_,ID,IDS,_,_), S),
                     comprimento(S,0)).



%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado serviço: IdServ,Descrição,Instituição,Cidade -> {V,F}

% Invariante Estrutural:  nao permitir a insercao de conhecimento
%                         repetido

+servico(IS,_,_,_) :: (solucoes(IS, (servico( IS,_,_,_ )), S),
                      comprimento(S,1)).

% Invariante Estrutural:  nao permitir a insercao de serviços que tenham a mesma
%                         descrição, na mesma instituição da mesma cidade.

+servico(_,D,I,C) :: (solucoes((D,I,C), servico(_,D,I,C),S),
                     comprimento(S,1)).

% Invariante Referencial:  nao permitir a remoção dum serviço se existirem consultas
%                          associadas a este.

-servico(ID,_,_,_) :: (solucoes(ID, consulta(_,_,ID,_,_), S),
                      comprimento(S,0)).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado consulta: Data,IdUt,IdServ,Custo,IdMed-> {V,F}

% Invariante Estrutural:  nao permitir a um utente que tenha mais de 10 consultas
%                          por dia.

+consulta(D,U,_,_,_) :: (solucoes(U, (consulta(Di,U,_,_,_),comparaDatas(D,Di,=)), S),
                        comprimento(S,LR),
                        LR =< 10).

% Invariante Estrutural:  nao permitir a insercao duma data que nao seja válida.

+consulta(D,_,_,_,_) :: (isData(D)).

% Invariante Referencial:  nao permitir a insercao de consultas relativas a utentes
%                          inexistentes.

+consulta(_,U,_,_,_) :: (utente(U,_,_,_,_)).

% Invariante Referencial:  nao permitir a insercao de consultas relativas a servicos
%                          inexistentes.

+consulta(_,_,ID,_,_) :: (servico(ID,_,_,_)).

% Invariante Referencial:  nao permitir a insercao de consultas relativas a servicos
%                          inexistentes.

+consulta(_,_,_,_,IM) :: (medico(IM,_,_,_)).



%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado data: D, M, A -> {V,F}

data(D, M, A) :-
	   member(M, [1,3,5,7,8,10,12]),
	   D >= 1,
	   D =< 31.
data(D, M, A) :-
	   member(M, [4,6,9,11]),
	   D >= 1,
	   D =< 30.
data(D, 2, A) :- % ano nao bissexto
	   A mod 4 =\= 0,
	   D >= 1,
	   D =< 28.
data(D, 2, A) :-
	   A mod 4 =:= 0,
	   D >= 1,
     D =< 29.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado isData: X -> {V,F}

isData(data(D, M, A)) :-
    data(D, M, A).





%--------------------------PONTO 1--------------------------%

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Registar Utente : IdUt,Nome,Idade,Cidade,IdSeguro-> {V,F}

registarU(IU,N,I,C,IdS) :-
    evolucao(utente(IU,N,I,C,IdS)).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Registar Serviço : IdServ,Descrição,Instituição,Cidade -> {V,F}

registarServ(IS,D,I,C) :-
    evolucao(servico(IS,D,I,C)).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Registar Consulta : Data,IdUt,IdServ,Custo,IdMed -> {V,F}

registarConsulta(DA,IU,IS,C,IM) :-
    evolucao(consulta(DA,IU,IS,C,IM)).





%--------------------------PONTO 2--------------------------%

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Remover Utente : IdUt,Nome,Idade,Cidade,IdSeguro-> {V,F}

removerU(IU,N,I,C,IdS) :-
    regressao(utente(IU,N,I,C,IdS)).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Remover Serviço : IdServ,Descrição,Instituição,Cidade -> {V,F}

removerServ(IS,D,I,C) :-
    regressao(servico(IS,D,I,C)).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Remover Consulta : Data,IdUt,IdServ,Custo,IdMed -> {V,F}

removerConsulta(DA,IU,IS,C,IM) :-
    regressao(consulta(DA,IU,IS,C,IM)).





%--------------------------PONTO 3--------------------------%

% ----------------------------------------------------------------------------------------------------
% Extensao do predicado instituicoes: Resultado -> {V,F}

instituicoes(R) :-
    solucoes(INST, servico(IDC,DESC,INST,CD), LR),
    removeReps(LR,R).





%--------------------------PONTO 4--------------------------%

% ----------------------------------------------------------------------------------------------------
% Extensao do predicado utentesPNome: Nome, Resultado -> {V,F}

utentesPNome(Nome,R) :-
    solucoes((IU,Nome,I,C), utente(IU,Nome,I,C,IdS), R).

% ----------------------------------------------------------------------------------------------------
% Extensao do predicado utentesPIdade: Idade, Resultado -> {V,F}

utentesPIdade(Idade,R) :-
    solucoes((IU,N,Idade,C), utente(IU,N,Idade,C,IdS), R).

% ----------------------------------------------------------------------------------------------------
% Extensao do predicado utentesPCidade: Cidade, Resultado -> {V,F}

utentesPCidade(Cidade,R) :-
    solucoes((IU,N,I,Cidade), utente(IU,N,I,Cidade,IdS), R).

% ----------------------------------------------------------------------------------------------------
% Extensao do predicado servicosPDesc: Descrição, Resultado -> {V,F}

servicosPDesc(Descricao,R) :-
    solucoes((IS,Descricao,I,C), servico(IS,Descricao,I,C), R).

% ----------------------------------------------------------------------------------------------------
% Extensao do predicado consultasPData: Data, Resultado -> {V,F}

consultasPData(Data,R) :-
    solucoes((Data,IU,IS,C,IM), consulta(Data,IU,IS,C,IM), R).





%--------------------------PONTO 5--------------------------%

% ----------------------------------------------------------------------------------------------------
% Extensao do predicado servicosPInst: Instituição, Resultado -> {V,F}

servicosPInst(Instituicao,R) :-
    solucoes((D,C), servico(IS,D,Instituicao,C), R).

% ----------------------------------------------------------------------------------------------------
% Extensao do predicado servicosPCidade: Cidade, Resultado -> {V,F}

servicosPCidade(Cidade,R) :-
    solucoes((D,I), servico(IS,D,I,Cidade), R).

% ----------------------------------------------------------------------------------------------------
% Extensao do predicado servicosPData: Data, Resultado -> {V,F}

servicosPData(Data,R) :-
    solucoes((D,I,C),
            (consulta(Data,_,IDS,_,_), servico(IDS,D,I,C)),
            S),
    removeReps(S,R).

% ----------------------------------------------------------------------------------------------------
% Extensao do predicado servicosPCusto: Custo, Resultado -> {V,F}

servicosPCusto(Custo,R) :-
    solucoes((D,I,Cidade),
            (consulta(_,_,IDS,Custo,_), servico(IDS,D,I,Cidade)),
            S),
    removeReps(S,R).





%--------------------------PONTO 6--------------------------%

% ----------------------------------------------------------------------------------------------------
% Extensao do predicado utentesPServ: Servico , Resultado -> {V,F}

utentesPServ(Descricao,R) :-
    solucoes((IdUt,Nome),
            (servico(IDS,Descricao,_,_), consulta(_,IdUt,IDS,_,_), utente(IdUt,Nome,_,_,_)),
            S),
    removeReps(S,R).

% ------------------------------------------------------------------------%
% Extensao do predicado utentesPInst: Instituicao , Resultado -> {V,F}

utentesPInst(Inst,R) :-
    solucoes((IdUt,Nome),
            (servico(IDS,_,Inst,_), consulta(_,IdUt,IDS,_,_), utente(IdUt,Nome,_,_,_)),
            S),
    removeReps(S,R).





%---------------------------PONTO 7 -------------------------------------%
%Extensão do predicado servicoRPUtente : IdUt , Resultado -> {V,F}

servicoRPUtente(IDU,R):-
	   solucoes((Desc,I,C),
              (consulta(_,IDU,IDS,_,_), servico(IDS,Desc,I,C)),
              S),
	   removeReps(S,R).


%-------------------------------------------------------------------------%
%Extensão do predicado servicoRPInst : Inst , Resultado -> {V,F}

servicoRPInst(Inst,R):-
	   solucoes((Desc,C),
             (consulta(_,_,IDS,_,_), servico(IDS,Desc,Inst,C)),
             S),
	   removeReps(S,R).

%-------------------------------------------------------------------------%
%Extensão do predicado servicoRPCidade : Cidade , Resultado -> {V,F}

servicosRPCidade(Cidade,R):-
	   solucoes((Desc,Inst),
             (consulta(_,_,IDS,_,_), servico(IDS,Desc,Inst,Cidade)),
             S),
  	 removeReps(S,R).





%---------------------------PONTO 8 -------------------------------------%

%-------------------------------------------------------------------------%
%Extensão do predicado custoTPUtente : Utente , Resultado -> {V,F}
custoTPUtente(IdUt,R) :-
     solucoes((Custo), consulta(_,IdUt,_,Custo,_), S),
     somaConjVal(S,X),
     retornosPUtente(IdUt,Y),
     R is X-Y.


%-------------------------------------------------------------------------%
%Extensão do predicado custoTPServico : Servico , Resultado -> {V,F}
custoTPServ(IdServ,R) :-
     solucoes((Custo), consulta(_,_,IdServ,Custo,_), S),
     somaConjVal(S,R).

%-------------------------------------------------------------------------%
%Extensão do predicado custoTPInst : Instituicao , Resultado -> {V,F}
custoTPInst(Inst,R) :-
     solucoes((Custo),
             (servico(IdServ,_,Inst,_), consulta(_,_,IdServ,Custo,_)),
             S),
     somaConjVal(S,R).

%-------------------------------------------------------------------------%
%Extensão do predicado custoTPData : Data , Resultado -> {V,F}
custoTPData(Data,R) :-
     solucoes((Custo), consulta(Data,_,_,Custo,_), S),
     somaConjVal(S,R).


%--------------------------PREDICADOS AUXILIARES--------------------------%

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensão do predicado que permite a evolucao do conhecimento

evolucao(Termo) :-
    solucoes(Invariante,+Termo::Invariante,Lista),
    insercao(Termo),
    teste(Lista).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado que permite a regressão do conhecimento

regressao(Termo) :-
	  Termo,
	  solucoes(Invariante,-Termo::Invariante,Lista),
	  remover(Termo),
    teste(Lista).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensão do predicado que permite encontrar as provas

solucoes(F,Q,S) :-
    Q, assert(tmp(F)), fail.
solucoes(F,Q,S) :-
    construir(S,[]).

construir(S1,S2) :-
    retract(tmp(X)), !,
    construir(S1, [X|S2]).
construir(S,S).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensão do predicado que permite a inserção do conhecimento
insercao(Termo) :-
    assert(Termo).
insercao(Termo) :-
    retract(Termo), !, fail.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensão do predicado que permite a remoção do conhecimento
remover(Termo) :-
    retract(Termo).
remover(Termo) :-
    assert(Termo), !, fail.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensão do predicado que realiza o teste do conhecimento
teste([]).
teste([R|LR]) :-
    R,
    teste(LR).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado comprimento: L,N -> {V,F}

comprimento([], 0).
comprimento([H|T], N) :-
    comprimento(T,S),
    N is S+1.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado removeReps: L,R -> {V,F}

removeReps([], []).
removeReps([H|T], R) :-
    member(H,T),
	  removeReps(T, R).
removeReps([H|T],[H|R]) :-
    nao(member(H,T)),
    removeReps(T,R).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado nao: T -> {V,F}

nao(T) :-
    T, !, fail.
nao(T).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado comparaDatas: Data1, Data2, R -> {V,F}
%
% O predicado comparaDatas compara duas datas. O resultado da comparacao e:
%   <  se a primeira data for anterior à segunda;
%   =  se as datas foram iguais;
%   >  se a primeira data for posterior à segunda.

comparaDatas(data(_, _, A1), data(_, _, A2), R) :-
	A1 \= A2,
    compare(R, A1, A2).
comparaDatas(data(_, M1, A), data(_, M2, A), R) :-
	M1 \= M2,
    compare(R, M1, M2).
comparaDatas(data(D1, M, A), data(D2, M, A), R) :-
    compare(R, D1, D2).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado somaConjVal: L,R -> {V,F}

somaConjVal([],0).
somaConjVal([X|L],R) :-
    somaConjVal(L,Y),
    R is X+Y.





%--------------------------PREDICADOS EXTRA--------------------------%

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensão do predicado que permite guardar a base de conhecimento num ficheiro
% guardaFactos: Ficheiro -> {V,F}

guardaFactos(Ficheiro) :-
    tell(Ficheiro),
    listing,
    told.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensão do predicado que permite carregar a base de conhecimento dum ficheiro
% carregaFactos: Ficheiro -> {V,F}

carregaFactos(Ficheiro) :-
    seeing(InputAtual),
    see(Ficheiro),
    repeat,
    read(Termo),
    (Termo == end_of_file -> true ;
    assert(Termo),fail),
    seen,
    see(InputAtual).





%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado medico: IdMed, Nome, Idade, IdServ -> {V,F}


% Invariante Estrutural: nao permitir a insercao de conhecimento
%                         repetido

+medico(IM,_,_,_) :: (solucoes(IM, medico( IM,_,_,_ ),S),
                     comprimento( S,1 )).

% Invariante Estrutural: a idade de cada medico a exercer tem de ser inteira e
%             estar no intervalo [25,70]

+medico(_,_,I,_) :: (integer(I),
                    I >= 25,
                    I =< 70).

% Invariante Estrutural: nao permitir medicos com mais de uma especialidade/servico

+medico(IM,_,_,IS) :: (solucoes((IM,IS), medico(IM,_,_,IS ), S),
                      comprimento( S,1 )).

% Invariante Referencial:  nao permitir a remoção dum medico se existirem consultas
%                          associadas a este.

-medico(ID,_,_,_) :: (solucoes(ID, consulta(_,_,_,_,ID), S),
                     comprimento(S,0)).



%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Registar Medico : IdMed, Nome, Idade, IdServ -> {V,F}

registarM(IM,N,I,IS) :-
   evolucao(medico(IM,N,I,IS)).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Remover Medico : IdMed, Nome, Idade, IdServ -> {V,F}

removerM(IM,N,I,IS) :-
   regressao(medico(IM,N,I,IS)).

% ----------------------------------------------------------------------------------------------------
% Extensao do predicado medicosPInst: Inst, Resultado -> {V,F}

medicosPInst(Inst,R) :-
   solucoes((IM,N,I,Desc),
           (medico(IM,N,I,IS), servico(IS,Desc,Inst,_)),
           R).

% ----------------------------------------------------------------------------------------------------
% Extensao do predicado consultasPMed: IdMed, Resultado -> {V,F}

consultasRPMed(IM,R) :-
   solucoes((N,Desc,Inst,Data),
           (medico(IM,N,_,IS), consulta(Data,_,_,_,IM), servico(IS,Desc,Inst,_)),
           R).

%-------------------------------------------------------------------------%
%Extensão do predicado custoTPMed: IdMed, Resultado -> {V,F}

custoTPMed(IM,R) :-
     solucoes((Custo),
             (consulta(_,_,_,Custo,IM)),
             S),
     somaConjVal(S,R).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado seguro: IdSeg,Descrição,Taxa -> {V,F}

% Invariante Estrutural:  nao permitir a insercao de conhecimento
%                         repetido

+seguro(IdSeg,_) :: (solucoes(IdSeg, (seguro(IdSeg,_)), S),
                     comprimento(S,1)).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Registar Seguro : IdSeg, Descrição, Taxa -> {V,F}

registarS(IdSeg,D,T) :-
   evolucao(seguro(IdSeg,D,T)).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Remover Seguro : IdSeg, Descrição, Taxa -> {V,F}

removerS(IdSeg,D,T) :-
   regressao(seguro(IdSeg,D,T)).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado custosTaxados: Custos,Taxa,Resultado-> {V,F}

custosTaxados([],T,[]).

custosTaxados([X|L],T,[Y|LN]) :-
              custosTaxados(L,T,LN),
              Y is X*T.


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado retornosPUtente: IdUt,Resultado-> {V,F}

retornosPUtente(IdUt,R) :-
   solucoes((Custo), consulta(_,IdUt,_,Custo,_), S),
      utente(IdUt,_,_,_,IdSeg),
       seguro(IdSeg,_,T),
        custosTaxados(S,T,L),
          somaConjVal(L,R).
