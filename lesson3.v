
From mathcomp Require Import all_ssreflect.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

(** 

----------------------------------------------------------
#<div class="slide">#
** Lesson 3: summary

- bool vs Prop
- views as iff
- using views
- reflect and other inductive "spec"
- a real proof

#</div>#


----------------------------------------------------------
#<div class="slide">#
** Propositions and booleans

So far we used boolean connectives.
But this is not what is used in the Curry Howard
correspondence to represent connectives and their
proofs.

#<div>#
*)
Print andb.
Print and.

Print orb.
Print or.

Check true ==> false.
Check True -> False.

(**
#</div>#

Let's play a little with [and] and [andb], [or] and [orb]
in order to understand the difference.

#<div>#
*)


Lemma test_and (P : bool) :
  True /\ P -> P. (* true && P -> P. *)
Proof.
move=> t_p.
case: t_p => t p.
apply: p.
Qed.

Lemma test_orb (P Q R : bool) :
  P \/ Q -> R. (* P || Q -> R *)
Proof.
move=> p_q.
case: p_q.
Abort.


(**
#</div>#

Propositions:
- structure to your proof as a tree
- more expressive logic (closed under forall, exists...)

Booleans:
- computation & Excluded Middle
- Uniqueness of Identity Proofs (lesson 4)

We want the best of the two worlds, and a way to
link them: views.

#<p><br/><p>#

#<div class="note">(notes)<div class="note-text">#

This slide corresponds to
section 3.x of
#<a href="https://math-comp.github.io/mcb/">the Mathematical Components book</a>#
#</div></div>#


#</div>#

----------------------------------------------------------
#<div class="slide">#
** Stating and proving a view

To link a concept in bool and one in Prop we typically
use the [reflect] predicate.

To prove [reflect] we use the [iffP] lemma that
turns it into a double implication. This is also a
recap of many of the proof commands we have seen
so far.

#<div>#
*)

About iffP.
About idP.

Lemma eqnP {n m : nat} :
  reflect (n = m) (eqn n m).
Proof.
apply: (iffP idP).
  elim: n m => [|n IH] m; case: m => // m Hm.
  by rewrite (IH m Hm).
move=> def_n; rewrite {}def_n.
Undo.
move=> ->. (* move + rewrie + clear idiom *)
by elim: m.
Qed.

(**
#</div>#

#<div class="note">(notes)<div class="note-text">#
This slide corresponds to
sections 4.1.1 and 4.1.2 of
#<a href="https://math-comp.github.io/mcb/">the Mathematical Components book</a>#
#</div></div>#


#</div>#


----------------------------------------------------------
#<div class="slide">#
** Using views

The syntax [/view] can be put in intro patterns
to modify the top assumption using [view]

#<div>#
*)
About andP.

Lemma example n m k : k <= n ->
  (n <= m) && (m <= k) -> n = k.
Proof.
move=> lekn /andP H; case: H => lenm lemk.
Undo.
move=> lekn /andP[lenm lemk]. (* view + case idiom *)
Abort.

(**
#</div>#

The [apply:] tactic accepts a [/view] flag
to modify the goal using [view].

#<div>#
*)

Lemma leq_total m n : (m <= n) || (m >= n).
Proof.
(* About implyNb.*)
rewrite -implyNb -ltnNge.
apply/implyP.
(* About ltnW *)
by apply: ltnW.
Qed.

(**
#</div>#

The [case:] tactic accepts a [/view] flag
to modify the term being analyzed just before
performing the case analysis.

#<div>#
*)

Lemma leq_max m n1 n2 :
  (m <= maxn n1 n2) = (m <= n1) || (m <= n2).
Proof.
case/orP: (leq_total n2 n1) => [le_n21 | le_n12].
Abort.

(**
#</div>#

#<p><br/><p>#

#<div class="note">(notes)<div class="note-text">#
This slide corresponds to
sections 4.1.3 and 4.1.4 of
#<a href="https://math-comp.github.io/mcb/">the Mathematical Components book</a>#
#</div></div>#


#</div>#


----------------------------------------------------------
#<div class="slide">#
** The reflect predicate and other specs

The [reflect] inductive predicate has an index.

Indexes are replaced by the value dictated by the
constructor when prforming a casa analysis. In a way
indexes express equations that are substituted
automatically.

In Mathematical Components we exploit this feature
of the logic in order to structure proofs that proceed
by case split.


#<div>#
*)
Print Bool.reflect.
About andP.

Lemma example_spec a b : a && b ==> (a == b).
Proof.
by case: andP => [ [-> ->] | // ].
Qed.

(**
#</div>#

Note that [(andP _ _)] has in the type, as the value of
the index, [(_ && _)] that we call "a pattern". The [case:]
tactic looks for a subterm of the goal that matches the
pattern and "guesses" that the two [_] are respectively
[a] and [b]. This form of automation is the same of [rewrite].

One can craft many "spec" to model the structure of a
proof. Eg [leqP] and [ltngtP]

#<div>#
*)

About leqP.
Print leq_xor_gtn.

Lemma example_spec2 a b : (a <= b) || (b < a).
Proof.
case: leqP.
Abort.

About ltngtP.
Print compare_nat.

Lemma example_spec3 a b : (a <= b) || (b < a) || (b == a).
Proof.
case: ltngtP.
Abort.

(**
#</div>#

#<div style='color: red; font-size: 150%;'>#
Motto: don't let Coq drive your proof!
#</div>#

#<div>#
*)

About ifP.

Lemma example_spec3 a b :
  (if (a <= 0) then a + b else b) == b.
Proof.
case: ifP => //.
rewrite leqn0 => /eqP ->.
by [].
Qed.

(**
#</div>#

#<p><br/><p>#


#<div class="note">(notes)<div class="note-text">#
This slide corresponds to
section 4.2 of
#<a href="https://math-comp.github.io/mcb/">the Mathematical Components book</a>#
#</div></div>#


#</div>#

----------------------------------------------------------
#<div class="slide">#
** Infinitude of primes

#<div>#
*)
Lemma prime_above (m : nat) : exists p, (prime p) && (m < p).
Proof.
have: 1 < m`! + 1 by rewrite addn1 ltnS fact_gt0.
move=> /pdivP[q pr_q q_dv_m1].
exists q; rewrite pr_q /= ltnNge.
apply: contraL q_dv_m1 => q_le_m.
by rewrite dvdn_addr ?dvdn_fact ?prime_gt0 // gtnNdvd ?prime_gt1.
Qed.

(**
#</div>#

#<p><br/><p>#

#</div>#

----------------------------------------------------------
#<div class="slide">#
** Lesson 3: sum up

- [reflect] and [iffP]
- [case/v: m] case split + view application
- [move=> /v H] introduction + view
- [apply/v: t] backchain with a view
- [_spec] predicates to model case split [leqP] and [ifP]
- [move=> []] (for case)
- [move=> ->] (for rewrite)
- [... => ...] the arrow can be used after any command
- [have: ... by ...] forward step
- [rewrite ?rule]

#</div>#

*)
