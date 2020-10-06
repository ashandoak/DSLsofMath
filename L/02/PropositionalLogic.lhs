%if false
\begin{code}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE EmptyCase #-}
module DSLsofMath.PropositionalLogic where
\end{code}
%endif

\subsection{Propositional Calculus}
\label{sec:PropFrag} % yep, the propositional calculus is a propositional fragment of other logics, such as FOL.

Our first DSL for this chapter is the language of \emph{propositional
  calculus} (or propositional logic), modelling simple propositions with the usual
combinators for and, or, implies, etc.
%
\lnOnly{(The Swedish translation is ``satslogik'' and some more Swe-Eng
translations are collected on the GitHub page of these lecture notes\footnote{\url{https://github.com/DSLsofMath/DSLsofMath/wiki/Translations-for-mathematical-terms}}.)}
%
When reading a logic book, one will encounter several concrete syntactic constructs related to propositional logic, which are collected in
Table~\ref{tab:PropCalc}. Each row lists common synonyms and their arity (number of arguments).
%
\begin{table}[htbp]
  \centering
\begin{tabular}{lccl}
   |False|    & $\bot$         & F      & nullary
\\ |True|     & $\top$         & T      & nullary
\\ |Not|      & $\neg$         & |~|    & unary
\\ |And|      & $\wedge$       & |&|    & binary
\\ |Or|       & $\vee$         & |bar|  & binary
\\ |Implies|  & $\supset$      & |=>|   & binary
\end{tabular}
\caption{Syntax for propositions. In addition, |a|, |b|, |c|, \ldots are used as names of propositions}
\label{tab:PropCalc}
\end{table}

Some example propositions will include \(|p1| = a \wedge (\neg a)\),
\(|p2| = a \Rightarrow b\), \(|p3| = a \vee (\neg a)\),
\(|p4| = (a \wedge b) \Rightarrow (b \wedge a)\).
%
The names |a|, |b|, |c|, \ldots are ``propositional variables'': they
can be substituted for any proposition. We could call them ``variables'', but in upcoming sections we will add
another kind of variables (and quantification over them) to the
calculus --- so we keep calling them ``names'' to avoid mixing them
up.


%
Just as we did with simple arithmetic, and with complex number
expressions in \cref{sec:DSLComplex}, we can model the abstract
syntax of propositions as a datatype:
\begin{code}
data Prop  =  Con      Bool
           |  Not      Prop
           |  And      Prop  Prop
           |  Or       Prop  Prop
           |  Implies  Prop  Prop
           |  Name     Name
type Name = String
\end{code}
%
The example expressions can then be expressed as
%
\begin{code}
p1 = And (Name "a") (Not (Name "a"))
p2 = Implies (Name "a") (Name "b")
p3 = Or (Name "a") (Not (Name "a"))
p4 = Implies (And a b) (And b a)
  where a = Name "a"; b = Name "b"
\end{code}
%
Because ``names'' stand for propositions, if we assign 
truth values for the names, we can compute a truth value of the whole
proposition for the assignment in question.
%

\subsubsection{An Evaluator for |Prop|}
Let us formalise this in general,
by writing an evaluator which takes
a |Prop| term to its truth value.

(The evaluation function for a DSL describing a logic is often called
|check| instead of |eval| but for consistency we stick to |eval|.)
%
\begin{code}
eval :: Prop -> (Name -> Bool) -> Bool
eval (Implies p q)  env = eval p env `implies` eval q env
eval (And p q)      env = eval p env && eval q env
eval (Or  p q)      env = eval p env || eval q env
eval (Not p)        env = not (eval p env)
eval (Name n)       env = env n
eval (Con t)        env = t

implies :: Bool -> Bool -> Bool
implies False  _  =  True
implies _      p  =  p
\end{code}
%
The function |eval| translates from the syntactic domain to the semantic
domain, given an environment (an assignment of names to truth values), which we represent as a function from each |Name| to |Bool|.
.
Here |Prop| is the (abstract) \emph{syntax} of the language of
propositional calculus and |Bool| is the \emph{semantic
  domain}, and |Name -> Bool| is a necessary extra parameter to write the function.
%
Alternatively, and perhaps more elegantly, we can view |(Name -> Bool) -> Bool| as the semantic domain.
%
\subsubsection{Truth tables and tautologies}
%
\begin{wrapfigure}{R}{0.17\textwidth}
  \centering
\begin{tabular}{||l||l||}
    \hline   a & t
  \\\hline   F & T
  \\         T & T
  \\\hline
\end{tabular}
\caption{|F => a|}
\label{fig:F2a}
\end{wrapfigure}
%
As a first example of a truth table, consider the proposition |F => a|
which we call |t| here.
%
% We will use the shorter notation with just |T| for true and |F| for
% false.
%
The truth table semantics of |t| is usually drawn as in~\refFig{fig:F2a}:
%
one column for the name |a| listing all combinations of |T| and |F|,
and one column for the result of evaluating the expression.
%
This table shows that no matter what value assignment we try for the
only variable |a|, the semantic value is |T = True|.
%
Thus the whole expression could be simplified to just |T| without
changing its semantics.

\begin{wrapfigure}{R}{0.35\textwidth}
  \centering
\begin{tabular}{||lllllll||}
    \hline   |a| & |&| & |b| & |=>| & |b| & |&| & |a|
  \\\hline    F  &  F  &  F  &  T   &  F  &  F  &  F
  \\          F  &  F  &  T  &  T   &  T  &  F  &  F
  \\          T  &  F  &  F  &  T   &  F  &  F  &  T
  \\          T  &  T  &  T  &  T   &  T  &  T  &  T
  \\\hline
\end{tabular}
\caption{\(|p4| = (a \wedge b) \Rightarrow (b \wedge a)\).
}
\label{fig:abswap}
\end{wrapfigure}
%
If we continue with the example |p4| from above we have two names |a|
and |b| which together can have any of four combinations of true and
false.
%
After the name-columns are filled, we fill in the rest of the table
one operation (column) at a time (see \refFig{fig:abswap}).
%
The |&| columns become |F F F T| and finally the |=>| column (the
output) becomes true everywhere.
%
For our other examples, |p1| is always false, |p2| is mixed and |p3| is always true.

A proposition whose truth table output is constantly true is called a
\emph{tautology}.
%
Thus |t|, |p3| and |p4| are tautologies. We can formalise this idea as the following tautology-tester:
\begin{code}
isTautology :: Prop -> Bool
isTautology p = and [eval p e | e <- envs (freeNames p)]
\end{code}
which uses the following intermediate function to generate all possible environments for a given list of names
\begin{code}
envs :: [Name] -> [Name -> Bool]
envs (n:ns) = [\n' -> if n == n' then b else e n' | b <- [True,False], e <- envs ns]
\end{code}
and a function to find all names in a proposition:
\begin{code}
freeNames :: Prop -> [Name]
freeNames = error "exercise"
\end{code}
%
Truth table verification is only viable for propositions with few
names because of the exponential growth in the number of cases to
check: we get $2^n$ different |truthTables| for |n| names.
%

% *TODO: formulate more clearly as an exercise
\begin{exercise}
At this point it is good to implement a few utility functions on
|Prop|: list the names used in a term (|freeNames|), simplify to disjunctive
normal form, simplify to conjunctive normal form, etc.
(Conjunctive normal form: allow only |And|, |Or|, |Not|, |Name| in that
order in the term.)
\end{exercise}

There are much better algorithms to evaluate truth values than the naive one we just showed,
but we will not go this route.  Rather, we can introduce the notion of \emph{proof}.
(And in fact, the best (known) algorithms remain exponential in the number of variables.)


\subsubsection{Proofs for Propositional Logic}

Given a |Prop|osition |p| and a proof |t| (represented as
an element of another type |Proof|), we can write a function that checks
that |t| is a valid proof of |p|:

\begin{code}
checkProof :: Proof -> Prop -> Bool
\end{code}

But we still have to figure out what consitutes proofs.

To prove |And P Q|, one needs simultaneously of |P| and a proof of
|Q|. (In logic texts, one will often find
\[ \frac{P \quad Q}{P \and Q} \] to represent this fact, which is called the \emph{introduction rule for (∧)})
(For the proof to be complete, one still needs to provide a full proof of |P| and another for |Q| --- it is not enough to just invoke this rule.)

Therefore, in Haskell, can represent this rule with the following proof-term constructor:
\begin{spec}
AndIntro :: Proof -> Proof -> Proof
\end{spec}

and, the corresponding case of the |checkProof| function will look like this:

\begin{spec}
checkProof (AndIntro t u) (And p q) = checkProof t p && checkProof u q
\end{spec}

To prove |Or P Q|, we need either a proof of |P| or proof of |Q| --- but
we need to know which side (|Left| for |p| or |Right| for |q|) we
refer to.  Therefore, we need a proof-term constructor:

\begin{spec}
OrIntro :: Either Proof Proof -> Proof
\end{spec}
\jp{insert Either.lhs here?}

To deal with negation, one approach is to push it down using de Morgan
laws until we reach names (Exercise \jp{ref?}). Another approach is to use the following rule:
\[ \frac{P → Q \quad P → ¬Q}{¬P} \], which we can represent by the
|NegIntro :: Prop -> Proof -> Proof -> Proof| constructor. Here, we have an additional |Prop| argument,
which gives the |Q| formula.


In addition to introduction rules (where the connective appears as
conclusion), we also have elimination rules (where the connective
appears as premiss). For conjuction, we have two eliminations rules: $\frac{P ∧ Q}{P}$ and
$\frac{P ∧ Q}{Q}$. Because we have inductive proofs (described from the bottom up),
we have the additional difficulty that these rules conjure-up a new
proposition, $Q$. So we represent them respectively by |AndElim1 :: Proof -> Prop -> Proof| (and |AndElim2| symmetrically),
where the extra |Prop| argument corresponds to |Q|.

Our eliminator of disjunction is $\frac {P ∨ Q \quad P → R \quad Q → R} R$.\jp{finish}
Our eliminator for negation is $\frac {¬ ¬ P} P$

We can then write our proof checker as follows:

Truth/Falsity

\begin{code}
checkProof TruthIntro (Con True) = True
checkProof (AndIntro t u) (And p q) = checkProof t p && checkProof u q
checkProof (OrIntro (Left t)) (Or p q) = checkProof t p
checkProof (OrIntro (Right t)) (Or p q) = checkProof t q
checkProof (NotIntro t u q) (Not p) = checkProof t (p `Implies` q) && checkProof u (p `Implies` Not q)
checkProof (AndElimL t q) p = checkProof t (p `And` q)
checkProof (AndElimR t p) q = checkProof t (p `And` q)
checkProof (OrElim t u v p q) r = checkProof t (p `Implies` r) && checkProof u (q `Implies` r) && checkProof v (Or p q)
checkProof (NotElim t) p = checkProof t (Not (Not p))
checkProof (FalseElim t) p = checkProof t (Con False)
\end{code}

Any other combination of proof/prop else is an incorrect combination: the proof is not valid for the proposition.


|checkProof :: Prop -> Proof -> Bool|

It can be interesting to note that, seeing |checkProof| as an evaluator,
one can understand |Proof -> Bool|, a subset of propositions, as the semantic domain of |Prop|.


\subsubsection{Implication, hypothetical derivations, contexts}

For |Implies|, we can use the so-called material implication
definition which we invoked earlier in truth tables. It means to define |Implies a b =
(Not a) `Or` b|. However this choice does not bring any new insight.

Another possibility is a rule which can be written like so:\[\frac{\begin{array}{c}P \\ \vdots \\ Q \end{array}}{P → Q}\].
Such a notation can however be terribly confusing. We were used to the fact that proofs above the line had to be continued. So what can the dots possibly mean?
The intent is that, to prove $P → Q$, it suffices to prove $Q$, but one is allowed to use $P$ as an assumption in the proof of $Q$.

We can use our DSL to make this formal, by adding a constructor for implication introduction: |ImplyIntro :: (Proof -> Proof) -> Proof|.
The fact that the premiss can depend on the assumption |Q| is represented by a function whose parameter is the proof of |Q| in question.

In other words, to prove the formula |P -> Q| we assume a proof |p :
P| and derive a proof |q : Q|, so a proof of an implication is a
function from proofs to proofs.

The eliminator for implication, known as \textit{modus ponens} is \(\frac{P → Q \quad P} Q\). We formalise it as |ImplyElim :: Proof -> Proof -> Prop -> Proof|
(The proposition |P| is a not given by the conclusion). We complete our proof checker as follows:

\begin{code}
checkProof Assumption p = True
checkProof (ImplyIntro f) (p `Implies` q) = checkProof (f Assumption) q
checkProof (ImplyElim t u p) q = checkProof t (q `Implies` p) && checkProof u q
checkProof _ _ = False -- incorrect proof
\end{code}
with the DSL for proofs being:

\begin{code}
data Proof  =  Assumption
            |  TruthIntro
            |  FalseElim Proof
            |  AndIntro Proof Proof
            |  AndElimL Proof Prop
            |  AndElimR Proof Prop
            |  OrIntro (Either Proof Proof)
            |  OrElim Proof Proof Proof Prop Prop
            |  NotIntro Proof Proof Prop
            |  NotElim Proof
            |  ImplyIntro (Proof -> Proof)
            |  ImplyElim  Proof Proof Prop
\end{code}


\paragraph{Aside}
The |Assumption| constructor may make the reader somewhat uneasy: how come that we can simply assume anything? The intent is that this
constructor is private to the |checkProof| function (or module). No user-defined proof can use it. The most worried readers
can also define the following version of |checkProof|, which uses an extra context to check that assumption have been rightfully introduced earlier.
\footnote{This kind of presentation of the checker matches well the sequent calculus presentation of the proof system.}
 
\begin{spec}
checkProof :: Context -> Proof -> Prop -> Bool
checkProof ctx (ImplyIntro t) (p `Implies` q) = checkProof' (p:ctx) t q
checkProof ctx Assumption p = p `elem` ctx
\end{spec}

\paragraph{Example proof}

\begin{code}
conjunctionCommutative = (a `And` b) `Implies` (b `And` a)
  where a = Name "a"; b = Name "b"

conjunctionCommutativeProof =
  ImplyIntro (\aAndb ->
  AndIntro  (AndElimR aAndb (Name "a"))
            (AndElimL aAndb (Name "b")) )

\end{code}

|checkProof conjunctionCommutativeProof conjunctionCommutative == True|

\paragraph{Using the Haskell type-checker as a proof checker}

What if we could do this:

\begin{code}
conjunctionCommutativeProof' :: (p `And` q) `Implies` (q `And` p)
conjunctionCommutativeProof' =
   implyIntro (\evPQ ->
   andIntro  (andElimR evPQ)
             (andElimL evPQ))
\end{code}
(where |evPQ| stands for "evidence for |P| and |Q|.")

Instead of writing propositions, we write types.

We would not have to run (or for that matter write) a proof checker: the haskell type-checker does the work for us.

Notice that Haskell will not accept
%
\begin{spec}
conjunctionCommutativeProof' =
   implyIntro (\evPQ ->
   andIntro  (andElimL evPQ)
             (andElimR evPQ))
\end{spec}
%
unless we change the type.


Well we can do it!


First, we can use the type-checker to encode the proof rules as programs:
\begin{code}
implyIntro :: (p -> q) -> (p `Implies` q)
implyElim :: p -> (p `Implies` q) -> q

andIntro :: p -> q -> And p q
andElimL :: a `And` b -> a
andElimR :: a `And` b -> b

orIntro :: Either a b -> Or a b
orElim :: Or p q -> (p `Implies` r) -> (q `Implies` r) -> r

falseElim :: False -> p -- ex falso quod libet

notElim        ::  Not (Not p) -> p

notIntro       ::  (p -> q) `And`  (p -> Not q) -> Not p
\end{code}

(Attn. diverging proofs/programs!)


\subsubsection{Logic as impoverished typing rules}
Another view of the above.

Typing rule for function application:

\(\frac{f : A → B \quad x : A}{f(x) : B}\)

Modus ponens is a version of application typing rule with program erased.
In general, such is the case for all logical rules.

The \emph{Curry--Howard correspondence} is a general principle that
says that we can think of propositions as types and proofs as
programs. This principle goes beyond propositional logic (and first
order logic, etc.): it applies to all sorts of logics and programming
languages.


%{
%let tupling = True
%include AbstractFOL.lhs
%let tupling = False
%}



\subsubsection{Intuitionistic Propositional Logic and Simply Typed Lambda-Calculus, Curry-Howard isomorphism.}

|Implies| is fundamental; |Not| is not.

\begin{code}
type Not a = a `Implies` False

notElim = error "not possible as such in Haskell"

notIntro (f,g) x = g x (f x)
\end{code}

It should come as no surprise that the ``API'' for implication can be implemented by
|Implies = (->)|, which means that both |impIntro| and |impElim| can be
implemented as |id|.


But also, because the meaning of a proof of conjuction is exactly a pair of proofs, etc.

Conjunction is represented as pairs; that is, if |p : P| and |q : Q| then |(p,q) : And P Q|.

%
If we see these introduction and elimination rules as an API, what
would be a reasonable implementation of the datatype |And p q|?
%
A type of pairs!
%
Then we see that the corresponding Haskell functions would be
%


Similarly, disjuction becomes |Either|.
%
If |p : P| then |Left p : Or P Q| and if |q : Q| then |Right q : Or P
Q|.
%
In this way we can build up what is called ``proof terms'' for a large
fragment of logic.
%
It turns out that each such proof term is basically a program in a
functional programming language, and that the formula a certain term
proves is the type for the program.


\begin{code}
type Implies p q = p -> q
implyElim a f = f a
implyIntro f x = f x

type And p q = (p,q)
andIntro t u = (t,u)
andElimL = fst
andElimR = snd

type Or a b = Either a b
orIntro x = x
orElim (Left   t) u _ = u t
orElim (Right  t) _ v = v t

type Truth = ()
truthIntro = ()

data False
falseElim x = case x of {}
\end{code}

Another example, which is very useful, is ``ex falso quodlibet'',
latin for ``from falsehood, anything (follows)''
\jp{Why this stranglely complicated version instead of forall r. BOT -> r}
%
\begin{code}
exFalso :: False -> p
exFalso = falseElim
\end{code}

\subsubsection{|Or| is the dual of |And|.}
Before moving on ...
%
Most of the properties of |And| have corresponding properties for |Or|.
%
Often it is enough to simply swap the direction of the ``arrows''
(implications) and swap the role between introduction and elimination.

Here the implementation type can be a labelled sum type, also called
disjoint union and in Haskell:
%
%include Either.lhs
%
%*TODO: Perhaps add an example with (q->p) -> (Not p -> Not q)
%*TODO: Perhaps add an example with (p->p')->(q->q')->(And p q -> And p q)
%*TODO: Perhaps add an example with (p->p')->(q->q')->(Or  p q -> Or  p q)
%*TODO: Explain that the values of type |And p q| can be seen as "proofs" (abstract or concrete).
%

