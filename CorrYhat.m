% ========================================================================
% Correlation Analysis of Regression Results
% ========================================================================
% This script loads regression results from three different models:
% - FIXED: A fixed-effects regression model.
% - ZIP (Zero-Inflated Poisson): A model accounting for excess zeros.
% - FIXED-BIN: A fixed-effects model with a binomial component.
%
% The goal is to compute the Pearson correlation between:
% 1. FIXED vs. ZIP
% 2. FIXED-BIN vs. ZIP
%
% The correlations are calculated for each year from 2000 to 2020 and 
% visualized using a time-series plot.
%
% ------------------------------------------------------------------------
% Usage:
% - Ensure the regression result files ('FIXED_RegressionResults.mat',
%   'ZIP_RegressionResults.mat', 'FIXED_BIN_RegressionResults.mat') are 
%   available in the 'RegressionResults' directory.
% - Run the script in MATLAB.
% ------------------------------------------------------------------------
%
% Outputs:
% - A 2x21 matrix (CORRE) storing computed correlations over the years.
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
load ZIP_RegressionResults.mat
ZipMatrici = MatriciFit;
load FIXED_BIN_RegressionResults.mat
FixedBinMatrici = MatriciFit;
Anni = 2000:2020;

%% Compute correlations
CORRE = zeros(2, 21);
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

    [h1, ~] = corr(x1, x2);
    [h2, ~] = corr(x3, x2);
    CORRE(1, i) = h1;
    CORRE(2, i) = h2;
end

%% Fancy plot
figure
hold on

% Plot data with customized styles
plot(Anni, CORRE(1, :), '-o', 'LineWidth', 2, 'Color', [0 0.4470 0.7410], 'MarkerFaceColor', [0 0.4470 0.7410], 'MarkerSize', 6)
plot(Anni, CORRE(2, :), '--s', 'LineWidth', 2, 'Color', [0.8500 0.3250 0.0980], 'MarkerFaceColor', [0.8500 0.3250 0.0980], 'MarkerSize', 6)

% Customize axes
grid on
axis tight
xlabel('Year', 'FontWeight', 'bold')
ylabel('Correlation', 'FontWeight', 'bold')
title('Correlation Over Time', 'FontWeight', 'bold')

% Add legend
legend({'Correlation: FIXED vs ZIP', 'Correlation: FIXED-BIN vs ZIP'}, 'Location', 'NorthOutside', 'Orientation', 'horizontal')

% Improve aesthetics
set(gca, 'FontSize', 12, 'LineWidth', 1.5)
box on

% Highlight specific points if needed
maxYear = Anni(CORRE(1, :) == max(CORRE(1, :)));
minYear = Anni(CORRE(1, :) == min(CORRE(1, :)));
text(maxYear, max(CORRE(1, :)), sprintf(' Max (%.4f)', max(CORRE(1, :))), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 10, 'Color', [0 0.4470 0.7410])
text(minYear, min(CORRE(1, :)), sprintf(' Min (%.4f)', min(CORRE(1, :))), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 10, 'Color', [0 0.4470 0.7410])

hold off
