
From mathcomp Require Import all_ssreflect.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

(** 

----------------------------------------------------------
#<div class="slide">#
** Lesson 4: summary

- generic notations and theories
- interfaces and hierarchies
- parametrizing theories
- the BigOp library (the theories of fold)
- subtypes

Let's start with a lie and then make it true:

#<div style='color: red; font-size: 150%;'>#
Coq is an object oriented
programming language.
#</div>#


#</div>#


----------------------------------------------------------
#<div class="slide">#
** Generic notations and theories

Polymorphism != overloading.

Example: the [==] computable equality

#<div>#
*)
Check 3 == 4.
Check true == false.
Check [::] == [:: 2; 3; 4].

Eval lazy in 3 == 4.
Eval lazy in true == false.
Eval lazy in [::] == [:: 2; 3; 4].

Check (3, true) == (4, false).
Fail Check (fun x => x) == (fun y => y).

Check [eqType of nat].
Fail Check [eqType of nat -> nat].

Check [eqType of seq nat].
Fail Check [eqType of seq (nat -> nat)].

(**
#</div>#

We call [eqType] an interface. With some "approximation"
[eqType] is defined as follows:

<<

Module Equality.

Structure type : Type := Pack {
  sort : Type;
  op : sort -> sort -> bool;
  axiom : ∀x y, reflect (x = y) (op x y)
}.


End Equality
>>

#<div class="note">(notes)<div class="note-text">#
This slide corresponds to
section 5.4 of
#<a href="https://math-comp.github.io/mcb/">the Mathematical Components book</a>#
#</div></div>#
#<p><br/><p>#
#</div>#


----------------------------------------------------------
#<div class="slide">#
** Interfaces and hierarchies

Mathematical Components defines a hierarchy
of interfaces. They group notations and
theorems.

# <img style="width: 100%" src="demo-support-master.png"/>#

Let's use the theory of [eqType]

#<div>#
*)
About eqxx.
About eq_refl.
Lemma test_eq (*(T : eqType) (x : T)*) :
  (3 == 3) && (true == true) (*&& (x == x)*).
Proof.
rewrite eqxx.
rewrite eqxx.
(* rewrite eqxx. *)
by [].
Qed.
(**
#</div>#

Interfaces do apply to registered, concrete examples
such as [bool] or [nat]. They can also apply to variables,
as long as their type is "rich" ([eqType] is richer than [Type]).

#<div class="note">(notes)<div class="note-text">#
This slide corresponds to
section 5.5 and 7 of
#<a href="https://math-comp.github.io/mcb/">the Mathematical Components book</a>#
#</div></div>#

#<p><br/><p>#
#</div>#


----------------------------------------------------------
#<div class="slide">#
** Theories over an interface

Interfaces can be used to parametrize an
entire theory

#<div>#
*)
Module Seq. Section Theory.
Variable T : eqType.
Implicit Type s : seq T.

Fixpoint mem_seq s x :=
  if s is y :: s1
  then (y == x) || mem_seq s1 x
  else false.

(* the infix \in and \notin are generic, not
   just for sequences. *)

Fixpoint uniq s :=
  if s is x :: s1
  then (x \notin s1) && uniq s1
  else true.

Fixpoint undup s :=
  if s is x :: s1 then
    if x \in s1 then undup s1 else x :: undup s1
  else [::].

End Theory. End Seq.

About undup_uniq.

Eval lazy in (undup [::1;3;1;4]).

Lemma test : uniq (undup [::1;3;1;4]).
Proof.
by rewrite undup_uniq.
Qed.


(**
#</div>#

#<div class="note">(notes)<div class="note-text">#
This slide corresponds to
section 5.6 of
#<a href="https://math-comp.github.io/mcb/">the Mathematical Components book</a>#
#</div></div>#

#<p><br/><p>#
#</div>#

----------------------------------------------------------
#<div class="slide">#
** Generic theories: the BigOp library

The BigOp library is the canonical example
of a generic theory. It it about the
[fold] iterator we studied in lesson 1,
and the many uses it can have.

#<div>#
*)

Lemma sum_odd_3 :
  \sum_(0 <= i < 6 | odd i) i = 3^2.
Proof.
rewrite unlock /=.
by [].
Qed.

About big_mkcond.
About big_nat_recr.
Lemma sum_odd_3_bis :
  \sum_(0 <= i < 6 | odd i) i = 3^2.
Proof.
rewrite big_mkcond big_nat_recr //= -big_mkcond /=.
Abort.

Lemma prod_odd_3_bis : (* try [maxn/0] and also [maxn/1] *)
  \big[muln/1]_(0 <= i < 6 | odd i) i = 3^2.
Proof.
rewrite big_mkcond big_nat_recr //= -big_mkcond /=.
Abort.

(**
#</div>#

Most of the lemmas require the operation to be a monoid,
some others to be a commutative monoid.

#<div>#
*)

About eq_big_perm.

(**
#</div>#

#<div class="note">(notes)<div class="note-text">#
This slide corresponds to
section 5.7 of
#<a href="https://math-comp.github.io/mcb/">the Mathematical Components book</a>#
#</div></div>#


#<p><br/><p>#
#</div>#

----------------------------------------------------------
#<div class="slide">#
** Sub types

A sub type extends another type by adding a property.
The new type has a richer theory.
The new type inherits the original theory.

Let's define the type of homogeneous tuples

#<div>#
*)

Module Tup.

Structure tuple_of n T := Tuple {
  tval  :> seq T;
  tsize :  size tval == n
}.
Notation "n .-tuple" := (tuple_of n) : type_scope.

Lemma size_tuple T n (t : n .-tuple T) : size t = n.
Proof. by case: t => s /= /eqP. Qed.

Example seq_on_tuple n (t : n .-tuple nat) :
  size (rev [seq 2 * x | x <- rev t]) = size t.
Proof. 
by rewrite map_rev revK size_map.
Undo.
rewrite size_tuple.
Fail rewrite size_tuple.
Abort.


(**
#</div>#

We instrument Coq to automatically promote
sequences to tuples.

#<div>#
*)

Lemma rev_tupleP n A (t : n .-tuple A) : size (rev t) == n.
Proof. by rewrite size_rev size_tuple. Qed.
Canonical rev_tuple n A (t : n .-tuple A) := Tuple (rev_tupleP t).

Lemma map_tupleP n A B (f: A -> B) (t: n .-tuple A) : size (map f t) == n.
Proof. by rewrite size_map size_tuple. Qed.
Canonical map_tuple n A B (f: A -> B) (t: n .-tuple A) := Tuple (map_tupleP f t).

Example seq_on_tuple2 n (t : n .-tuple nat) :
  size (rev [seq 2 * x | x <- rev t]) = size t.
Proof. rewrite size_tuple. rewrite size_tuple. by []. Qed.

(**
#</div>#

Now we the tuple type to form an eqType,
exactly as seq does.

Which is the expected comparison for tuples?

#<div>#
*)

Lemma p1 : size [:: 1;2] == 2. Proof. by []. Qed.
Lemma p2 : size ([:: 1] ++ [::2]) == 2. Proof. by rewrite cat_cons cat0s. Qed.

Definition t1 := {| tval := [::1;2];        tsize := p1 |}.
Definition t2 := {| tval := [::1] ++ [::2]; tsize := p2 |}.

Lemma tuple_uip : t1 = t2.
Proof.
rewrite /t1 /t2. rewrite /=.
Fail by [].
congr (Tuple _).
Fail by [].
(*About bool_irrelevance.*)
apply: bool_irrelevance.
Qed.

(**
#</div>#

Given that propositions are expressed (whenever possible)
as booleans we can systematically prove that proofs
of these properties are irrelevant.

As a consequence we can form subtypes and systematically
prove that the projection to the supertype is injective,
that means we can craft an eqType.

#<div>#
*)


Canonical tuple_subType n T := Eval hnf in [subType for (@tval n T)].
Definition tuple_eqMixin n (T : eqType) := Eval hnf in [eqMixin of n .-tuple T by <:].
Canonical tuple_eqType n (T : eqType) := Eval hnf in EqType (n .-tuple T) (tuple_eqMixin n T).

Check [eqType of 3.-tuple nat].

Example test_eqtype (x y : 3.-tuple nat) : x == y -> True.
Proof.
move=> /eqP H.
Abort.

(**
#<div/>#

Tuples is not the only subtype part of the library.
Another one is ['I_n], the finite type of natural
numbers smaller than n.

#<div>#
*)
Print ordinal.

About tnth. (* like the safe nth function for vectors *)

End Tup.

(**
#</div>#

#<div class="note">(notes)<div class="note-text">#
This slide corresponds to
section 6.1 and 6.2 of
#<a href="https://math-comp.github.io/mcb/">the Mathematical Components book</a>#
#</div></div>#

#<p><br/><p>#
#</div>#

----------------------------------------------------------
#<div class="slide">#
** Sum up

- Coq is an object oriented language ;-)

- in the Mathematical Components library [xxType] is an
  interface (eg [eqType] for types with an equality test).
  Notations and theorems are linked to interfaces.
  Interfaces are organized in hierarchies (we just saw a picture,
  how it works can be found in the book).

- subtypes add properties and inherit the theory of the supertype
  thanks to boolean predicates (UIP).
  In some cases the property can be inferred by Coq, letting one apply
  a lemma about the subtype on terms of the supertype.


#</div>#

*)
