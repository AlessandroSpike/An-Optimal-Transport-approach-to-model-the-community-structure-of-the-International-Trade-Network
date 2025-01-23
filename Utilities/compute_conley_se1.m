function conley_se = compute_conley_se1(Y, yhat, X, PaeExp, PaeImp, distanza)
    % Compute Pearson residuals and scale them
    yhat(isinf(yhat))=0;
    Y(isinf(Y))=0;
    X(isinf(X))=0;
    residuals = (Y - yhat);
    % Pearson residuals
    residuals(isnan(residuals))=0;
    residuals(isinf(residuals))=0;
    n_obs = length(residuals);
    scaled_residuals = residuals./sqrt(n_obs) ;
    
    % Combine dependent and independent variables
    dataN = [Y, X];

    % Identify unique exporters and importers
    [~, ~, exporter_idx] = unique(PaeExp);
    [~, ~, importer_idx] = unique(PaeImp);

    % Prepare design matrix
    X = [ones(size(dataN, 1), 1), dataN(:, 2:end)];
    X(isnan(X)) = 0;
    X(isinf(X)) = 0;
    distanza(isinf(distanza)) = 0;

    % Initialize parameters for block processing
    block_size = 1000;  % Adjust based on memory
    n_blocks = ceil(n_obs / block_size);

    % Initialize meat matrix
    meat = zeros(size(X, 2), size(X, 2));

    % Process in blocks
    for i = 1:n_blocks
        start_idx = (i - 1) * block_size + 1;
        end_idx = min(i * block_size, n_obs);
        block_indices = start_idx:end_idx;

        % Get block of residuals
        res_i = scaled_residuals(block_indices);
        X_i = X(block_indices, :);

        % Process weights for this block
        for j = 1:n_blocks
            start_j = (j - 1) * block_size + 1;
            end_j = min(j * block_size, n_obs);
            block_indices_j = start_j:end_j;

            % Compute weights for this block pair
            weights_block = double(distanza(exporter_idx(block_indices), ...
                importer_idx(block_indices_j)) <= 2000);

            % Update meat matrix
            res_j = scaled_residuals(block_indices_j);
            X_j = X(block_indices_j, :);

            meat = meat + X_i' * (weights_block .* (res_i * res_j')) * X_j;
        end
    end

    % Compute bread matrix
    bread = inv(X' * X);

    % Compute Conley variance-covariance matrix
    V_conley = bread * meat * bread;

    % Extract Conley standard errors
    conley_se = sqrt(diag(abs(V_conley)));
end
