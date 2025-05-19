using Pkg
Pkg.activate(".")

#Pkg.add("Plots")
#Pkg.add("ArgParse")
#Pkg.add("CSV")
#Pkg.add("Distributions")
#Pkg.add("DataFrames")
#Pkg.add("ProgressMeter")
#Pkg.add("StaticArrays")
#Pkg.add("Setfield")
#Pkg.add("Tables")

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
        default = 1.0e-6

        "--beta"
        arg_type = Float64
        default  = 1.0
    end

    parsed_args = parse_args(args, s)

    # Parameters from command inputs
    num_sim    = parsed_args["num_sim"]
    time_step  = parsed_args["time_step"]
    β          = parsed_args["beta"]

    # Parameters
    p = (;
        Ω_inf = 0.0,        # nm
        Ω_sup = 200.0,      # nm
        T     = 0.3,        # s 
        Δt    = time_step,  # s
        C₀    = 1.25e-4,    # nm^{-3}

        λ₁ = 1.0e4,         # 1/s, Pb = 0.2323
        λ₀ = 17.3,          # 1/s
        ε  = 10.0,          # nm
        γ₁ =  0.5,          # ratio
        γ₀ =  0.5,          # ratio

        D₁ = 1.0e6,         # nm 
        D₂ = 1.0e6,         # nm
        D₃ = 1.0e6,         # nm

        β₁_hat = 1.0,
        β₂_hat = 1.0
    )
    p = (; p...,
        β₃_hat = (p.D₁ * p.β₁_hat * p.D₂ * p.β₂_hat) / (p.D₁ * p.β₁_hat + p.D₂ * p.β₂_hat) / p.D₃,
        D  = @SVector [p.D₁; p.D₂; p.D₃]
    )
    p = (; p...,
        β₁ = β * p.β₁_hat,
        β₂ = β * p.β₂_hat,
        β₃ = β * p.β₃_hat,

        δ₁ = sqrt(2 * p.D₁ * p.Δt),
        δ₂ = sqrt(2 * p.D₂ * p.Δt),
        δ₃ = sqrt(2 * p.D₃ * p.Δt)
    )
    p = (; p..., 
        # diffusion
        β₁Δt_plus_1_inv = 1 / (p.β₁ * p.Δt + 1),
        β₂Δt_plus_1_inv = 1 / (p.β₂ * p.Δt + 1),
        β₃Δt_plus_1_inv = 1 / (p.β₃ * p.Δt + 1), 
        
        β₁δ₁ = p.β₁ * p.δ₁,
        β₂δ₂ = p.β₂ * p.δ₂,
        β₃δ₃ = p.β₃ * p.δ₃,

        # reaction
        one_minus_γ₀ = 1 - p.γ₀,

        m1_over_m3 = (p.D₃ * p.β₃) / (p.D₁ * p.β₁),
        m2_over_m3 = (p.D₃ * p.β₃) / (p.D₂ * p.β₂), 
        
        sqrt_D_over_Δt = sqrt.(p.D / p.Δt),
        std_ζ = sqrt(p.D₁ * p.β₁ + p.D₂ * p.β₂),

        # update_state
        ε_square = (p.ε)^2,
        λ₁Δt = p.λ₁ * p.Δt,
        λ₀Δt = p.λ₀ * p.Δt
    )


    # Inititialize
    (; T, Δt, C₀, Ω_sup) = p

    num_Δt     = Int(floor(T / Δt))
    num_states = Int(C₀ * (Ω_sup)^3)

    save_time_step = T / 5000 # plot 5000 points
    step_ratio     = Int(floor(save_time_step / Δt))
    num_save_steps = Int(floor(T / save_time_step)) + 1
    num_C_sim_path = zeros(num_save_steps)
    num_C_total    = zeros(num_save_steps)

    num_C_sim_path[1]   = Float64(num_states)
    one_percent_num_sim = Int(num_sim * 0.01)

    # Main Loop
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
    save_result(C_means, num_sim, β, p)
    println("The program has completed and results are saved as CSV file!")
end

# Call the main function if this script is run directly
if abspath(PROGRAM_FILE) == @__FILE__
    main(ARGS)
end

# command line:
# nohup JULIA_NUM_THREADS=5 julia AB_C_V.jl --num_sim 11000 --beta 1.0e19 --time_step 1.0e-7 > ABCV_sim11000_beta1.0e19_time_step1.0e-7_24072210.log 2>&1 &
# tail -n 50 -f ABCV_sim11000_beta1.0e19_time_step1.0e-7_24072210.log
# ps aux | grep julia