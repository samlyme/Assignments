# How does group theory show up in machine learning?

Abstract algebra and group theory feels like *pure math* in the purest sense of the word. Sure, we can use it to describe "symmetries", but really, are there any applications of group theory outside of more math? 
(TODO)

This article aims to demonstrate a real application of group theory in machine learning.

## What is machine learning?
(Can potentially remove this section)

some problems are hard to explicitly describe with code
but that we have access to a decent amount of data.
we can make the code "learn" from data to create a model.
# Everyone's favorite ML problem: MNIST

The MNIST dataset is a of handwritten digits. 

## What is the issue with this model?

## How can we fix it? 

### Data augmentation
### The "real" solution

# Intro to group theory

Formal definition: a set $G$ along with a binary operation $*$ such that:
1. For all $a, b \in G$, $a * b \in G$ (Closure)
2. There exists an identity element $e$ such that $a * e = a = e * a$
3. For all $a \in G$, there exists an inverse element $a^{-1}$ such that $a * a^{-1} = e = a^{-1} * a$
	1. Notice that $(a^{-1})^{-1} = a$
4. For all $a,b,c \in G$, $a * (b * c) = (a * b) * c$

Now, what does this actually mean? Well, for one, it describes some form of algebra, since we can substitute, and solve for elements. But it doesn't describe anything concrete like numbers or linear systems. It is **abstract.** That is, this is an **abstract algebra**. We can describe (almost) anything!

## Example Group: $D_4$

This group describes the symmetries of a square. 
- For those curious $D_4$ stands for the *dihedral group of order 4*.

Notice that certain combinations of rotations and flips are the exact same. This lets us imply a sort of "canonical name" for each of the individual orientations.

## A broader concept

I mentioned that we can describe almost anything with groups, and one of the most important things that they describe a large subset of what I will call "relative motions". Sure, we can play already with the algebra and substitute and rewrite to find cool identities with the group, but the most useful thing is that it gives us a concrete way to **enumerate** and reason about the space of possible states an object can be in, given we have set of moves to play with.

> We can view groups as symmetries of arbitrary objects, or we can view them as a collection of available "moves". This second view is formalized by the notion of **group actions.**

> I mentioned that these moves are "relative", but why does that matter? Why does can move like "set the angle to 30 degrees" never exist within a **group**? (Hint: it breaks one of the axioms.)

## Example Group: $E_2$

This group describes all possible translations in a 2D space. 
For our uses, we will think of these translations as being **discrete** steps.

> We can view $E_2$ as being **represented** by the set of vectors $v \in \mathbb{Z}^2$ under addition.

