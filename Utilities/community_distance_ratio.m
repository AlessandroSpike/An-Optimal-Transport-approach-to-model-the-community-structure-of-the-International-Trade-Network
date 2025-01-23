function  [ratio,mean_within,mean_between] = community_distance_ratio(D, C)
    % D: NxN distance matrix (symmetric)
    % C: Nx1 vector of community memberships

    N = size(D,1);
    
    % Create logical matrices for within-community and between-community pairs
    [I, J] = ndgrid(1:N, 1:N); % Generate index grids
    within_mask = C(I) == C(J) & I ~= J;  % Same community, exclude diagonal
    between_mask = C(I) ~= C(J);          % Different communities

    % Extract distances using logical indexing
    within_distances = D(within_mask);
    between_distances = D(between_mask);

    % Compute mean distances
    mean_within = mean(within_distances);
    mean_between = mean(between_distances);

    % Compute ratio
    ratio = mean_within / mean_between;
end