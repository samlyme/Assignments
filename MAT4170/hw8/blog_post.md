# Topology up to the Fundamental Group, and why we care
(work in progress title)

Many of us have probably heard something along the lines of 
"topologist view donuts and coffee mugs as the same thing", but I
feel like that is a very poor representation of what the field of 
topology has to offer. 
Topology is one of the most intriguing and beautiful branches of
math, that has some truly deep foundational insights on 
computer science, engineering, and the very *structure* of 
mathematics itself, and this view of topology is really a
disservice. In this article, I intend to provide you, the reader, 
with a more complete view of topology, and why we even care. 

## The building blocks of topology

Now, the "real" foundations of topology lie in something known as 
[metric spaces](https://ncatlab.org/nlab/show/metric+space). However, I feel as though we can still form a 
complete enough view of topology and its uses if we accept some 
abstractions. A true deep dive into metric spaces touches on 
topics like continuity, and even Real Analysis, which is a bit 
out of scope for us. Despite this, we still need a some grasp 
on what a metric space is.

### Metric Spaces

Simply put, a metric space is a set of points, such that we have 
some notion of distances (there are some special requirements!)
between them, ie. a **metric**. Formally, we have a set of points $X$ 
and a $d(x_1, x_2)$ is a metric. Together, $(X, d)$ form a **metric space**. 

For $(X, d)$ to to be a metric space, $d$ must satisfies some 
constraints. Namely:
1. $d$ must take in two points of $x_1, x_2 \in X$, and give us a real number $r > 0$. Formally, $d \colon X \times X \to [0, \infty)$.
2. $d$ must be symmetric, so $d(x_1, x_2) = d(x_2, x_1)$.
3. $d(x_1,x_2) = 0$  if and only if $x_1 = x_2$.
4. $d$ satisfies the **triangle inequality**. So for, $x, y, z \in X$, $d(x,z) \le d(x,y) + d(y,z)$.

Notice that we actually haven't said anything about the set $X$,
and that is because we actually don't need to, if we are strictly 
talking about metric spaces. For example, for those in computer 
science, we may recognize these requirements as the exact same 
requirements needed for a heuristic function for path finding 
algorithms like A*!

However, for topology specifically, we do need the set $X$ to be 
**continuous**. There is a very formal and mathematically rigorous 
definition for [continuity](https://ncatlab.org/nlab/show/topology#Continuity), 
but we only need a sort of intuition for what it means. I am 
sure your imagination won't lead you astray here.

### Open Sets

One idea that is crucial to the understanding of topology is the 
notion of the **open set**. Be prepared, as this is one of the most
mind bending concepts we have to visit. 

Before we get into any formal definitions, I would like to invite 
you to consider an example.
Suppose we have the set $S$ of real numbers $0 < s < 1$ (the exclusive range is very important). Can we define a continuous mapping $f$ that takes $S$ and to the range $(0, \infty)$?

> $S$ is actually an example of an open set. I will explain why in the next section.

Yes! We can say $f(x) = -\text{log}(x)$. 

Now, what if we let our input be the set $Q$ with values in the  *inclusive* range $[0,1]$, can we define a similar mapping to the to $[0,\infty)$? 

Surprisingly, no! If we take the same function $f(x) = -\text{log}(x)$, this works for the "left" side of the desired input range since $f(1) = 0$. However, $f$ is undefined for $x = 0$. Somehow, *expanding* the input range *shrinks* the output range!

If you don't believe me, try it yourself! There is no continuous, well-defined function that satisfies these requirements. You can construct a discontinuous function, but constructing a continuous function is impossible. 

Now, this is where I start to get excited, because in topology, we often speak about this thing called "continuous deformations", where we arbitrary stretch a shape without tearing or gluing. For example, the thing where we morph a donut into a coffee mug and vice versa. Intuitively, we can kind of see how we can stretch the open set $(0, 1)$ into the open set $(0, \infty)$, but we can't do the same for $[0, 1]$. This our first taste of stretching things around!

Ok, I hope that you can begin to see why open sets are important to our discussion about donuts and coffee mugs, but if not, I hope that you at least thought it was interesting how adding numbers to our range can actually clamp the range of the output. 

### Open sets, formally

Open sets can only be defined on continuous metric spaces. Yes, that means that the range $S = (0,1)$ is a continuous metric space.

> I invite you to define as many metric functions $d$ as you can.
> Here are some examples to get your mind going:
>
> 1. $d(x,y) = |x-y|$
> 2. $d(x,y) = (x-y)^2$

Now, let us pick a point $x \in S$. We a **neighborhood** $N \subset S$ around $x$ is defined as some set of points around $x$. Within our neighborhood $N$, there exists an **open ball** $B$ with radius $\varepsilon$. In other words, $B = \{y \mid d(x,y) < \varepsilon\}$.
![[attachments/Pasted image 20260419194638.png]]

All of that is a fancy way of saying that if we have a point $x$, we can wiggle it around a bit by $\varepsilon$ and we are still in $S$.

Now, for a set to be **open**, every point $x \in S$ must have some neighborhood around it. For example, let us take a look at our example from earlier, $S = (0,1)$. 

Obvious, a value like $0.5$ will have a neighborhood around it, and a pretty big neighborhood at that. However, what about values like $0.001$? Sure they do! Just wiggle it around by $0.0001$! As a matter of fact, no matter what value we pick, we can *always* create a neighborhood around it, so $S$ is open. Try it yourself!
![[attachments/Pasted image 20260419195813.png]]

This openness (the ability to wiggle things around) is the precise reason why our mapping $f$ could be constructed from $(0,1)$ to $(0, \infty)$, but not from $[0,1]$. (TODO, need some more intuition behind this)

### Topological spaces

Alright, We have done a *lot* of "tool-making". But now, all of the mathematical machinery is in place for us to begin tackling topological spaces! In other words, we are ready to start talking about proverbial donuts and coffee mugs.

