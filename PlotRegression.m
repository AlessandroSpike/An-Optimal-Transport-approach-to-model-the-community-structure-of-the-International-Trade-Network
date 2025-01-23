% ========================================================================
% Analysis of Gravity Models and Economic Network Visualization
% ========================================================================
% This script analyzes the results of various gravity models (OLS, Poisson, 
% and others) for a set of economic variables over the period 2000-2020. 
% The analysis includes the visualization of coefficient estimates and 
% standard errors for variables such as GDP, distance, area, population, 
% and trade-related dummy variables. Multiple gravity models, including 
% Zero-Inflated Poisson (ZIP), Fixed Effects, and Binary Trade models, 
% are compared. The results are presented using line plots, bar charts, 
% and grouped bar plots. The figures are organized in tiled layouts for 
% easier comparison across different sets of coefficients and their 
% corresponding standard errors.
%
% The script performs the following tasks:
% - Loads the regression results for different gravity models.
% - Processes and organizes coefficient estimates and standard errors.
% - Generates visualizations of coefficient trends over time.
% - Visualizes the evolution of the coefficients for key variables 
%   across different gravity model types.
% - Compares coefficient estimates and standard errors between models 
%   using bar plots and line charts.
% - Organizes output in a tiled layout for easier interpretation of results.
%
% ------------------------------------------------------------------------
% Usage:
% - Ensure that the regression result files ('OLS_RegressionResults.mat', 
%   'ZIP_RegressionResults.mat', etc.) are available in the 'RegressionResults' folder.
% - Run the script in MATLAB.
% ------------------------------------------------------------------------
%
% Outputs:
% - Line plots and bar charts showing the coefficients for various 
%   economic variables (e.g., GDP, distance, population) across different 
%   gravity models.
% - Tiled figure layouts comparing coefficient estimates and their 
%   standard errors over time.
% - Visualizations of the evolution of economic relationships over the 
%   period 2000-2020.
%
% Additional Features:
% - Uses customized color schemes for better visualization (e.g., ordered colors).
% - Automatically loads and processes regression results for multiple models.
% - Supports comparison between multiple gravity models (OLS, ZIP, Fixed Effects, etc.).
%
% ========================================================================

clc; clearvars; close all
%% addpath
addpath('RegressionResults')
%% gravity type
GravType='OTHERS'; %OLS POISSON OTHERS
%% read regression results
switch GravType
    case 'OLS'
         load OLS_RegressionResults.mat
         singolo=1;
    case 'POISSON'   
        load OLS_RegressionResults.mat
        singolo=1;
    case 'OTHERS'   
        load ZIP_RegressionResults.mat
        CoefficientiZIP=Coefficienti;
        StandardErrZIP=StandardErr;

        load FIXED_RegressionResults.mat
        CoefficientiFIXED=Coefficienti;
        StandardErrFIXED=StandardErr;

        load FIXED_BIN_RegressionResults.mat
        CoefficientiFIXED_BIN=Coefficienti;
        StandardErrFIXED_BIN=StandardErr;

        

        singolo=2;
end
%% variable names
VarName=["GDP Source","GDP Dest.","DIST","AREA Source","AREA Dest.",...
    "POP Source","POP Dest.","LL Source","LL Dest.","TA","CTG",...
    "COMC","COL","COML"];
VarName2=["GDP Source","GDP Dest.","DIST","AREA Source","AREA Dest.",...
    "POP Source","POP Dest.","LL Source","LL Dest.","TA","CTG",...
    "COMC","COL","COML","Bin. Trade"];
Anni=2000:2020;
%% plot
if singolo==1
    C = orderedcolors('sail');
    figure
    tiledlayout(3,1)
    nexttile(1,[2 1]);
    yyaxis left
    plot(Anni,Coefficienti(2,:),'Color',C(1,:),'LineWidth',2)
    hold on
    plot(Anni,Coefficienti(3,:),'-','Color',C(2,:),'LineWidth',2)
    ylabel('GDP \beta')
    axis tight
    grid on
    yyaxis right
    plot(Anni,Coefficienti(4,:),'Color',C(3,:),'LineWidth',2)
    ylabel('DIST \beta')
    axis tight
    grid on
    legend(VarName(1:3)...
        ,'Location','Northoutside','NumColumns',3)
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k';
    colororder('sail')
    nexttile
    bar(Anni, StandardErr(2:4,:)','grouped','FaceAlpha',0.5)
    grid on
    axis tight
    ylabel('Std. Err.')
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    colororder('sail')
    
    C = orderedcolors('sail');
    figure
    tiledlayout(3,1)
    nexttile(1,[2 1]);
    yyaxis left
    plot(Anni,Coefficienti(5,:),'Color',C(1,:),'LineWidth',2)
    hold on
    plot(Anni,Coefficienti(6,:),'-','Color',C(2,:),'LineWidth',2)
    ylabel('AREA \beta')
    axis tight
    grid on
    yyaxis right
    plot(Anni,Coefficienti(7,:),'Color',C(3,:),'LineWidth',2)
    plot(Anni,Coefficienti(8,:),'-','Color',C(4,:),'LineWidth',2)
    ylabel('POP \beta')
    axis tight
    grid on
    legend(VarName(4:7)...
        ,'Location','Northoutside','NumColumns',4)
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k';
    colororder('sail')
    nexttile
    bar(Anni, StandardErr(5:8,:)','grouped','FaceAlpha',0.5)
    grid on
    axis tight
    ylabel('Std. Err.')
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    colororder('sail')
    
    figure
    tiledlayout(3,1)
    nexttile(1,[2 1]);
    plot(Anni,Coefficienti(9,:),'LineWidth',2)
    hold on
    plot(Anni,Coefficienti(10,:),'-','LineWidth',2)
    ylabel('LL \beta')
    axis tight
    grid on
    legend(VarName(8:9)...
        ,'Location','Northoutside','NumColumns',4)
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    colororder('sail')
    nexttile
    bar(Anni, StandardErr(9:10,:)','grouped','FaceAlpha',0.5)
    grid on
    axis tight
    ylabel('Std. Err.')
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    colororder('sail')
    
    figure
    tiledlayout(3,1)
    nexttile(1,[2 1]);
    plot(Anni,Coefficienti(11:15,:),'LineWidth',2)
    ylabel('Dummy \beta')
    axis tight
    grid on
    legend(VarName(10:14)...
        ,'Location','Northoutside','NumColumns',4)
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    colororder('sail')
    nexttile
    bar(Anni, StandardErr(11:15,:)','grouped','FaceAlpha',0.5)
    grid on
    axis tight
    ylabel('Std. Err.')
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    colororder('sail')
    
    figure
    [incSort, sortPos] = sort(mean(Coefficienti(2:end,:),2));
    barh(1:2:numel(incSort), incSort(1:2:end), "FaceColor", "b", "BarWidth", 0.4, "FaceAlpha", 0.5)
    hold on
    barh(2:2:numel(incSort), incSort(2:2:end), "FaceColor", "r", "BarWidth", 0.4, "FaceAlpha", 0.5)
    nodeNames = VarName(sortPos);
    yticks(1:numel(nodeNames))
    yticklabels(nodeNames)
    axis tight
    grid on
    title('Average Coefficient Values')
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
else

    figure
    subplot(2,2,[1 3])
    [incSort, sortPos] = sort(mean(CoefficientiZIP(2:end,:),2));
    barh(1:2:numel(incSort), incSort(1:2:end), "FaceColor", "b", "BarWidth", 0.4, "FaceAlpha", 0.5)
    hold on
    barh(2:2:numel(incSort), incSort(2:2:end), "FaceColor", "r", "BarWidth", 0.4, "FaceAlpha", 0.5)
    nodeNames = VarName(sortPos);
    yticks(1:numel(nodeNames))
    yticklabels(nodeNames)
    axis tight
    grid on
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    subplot(2,2,2)
    [incSort, sortPos] = sort(mean(CoefficientiFIXED(2:end,:),2));
    tolgo=isnan(incSort);
    incSort(tolgo)=[];
    sortPos(tolgo)=[];
    barh(1:2:numel(incSort), incSort(1:2:end), "FaceColor", "b", "BarWidth", 0.4, "FaceAlpha", 0.5)
    hold on
    barh(2:2:numel(incSort), incSort(2:2:end), "FaceColor", "r", "BarWidth", 0.4, "FaceAlpha", 0.5)
    nodeNames = VarName(sortPos);
    yticks(1:numel(nodeNames))
    yticklabels(nodeNames)
    axis tight
    grid on
    title('Fixed Effect')
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    sgtitle('Average Coefficient Values')
    subplot(2,2,4)
    [incSort, sortPos] = sort(mean(CoefficientiFIXED_BIN(2:end,:),2));
    tolgo=isnan(incSort);
    incSort(tolgo)=[];
    sortPos(tolgo)=[];
    barh(1:2:numel(incSort), incSort(1:2:end), "FaceColor", "b", "BarWidth", 0.4, "FaceAlpha", 0.5)
    hold on
    barh(2:2:numel(incSort), incSort(2:2:end), "FaceColor", "r", "BarWidth", 0.4, "FaceAlpha", 0.5)
    nodeNames = VarName2(sortPos);
    yticks(1:numel(nodeNames))
    yticklabels(nodeNames)
    axis tight
    grid on
    title('Binary Trade F.E.')
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    sgtitle('Average Coefficient Values')




    C = orderedcolors('sail');
    figure
    tiledlayout(3,1)
    nexttile(1,[2 1]);
    yyaxis left
    plot(Anni,CoefficientiZIP(2,:),'Color',C(1,:),'LineWidth',2)
    hold on
    plot(Anni,CoefficientiZIP(3,:),'-','Color',C(2,:),'LineWidth',2)
    ylabel('GDP \beta')
    axis tight
    grid on
    yyaxis right
    plot(Anni,CoefficientiZIP(4,:),'Color',C(3,:),'LineWidth',2)
    ylabel('DIST \beta')
    axis tight
    grid on
    legend(VarName(1:3)...
        ,'Location','Northoutside','NumColumns',3)
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k';
    colororder('sail')
    nexttile
    bar(Anni, StandardErrZIP(2:4,:)','grouped','FaceAlpha',0.5)
    grid on
    axis tight
    ylabel('Std. Err.')
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    colororder('sail')
    
    C = orderedcolors('sail');
    figure
    tiledlayout(3,1)
    nexttile(1,[2 1]);
    yyaxis left
    plot(Anni,CoefficientiZIP(5,:),'Color',C(1,:),'LineWidth',2)
    hold on
    plot(Anni,CoefficientiZIP(6,:),'-','Color',C(2,:),'LineWidth',2)
    ylabel('AREA \beta')
    axis tight
    grid on
    yyaxis right
    plot(Anni,CoefficientiZIP(7,:),'Color',C(3,:),'LineWidth',2)
    plot(Anni,CoefficientiZIP(8,:),'-','Color',C(4,:),'LineWidth',2)
    ylabel('POP \beta')
    axis tight
    grid on
    legend(VarName(4:7)...
        ,'Location','Northoutside','NumColumns',4)
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k';
    colororder('sail')
    nexttile
    bar(Anni, StandardErrZIP(5:8,:)','grouped','FaceAlpha',0.5)
    grid on
    axis tight
    ylabel('Std. Err.')
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    colororder('sail')
    
    figure
    tiledlayout(3,1)
    nexttile(1,[2 1]);
    plot(Anni,CoefficientiZIP(9,:),'LineWidth',2)
    hold on
    plot(Anni,CoefficientiZIP(10,:),'-','LineWidth',2)
    ylabel('LL \beta')
    axis tight
    grid on
    legend(VarName(8:9)...
        ,'Location','Northoutside','NumColumns',4)
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    colororder('sail')
    nexttile
    bar(Anni, StandardErrZIP(9:10,:)','grouped','FaceAlpha',0.5)
    grid on
    axis tight
    ylabel('Std. Err.')
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    colororder('sail')
    
    figure
    tiledlayout(3,1)
    nexttile(1,[2 1]);
    plot(Anni,CoefficientiZIP(11:15,:),'LineWidth',2)
    ylabel('Dummy \beta')
    axis tight
    grid on
    legend(VarName(10:14)...
        ,'Location','Northoutside','NumColumns',4)
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    colororder('sail')
    nexttile
    bar(Anni,StandardErrZIP(11:15,:)','grouped','FaceAlpha',0.5)
    grid on
    axis tight
    ylabel('Std. Err.')
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    colororder('sail')


    C = orderedcolors('earth');
    figure
    tiledlayout(3,1)
    nexttile(1,[2 1]);
    yyaxis left
    plot(Anni,CoefficientiFIXED(11,:),'Color',C(1,:),'LineWidth',2)
    hold on
    plot(Anni,CoefficientiFIXED(12,:),'Color',C(2,:),'LineWidth',2)
    plot(Anni,CoefficientiFIXED(13,:),'Color',C(3,:),'LineWidth',2)
    plot(Anni,CoefficientiFIXED(14,:),'Color',C(4,:),'LineWidth',2)
    plot(Anni,CoefficientiFIXED(15,:),'Color',C(5,:),'LineWidth',2)
    ylabel('Dummy \beta')
    axis tight
    grid on
    yyaxis right
    plot(Anni,CoefficientiFIXED(4,:),'Color',C(6,:),'LineWidth',2)
    ylabel('DIST \beta')
    axis tight
    grid on
    legend([VarName(10:14),"DIST"]...
        ,'Location','Northoutside','NumColumns',3)
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k';
    nexttile
    b=bar(Anni, [StandardErrFIXED(11:15,:)',StandardErrFIXED(4,:)'],'grouped','FaceAlpha',0.5);
    % Apply matching colors to the bar groups
    for k = 1:numel(b)
        b(k).FaceColor = 'flat';
        b(k).CData = repmat(C(k,:), size(b(k).YData', 1), 1); % Match each bar group color
    end
    grid on
    axis tight
    ylabel('Std. Err.')
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    colororder('sail')


    C = orderedcolors('earth');
    figure
    tiledlayout(4,1)
    nexttile(1,[2 1]);
    yyaxis left
    plot(Anni,CoefficientiFIXED_BIN(11,:),'Color',C(1,:),'LineWidth',2)
    hold on
    plot(Anni,CoefficientiFIXED_BIN(12,:),'Color',C(2,:),'LineWidth',2)
    plot(Anni,CoefficientiFIXED_BIN(13,:),'Color',C(3,:),'LineWidth',2)
    plot(Anni,CoefficientiFIXED_BIN(14,:),'Color',C(4,:),'LineWidth',2)
    plot(Anni,CoefficientiFIXED_BIN(15,:),'Color',C(5,:),'LineWidth',2) 
    ylabel('Dummy \beta')
    axis tight
    grid on
    yyaxis right
    plot(Anni,CoefficientiFIXED_BIN(4,:),'Color',C(6,:),'LineWidth',2)
    ylabel('DIST \beta')
    axis tight
    grid on
    legend([VarName(10:14),"DIST"]...
        ,'Location','Northoutside','NumColumns',3)
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k';
    nexttile
    plot(Anni,CoefficientiFIXED_BIN(16,:),'Color',C(7,:),'LineWidth',2) 
    legend('Binary Trade')
    ylabel('Binary Trade \beta')
    axis tight
    grid on

    nexttile
    b=bar(Anni, [StandardErrFIXED_BIN(11:16,:)',StandardErrFIXED_BIN(4,:)'],'grouped','FaceAlpha',0.5);
    % Apply matching colors to the bar groups
    for k = 1:numel(b)
        b(k).FaceColor = 'flat';
        b(k).CData = repmat(C(k,:), size(b(k).YData', 1), 1); % Match each bar group color
    end
    grid on
    axis tight
    ylabel('Std. Err.')
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    colororder('sail')
    

end
