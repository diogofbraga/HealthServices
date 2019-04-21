%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MiEI

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Programacao em logica estendida
% Representacao de conhecimento imperfeito

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Base de Conhecimento para caracterizar um universo de discurso na área da prestação de cuidados de saúde.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: Declaracoes iniciais

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: definicoes iniciais

:- op(900,xfy,'::').
:- op(996,xfy, '&&').  % operador de conjuncao
:- op(997,xfy, '$$').  % operador de disjuncao
:- op(998,xfx, '=>').  % operador de implicacao
:- op(999,xfx, '<=>'). % operador de equivalencia

:- dynamic utente/5.
:- dynamic servico/4.
:- dynamic consulta/5.
:- dynamic medico/4.
:- dynamic seguro/3.

:- dynamic '-'/1.

% utente: IdUt,Nome,Idade,Cidade,Seguro-> {V,F,D}
% serviço: IdServ,Descrição,Instituição,Cidade -> {V,F,D}
% consulta: Data,IdUt,IdServ,Custo,IdMed-> {V,F,D}
% medico: IdMed, Nome, Idade, IdServ -> {V,F,D}
% seguro: IdSeg,Descrição,Taxa -> {V,F,D}
% data: Dia, Mes, Ano -> {V,F}

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
% Extensao do predicado comprimento: L,N -> {V,F}

comprimento([], 0).
comprimento([H|T], N) :-
    comprimento(T,S),
    N is S+1.



%--------------------------REPRESENTACAO CONHECIMENTO POSITIVO--------------------------%

% carregaFactos('GRUPO10_FACTOS.txt').




%--------------------------REPRESENTACAO CONHECIMENTO NEGATIVO--------------------------%

%------------NEGACAO FORTE DOS PREDICADOS------------%

% Extensao do predicado que define a negação forte do predicado utente
-utente(IU,N,I,C,IdS) :-
    nao(utente(IU,N,I,C,IdS)),
    nao(excecao(utente(IU,N,I,C,IdS))).

% Extensao do predicado que define a negação forte do predicado servico
-servico(IS,D,I,C) :-
    nao(servico(IS,D,I,C)),
    nao(excecao(servico(IS,D,I,C))).

% Extensao do predicado que define a negação forte do predicado consulta
-consulta(DA,IU,IS,C,IM) :-
    nao(consulta(DA,IU,IS,C,IM)),
    nao(excecao(consulta(DA,IU,IS,C,IM))).

% Extensao do predicado que define a negação forte do predicado medico
-medico(IM,N,I,IS) :-
    nao(medico(IM,N,I,IS)),
    nao(excecao(medico(IM,N,I,IS))).

% Extensao do predicado que define a negação forte do predicado seguro
-seguro(IdSeg,D,T) :-
    nao(seguro(IdSeg,D,T)),
    nao(excecao(seguro(IdSeg,D,T))).


%-----------------NEGACAO EXPLICITA-----------------%

% Não existe um utente de 50 anos com id 11 e nome rafa, que viva em guimaraes sem seguro.
-utente(11,rafa,50,guimaraes,0).

% Não existe um serviço de neurologia, com id 8, no hsog em guimaraes.
-servico(8, neurologia, hsog, guimaraes).

% Não existe uma consulta do dia 07/03/2019 do utente com o id 10 para o serviço com o id 3,
% no qual o custo monetário é 10 e o id do médico é 8.
-consulta(data(7,3,2019), 10, 3, 10, 8).

% Não existe um médico de ginecologia com o id 8, chamado roberto, e com 48 anos de idade.
-medico(8, roberto, 48, 5).

% Não existe um seguro com id 4 e nome secur que possuia uma taxa de retorno de 0.2.
-seguro(4, secur, 0.2).




%--------------------------REPRESENTACAO CONHECIMENTO IMPERFEITO INCERTO--------------------------%

% Não sabemos qual a Instituição que prestou o serviço 9 correspondente a Fisiatria, apenas sabemos que foi realizada em Braga
servico(9,fisiatria,xpto021,braga).
excecao( servico(IDS,D,I,C) ) :-
         servico(IDS,D,xpto021,C).

% Não sabemos qual é a cidade onde reside o Utente 11 chamado Alfredo, com 86 anos e portador do seguro 2
utente(11,alfredo,86,xpto022,2).
excecao( utente(IU,N,I,C,IdS) ) :-
         utente(IU,N,I,xpto022,IdS).

% Não sabemos o serviço que o médico 8, chamado António e com 37 anos realiza
medico(8,antonio,37,xpto023).
excecao( medico(IM,N,I,S) ) :-
         medico(IM,N,I,xpto023).




%--------------------------REPRESENTACAO CONHECIMENTO IMPERFEITO IMPRECISO--------------------------%

% Não sabemos se o serviço 10 de pneumologia foi realizado no Hospital de Braga ou no Hospital Senhora da Oliveira em Guimarães
excecao( servico(10,pneumologia,hospitalbraga,braga) ).
excecao( servico(10,pneumologia,hsog,guimaraes) ).

% Não sabemos qual a taxa do Seguro 3 Allianz, apenas sabemos que está entre 0.2 e 0.25
excecao( seguro(5,allianz,X) ) :-
         X >= 0.2,
         X =< 0.25.




%--------------------------REPRESENTACAO CONHECIMENTO IMPERFEITO INTERDITO--------------------------%

% Nunca será possivel saber o custo da consulta realizada no dia 10 de Abril de 2019 pelo médico 1 que frequenta o serviço 7.
% Esta consulta foi requisitada pelo utente 2
consulta(data(10,4,2019),2,7,xpto024,1).
excecao( consulta(DA,IU,IS,C,IM) ) :-
         consulta(DA,IU,IS,xpto024,IM).
nulo(xpto024).
+consulta( DA,IU,IS,C,IM ) :: (solucoes((CS), (consulta(data(10,4,2019),2,7,CS,1), nao(nulo(CS))), S),
                    comprimento( S,N ), N == 0
                    ).




%-----------------INVARIANTES QUE DESIGNEM RESTRICOES À INSERCAO DE CONHECIMENTO DO SISTEMA-----------------%

%-----------------UTENTE-----------------%

% Invariante Estrutural:  nao permitir a insercao de conhecimento positivo repetido
+utente(IU,_,_,_,_) :: (solucoes(IU, (utente(IU,_,_,_,_)), S),
                     comprimento(S,1)).

% Invariante Estrutural: nao permitir a insercao de conhecimento negativo repetido
+(-utente(IU,N,I,C,IdS)) :: (solucoes(IU, -utente(IU,N,I,C,IdS), S),
													comprimento(S, 1)).

% Invariante Estrutural: a idade de cada utente tem de ser inteira e estar no intervalo [0,120]
+utente(_,_,I,_,_) :: (integer(I),
                      I >= 0,
                      I =< 120).


%-----------------SERVICO-----------------%

% Invariante Estrutural: nao permitir a insercao de conhecimento positivo repetido
+servico(IS,_,_,_) :: (solucoes(IS, (servico( IS,_,_,_ )), S),
                      comprimento(S,1)).

% Invariante Estrutural: nao permitir a insercao de conhecimento negativo repetido
+(-servico(IS,D,I,C)) :: (solucoes(IS, -servico(IS,D,I,C), S),
													comprimento(S, 1)).

% Invariante Estrutural: nao permitir a insercao de serviços que tenham a mesma descrição, na mesma instituição da mesma cidade
+servico(_,D,I,C) :: (solucoes((D,I,C), servico(_,D,I,C),S),
                     comprimento(S,1)).

%-----------------CONSULTA-----------------%

% Invariante Estrutural:  nao permitir a um utente que tenha mais de 10 consultas por dia.
+consulta(D,U,_,_,_) :: (solucoes(U, (consulta(Di,U,_,_,_),comparaDatas(D,Di,=)), S),
                        comprimento(S,LR),
                        LR =< 10).

% Invariante Estrutural:  nao permitir a insercao duma data que nao seja válida.
+consulta(D,_,_,_,_) :: (isData(D)).

% Invariante Referencial:  nao permitir a insercao de consultas relativas a utentes inexistentes.
+consulta(_,U,_,_,_) :: (utente(U,_,_,_,_)).

% Invariante Referencial:  nao permitir a insercao de consultas relativas a servicos inexistentes.
+consulta(_,_,ID,_,_) :: (servico(ID,_,_,_)).

% Invariante Referencial:  nao permitir a insercao de consultas relativas a servicos inexistentes.
+consulta(_,_,_,_,IM) :: (medico(IM,_,_,_)).

%-----------------MEDICO-----------------%

% Invariante Estrutural: nao permitir a insercao de conhecimento positivo repetido
+medico(IM,_,_,_) :: (solucoes(IM, medico( IM,_,_,_ ),S),
                     comprimento( S,1 )).

% Invariante Estrutural: nao permitir a insercao de conhecimento negativo repetido
+(-medico(IM,N,I,IS)) :: (solucoes(IM, -medico(IM,N,I,IS), S),
													comprimento(S, 1)).

% Invariante Estrutural: a idade de cada medico a exercer tem de ser inteira e estar no intervalo [25,70]
+medico(_,_,I,_) :: (integer(I),
                    I >= 25,
                    I =< 70).

% Invariante Estrutural: nao permitir medicos com mais de uma especialidade/servico
+medico(IM,_,_,IS) :: (solucoes((IM,IS), medico(IM,_,_,IS ), S),
                      comprimento( S,1 )).

%-----------------SEGURO-----------------%

% Invariante Estrutural:  nao permitir a insercao de conhecimento positivo repetido
+seguro(IdSeg,_,_) :: (solucoes(IdSeg, (seguro(IdSeg,_,_)), S),
                    comprimento(S,1)).

% Invariante Estrutural: nao permitir a insercao de conhecimento negativo repetido
+(-seguro(IdSeg,D,T)) :: (solucoes(IdSeg, -seguro(IdSeg,D,T), S),
													comprimento(S, 1)).



%-----------------INVARIANTES QUE DESIGNEM RESTRICOES À REMOCAO DE CONHECIMENTO DO SISTEMA-----------------%

%-----------------UTENTE-----------------%

% Invariante Referencial: um utente so pode ser removido se nao existir consultas associadas a este.
-utente(ID,_,_,_,_) :: nao(consulta(_,ID,IDS,_,_)).

%-----------------SERVICO-----------------%

% Invariante Referencial:  nao permitir a remoção dum serviço se existirem consultas associadas a este.
-servico(ID,_,_,_) :: nao(consulta(_,_,ID,_,_)).

%-----------------MEDICO-----------------%

% Invariante Referencial:  nao permitir a remoção dum medico se existirem consultas associadas a este.
-medico(ID,_,_,_) :: nao(consulta(_,_,_,_,ID)).





%--------------------------EVOLUCAO E REGRESSAO DO CONHECIMENTO--------------------------%

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado evolucaoPerfeito: evolucaoPerfeito -> {V,F}

% Evolucao de conhecimento perfeito que remove conhecimento imperfeito

% UTENTE
evolucaoPerfeito(utente(Id,Nome,Idade,Morada,Seguro)):-
	si(utente(Id,Nome,Idade,Morada,Seguro), desconhecido),
	solucoes(utente(Id,N,I,M,S), utente(Id,N,I,M,S), Lista),
	removerLista(utente(Id,Nome,Idade,Morada,Seguro), Lista).

evolucaoPerfeito(utente(Id,Nome,Idade,Morada,Seguro)):-
	si(utente(Id,Nome,Idade,Morada,Seguro), falso),
    evolucao(utente(Id,Nome,Idade,Morada,Seguro)).

evolucaoPerfeito(-utente(Id,Nome,Idade,Morada,Seguro)):-
	si(-utente(Id,Nome,Idade,Morada,Seguro), verdadeiro),
    evolucao(-utente(Id,Nome,Idade,Morada,Seguro)).

% SERVICO
evolucaoPerfeito(servico(Id,Descricao,Instituicao,Cidade)):-
	si(servico(Id,Descricao,Instituicao,Cidade), desconhecido),
	solucoes(servico(Id,D,I,C), servico(Id,D,I,C), Lista),
	removerLista(servico(Id,Descricao,Instituicao,Cidade), Lista).

evolucaoPerfeito(servico(Id,Descricao,Instituicao,Cidade)):-
	si(servico(Id,Descricao,Instituicao,Cidade), falso),
    evolucao(servico(Id,Descricao,Instituicao,Cidade)).

evolucaoPerfeito(-servico(Id,Descricao,Instituicao,Cidade)):-
	si(-servico(Id,Descricao,Instituicao,Cidade), verdadeiro),
    evolucao(-servico(Id,Descricao,Instituicao,Cidade)).

% CONSULTA
evolucaoPerfeito(consulta(Data,IdUtente,IdServico,Custo,IdMedico)):-
	si(consulta(Data,IdUtente,IdServico,Custo,IdMedico), desconhecido),
	solucoes(consulta(Data,IdUtente,IdServico,Custo,IdMedico), consulta(Data,IdUtente,IdServico,Custo,IdMedico), Lista),
	removerLista(consulta(Data,IdUtente,IdServico,Custo,IdMedico), Lista).

evolucaoPerfeito(consulta(Data,IdUtente,IdServico,Custo,IdMedico)):-
	si(consulta(Data,IdUtente,IdServico,Custo,IdMedico), falso),
    evolucao(consulta(Data,IdUtente,IdServico,Custo,IdMedico)).

evolucaoPerfeito(-consulta(Data,IdUtente,IdServico,Custo,IdMedico)):-
	si(-consulta(Data,IdUtente,IdServico,Custo,IdMedico), verdadeiro),
    evolucao(-consulta(Data,IdUtente,IdServico,Custo,IdMedico)).

% MÉDICO
evolucaoPerfeito(medico(IdMedico,Nome,Idade,IdServico)):-
	si(medico(IdMedico,Nome,Idade,IdServico), desconhecido),
	solucoes(medico(IdMedico,N,I,IdS), medico(IdMedico,N,I,IdS), Lista),
	removerLista(medico(IdMedico,Nome,Idade,IdServico), Lista).

evolucaoPerfeito(medico(IdMedico,Nome,Idade,IdServico)):-
	si(medico(IdMedico,Nome,Idade,IdServico), falso),
    evolucao(medico(IdMedico,Nome,Idade,IdServico)).

evolucaoPerfeito(-medico(IdMedico,Nome,Idade,IdServico)):-
	si(-medico(IdMedico,Nome,Idade,IdServico), verdadeiro),
    evolucao(-medico(IdMedico,Nome,Idade,IdServico)).

% SEGURO
evolucaoPerfeito(seguro(IdSeguro,Descricao,Taxa)):-
	si(seguro(IdSeguro,Descricao,Taxa), desconhecido),
	solucoes(seguro(IdSeguro,D,T), seguro(IdSeguro,D,T), Lista),
	removerLista(seguro(IdSeguro,Descricao,Taxa), Lista).

evolucaoPerfeito(seguro(IdSeguro,Descricao,Taxa)):-
	si(seguro(IdSeguro,Descricao,Taxa), falso),
    evolucao(seguro(IdSeguro,Descricao,Taxa)).

evolucaoPerfeito(-seguro(IdSeguro,Descricao,Taxa)):-
	si(-seguro(IdSeguro,Descricao,Taxa), verdadeiro),
    evolucao(-seguro(IdSeguro,Descricao,Taxa)).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado regressaoPerfeito: regressaoPerfeito -> {V,F}

% Regressao de conhecimento perfeito que remove conhecimento perfeito

regressaoPerfeito(Termo) :-
    si(Termo,verdadeiro),
    regressao(Termo).

regressaoPerfeito(-Termo) :-
    si(-Termo,verdadeiro),
    regressao(-Termo).





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
% Extensão do predicado que permite a remoção duma lista de conhecimento
removerLista( Termo,L ) :-
    retractLista( L ),
    evolucao(Termo).
removerLista( Termo,L) :-
    assertLista( L ),!,fail.

retractLista([]).
retractLista([X|L]):-
		retract(X),
		retractLista(L).

assertLista([]).
assertLista([X|L]):-
		assert(X),
assertLista(L).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensão do predicado que realiza o teste do conhecimento
teste([]).
teste([R|LR]) :-
    R,
    teste(LR).




%--------------------------SISTEMA DE INFERENCIA--------------------------%

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do meta-predicado si: Questao,Resposta -> {V,F}
%                            Resposta = { verdadeiro,falso,desconhecido }

si(Questao && X, V) :- si(Questao, V1), si(X, V2), conjuncao(V1, V2, V), !.
si(Questao $$ X, V) :- si(Questao, V1), si(X, V2), disjuncao(V1, V2, V), !.
si(Questao => X, V) :- si(Questao, V1), si(X, V2), implicacao(V1, V2, V), !.
si(Questao <=> X, V) :- si(Questao, V1), si(X, V2), equivalencia(V1, V2, V), !.

conjuncao(verdadeiro, verdadeiro, verdadeiro).
conjuncao(falso, _, falso).
conjuncao(_, falso, falso).
conjuncao(desconhecido, verdadeiro, desconhecido).
conjuncao(verdadeiro, desconhecido, desconhecido).

disjuncao(verdadeiro, X, verdadeiro).
disjuncao(X, verdadeiro, verdadeiro).
disjuncao(desconhecido, Y, desconhecido) :- Y \= verdadeiro.
disjuncao(Y, desconhecido, desconhecido) :- Y \= verdadeiro.
disjuncao(falso, falso, falso).

implicacao(falso, X, verdadeiro).
implicacao(X, verdadeiro, verdadeiro).
implicacao(verdadeiro, desconhecido, desconhecido).
implicacao(desconhecido, X, desconhecido) :- X \= verdadeiro.
implicacao(verdadeiro, falso, falso).

equivalencia(X, X, verdadeiro) :- X \= desconhecido.
equivalencia(desconhecido, Y, desconhecido).
equivalencia(X, desconhecido, desconhecido).
equivalencia(verdadeiro, falso, falso).
equivalencia(verdadeiro, falso, falso).

si(Questao,verdadeiro) :-
    Questao.
si(Questao,falso) :-
    -Questao.
si(Questao,desconhecido) :-
    nao(Questao),
    nao(-Questao).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do meta-predicado nao: Questao -> {V,F}

nao(Questao) :-
    Questao, !, fail.
nao(Questao).





%--------------------------GUARDAR EM FICHEIRO--------------------------%

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
