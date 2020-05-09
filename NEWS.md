# Lyceum 0.4 Release Notes

## `AbstractEnvironment` Changes

* Rename `obsspace`/`getobs!`/`getobs` --> `observationspace`/`getobservation!`/`getobservation`
* `isdone(s, a, o, env)` --> `isdone(s, o, env)`
* Removed `evalspace`/`geteval`

## `EnvironmentSampler` Changes

* renamed `sample!(policy!, sampler::EnvironmentSampler, args...; kwargs...)` to `sample` and added a in-place version: `sample!(B::TrajectoryBuffer, policy!, sampler::EnvironmentSampler, args...; kwargs...)`.
* `sample`/`sample!` now extend `Distributions.sample`/`Distributions.sample!`.
* `sample`/`sample!` now return a `TrajectoryBuffer`.
* The function signature for `policy!` in `sample`/`sample!` has changed from `policy!(a, s, o)` to `policy!(a, o)`.
* Fixed a bug that caused multi-threaded sampling to bias towards trajectories that were less computationally expensive.

## Miscellaneous Changes

* Removed the `LyceumBase.Tools` submodule. Everything is now under `LyceumBase`.

## Miscellaneous Changes

* Rename `seed_threadrngs!` --> `tseed!`
* Rename `expplot` -> `termplot`
* Removed `BatchedArray` and `ElasticBuffer`. All array-like types are now in [SpecialArrays.jl](https://github.com/Lyceum/SpecialArrays.jl)
