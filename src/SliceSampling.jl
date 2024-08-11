
module SliceSampling

using AbstractMCMC
using Accessors
using Distributions
using FillArrays
using LinearAlgebra
using LogDensityProblems
using SimpleUnPack
using Random

# The following is necessary because Turing wraps all models with
# LogDensityProblemsAD by default. So we need access to these types.
using LogDensityProblemsAD

# reexports
using AbstractMCMC: sample, MCMCThreads, MCMCDistributed, MCMCSerial
export sample, MCMCThreads, MCMCDistributed, MCMCSerial

# Interfaces
abstract type AbstractSliceSampling <: AbstractMCMC.AbstractSampler end

"""
    struct Transition

Struct containing the results of the transition.

# Fields
- `params`: Samples generated by the transition.
- `lp::Real`: Log-target density of the samples.
- `info::NamedTuple`: Named tuple containing information about the transition. 
"""
struct Transition{P, L <: Real, I <: NamedTuple}
    "current state of the slice sampling chain"
    params::P

    "log density of the current state"
    lp::L

    "information generated from the sampler"
    info::I
end

"""
    initial_sample(rng, model)

Return the initial sample for the `model` using the random number generator `rng`.

# Arguments
- `rng::Random.AbstractRNG`: Random number generator.
- `model`: The target `LogDensityProblem`.
"""
function initial_sample(::Random.AbstractRNG, ::Any)
    error(
        "`initial_sample` is not implemented but an initialization wasn't provided. " *
        "Consider supplying an initialization to `initial_params`."
    )
    println("fuck!!!")
end

# If target is from `LogDensityProblemsAD`, unwrap target before calling `initial_sample`.
# This is necessary since Turing wraps `DynamicPPL.Model`s when passed to an `externalsampler`.
initial_sample(
    rng::Random.AbstractRNG,
    wrap::LogDensityProblemsAD.ADGradientWrapper
) = initial_sample(rng, parent(wrap))

function exceeded_max_prop(max_prop::Int)
    error("Exceeded maximum number of proposal $(max_prop).\n", 
          "Here are possible causes:\n",
          "- The model might be broken or pathologic.\n",
          "- There might be a bug in the sampler.")
end

## Univariate Slice Sampling Algorithms
export Slice, SliceSteppingOut, SliceDoublingOut

abstract type AbstractUnivariateSliceSampling <: AbstractSliceSampling  end

accept_slice_proposal(
    ::AbstractSliceSampling,
    ::Any,
    ::Real,
    ::Real,
    ::Real,
    ::Real,
    ::Real,
    ::Real,
) = true

function find_interval end

include("univariate/univariate.jl")
include("univariate/fixedinterval.jl")
include("univariate/steppingout.jl")
include("univariate/doublingout.jl")

## Multivariate slice sampling algorithms
abstract type AbstractMultivariateSliceSampling <: AbstractSliceSampling  end

# Meta Multivariate Samplers
export RandPermGibbs, HitAndRun

include("multivariate/randpermgibbs.jl")
include("multivariate/hitandrun.jl")

# Latent Slice Sampling 
export LatentSlice
include("multivariate/latent.jl")

# Gibbsian Polar Slice Sampling 
export GibbsPolarSlice
include("multivariate/gibbspolar.jl")

# Turing Compatibility

if !isdefined(Base, :get_extension)
    using Requires
end

@static if !isdefined(Base, :get_extension)
    function __init__()
        @require Turing = "fce5fe82-541a-59a6-adf8-730c64b5f9a0" include(
            "../ext/SliceSamplingTuringExt.jl"
        )
    end
end

end
