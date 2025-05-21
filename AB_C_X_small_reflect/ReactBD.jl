using Pkg
Pkg.activate("env")

Pkg.add("ArgParse")
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("Distributions")
Pkg.add("ProgressMeter")
Pkg.add("StaticArrays")
Pkg.add("Setfield")
Pkg.add("Tables")

using LinearAlgebra, StaticArrays, Setfield
using Random, Distributions, Statistics
using ArgParse, ProgressMeter
using Tables, CSV, DataFrames
# using BenchmarkTools

include("./utils.jl")
include("./diffusion.jl")
include("./reaction.jl")

function main(args)

    s = ArgParseSettings()

    @add_arg_table s begin
        "--num_sim"
        help = "Number of simulations"
        arg_type = Int64
        default  = 5
    end

    parsed_args = parse_args(args, s)

    # Parameters from command inputs
    num_sim = parsed_args["num_sim"]

    # Parameters
    p = (;
        Ω_inf =  0.0,      # nm
        Ω_sup = 20.0,      # nm
        T     =  0.5,      # s
        Δt    =  1.0e-8,   # s
        C₀    = 1.25e-4,   # nm^{-3}
        
        λ = 40.5745,      # 1/s, varies based on Ω
        β = 17.3,         # 1/s
        ε = 10.0,         # nm
        γ =  0.5,         # ratio
        D =  1.0e6,       # nm
    )
    p = (; p..., δ=sqrt(2 * p.D * p.Δt))

    (; C₀, Ω_sup, T, Δt) = p

    # inititialize
    num_states = Int(C₀ * (Ω_sup)^3)
    num_Δt = Int(floor(T / Δt))

    num_saveΔt = div(num_Δt + 1, 1000) + 1
    C_matrix = Matrix{Float64}(undef, num_saveΔt, num_sim)
    num_C = zeros(Float64, num_saveΔt)
    num_C[1] = num_states

    # main
    @showprogress for n in 1:num_sim
        react_states = init_states(num_states, p)
        for i in 1:num_Δt
            for j in 1:num_states
                update_state(react_states[j], p)
            end
            if mod(i+1, 1000) == 0
                num_C[div(i+1, 1000) + 1] = count_C(react_states, num_states)
            end
        end
        C_matrix[:, n] = num_C
    end

    C_means = [mean(row) for row in eachrow(C_matrix)]
    C_stds = [std(row) for row in eachrow(C_matrix)]
    # save
    save_result(C_means, C_stds, num_sim)
end

# Call the main function if this script is run directly
if abspath(PROGRAM_FILE) == @__FILE__
    main(ARGS)
end

# command line:
# nohup julia ReactBD.jl --num_sim 11000  > ABCX_sim11000_24072201.log 2>&1 &
# tail -n 50 -f ABCX_sim11000_24072201.log