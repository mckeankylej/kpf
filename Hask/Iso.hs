{-|
Module      : Hask.Iso
Description : Lens like Isomorphisms
Copyright   : (c) Edward Kmett, 2018
                  Kyle McKean,  2018
License     : BSD-3-Clause
Maintainer  : mckean.kylej@gmail.com
Stability   : experimental
Portability : portable

__FIXME__: Doc

@since 0.1.0
-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeInType #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Hask.Iso
  (
  -- * Isomorphisms
    type Iso
  -- * To
  , To
  , _To
  , to
  -- * From
  , From
  , _From
  , from
  -- * Yoneda's Lemma
  , yoneda
  ) where

import qualified Prelude as Base ()

import Hask.Functor

--------------------------------------------------------------------------------
-- * Isomorphisms
--------------------------------------------------------------------------------

-- | __FIXME__: Doc
--
-- @since 0.1.0
type Iso p q r s t a b = forall f. BifunctorOf (Op p) q r f => f a b -> f s t

--------------------------------------------------------------------------------
-- * To
--------------------------------------------------------------------------------

-- | __FIXME__: Doc
--
-- @since 0.1.0
newtype To (p :: Cat i) (x :: i) (a :: i) (b :: i) 
  = To { runTo :: p a x }

-- | __FIXME__: Doc
--
-- @since 0.1.0
_To :: Iso (->) (->) (->) (To p x a b) (To p y c d) (p a x) (p c y)
_To = dimap runTo To

-- | __FIXME__: Doc
--
-- @since 0.1.0
instance Category p => Functor (To p x a) where
  type Dom (To p x a) = p
  type Cod (To p x a) = (->)
  fmap _ = _To id

-- | __FIXME__: Doc
--
-- @since 0.1.0
instance Category p => Functor (To p x) where
  type Dom (To p x) = Op p
  type Cod (To p x) = Nat p (->)
  fmap f = Nat (_To (\p -> p . unop f))

-- | __FIXME__: Doc
--
-- @since 0.1.0
instance Category p => Functor (To p) where
  type Dom (To p) = p
  type Cod (To p) = Nat (Op p) (Nat p (->))
  fmap f = Nat (Nat (_To (\p -> f . p)))

-- | __FIXME__: Doc
--
-- @since 0.1.0
to :: (Category p, Ob p a) => (To p a a a -> To p a s s) -> p s a
to l = runTo (l (To id))

--------------------------------------------------------------------------------
-- * From
--------------------------------------------------------------------------------

-- | __FIXME__: Doc
--
-- @since 0.1.0
newtype From (p :: Cat i) (x :: i) (a :: i) (b :: i) 
  = From { runFrom :: p x b }

-- | __FIXME__: Doc
--
-- @since 0.1.0
_From :: Iso (->) (->) (->) (From p x a b) (From p y c d) (p x b) (p y d)
_From = dimap runFrom From

-- | __FIXME__: Doc
--
-- @since 0.1.0
instance Category p => Functor (From p x a) where
  type Dom (From p x a) = p
  type Cod (From p x a) = (->)
  fmap f = _From (\p -> f . p)

-- | __FIXME__: Doc
--
-- @since 0.1.0
instance Category p => Functor (From p x) where
  type Dom (From p x) = Op p
  type Cod (From p x) = Nat p (->)
  fmap _ = Nat (_From id)

-- | __FIXME__: Doc
--
-- @since 0.1.0
instance Category p => Functor (From p) where
  type Dom (From p) = Op p
  type Cod (From p) = Nat (Op p) (Nat p (->))
  fmap f = Nat (Nat (_From (\p -> p . unop f)))

-- | __FIXME__: Doc
--
-- @since 0.1.0
from :: (Category p, Ob p a) => (From p a a a -> From p a s s) -> p a s
from l = runFrom (l (From id))

--------------------------------------------------------------------------------
-- * Yonedas lemma
--------------------------------------------------------------------------------

-- | __FIXME__: Doc
--
-- @since 0.1.0
yoneda 
  :: forall p f g a b
  .  (Ob p a, FunctorOf p (->) g, FunctorOf p (->) (p b)) 
  => Iso (->) (->) (->) (Nat p (->) (p a) f) (Nat p (->) (p b) g) (f a) (g b)
yoneda = dimap hither yon
  where
    hither :: Nat p (->) (p a) f -> f a
    hither (Nat f) = f id
    yon :: g b -> Nat p (->) (p b) g 
    yon g = Nat (\p -> fmap p g)
