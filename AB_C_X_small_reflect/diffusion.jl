function forward_diff(X1, X2, p)
    # unpack variables from p 
    (; δ, Ω_inf, Ω_sup) = p

    # generate standard normal random vector
    # store as static arrays
    Z₁ = @SVector randn(3)
    Z₂ = @SVector randn(3)

    X1_next = X1 + δ * Z₁
    X2_next = X2 + δ * Z₂

    X1_next_inside = (Ω_inf <= elem <= Ω_sup for elem in X1_next)
    # if X1_next outside Ω
    if !all(X1_next_inside)
        drift_not_far, X1_reflected = reflect(X1_next, p)
        if drift_not_far
            X1_next = X1_reflected
        else
            # drift too far, don't update
            X1_next = X1
        end
        # else
        #   keep X1_next
    end

    X2_next_inside = (Ω_inf <= elem <= Ω_sup for elem in X2_next)
    if !all(X2_next_inside) # outside
        drift_not_far, X2_reflected = reflect(X2_next, p)
        if drift_not_far
            X2_next = X2_reflected
        else
            # drift too far, don't update
            X2_next = X2
        end
    end

    return (X1_next, X2_next)
end

function backward_diff(X3, p)
    (; δ, Ω_inf, Ω_sup) = p
    Z = @SVector randn(3)
    X3_next = X3 + δ * Z

    X3_next_inside = (Ω_inf <= elem <= Ω_sup for elem in X3_next)
    # if X3_next in Ω
    if all(X3_next_inside)
        return X3_next
    else
        drift_not_far, X3_reflected = reflect(X3_next, p)
        if drift_not_far
            return X3_reflected
        else
            # drift too far, don't update
            return X3
        end
    end
end