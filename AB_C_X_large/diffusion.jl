function forward_diff(X1, X2, p)
    # unpack variables from p 
    (; δ, Ω_sup) = p

    # generate standard normal random vector
    # store as static arrays
    Z₁ = @SVector randn(3)
    X1_next = X1 + δ * Z₁
    if !all(0.0 .<= X1_next .<= 200.0)
        X1_next = mod.(X1_next, Ω_sup)
    end

    Z₂ = @SVector randn(3)
    X2_next = X2 + δ * Z₂
    if !all(0.0 .<= X2_next .<= 200.0)
        X2_next = mod.(X2_next, Ω_sup)
    end

    return (X1_next, X2_next)
end

function backward_diff(X3, p)
    (; δ, Ω_sup) = p
    Z = @SVector randn(3)
    X3_next = X3 + δ * Z
    if all(0.0 .<= X3_next .<= 200.0)
        return X3_next
    else
        return mod.(X3_next, Ω_sup)
    end
end