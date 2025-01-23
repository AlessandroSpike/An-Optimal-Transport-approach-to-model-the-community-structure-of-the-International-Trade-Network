% ========================================================================
% Gravity Model Data Processing
% ========================================================================
% This script processes trade-related data to prepare covariates for 
% a gravity model estimation. The gravity model is used to analyze 
% bilateral trade flows based on economic and geographical factors.
%
% The script performs the following tasks:
% - Loads preprocessed data from 'DatiProcessati.mat'.
% - Sets the gravity model type (OLS, Poisson, or ZIP).
% - Extracts and cleans relevant variables (GDP, population, area, 
%   landlocked status, currency, colonial ties, common language, 
%   contiguity, distance, and trade barriers).
% - Filters out countries with missing or zero information.
% - Reshapes variables for regression analysis.
% - Constructs the regression matrix (X) and dependent variable (Y).
% - Saves the final dataset as '[GravType]_SCENARIO_Covariates.mat'.
%
% ------------------------------------------------------------------------
% Usage:
% - Ensure the 'DatiProcessati.mat' file is available in the 'Data' folder.
% - Set the 'GravType' variable to one of the available models: 'OLS', 
%   'POISSON', or 'ZIP'.
% - Run the script in MATLAB.
% ------------------------------------------------------------------------
%
% Outputs:
% - A cell array 'CovariateScenarioA' containing:
%   1. X: Matrix of independent variables (log-transformed where needed).
%   2. Y: Dependent variable (trade flow).
% - Saves the output as a .mat file with the gravity type prefix.
%
% Additional Features:
% - Handles missing values using forward fill.
% - Ensures variables are properly formatted for regression.
% - Filters out countries with no trade activity.
%
% ========================================================================

clc; clearvars; close all; 
%% addpath
addpath("Data")
%% read data
load DatiProcessati.mat
%% gravity type
GravType='ZIP'; %OLS POISSON ZIP
%% Contenitori
CovariateScenarioA=cell(1,2);
%% main loop

for t=length(Anni)
    t
    %estreaggo
    Adj=MatriceEx(:,:,t-1);
    Barrier=MatriceTardeAgg(:,:,t-1);
    gdp=GDP(:,t-1:t);
    gdp=fillmissing(gdp',"previous");
    gdp=gdp';
    gdp=gdp(:,end);
    pop=Popolazione(:,t-1:t);
    pop=fillmissing(pop',"previous");
    pop=pop';
    pop=pop(:,end);
    area=Area;
    landolock=LandLock;
    matricecolonial=MatriceColonial;
    matricecommonlanguage=MatriceCommonLanguage;
    matricecontiguity=MatriceContiguity;
    distanza=MatriceDistanza;
    valuta=MatriceValuta;
    Nodi=PaesiBaci;
   
    % tolgo paesi senza info
    tolgo1=intersect(find(sum(Adj,1)==0),find(sum(Adj,2)==0));
    tolgo2=find(isnan(gdp));
    tolgo=union(tolgo1,tolgo2);
    Adj(tolgo,:)=[];
    Adj(:,tolgo)=[];
    Barrier(tolgo,:)=[];
    Barrier(:,tolgo)=[];
    gdp(tolgo)=[];
    pop(tolgo)=[];
    area(tolgo)=[];
    Nodi(tolgo)=[];
    landolock(tolgo)=[];
    valuta(tolgo,:)=[];
    valuta(:,tolgo)=[];
    matricecolonial(tolgo,:)=[];
    matricecolonial(:,tolgo)=[];
    matricecommonlanguage(tolgo,:)=[];
    matricecommonlanguage(:,tolgo)=[];
    matricecontiguity(tolgo,:)=[];
    matricecontiguity(:,tolgo)=[];
    distanza(tolgo,:)=[];
    distanza(:,tolgo)=[];
    % reshape variable by colunmns
    Ex=Adj(:);
    Bar=Barrier(:);
    ComVal=valuta(:);
    Colony=matricecolonial(:);
    CommLang=matricecommonlanguage(:);
    Contig=matricecontiguity(:);
    Dist=distanza(:);
    Gdp_o=repmat(gdp,size(gdp,1),1);
    Gdp_d=repelem(gdp,size(gdp,1));
    Area_o=repmat(area,size(gdp,1),1);
    Area_d=repelem(area,size(gdp,1));
    Pop_o=repmat(pop,size(gdp,1),1);
    Pop_d=repelem(pop,size(gdp,1));
    Land_o=repmat(landolock,size(gdp,1),1);
    Land_d=repelem(landolock,size(gdp,1));
    % set regression variables
    Y=Ex;
    X=[log(Gdp_o),log(Gdp_d),log(Dist),log(Area_o),log(Area_d)...
        ,log(Pop_o),log(Pop_d),...
        (Land_o),(Land_d),(Bar),(Contig),...
        (ComVal),(Colony),(CommLang)];
   
   CovariateScenarioA{1}=X;
   CovariateScenarioA{2}=Y;
end
%% save
filename=([GravType,'_SCENARIO_Covariates.mat']);
save(filename,'CovariateScenarioA')