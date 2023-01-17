Some live coding from the second half of lecture 1 (week 1).
(DSLsofMath course, 2022).

This file is an example of a "literate Haskell file" where the
default (like this intro text) is comment and code blocks are
enclosed in "\begin{code}" and "\end{code}."

\begin{code}
module Live1_2023 where
import Data.Ratio

r :: Rational
r = 3%2

f x = x^2

\end{code}

The function |f| can be given different types:

\begin{code}
f1 :: Integer -> Integer
f1 = f
f2 :: Float -> Float
f2 = f
f3 :: Rational -> Rational
f3 = f
-- and the most general:
f :: Num a =>    a -> a

-- all values of type B->B
allBtoBs :: [Bool -> Bool]
allBtoBs = error "TODO"

b1 = allBtoBs !! 0  
b2 = allBtoBs !! 1
b3 = allBtoBs !! 2
b4 = allBtoBs !! 3

-- all values of type B->B->B
exercise :: [Bool -> Bool -> Bool]
exercise = [(&&), (||) ] -- ... should be quite a few more (2^(2^2) in total)
\end{code}

The type class Num has the operations (+), (*), (-), fromInteger (ask
 ghci with ":i" to get the full list) but not the operation (/).

Fractional has the operations from Num and also division (/).

\begin{code}
g :: Fractional a => a -> a
g x = x / x    -- 1 om x/=0, annars?
\end{code}

Float and Double have
+ finite precision (most real numbers are missing)
+ but also extra values: NaN, Infinity, -Infinity, and a few more


div :: Int -> Int -> Maybe Int

\begin{code}
inf :: Double -- an approximation of the REAL number type
inf = 1/0

nan :: Double
nan = 0/0
\end{code}

Associative(+) = forall x,y,z. (x+y)+z == x+(y+z)
Note: Float and Double are _not_ associative (but almost)

\begin{code}
lhs, rhs :: Num a => a -> a -> a -> a
lhs x y z =  (x+y)+z
rhs x y z =  x+(y+z)

checkAssoc :: (Eq a, Num a) => a -> a -> a -> (a, a, a, Bool)
checkAssoc x y z = (l, r, l-r, l == r)
  where
    l = lhs x y z
    r = rhs x y z

nonAssoc :: (Double, Double, Double, Bool)
nonAssoc = checkAssoc (1/3) 1 1

isAssoc :: (Rational, Rational, Rational, Bool)
isAssoc = checkAssoc (1/3) 1 1
\end{code}

----------------

The data declaration below defines the new type E and three new
constructor functions: Add, Mul, och Con.

forall x. x*0 == 0

\begin{code}
data E
\end{code}

E is a type of abstract syntax trees.
   can represent simple functions
   (not only 1-argument expressions)

semantics = meaning

"meaning-assigning function"

translator from an abstract (un-interpreted) syntax to some meaningful value type (the semantic type)

\begin{code}
a1, a2 :: E
a1 = error "TODO"    -- 1+(2*3)
a2 = error "TODO"    -- (1+2)*3
a3 = error "TODO"    -- x^2
\end{code}

We can evaluate (translate) an E to an integer:

-- DSL for simple arithemtic expressions
eval  ::  Syntax  ->  Semantics
eval  ::  E       ->  Integer
-- the semantic domain is integers
\begin{code}
type AbsSyn = E
type SimpleSem = Integer
type Sem = Integer -> Integer
eval :: AbsSyn  ->  Sem
eval = error "TODO"

addE :: Sem -> Sem -> Sem
addE = error "TODO"

mulE :: Sem -> Sem -> Sem
mulE = error "TODO"
\end{code}
