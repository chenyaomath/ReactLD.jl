using Pkg
Pkg.activate(".")

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

        "--domain_len"
        arg_type = Float64
        default  = 20.0

        "--time_step"
        arg_type = Float64
        default  = 1.0e-7
    end

    parsed_args = parse_args(args, s)

    # Parameters from command inputs
    num_sim    = parsed_args["num_sim"]
    domain_len = parsed_args["domain_len"]
    time_step  = parsed_args["time_step"]

    # Parameters
    p = (;
        Ω_inf = 0.0,         # nm
        Ω_sup = domain_len,  # nm
        T     = 0.25,        # s
        Δt    = time_step,   # s
        C₀    = 1.25e-4,     # nm^{-3}

        λ₁ = 40.5745,        # 1/s, varies based on Ω
        λ₀ = 17.3,           # 1/s
        ε  = 10.0,           # nm
        γ  = 0.5,            # ratio
        D  = 1.0e6           # nm
    )
    p = (; p..., 
        δ = sqrt(2 * p.D * p.Δt),
        
        # update states 
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

    # Main loop
    @showprogress for n in 1:num_sim
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
    end
    C_means = num_C_total / num_sim
    save_result(C_means, num_sim, p)
end

# Call the main function if this script is run directly
if abspath(PROGRAM_FILE) == @__FILE__
    main(ARGS)
end

# command line:
# nohup julia AB_C_X.jl > logs/ABCX.log 2>&1 &
# tail -n 50 -f ABCX_sim11000_24072201.log