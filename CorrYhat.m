% ========================================================================
% Correlation Analysis of Regression Results
% ========================================================================
% This script loads regression results from three different models:
% - FIXED: A fixed-effects regression model.
% - ZIP (Zero-Inflated Poisson): A model accounting for excess zeros.
% - FIXED-BIN: A fixed-effects model with a binomial component.
% - PANEL: A fixed-effects panel model with country and time fixed effect.
%
% The goal is to compute the Pearson correlation between:
% 1. FIXED vs. ZIP
% 2. FIXED-BIN vs. ZIP
% 2. PANEL vs. ZIP
%
% The correlations are calculated for each year from 2000 to 2020 and 
% visualized using a time-series plot.
%
% ------------------------------------------------------------------------
% Usage:
% - Ensure the regression result files ('FIXED_RegressionResults.mat',
%   'ZIP_RegressionResults.mat', 'FIXED_BIN_RegressionResults.mat','Panel.mat') are 
%   available in the 'RegressionResults' directory.
% - Run the script in MATLAB.
% ------------------------------------------------------------------------
%
% Outputs:
% - A 3x21 matrix (CORRE) storing computed correlations over the years.
% - A figure displaying correlation trends over time.
%
% Additional Features:
% - Handles NaN values by replacing them with zeros.
% - Normalizes matrices to sum to 1 before computing correlations.
% - Highlights max and min correlation years in the plot.
%
% ========================================================================


clc; clearvars; close all
%% Add paths
addpath('RegressionResults')
%% Read regression results
load FIXED_RegressionResults.mat
FixedMatrici = MatriciFit;
MatriciReali = MatriciTrade;

load ZIP_RegressionResults.mat
ZipMatrici = MatriciFit;
load FIXED_BIN_RegressionResults.mat
FixedBinMatrici = MatriciFit;
load Panel.mat
PanelMatrici = MatriciFit;
Anni = 2000:2020;

%% Compute correlations
CORRE = zeros(3, 21);
HAMMING = zeros(1, 20);
JACCARD = zeros(1, 20);
for i = 1:21
    x1 = FixedMatrici{i};
    x1 = x1(:);
    x1(isnan(x1)) = 0;
    x1 = x1 / sum(x1);

    x2 = ZipMatrici{i};
    x2 = x2(:);
    x2(isnan(x2)) = 0;
    x2 = x2 / sum(x2);

    x3 = FixedBinMatrici{i};
    x3 = x3(:);
    x3(isnan(x3)) = 0;
    x3 = x3 / sum(x3);

    x4 = PanelMatrici{i};
    x4 = x4(:);
    x4(isnan(x4)) = 0;
    x4 = x4 / sum(x4);

    [h1, ~] = corr(x1, x2);
    [h2, ~] = corr(x3, x2);
    [h3, ~] = corr(x4, x2);
    CORRE(1, i) = h1;
    CORRE(2, i) = h2;
    CORRE(3, i) = h3;

    if i>1
       x1r = FixedMatrici{i};
       x1r = x1r(:);
       x1r(x1r>0)=1;
       x1r(isnan(x1r))=0;
       
       x2r = FixedMatrici{i-1};
       x2r = x2r(:);
       x2r(x2r>0)=1;
       x2r(isnan(x2r))=0;
       [a,b,c]=intersect(NodiFin{i},NodiFin{i-1});
       length(a)
       hamming_dist = sum(xor(x1r(b), x2r(c)));
       HAMMING(i)=hamming_dist;

       jaccardIndex = jaccard_similarity(x1r, x2r);
       JACCARD(i)=jaccardIndex;
    end
end

function jaccardIndex = jaccard_similarity(vec1, vec2)
    % Ensure the inputs are row vectors
    vec1 = vec1(:)';
    vec2 = vec2(:)';
    
    % Align the lengths by zero-padding
    maxLen = max(length(vec1), length(vec2));
    vec1 = [vec1 zeros(1, maxLen - length(vec1))];
    vec2 = [vec2 zeros(1, maxLen - length(vec2))];
    
    % Compute intersection and union
    intersection = sum(vec1 & vec2);
    union_ = sum(vec1 | vec2);
    
    % Avoid division by zero
    if union_ == 0
        jaccardIndex = NaN;  % or 0 if you prefer
    else
        jaccardIndex = intersection / union_;
    end
end
%% Fancy plot
figure
hold on

% Plot data with customized styles
plot(Anni, CORRE(1, :), '-o', 'LineWidth', 2, 'Color', [0 0.4470 0.7410], 'MarkerFaceColor', [0 0.4470 0.7410], 'MarkerSize', 6)
plot(Anni, CORRE(2, :), '--s', 'LineWidth', 2, 'Color', [0.8500 0.3250 0.0980], 'MarkerFaceColor', [0.8500 0.3250 0.0980], 'MarkerSize', 6)
plot(Anni, CORRE(3, :), '--s', 'LineWidth', 2, 'Color', [0.2500 0.6250 0.980], 'MarkerFaceColor', [0.2500 0.6250 0.980], 'MarkerSize', 6)

% Customize axes
grid on
axis tight
xlabel('Year', 'FontWeight', 'bold')
ylabel('Correlation', 'FontWeight', 'bold')
title('Correlation Over Time', 'FontWeight', 'bold')

% Add legend
legend({'Correlation: FIXED vs ZIP', 'Correlation: FIXED-BIN vs ZIP','Correlation: PANEL vs ZIP'}, 'Location', 'NorthOutside', 'Orientation', 'horizontal')

% Improve aesthetics
set(gca, 'FontSize', 12, 'LineWidth', 1.5)
box on
hold off

figure
plot(Anni(2:end), JACCARD(2:end), '-o', 'LineWidth', 2, 'Color', [0 0.4470 0.7410], 'MarkerFaceColor', [0 0.4470 0.7410], 'MarkerSize', 6)
% Customize axes
grid on
axis tight
xlabel('Year', 'FontWeight', 'bold')
ylabel('Jaccard Similarity', 'FontWeight', 'bold')
title('Similarity between consecutive years', 'FontWeight', 'bold')
% Improve aesthetics
set(gca, 'FontSize', 12, 'LineWidth', 1.5)
box on
