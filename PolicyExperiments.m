% ========================================================================
% Analysis of Gravity Model with Shocks and Optimal Transport (OT)
% ========================================================================
% This script analyzes the impact of economic shocks on the trade network 
% using a gravity model. It compares results with and without shocks for 
% the G7 and BRICS countries, performing a series of regressions and 
% evaluating the impact of these shocks on trade flow dynamics. The script 
% uses optimal transport (OT) to measure changes in network modularity and 
% compares the partitions of the trade network before and after the shock. 
% Geographical visualizations and bar plots are generated to highlight the 
% results and network changes.
%
% The script performs the following tasks:
% - Loads regression results for the selected gravity model and scenarios.
% - Applies economic shocks to GDP for selected countries (BRICS or G7).
% - Performs regressions using the ZIP gravity model with and without shocks.
% - Computes optimal transport (OT) to compare trade network structures.
% - Measures modularity changes using OT-based partitions.
% - Evaluates the impact of shocks on network partitions using partition 
%   distance.
% - Generates geographical visualizations to show the distribution of 
%   network partitions with and without shocks.
% - Produces bar plots comparing modularity, number of communities, and 
%   information theory metrics between the shocked and unshocked networks.
%
% ------------------------------------------------------------------------
% Usage:
% - Ensure that the regression result files ('ZIP_RegressionResults.mat', 
%   'ZIP_SCENARIO_Covariates.mat') are available in the working directory.
% - Ensure the shapefile ('TM_WORLD_BORDERS_SIMPL-0.3.shp') for map plotting 
%   is available.
% - Run the script in MATLAB.
% ------------------------------------------------------------------------
%
% Outputs:
% - Geographical visualizations of trade network partitions (before and 
%   after shock).
% - Bar plots comparing modularity, number of communities, and information 
%   theory metrics for shocked vs. unshocked networks.
% - Evaluation of network changes due to shocks using partition distance.
%
% Additional Features:
% - Uses the Sinkhorn algorithm for optimal transport.
% - Supports shocks to GDP for both BRICS and G7 countries.
% - Visualizes trade network partitions using a 'hot' colormap for clarity.
% - Generates modularity and community-related statistics (e.g., number of 
%   communities, variation in information).
% - Handles data in CSV format and cleans up temporary files after execution.
%
% ========================================================================

clc; clearvars; close all;
%% addpath
addpath('Utilities')
%% gravity type
GravType='ZIP'; %OLS POISSON ZIP
Shock='G7'; % BRICS G7
%% read data
load([GravType,'_RegressionResults.mat'])
load ZIP_SCENARIO_Covariates.mat
%% anni e paesi
anno=2020;
Anni=2000:2020;
periodo=find(Anni==anno);
Country=NodiFin{periodo};
Country_o=repmat(Country,size(Country,1),1);
Country_d=repelem(Country,size(Country,1));
X=CovariateScenarioA{1};
XShock=X;
Y=CovariateScenarioA{2};
Adj=MatriciTrade{periodo};
%% shock to gdp
if strcmp(Shock,"BRICS")==1
    initshock_o=ismember(Country_o,["CHN","BRA","RUS","IND","ZAF"]);
    initshock_d=ismember(Country_d,["CHN","BRA","RUS","IND","ZAF"]);
    XShock(initshock_o,1)=XShock(initshock_o,1)*.9;
    XShock(initshock_d,2)=XShock(initshock_d,2)*.9;
    titolo='BRICS Shock';
else
     initshock_o=ismember(Country_o,["ITA","FRA","DEU","JPN","USA","CAN","GBR"]);
     initshock_d=ismember(Country_d,["ITA","FRA","DEU","JPN","USA","CAN","GBR"]);
     XShock(initshock_o,1)=XShock(initshock_o,1)*.9;
     XShock(initshock_d,2)=XShock(initshock_d,2)*.9;
     titolo='G7 Shock';
end


%% do regression
writetable(array2table([round(Y) X]),'DatiR.csv')
writetable(array2table([round(Y) XShock]),'DatiRShock.csv')
 
RunRcode('E:\NullModel\Codici\final\FinalMagari\Soc_Net\Utilities\ZIP1_Policy.R')
pause(.5)    
yhat_aus=readtable('Fit.csv');
yhat1=yhat_aus.x;
yhat=reshape(yhat1,size(Adj));
yhatNoshock=yhat-diag(diag(yhat));

yhat_aus=readtable('FitShock.csv');
yhat1=yhat_aus.x;
yhat=reshape(yhat1,size(Adj));
yhatShock=yhat-diag(diag(yhat));
pause(.5)    
delete Fit.csv
delete DatiR.csv
delete DatiRShock.csv
delete FitShock.csv
pause(.5)

%% do OT
% do costs
yhatNoshock(isnan(yhatNoshock))=0;
yhatShock(isnan(yhatShock))=0;
C=1./yhatNoshock;
C_shock=1./yhatShock;

% do constraint
Adj=Adj/sum(sum(Adj));
InStr=sum(Adj); 
InStr=InStr/sum(InStr);
OutStr=sum(Adj,2); 
OutStr=OutStr/sum(OutStr);
% do OT
T = Sinkhorn_OT(C,0.00001,OutStr,InStr', 10^-5,100);
T_shock = Sinkhorn_OT(C_shock,0.00001,OutStr,InStr', 10^-5,100);
% do modularity max
[CiOT,QOT]=OTmodularity_dir(Adj,1,T);
ModulOT=QOT
PartitionOT=CiOT;

[CiOT,QOT]=OTmodularity_dir(Adj,1,T_shock);
ModulOT_shock=QOT
PartitionOT_shock=CiOT;

[VIn, MIn] = partition_distance(PartitionOT, PartitionOT_shock)
%% plot mappe
DatiGeo=shaperead('TM_WORLD_BORDERS_SIMPL-0.3.shp');
Pae=string({DatiGeo.ISO3});
PaesiBaci=NodiFin{periodo};
figure
rgb = vals2colormap(1:max(PartitionOT), 'hot');
for y=1:max(PartitionOT)
    chi=PaesiBaci(PartitionOT==y);    
    [ss_eu,ia_eu,ib_eu]=intersect(Pae,chi);
    [ss_off,ia_off]=setdiff(Pae,PaesiBaci);
    mapshow(DatiGeo(ia_eu),'FaceColor',rgb(y,:))
    mapshow(DatiGeo(ia_off),'FaceColor',[192/256 192/256 192/256])
    axis off
end
title('No Shock')


figure
rgb = vals2colormap(1:max(PartitionOT_shock), 'hot');
for y=1:max(PartitionOT_shock)
    chi=PaesiBaci(PartitionOT_shock==y);    
    [ss_eu,ia_eu,ib_eu]=intersect(Pae,chi);
    [ss_off,ia_off]=setdiff(Pae,PaesiBaci);
    mapshow(DatiGeo(ia_eu),'FaceColor',rgb(y,:))
    mapshow(DatiGeo(ia_off),'FaceColor',[192/256 192/256 192/256])
    axis off
end
title(titolo)

%% plot barre
figure
subplot(1,3,1)
bar([ModulOT,ModulOT_shock])
xticks(1:2)
xticklabels({'No Shock','Shock'})
axis tight
grid on
title('Modul.')
set(findall(gcf,'-property','FontSize'),'FontSize',12)
subplot(1,3,2)
bar([max(PartitionOT),max(PartitionOT_shock)])
xticks(1:2)
xticklabels({'No Shock','Shock'})
axis tight
grid on
title('Num. Comm.')
set(findall(gcf,'-property','FontSize'),'FontSize',12)
subplot(1,3,3)
bar([VIn, MIn])
xticks(1:2)
xticklabels({'Var. Info.','Mut. Info.'})
axis tight
grid on
title('Th. Info.')
set(findall(gcf,'-property','FontSize'),'FontSize',12)
sgtitle(titolo)
