function conley_se = compute_conley_se2(Y, yhat, X, PaeExp, PaeImp, distanza)
    % Ensure dimensions match
    n_obs = length(Y);
    if size(X, 1) ~= n_obs
        error('X and Y must have the same number of observations.');
    end
    yhat(isinf(yhat))=0;
    Y(isinf(Y))=0;
    X(isinf(X))=0;
    % Compute Pearson residuals
    residuals = (Y - yhat);  % Avoid division by zero
    residuals(isnan(residuals) | isinf(residuals)) = 0;
    residuals=residuals./sqrt(length(residuals));
    % Identify unique exporters and importers
    [~, ~, exporter_idx] = unique(PaeExp);
    [~, ~, importer_idx] = unique(PaeImp);

    % Prepare design matrix
    X = [ones(n_obs, 1), X];
    distanza(isinf(distanza)) = 0;

    % Initialize meat matrix
    meat = zeros(size(X, 2), size(X, 2));

    % Block processing for efficiency
    block_size = 1000;  % Adjust block size
    n_blocks = ceil(n_obs / block_size);
    for i = 1:n_blocks
        start_idx = (i - 1) * block_size + 1;
        end_idx = min(i * block_size, n_obs);
        block_indices = start_idx:end_idx;

        % Extract block residuals and design matrix
        res_i = residuals(block_indices);
        X_i = X(block_indices, :);

        % Precompute weights for this block
        weights = distanza(exporter_idx(block_indices), importer_idx(:)) <= 2000;

        % Compute weighted residuals
        weighted_residuals = weights .* (res_i * residuals');
        meat = meat + X_i' * weighted_residuals * X;
    end

    % Compute weight matrix (W) for Poisson regression
    W = spdiags(yhat, 0, n_obs, n_obs);  % Diagonal matrix of predicted values
    bread = pinv(X' * W * X);  % Use pseudo-inverse for numerical stability

    % Compute Conley variance-covariance matrix
    V_conley = bread * meat * bread;

    % Extract Conley standard errors
    conley_se = sqrt(diag(abs(V_conley)));
end
