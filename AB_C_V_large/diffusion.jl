function forward_diff(X1, V1, X2, V2, p)
    # unpack variables from p 
    (; Ω_sup, Δt, β₁δ₁, β₂δ₂, β₁Δt_plus_1_inv, β₂Δt_plus_1_inv) = p

    Z1 = @SVector randn(3)
    V1_next = (V1 + β₁δ₁ * Z1) * β₁Δt_plus_1_inv
    X1_next = X1 + V1_next * Δt
    if !all(0.0 .<= X1_next .<= 200.0)
        X1_next = mod.(X1_next, Ω_sup)
    end

    Z2 = @SVector randn(3)
    V2_next = (V2 + β₂δ₂ * Z2) * β₂Δt_plus_1_inv
    X2_next = X2 + V2_next * Δt
    if !all(0.0 .<= X2_next .<= 200.0)
        X2_next = mod.(X2_next, Ω_sup)
    end

    return (X1_next, V1_next,
            X2_next, V2_next)
end

function backward_diff(X3, V3, p)
    (; Ω_sup, Δt, β₃δ₃, β₃Δt_plus_1_inv) = p

    # implicit method
    Z = @SVector randn(3)
    V3_next = (V3 + β₃δ₃ * Z) * β₃Δt_plus_1_inv
    X3_next = X3 + V3_next * Δt
    if all(0.0 .<= X3_next .<= 200.0)
        return (X3_next, V3_next)
    else
        return (mod.(X3_next, Ω_sup), V3_next)
    end
end