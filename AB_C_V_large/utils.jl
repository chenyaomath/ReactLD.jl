const DIM = 3  # dim of the domain

mutable struct Particle
    X::SVector{DIM,Float64}
    V::SVector{DIM,Float64}
end

mutable struct ReactState
    dir::Float64
    A::Particle
    B::Particle
    C::Particle
end

# Calculate the square of periodic distance between two positions
function period_dist_square(X1, X2, p)
    (; Ω_sup) = p
    diff1 = abs.(X1 - X2)
    diff2 = Ω_sup .- diff1
    return sum(min.(diff1, diff2) .^ 2)
end

function update_state(state, p)
    (; λ₁Δt, λ₀Δt, ε_square) = p

    # Forward reaction-diffusion 
    if state.dir == 1.0
        # forward diffusion
        X1, V1, X2, V2 = forward_diff(state.A.X, state.A.V,
                                      state.B.X, state.B.V, p)

        if (rand() <= λ₁Δt) && (period_dist_square(X1, X2, p) <= ε_square)
            # forward reaction
            X3, V3 = forward_react(X1, V1, X2, V2, p)
            state.C.X = X3
            state.C.V = V3
            state.dir = 0.0
        else
            state.A.X = X1
            state.A.V = V1
            state.B.X = X2
            state.B.V = V2
        end
    # Backward reaction-diffusion
    else
        # backward diffusion
        X3, V3 = backward_diff(state.C.X, state.C.V, p)

        if (rand() <= λ₀Δt)
            # backward reaction
            X1, V1, X2, V2 = backward_react(X3, V3, p)

            state.A.X = X1
            state.A.V = V1
            state.B.X = X2
            state.B.V = V2
            state.dir = 1.0
        else
            state.C.X = X3
            state.C.V = V3
        end
    end
end

function init_states(num_states, p)
    (; Ω_sup, sqrt_D_over_Δt) = p

    react_states = Vector{ReactState}(undef, num_states)
    for i in 1:num_states
        init_dir = 0.0

        # init A
        init_X1 = Ω_sup * @SVector rand(3)
        init_V1 = @SVector rand(3)
        init_V1 = (20 .* init_V1 .- 10) .* sqrt_D_over_Δt
        init_A = Particle(init_X1, init_V1)

        # init B
        init_X2 = Ω_sup * @SVector rand(3)
        init_V2 = @SVector rand(3)
        init_V2 = (20 .* init_V2 .- 10) .* sqrt_D_over_Δt
        init_B = Particle(init_X2, init_V2)

        # init C
        init_X3 = Ω_sup * @SVector rand(3)
        init_V3 = @SVector rand(3)
        init_V3 = (20 .* init_V3 .- 10) .* sqrt_D_over_Δt
        init_C = Particle(init_X3, init_V3)

        init_state = ReactState(init_dir, init_A, init_B, init_C)
        react_states[i] = init_state
    end
    return react_states
end

function count_C(react_states, num_states)
    num_AB = 0.0
    for j in 1:num_states
        num_AB += react_states[j].dir
    end
    return (num_states - num_AB)
end

function save_result(means, num_sim, β, p)
    # Store
    (; Δt) = p
    df = DataFrame(mean=means)
    file_path = "results/ABCV_sim$num_sim" * "_beta$β" * "_Δt$Δt.csv"
    CSV.write(file_path, df)
end