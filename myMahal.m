function J_mahal = myMahal(X, Y) % Mahalonibus distance for two populations

    X_sz = size(X);
    Y_sz = size(Y);
    
    X_rows = X_sz(1);
    Y_rows = Y_sz(1);
    
    cols = X_sz(2);
    
    rows = min(X_rows,Y_rows);
    
    X = X(1:rows,:);
    Y = Y(1:rows,:);
    
    common_cov = (cov(X)*(rows - 1) + cov(Y)*(rows - 1) )./(2*rows);
    
    if rank(common_cov) < cols % don't calculate if the matrix is singular
    
        J_mahal = 0;
    else 
        
        u_X = mean(X,1)';
        u_Y = mean(Y,1)';
    
        J_mahal = (u_X - u_Y)' * inv(common_cov) * (u_X - u_Y);
    end
end