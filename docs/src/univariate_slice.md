
# Univariate Slice Sampling Algorithms

## Introduction
These algorithms are the "single-variable" slice sampling algorithms originally described by Neal[^N2003].
Since these algorithms are univariate, they are applied to each coordinate of the target distribution in a random-scan Gibbs sampling fashion.

!!! info
    By the nature of Gibbs sampling, univariate methods mix slowly when the posterior is highly correlated.
    Furthermore, their computational efficiency drops as the number of dimensions increases.
    As such, univariate slice sampling algorithms are best applied to low-dimensional problems with a few tens of dimensions.

## Fixed Initial Interval Slice Sampling 
This is the most basic form of univariate slice sampling, where the proposals are generated within a fixed interval formed by the `window`.


```@docs
Slice
```

## Adaptive Initial Interval Slice Sampling

These algorithms try to adaptively set the initial interval through a simple search procedure.
The "stepping-out" procedure grows the initial window on a linear scale, while the "doubling-out" procedure grows it geometrically.
`window` controls the scale of the increase.

### What Should I Use?
This highly depends on the problem at hand.
In general, the doubling-out procedure tends to be more expensive as it requires additional log-target evaluations to decide whether to accept a proposal.
However, if the scale of the posterior varies drastically, doubling out might work better.
In general, it is recommended to use the stepping-out procedure.

```@docs
SliceSteppingOut
SliceDoublingOut
```

<<<<<<< HEAD
## Univariate-to-Multivariate Strategies
=======
## Combining Univariate Samplers for Multivariate Targets
>>>>>>> 225afc96289de722dc0ba160abb6d33165517781
To use univariate slice sampling strategies on targets with more than on dimension, one has to embed them into a multivariate sampling scheme that relies on univariate sampling elements.
The two most popular approaches for this are Gibbs sampling[^GG1984] hit-and-run[^BRS1993].

### Random Permutation Gibbs Strategy
Gibbs sampling[^GG1984] is a simple strategy where we sample a coordinate at a time, conditioned on the values of all other coordinates.
<<<<<<< HEAD
In practice, one can pick the coordinates in any order they want as long as it does not depend on the state of the chain.
It is generally hard to know a-prior which ``scan order'' is best, but randomly picking coordinates tend to work well in general:

```@docs
RandPermGibbs
```

### Hit-and-Run Strategy
Hit-and-run is a simple ``meta''-algorithm, where we sample over a random 1-dimensional projection of the space.
That is, at each iteration, we sample a random direction
```math
    \theta \sim \operatorname{Uniform}(\mathbb{S}^{d-1}),
```
and sample along the 1-dimensional subspace
```math
\begin{aligned}
    \lambda &\sim p\left(\lambda \mid x_{n-1}, \theta \right) = \pi\left( x_{n-1} + \lambda \theta \right) \\
    x_{n} &= x_{n-1} + \lambda \theta
\end{aligned}
```
Applying slice sampling for the 1-dimensional subproblem has been popularized by David Mackay[^M2003].
Unlike Gibbs sampling, which only makes axis-aligned moves, hit-and-run can choose arbitrary directions, which could be helpful in some cases.

```@docs
HitAndRun
```

Unlike `RandPermGibbs`, `HitAndRun` does not provide the option of using a unique `unislice` object for each coordinate.
This is a natural limitation of the hit-and-run sampler: it does not operate on individual coordinates.

[^N2003]: Neal, R. M. (2003). Slice sampling. The Annals of Statistics, 31(3), 705-767.
[^GG1984]: Geman, S., & Geman, D. (1984). Stochastic relaxation, Gibbs distributions, and the Bayesian restoration of images. IEEE Transactions on Pattern Analysis and Machine Intelligence, (6).
[^BRS1993]: Bélisle, C. J., Romeijn, H. E., & Smith, R. L. (1993). Hit-and-run algorithms for generating multivariate distributions. Mathematics of Operations Research, 18(2), 255-266.
[^M2003]: MacKay, D. J. (2003). Information theory, inference and learning algorithms. Cambridge university press.