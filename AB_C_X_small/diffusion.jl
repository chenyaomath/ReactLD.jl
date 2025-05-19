function forward_diff(X1, X2, p)
    # unpack variables from p 
    (; δ, Ω_sup) = p

    # generate standard normal random vector
    # store as static arrays
    Z₁ = @SVector randn(3)
    X1_next = X1 + δ * Z₁
    X1_next = mod.(X1_next, Ω_sup)

    Z₂ = @SVector randn(3)
    X2_next = X2 + δ * Z₂
    X2_next = mod.(X2_next, Ω_sup)

    return (X1_next, X2_next)
end

function backward_diff(X3, p)
    (; δ, Ω_sup) = p
    Z = @SVector randn(3)
    X3_next = X3 + δ * Z
    return mod.(X3_next, Ω_sup)
end