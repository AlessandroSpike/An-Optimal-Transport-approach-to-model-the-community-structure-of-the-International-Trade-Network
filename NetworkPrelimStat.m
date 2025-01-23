% ========================================================================
% Analysis of Trade Network Evolution and Degree Distributions
% ========================================================================
% This script analyzes the evolution of international trade networks over 
% the period 2000-2020. It computes various network statistics, including 
% node count, link count, total flow, and network density. The script also 
% evaluates degree and strength distributions (both in-degree and out-degree) 
% for each year and visualizes trade flows and network characteristics.
%
% The script performs the following tasks:
% - Loads the regression results from 'ZIP_RegressionResults.mat'.
% - Calculates network statistics (number of nodes, links, flow, density).
% - Computes survival distributions for in-degree, out-degree, in-strength, 
%   and out-strength for each year.
% - Generates geographical network visualizations for selected years.
% - Plots evolution of network properties over time, including node and 
%   link counts, total flow, and network density.
% - Visualizes degree and strength distributions using log-log plots.
%
% ------------------------------------------------------------------------
% Usage:
% - Ensure 'ZIP_RegressionResults.mat' and 'DatiGrezzi.mat' are available 
%   in the 'Data' folder.
% - Run the script in MATLAB.
% ------------------------------------------------------------------------
%
% Outputs:
% - Geographical visualizations of trade networks for selected years.
% - Evolution plots of network properties over time (nodes, links, flow, 
%   and density).
% - Degree and strength distribution plots (in-degree, out-degree, 
%   in-strength, out-strength).
%
% Additional Features:
% - Generates geographical network plots using the Mapping Toolbox.
% - Calculates and visualizes survival distributions for degree and strength.
% - Uses 'turbo' colormap for enhanced visualizations.
% - Plots both global network properties and yearly degree distributions.
%
% ========================================================================
clc; clearvars; close all
%% addpath
addpath('Data')
addpath('RegressionResults')
addpath('Utilities')
%% read regression results
load ZIP_RegressionResults.mat
%% years
Anni=2000:2020;
%% container
NumNodes=zeros(length(Anni),1);
NumLink=zeros(length(Anni),1);
TotFlow=zeros(length(Anni),1);
Density=zeros(length(Anni),1);

InStr_distr=cell(length(Anni),2);
InDeg_distr=cell(length(Anni),2);

OutStr_distr=cell(length(Anni),2);
OutDeg_distr=cell(length(Anni),2);

%% main loop
for t=1:length(Anni)
    adj=MatriciTrade{t};
    NumNodes(t)=size(adj,1);
    NumLink(t)=nnz(adj);
    TotFlow(t)=sum(sum(adj));
    Density(t)=NumLink(t)/(NumNodes(t)*(NumNodes(t)-1));

    [f,x] = ecdf(sum(adj,1),'Function','survivor');
    InStr_distr{t,1}=f;
    InStr_distr{t,2}=x;   
    
    adjBin=adj;
    adjBin(adjBin>0)=1;
    [f,x] = ecdf(sum(adjBin,1),'Function','survivor');
    InDeg_distr{t,1}=f;
    InDeg_distr{t,2}=x;

    [f,x] = ecdf(sum(adj,2),'Function','survivor');
    OutStr_distr{t,1}=f;
    OutStr_distr{t,2}=x;   
    
   
    [f,x] = ecdf(sum(adjBin,2),'Function','survivor');
    OutDeg_distr{t,1}=f;
    OutDeg_distr{t,2}=x;
end
%% plot net
load('DatiGrezzi.mat','LatLonPaesi')


Periodo = [5 10 15 20];
figure
for z = 1:length(Periodo)
    periodo = Periodo(z);
    link1 = MatriciTrade{periodo};

    PaesiDist=LatLonPaesi.Alpha_3Code;
    Lat=LatLonPaesi.Latitude_average_;
    Lon=LatLonPaesi.Longitude_average_;
    [nodes,ia,ib]=intersect(NodiFin{periodo},PaesiDist);
    Latit=Lat(ib);
    Longit=Lon(ib);

    sizeV = sum(link1);
    colV = sum(link1,2);
    rgb = vals2colormap(colV, 'turbo');

    % use the mapping toolbox to plot in geo coordinates into loop
    pesi = reshape(link1,size(link1,1)^2,1); % vectorize
    pesi(pesi==0)=[]; % delete zero weight cell
    soglia = prctile(pesi,99); % plot link with weight higher then the median (see reshape and prctile fucntions)                    
    subplot(2,2,z)
    for x = 1:length(nodes)
        for y = 1:length(nodes)
            l = link1(x,y);
            if l > soglia
                if sum(isnan([Longit(y) Latit(y) Longit(x) Latit(x)]))==0
                    geoplot([Latit(y) Latit(x)],[Longit(y) Longit(x)],'k:','LineWidth',0.05)
                    geoscatter(Latit(y),Longit(y),800*(sizeV(y)/sum(sizeV)),rgb(y,:),'filled')
                    geoscatter(Latit(x),Longit(x),800*(sizeV(x)/sum(sizeV)),rgb(x,:),'filled')
                    text(Latit(y),Longit(y),nodes(y),'FontSize',6);
                    text(Latit(x),Longit(x),nodes(x),'FontSize',6);
                    hold on
                end
            end

        end
    end
    title(['ITN network: ',num2str(Anni(periodo))])
    geobasemap grayland

end
%% figure
figure
tiledlayout(2,1)
nexttile;
yyaxis left
plot(Anni,NumNodes,'-d','Color',[0 0.4470 0.7410],'LineWidth',2)
ylabel('Num. Nodes')
axis tight
grid on
yyaxis right
plot(Anni,NumLink,'-o','Color',[0.8500 0.3250 0.0980],'LineWidth',2)
ylabel('Num. Links')
axis tight
grid on
legend('Num. Nodes','Num. Links',...
   'Location','Northoutside','NumColumns',2)
set(findall(gcf,'-property','FontSize'),'FontSize',12)
ax = gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'k';
nexttile
yyaxis left
plot(Anni,TotFlow,'-d','Color',[0 0.4470 0.7410],'LineWidth',2)
ylabel('Tot. Flow')
axis tight
grid on
yyaxis right
plot(Anni,Density,'-o','Color',[0.8500 0.3250 0.0980],'LineWidth',2)
ylabel('Density')
axis tight
grid on
legend('Tot. Flow','Density',...
   'Location','Northoutside','NumColumns',2)
set(findall(gcf,'-property','FontSize'),'FontSize',12)
ax = gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'k';

calormap=turbo(length(InDeg_distr));
figure
subplot(2,2,1)
for u=1:length(InDeg_distr)
    loglog(InDeg_distr{u,2},InDeg_distr{u,1},'color',calormap(u,:),'linewidth',.5)
    hold on
end
grid on
axis square
title('In-Degree survival distribution')
set(gca,'fontsize',12,'fontweight','bold')

subplot(2,2,2)
for u=1:length(OutDeg_distr)
    loglog(OutDeg_distr{u,2},OutDeg_distr{u,1},'color',calormap(u,:),'linewidth',.5)
    hold on
end
grid on
axis square
title('Out-Degree survival distribution')
set(gca,'fontsize',12,'fontweight','bold')

subplot(2,2,3)
for u=1:length(InStr_distr)
    loglog(InStr_distr{u,2},InStr_distr{u,1},'color',calormap(u,:),'linewidth',.5)
    hold on
end
grid on
axis square
title('In-Strength survival distribution')
set(gca,'fontsize',12,'fontweight','bold')
subplot(2,2,4)
for u=1:length(OutStr_distr)
    loglog(OutStr_distr{u,2},OutStr_distr{u,1},'color',calormap(u,:),'linewidth',.5)
    hold on
end
grid on
axis square
title('Out-Strength survival distribution')

set(gca,'fontsize',12,'fontweight','bold')
lgn = legend(string(num2str(Anni'))...
,'NumColumns',2,'location','southoutside');
title(lgn,'Years')
set(gca,'fontsize',12,'fontweight','bold')