using Pkg
Pkg.activate(".")

# Pkg.add("ArgParse")
# Pkg.add("CSV")
# Pkg.add("DataFrames")
# Pkg.add("Distributions")
# Pkg.add("ProgressMeter")
# Pkg.add("StaticArrays")
# Pkg.add("Setfield")
# Pkg.add("Tables")

using LinearAlgebra, StaticArrays, Setfield
using Random, Distributions, Statistics
using Tables, CSV, DataFrames
using ArgParse, Plots, Printf
using ProgressMeter, ProfileView
using Base.Threads, Distributed

println("Number of threads: ", nthreads())
flush(stdout)

include("./utils.jl")
include("./diffusion.jl")
include("./reaction.jl")

function main(args)

    s = ArgParseSettings()

    @add_arg_table s begin
        "--num_sim"
        help = "Number of simulations"
        arg_type = Int64
        default  = 40000

        "--time_step"
        arg_type = Float64
        default  = 1.0e-6
    end

    parsed_args = parse_args(args, s)

    # Parameters from command inputs
    num_sim    = parsed_args["num_sim"]
    time_step  = parsed_args["time_step"]

    # Parameters
    p = (;
        Ω_inf = 0.0,         # nm
        Ω_sup = 200.0,       # nm
        T     = 0.3,         # s
        Δt    = time_step,   # s
        C₀    = 1.25e-4,     # nm^{-3}, 1000 particles
        #C₀    = 1.25e-5,     # nm^{-3}, 100 particles
        #C₀    = 1.25e-6,     # nm^{-3}, 10 particles

        λ₁ = 1.0e4,          # 1/s, Pb = 0.2323
        λ₀ = 17.3,           # 1/s
        ε  = 10.0,           # nm
        γ  = 0.5,            # ratio
        D  = 1.0e6           # nm
    )
    p = (; p..., 
        # diffusion
        δ = sqrt(2 * p.D * p.Δt),

        # reaction
        one_minus_γ = 1 - p.γ,

        # update states 
        ε_square = (p.ε)^2,
        λ₁Δt = p.λ₁ * p.Δt,
        λ₀Δt = p.λ₀ * p.Δt
    )

    (; T, Δt, C₀, Ω_sup) = p

    num_Δt         = Int(floor(T / Δt))
    num_states     = Int(C₀ * (Ω_sup)^3)

    save_time_step = T / 5000
    step_ratio     = Int(floor(save_time_step / Δt))
    num_save_steps = Int(floor(T / save_time_step)) + 1
    num_C_sim_path = zeros(num_save_steps)
    num_C_total    = zeros(num_save_steps)

    num_C_sim_path[1] = Float64(num_states)
    one_percent_num_sim = Int(num_sim * 0.01)

    # Main loop
    cur_num_sim = 0
    start_time = time()
    @threads for _ in 1:num_sim
        react_states = init_states(num_states, p)
        for i in 1:num_Δt
            for j in 1:num_states
                update_state(react_states[j], p)
            end
            if mod(i, step_ratio) == 0
                num_C_sim_path[div(i, step_ratio)+1] = count_C(react_states, num_states)
            end
        end
        @. num_C_total += num_C_sim_path

        # output to log file
        cur_num_sim += 1
        if mod(cur_num_sim, one_percent_num_sim) == 0
            sim_ratio = Int(floor((cur_num_sim / num_sim) * 100))
            elapsed_time = (time() - start_time) / 3600
            @printf "The program has been running for %.3f hours and is %d%% complete.\n" elapsed_time sim_ratio
            flush(stdout)
        end
    end
    C_means = num_C_total / (num_sim * num_states)
    save_result(C_means, num_sim, p)
    println("The program has completed and results are saved as CSV file!")
end

# Call the main function if this script is run directly
if abspath(PROGRAM_FILE) == @__FILE__
    main(ARGS)
end

# command line:
# nohup julia AB_C_X.jl > logs/ABCX.log 2>&1 &
# tail -n 50 -f ABCX_sim11000_24072201.log