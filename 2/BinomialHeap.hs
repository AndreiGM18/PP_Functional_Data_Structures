{- Mitran Andrei-Gabriel, 323CA, 2023 -}

module BinomialHeap where

import Data.Function (on)
import Data.List

{-
    Reprezentarea unui arbore binomial, având priorități de tipul p și chei
    de tipul k. Conform proprietății definitorii a acestor arbori, fiecare
    copil i dintre cei r copii ai unui nod de rang r, cu 1 <= i <= r, trebuie
    să aibă exact r-i copii la rândul său, adică r-1, r-2, ..., 1, 0 copii,
    exact în această ordine descrescătoare. Dacă rădăcina are r copii, atunci,
    în conjuncție cu proprietate anterioară, întregul arbore are 2^r noduri.
-}
data BinomialTree p k
    = EmptyTree
    | Node { prio :: p, key :: k, children :: [BinomialTree p k] }
    deriving (Show, Eq)

{-
    Reprezentarea unui heap binomial, ca listă de arbori binomiali ce respectă
    proprietatea de heap. Mai precis, considerăm că, în fiecare arbore binomial,
    rădăcina are cea mai mică prioritate; analog pt subarbori. Câmpul size
    desemnează numărul de elemente din heap (nu numărul de arbori). Mai precis,
    dimensiunea este egală cu suma dimensiunilor arborilor din listă. Cum
    dimensiunea unui arbore de rang r este 2^r, dimensiunea este o sumă
    de puteri ale lui 2, unde exponenții sunt dimensiunile câmpurilor children
    (rangurile) din rădăcinile arborilor nevizi.
-}
data BinomialHeap p k = BinomialHeap { size :: Int, trees :: [BinomialTree p k] }
    deriving (Show, Eq)

{-
    Construiește recursiv un arbore binomial de rang r din doi arbori binomiali
    de rang r-1, atașând unul dintre arbori drept prim copil al rădăcinii
    celuilalt. Maniera în care se realizează atașarea trebuie să țină cont
    de faptul că cei doi arbori respectă proprietatea de heap, și că arborele
    rezultant trebuie de asemenea să o respecte. Astfel, arborele cu cheia mai
    mică din rădăcină trebuie să încorporeze arborele cu cheia mai mare.

    Atenție! Cei doi arbori primiți ca parametru au întotdeauna același rang,
    conform principiului de construcție. Funcția nu necesită parcurgeri
    recursive, putând opera direct la nivelul rădăcinilor.

    Constrângeri: utilizați gărzi.

    Hint: pt pattern matching, pot fi utile alias-urile (@).

    Exemple:

    > attach (Node 0 'a' []) (Node 1 'b' [])
    Node {prio = 0, key = 'a', children = [Node {prio = 1, key = 'b', children = []}]}

    > attach (Node 1 'b' []) (Node 0 'a' [])
    Node {prio = 0, key = 'a', children = [Node {prio = 1, key = 'b', children = []}]}
-}
attach :: Ord p => BinomialTree p k -> BinomialTree p k -> BinomialTree p k
attach tree1 EmptyTree = tree1
attach EmptyTree tree2 = tree2
attach tree1@(Node p1 k1 ch1) tree2@(Node p2 k2 ch2)
    | p1 <= p2 = tree1{children = tree2:ch1}
    | otherwise = tree2{children = tree1:ch2}

{-
    Introduce un arbore binomial nevid într-o listă cu alți arbori binomiali,
    toți arborii respectând proprietatea de heap. Cum nu pot exista simultan
    în listă doi arbori binomiali cu același rang, la întâlnirea unui arbore
    cu același rang cu cel care se dorește introdus, este necesară atașarea
    unuia la celălalt, cu crearea unui transport.

    Operația o oglindește pe cea de incrementare a unui număr binar din etapa 1.
    Astfel, elementele EmptyTree sunt analoagele biților 0, iar elementele Node,
    biților 1. O diferență este că, în această etapă, biții 1 „nu mai arată toți
    la fel”, ci elementele Node au rangul dat de poziția în listă. Spre exemplu:
    * un element Node de pe poziția 0 din listă trebuie să aibă rangul 0
      (dimensiunea 2^0 = 1)
    * un element Node de pe poziția 1 din listă trebuie să aibă rangul 1
      (dimensiunea 2^1 = 2)
    * un element Node de pe poziția 2 din listă trebuie să aibă rangul 2
      (dimensiunea 2^2 = 4)
    etc.

    Gestiunea transportului apărut în incrementare corespunde operației attach.
    Modul în care va fi utilizată mai departe funcția insertTree garantează
    respectarea presupunerilor funcției attach, cum că arborii primiți ca
    parametru au întotdeauna același rang.

    Constrângeri: utilizați
    * construcția case
    * funcția attach.

    Exemple:

    > insertTree (Node 1 'a' []) []
    [Node {prio = 1, key = 'a', children = []}]

    > insertTree (Node 2 'b' []) $ insertTree (Node 1 'a' []) []
    [ EmptyTree
    , Node {prio = 1, key = 'a', children = [Node {prio = 2, key = 'b', children = []}]}
    ]

    > insertTree (Node 3 'c' []) $ insertTree (Node 2 'b' []) $ insertTree (Node 1 'a' []) []
    [ Node {prio = 3, key = 'c', children = []}
    , Node {prio = 1, key = 'a', children = [Node {prio = 2, key = 'b', children = []}]}
    ]
-}
insertTree :: Ord p => BinomialTree p k -> [BinomialTree p k] -> [BinomialTree p k]
insertTree tree trees = case trees of
    [] -> [tree]
    [EmptyTree] -> [tree]
    [t] -> [EmptyTree, attach t tree]
    EmptyTree:ts -> tree:ts
    t:ts -> EmptyTree:insertTree (attach t tree) ts

{-
    Heap-ul vid.
-}
emptyHeap :: BinomialHeap p k
emptyHeap = BinomialHeap 0 []

{-
    Introduce o cheie cu prioritatea aferentă într-un heap binomial.

    Constrângeri: utilizați funcția insertTree.

    Exemple:

    > insert 1 'a' emptyHeap
    BinomialHeap 
        { size = 1
        , trees = [Node {prio = 1, key = 'a', children = []}]
        }

    > insert 2 'b' $ insert 1 'a' emptyHeap
    BinomialHeap
        { size = 2
        , trees = [ EmptyTree
                  , Node {prio = 1, key = 'a', children = [Node {prio = 2, key = 'b', children = []}]}
                  ]
        }

    > insert 3 'c' $ insert 2 'b' $ insert 1 'a' emptyHeap
    BinomialHeap 
        { size = 3
        , trees = [ Node {prio = 3, key = 'c', children = []}
                  , Node {prio = 1, key = 'a', children = [Node {prio = 2, key = 'b', children = []}]}
                  ]
        }
-}
insert :: Ord p => p -> k -> BinomialHeap p k -> BinomialHeap p k
insert prio key heap@(BinomialHeap s ts) = BinomialHeap newS $ insertTree t ts
    where newS = s + 1
          t = Node prio key []

{-
    Dacă heap-ul nu este vid, întoarce perechea formată din prioritatea minimă
    și cheia aferentă; în caz contrar, întoarce Nothing. Cum toți arborii din
    listă respectă proprietatea de heap, este suficient să parcurgeți doar
    rădăcinile pt a o determina pe cea cu prioritate minimă, fără a fi necesară
    explorarea nivelurilor inferioare ale arborilor.

    Constrângeri: pt selectarea arborilor nevizi din listă (ignorând elementele
    EmptyTree), utilizați list comprehension cu pattern matching.

    Hint: pt determinarea elementului minim dintr-o listă pe baza valorii
    calculate de o funcție numită criteriu, utilizați o expresie de forma:
    minimumBy (compare `on` criteriu) lista.

    Exemple:

    > findMin emptyHeap
    Nothing

    > findMin $ insert 3 'c' $ insert 2 'b' $ insert 1 'a' emptyHeap
    Just (1,'a')
-}
findMin :: Ord p => BinomialHeap p k -> Maybe (p, k)
findMin heap@(BinomialHeap s ts) = if isEmptyHeap heap then Nothing else Just (p, k)
    where min@(Node p k ch) = minimumBy (compare `on` prio) [t | t <- trees heap, isTree t]
          isTree EmptyTree = False
          isTree _ = True
          isEmptyHeap heap = s == 0 && null ts

{-
    Funcția zipExtend este similară funcției predefinite zip. Scopul ei este
    de a compensa limitarea funcției zip, care se oprește când atinge sfârșitul
    listei mai scurte. Primii doi parametri reprezintă valori cu care se extind
    prima, respectiv a doua listă, în funcție de care listă este mai scurtă.
    O puteți folosi în cele ce urmează.

    Exemple:

    > zipExtend 0 'z' [1,2] "abcd"
    [(1,'a'),(2,'b'),(0,'c'),(0,'d')]

    > zipExtend 0 'z' [1,2,3,4] "ab"
    [(1,'a'),(2,'b'),(3,'z'),(4,'z')]
-}
zipExtend :: a -> b -> [a] -> [b] -> [(a, b)]
zipExtend a' _  [] bs = zip (repeat a') bs
zipExtend _  b' as [] = zip as (repeat b')
zipExtend a' b' (a : as) (b : bs) = (a, b) : zipExtend a' b' as bs

{-
    Combină două liste de arbori binomiali care respectă proprietatea de heap.
    Observațiile din comentariile funcției insertTree, legate de necesitatea
    atașării arborilor cu același rang, rămân valabile.

    Operația o oglindește pe cea de adunare a două numere binare din etapa 1.

    Constrângeri:
    * evitați recursivitatea explicită
    * utilizați funcția zipExtend pt a facilita aplicarea unor funcționale.

    Exemple:

    > mergeTrees [Node 1 'a' []] []
    [Node {prio = 1, key = 'a', children = []}]

    > mergeTrees [Node 1 'a' []] [Node 2 'b' []]
    [ EmptyTree
    , Node {prio = 1, key = 'a', children = [Node {prio = 2, key = 'b', children = []}]}
    ]

    > mergeTrees [Node 3 'c' []] $ mergeTrees [Node 1 'a' []] [Node 2 'b' []]
    [ Node {prio = 3, key = 'c', children = []}
    , Node {prio = 1, key = 'a', children = [Node {prio = 2, key = 'b', children = []}]}
    ]
-}
mergeTrees :: Ord p => [BinomialTree p k] -> [BinomialTree p k] -> [BinomialTree p k]
mergeTrees trees1 trees2 = result ++ rest
    where accumulated = mapAccumL mergeTrees' EmptyTree zipped
          result = fst $ unzip $ snd accumulated
          rest = if isEmptyTree (fst accumulated) then [] else [fst accumulated]
          mergeTrees' = \carry (t1, t2) -> case carry of
                                            EmptyTree -> if isEmptyTree t1 || isEmptyTree t2
                                                            then (EmptyTree, (attach t1 t2, EmptyTree))
                                                            else (attach t1 t2, (EmptyTree, EmptyTree))
                                            t -> if isEmptyTree t1 /= isEmptyTree t2
                                                    then (attach t (attach t1 t2), (EmptyTree, EmptyTree))
                                                    else (attach t1 t2, (t, EmptyTree))
          zipped = zipExtend EmptyTree EmptyTree trees1 trees2
          isEmptyTree EmptyTree = True
          isEmptyTree _ = False

{-
    Combină două heap-uri binomiale.

    Constrângeri: utilizați funcția mergeTrees.

    Exemple: similare cu cele de la mergeTrees.
-}
merge :: Ord p => BinomialHeap p k -> BinomialHeap p k -> BinomialHeap p k
merge heap1@(BinomialHeap s1 ts1) heap2@(BinomialHeap s2 ts2) = BinomialHeap newS $ mergeTrees ts1 ts2
    where newS = s1 + s2
