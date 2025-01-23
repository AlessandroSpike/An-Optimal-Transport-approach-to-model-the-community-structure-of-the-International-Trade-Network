function [Y, X, Adj,PaeExp,PaeImp,Nodi,distanza] = filter_and_prepare_data(MatriceEx, MatriceTardeAgg, GDP, Popolazione, Area, LandLock, MatriceColonial, MatriceCommonLanguage, MatriceContiguity, MatriceDistanza, MatriceValuta, PaesiBaci, t)
    % Extract matrices for the given time step
    Adj = MatriceEx(:,:,t);
    Barrier = MatriceTardeAgg(:,:,t);
    gdp = GDP(:,t);
    pop = Popolazione(:,t);
    area = Area;
    landolock = LandLock;
    matricecolonial = MatriceColonial;
    matricecommonlanguage = MatriceCommonLanguage;
    matricecontiguity = MatriceContiguity;
    distanza = MatriceDistanza;
    valuta = MatriceValuta;
    Nodi = PaesiBaci;

    % Remove countries with missing information
    tolgo1 = intersect(find(sum(Adj,1) == 0), find(sum(Adj,2) == 0));
    tolgo2 = find(isnan(gdp));
    tolgo = union(tolgo1, tolgo2);
    
    Adj(tolgo,:) = [];
    Adj(:,tolgo) = [];
    Barrier(tolgo,:) = [];
    Barrier(:,tolgo) = [];
    gdp(tolgo) = [];
    pop(tolgo) = [];
    area(tolgo) = [];
    Nodi(tolgo) = [];
    landolock(tolgo) = [];
    valuta(tolgo,:) = [];
    valuta(:,tolgo) = [];
    matricecolonial(tolgo,:) = [];
    matricecolonial(:,tolgo) = [];
    matricecommonlanguage(tolgo,:) = [];
    matricecommonlanguage(:,tolgo) = [];
    matricecontiguity(tolgo,:) = [];
    matricecontiguity(:,tolgo) = [];
    distanza(tolgo,:) = [];
    distanza(:,tolgo) = [];
    
    % Reshape variables into column vectors
    Ex = Adj(:);
    Bar = Barrier(:);
    ComVal = valuta(:);
    Colony = matricecolonial(:);
    CommLang = matricecommonlanguage(:);
    Contig = matricecontiguity(:);
    Dist = distanza(:);

    Gdp_o = repmat(gdp, size(gdp,1), 1);
    Gdp_d = repelem(gdp, size(gdp,1));
    Area_o = repmat(area, size(gdp,1), 1);
    Area_d = repelem(area, size(gdp,1));
    Pop_o = repmat(pop, size(gdp,1), 1);
    Pop_d = repelem(pop, size(gdp,1));
    Land_o = repmat(landolock, size(gdp,1), 1);
    Land_d = repelem(landolock, size(gdp,1));

    % Define output variables
    Y = Ex;
    X = [log(Gdp_o), log(Gdp_d), log(Dist), log(Area_o), log(Area_d), ...
         log(Pop_o), log(Pop_d), Land_o, Land_d, Bar, Contig, ...
         ComVal, Colony, CommLang];

    PaeExp=repmat(Nodi,size(gdp,1),1);
    PaeImp=repelem(Nodi,size(gdp,1),1);
   
end
