%Historical snowfall race among US cities >100,000
%Data included begins 1912-13, but will only publish statistics for 1950-51
%onward, as Syracuse Hancock came online then

%Current runtime:
%5 sec to read in data

numcities=73;
latestyear=2015;

%Runtime options
readinanddefinedata=0;
showspreadhists=0;
docorrelmatrix=0;
dokmeansclusteringforenso=0;
    redoclusteringofcities=0;
    redoclusteringofyears=0;
doheavysnowfallclusteringenso=0;
calceofs=1;

xfull=1913:latestyear;
x1951=1951:latestyear;
numyears=latestyear+2-1913;smallnumyears=latestyear-1951+1;offset=38;
%misleadingly, there are actually numyears-1 of actual data

%Read in and define data
if readinanddefinedata==1
    data=csvread('rwHistoricalSnowfallforMatlab.csv');

    worcester=data(2:numyears,1);
    boston=data(2:numyears,2);
    syracuse=data(2:numyears,3);
    rochesterny=data(2:numyears,4);
    buffalo=data(2:numyears,5);
    cleveland=data(2:numyears,6);
    newyork=data(2:numyears,7);
    philadelphia=data(2:numyears,8);
    washington=data(2:numyears,9);
    chicago=data(2:numyears,10);
    minneapolis=data(2:numyears,11);
    detroit=data(2:numyears,12);
    columbus=data(2:numyears,13);
    denver=data(2:numyears,14);
    milwaukee=data(2:numyears,15);
    coloradosprings=data(2:numyears,16);
    omaha=data(2:numyears,17);
    stlouis=data(2:numyears,18);
    pittsburgh=data(2:numyears,19);
    anchorage=data(2:numyears,20);
    toledo=data(2:numyears,21);
    lincoln=data(2:numyears,22);
    fortwayne=data(2:numyears,23);
    madison=data(2:numyears,24);
    boise=data(2:numyears,25);
    spokane=data(2:numyears,26);
    desmoines=data(2:numyears,27);
    aurora=data(2:numyears,28);
    akron=data(2:numyears,29);
    grandrapids=data(2:numyears,30);
    saltlakecity=data(2:numyears,31);
    providence=data(2:numyears,32);
    siouxfalls=data(2:numyears,33);
    springfieldma=data(2:numyears,34);
    fortcollins=data(2:numyears,35);
    rockford=data(2:numyears,36);
    kansascity=data(2:numyears,37);
    joliet=data(2:numyears,38);
    bridgeport=data(2:numyears,39);
    dayton=data(2:numyears,40);
    cedarrapids=data(2:numyears,41);
    topeka=data(2:numyears,42);
    seattle=data(2:numyears,43);
    allentown=data(2:numyears,44);
    annarbor=data(2:numyears,45);
    springfieldil=data(2:numyears,46);
    peoria=data(2:numyears,47);
    provo=data(2:numyears,48);
    columbia=data(2:numyears,49);
    lansing=data(2:numyears,50);
    fargo=data(2:numyears,51);
    rochestermn=data(2:numyears,52);
    manchester=data(2:numyears,53);
    waterbury=data(2:numyears,54);
    billings=data(2:numyears,55);
    lowell=data(2:numyears,56);
    pueblo=data(2:numyears,57);
    greenbay=data(2:numyears,58);
    boulder=data(2:numyears,59);
    davenport=data(2:numyears,60);
    edison=data(2:numyears,61);
    southbend=data(2:numyears,62);
    erie=data(2:numyears,63);
    cincinnati=data(2:numyears,64);
    indianapolis=data(2:numyears,65);
    baltimore=data(2:numyears,66);
    albuquerque=data(2:numyears,67);
    amarillo=data(2:numyears,68);
    evansville=data(2:numyears,69);
    lexington=data(2:numyears,70);
    louisville=data(2:numyears,71);
    reno=data(2:numyears,72);
    wichita=data(2:numyears,73);
    
    allcities=data(40:numyears,1:numcities); %data since 1951 only

    %Sort data for each year along with #'s corresponding to each city name
    alltop10=zeros(10,numyears*2-2);
    fullrank=zeros(numcities,smallnumyears);
    for year=1:numyears
        yeartop10=zeros(10,2);
        yearfullrank=zeros(numcities,2);
        for city=1:numcities
            if data(year+1,city)>yeartop10(10,1)
                yeartop10(10,1)=data(year+1,city);
                yeartop10(10,2)=city;
                yeartop10=flipud(sortrows(yeartop10));
            end
            yearfullrank(city,1)=data(year+1,city);
            yearfullrank(city,2)=city;
        end
        yearfullrank=flipud(sortrows(yearfullrank));
        alltop10(:,2*year-1:2*year)=yeartop10(:,:);
        fullrank(:,2*year-1:2*year)=yearfullrank(:,:);
    end

    %Dictionary vector that connects numbers to city names (as above but in a
    %form MATLAB understands)
    reference={'Worcester','Boston','Syracuse','Rochester NY','Buffalo','Cleveland','New York','Philadelphia', ...
        'Washington','Chicago','Minneapolis','Detroit','Columbus','Denver','Milwaukee','Colorado Springs', ...
        'Omaha','St. Louis','Pittsburgh','Anchorage','Toledo','Lincoln','Fort Wayne','Madison','Boise','Spokane', ...
        'Des Moines','Aurora','Akron','Grand Rapids','Salt Lake City','Providence','Sioux Falls', ...
        'Springfield MA','Fort Collins','Rockford','Kansas City','Joliet','Bridgeport','Dayton','Cedar Rapids', ...
        'Topeka','Seattle','Allentown','Ann Arbor','Springfield IL','Peoria','Provo','Columbia MO','Lansing', ...
        'Fargo','Rochester MN','Manchester','Waterbury CT','Billings','Lowell','Pueblo CO','Green Bay', ...
        'Boulder','Davenport IA','Edison NJ','South Bend','Erie','Cincinnati','Indianapolis','Baltimore',...
        'Albuquerque','Amarillo','Evansville','Lexington','Louisville','Reno','Wichita'};
    %Relatedly, city lat/lon coordinates in same order
    refwithlatlon=csvread('/Users/colin/Documents/General_Academics/Website/Recent_Weather/rwhistsnowfallcitylatlon.csv');

    %Change city #'s to names
    count=1;
    for i=77:2:numyears*2-2 %set to 77 if wishing to start in 1951
        for j=1:10
            x=alltop10(j,i);name=alltop10(j,i+1);
            top10citynames(j,count)=reference(name);
        end
        count=count+1;
    end
    top10citynames=top10citynames(:,1:65)';
    count=1;fullrankcitynames=zeros(numcities,65);
    for i=77:2:numyears*2-2 %set to 77 if wishing to start in 1951
        for j=1:numcities
            x=fullrank(j,i);name=fullrank(j,i+1);
            fullrankcitynames2(j,count)=reference(name);
        end
        count=count+1;
    end
    fullrankcitynames=fullrankcitynames2(:,1:65)';

    %Write names into purpose-built CSV file
    cell2csv('/Users/colin/Documents/General_Academics/Website/Recent_Weather/rwhistsnowfallfullnames.csv',...
        fullrankcitynames);
end

%Histograms of spreads between #1 and #3,5,7,8, and 10

if showspreadhists==1
    spread12=data(1:numcities,numcities+1);centers12=[2.5 7.5 12.5 17.5 22.5 27.5 32.5 37.5 42.5 47.5 52.5 57.5 62.5];
    spread13=data(1:numcities,numcities+2);centers13=[centers12 67.5 72.5];
    spread15=data(1:numcities,numcities+3);centers15=[10 20 30 40 50 60 70 80 90 100 110];
    spread17=data(1:numcities,numcities+4);centers17=[centers15 120 130];
    spread18=data(1:numcities,numcities+5);centers18=centers17;
    spread110=data(1:numcities,numcities+6);centers110=[centers18 140];
    figure(1);clf;hist(spread12,centers12);title('Spread b/w 1st & 2nd Place');
    figure(2);clf;hist(spread13,centers13);title('Spread b/w 1st & 3rd Place');
    figure(3);clf;hist(spread15,centers15);title('Spread b/w 1st & 5th Place');
    figure(4);clf;hist(spread17,centers17);title('Spread b/w 1st & 7th Place');
    figure(5);clf;hist(spread18,centers18);title('Spread b/w 1st & 8th Place');
    figure(6);clf;hist(spread110,centers110);title('Spread b/w 1st & 10th Place');
end

%Climatological correlation matrices of seasonal snowfall between stations
%Here, stations are ordered primarily according to a k-means clustering and 
%secondarily according to distance from Manchester, NH
%(rather than the arbitrary ordering in the previous section)
%Order is listed on left side of rwHSRwithText.xls, a74:a139

if docorrelmatrix==1   
    changematrix=data(numyears+1:numyears+(latestyear+2-1951),3);
    for col=1:numcities
        shuffleddata(1:numyears-1,col)=data(2:numyears,changematrix(col));
    end
    
    %actualdata=data(numyears+2:1+2*numyears,1:numcities);
    actualdata=shuffleddata(1:numyears-1,1:numcities);
    for i=1:numyears-1
        for j=1:numcities
            if actualdata(i,j)==0
                actualdata(i,j)=NaN;
            end
        end
    end
    R=corrcoef(actualdata,'rows','pairwise');
    figure(7);clf;
    imagesc(R);
    colormap('jet');colorbar;
    pos=get(gca,'Position');
    set(gca,'Position',[pos(1),.2,pos(3) .65]);
    Xt=1:numcities;
    Xl=[1 numcities];
    set(gca,'XTick',Xt,'XLim',Xl);
    cities=['   Manchester NH';'          Lowell';'          Boston';'       Worcester';
        '      Providence';'  Springfield MA';'       Waterbury';'      Bridgeport';
        '        New York';'       Edison NJ';'       Allentown';'        Syracuse';
        '    Philadelphia';'       Rochester';'       Baltimore';'   Washington DC';
        '         Buffalo';'            Erie';'      Pittsburgh';'           Akron';
        '       Cleveland';'        Columbus';'         Detroit';'       Ann Arbor';
        '          Toledo';'          Dayton';'         Lansing';'      Fort Wayne';
        '    Grand Rapids';'      South Bend';'      Cincinnati';'    Indianapolis';
        '         Chicago';'       Milwaukee';'          Joliet';'       Green Bay';
        '          Aurora';'        Rockford';'         Madison';'          Peoria';
        '  Springfield IL';'    Davenport IA';'       St. Louis';'    Cedar Rapids';
        '    Rochester MN';'     Columbia MO';'     Minneapolis';'      Des Moines';
        '     Kansas City';'          Topeka';'           Omaha';'     Sioux Falls';
        '         Lincoln';'           Fargo';'          Denver';'       Pueblo CO';
        'Colorado Springs';'    Fort Collins';'         Boulder';'        Billings';
        '           Provo';'  Salt Lake City';'           Boise';'         Spokane';
        '         Seattle';'       Anchorage'];
    ax=axis;
    axis(axis);
    Yl=ax(3:4);
    %t=text(Xt,Yl(1)*ones(1,length(Xt)),cities(1:numcities,:));
    t=text(Xt,(numcities+3)*ones(1,length(Xt)),cities(1:numcities,:));
    set(t,'HorizontalAlignment','right','VerticalAlignment','top', ...
        'Rotation',45,'FontSize',9);
    t=text(-1*ones(1,length(Xt)),Xt,cities(1:numcities,:));
    set(t,'HorizontalAlignment','right','VerticalAlignment','top', ...
        'Rotation',45,'FontSize',7);
end

if dokmeansclusteringforenso==1
    fullnames=...
        csvimport('/Users/colin/Documents/General_Academics/Website/Recent_Weather/rwhistsnowfallfullnamesFINAL.csv');
    %Laboriously go through and convert city names to numbers using
    %dictionary defined above
    fullnumbers=zeros(smallnumyears,numcities);
    for row=1:smallnumyears
        for col=1:numcities
            for i=1:size(reference,2)
                if strcmp(fullnames(row,col),reference(i))
                    fullnumbers(row,col)=i;
                end
            end
        end
    end
    
    %Now that I have a numeric matrix, do k-means clustering to see which
    %cities tend to vary together
    numclusts=6;
    if redoclusteringofcities==1
        fullnumbers=fullnumbers';
        idx=kmeans(fullnumbers,numclusts);
        silhouette(fullnumbers,idx);
        fullnumbers=fullnumbers';
    elseif redoclusteringofyears==1
        idx=kmeans(fullnumbers,numclusts);
        silhouette(fullnumbers,idx);
    end
    
    for i=1:size(idx,1)
        if i<=numcities
            clusters1aa(i)=reference(i); %only meaningful if clustering cities
        end
        if i<=smallnumyears
            clusters1bb(i)=x1951(i);     %only meaningful if clustering years
        end
        clusters2(i)=idx(i);
    end
    
    desclust=6; %cluster whose members to examine
    for i=1:size(idx,1)
        if clusters2(i)==desclust
            disp(clusters1aa(i));
        end
    end
    
    %Map of clusters as different colors/shapes
    fg=figure(figc);figc=figc+1;
    latlim=[23 50];lonlim=[-128 -63];
    fgtitle=sprintf('Clusters of US Cities >100,000 by Annual-Snowfall Variability');
    set(fg,'Color',[1 1 1]);title(fgtitle,'FontSize',16,'FontWeight','bold');
    axesm('mercator','MapLatLimit',latlim,'MapLonLimit',lonlim);axis off;
    framem off;gridm off; mlabel off; plabel off;
    load coast;
    states=shaperead('usastatelo', 'UseGeoCoords', true, 'Selector', ...
             {@(name) ~any(strcmp(name,{'Alaska','Hawaii'})), 'Name'});
    geoshow(states, 'DisplayType', 'polygon', 'DefaultFaceColor', 'none');
    tightmap;
    
    markerlist={'v';'o';'s';'x';'*';'^'};
    colorlist={colors('red');colors('orange');colors('green');colors('blue');colors('light purple');colors('gray')};
    for city=1:numcities
        clustmembership=idx(city);
        mark=markerlist{clustmembership};color=colorlist{clustmembership};
        pt1lat=refwithlatlon(city,1);pt1lon=refwithlatlon(city,2);
        h=geoshow(pt1lat,pt1lon,'DisplayType','Point','Marker',mark,...
            'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',11);
    end
    
    
    %For each year, median rank of members of each cluster
    for i=1:smallnumyears
        for clust=1:numclusts
            count=0;
            for j=1:numcities
                if fullnumbers(i,j)>0
                    if idx(fullnumbers(i,j))==clust
                        count=count+1;
                        ranksforthisclust(i,clust,count)=j;
                    end
                end
            end
        end
    end
    
    %Look at results
    squeeze(ranksforthisclust(:,1,:));
    
    %Calculate median & st dev of ranks for each year and each cluster
    for clust=1:numclusts
        matrixhere=squeeze(ranksforthisclust(:,clust,:));
        matrixhere(:,~any(matrixhere,1))=[]; %removes zero columns
        rankbycluster{clust}=median(matrixhere,2);
        medianrankbycluster{clust}=median(rankbycluster{clust});
        stdevrankbycluster{clust}=std(rankbycluster{clust});
        anomalousrankbycluster{clust}=rankbycluster{clust}-medianrankbycluster{clust};
    end
    
    %Plot anomalous ranks of different clusters over 1951-2015
    figure(figc);clf;figc=figc+1;
    plot(x1951,anomalousrankbycluster{1},'Color',colors('red'));hold on;
    plot(x1951,anomalousrankbycluster{2},'Color',colors('orange'));
    plot(x1951,anomalousrankbycluster{3},'Color',colors('green'));
    plot(x1951,anomalousrankbycluster{4},'Color',colors('sky blue'));
    plot(x1951,anomalousrankbycluster{5},'Color',colors('dark blue'));
    plot(x1951,anomalousrankbycluster{6},'Color',colors('light purple'));
    xlim([1951 latestyear]);
    legend('Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Cluster 6');
    
    %Correlation between clusters' anomalous ranks and ENSO [Nino 3.4]
    enso=load('indicesmonthlyenso.txt','r'); %monthly values from 01/1950 to 07/2015
    enso=enso(:,10); %using Nino 3.4
    nummon=size(enso,1);
    %1. Create timeseries of self-normalized JAS and SON readings
    jasc=1;sonc=1;
    for i=1:nummon-7 %through 12/14
        if rem(i,12)==7
            ENSOjas(jasc:jasc+2)=enso(i:i+2);
            ENSOjasavg(ceil(i/12))=mean(enso(i:i+2));
            jasc=jasc+3;
        end
        if rem(i,12)==9
            ENSOson(sonc:sonc+2)=enso(i:i+2);
            ENSOsonavg(ceil(i/12))=mean(enso(i:i+2));
            sonc=sonc+3;
        end
    end
    ENSOjas=ENSOjas-mean(ENSOjas);ENSOson=ENSOson-mean(ENSOson);
    ENSOjasavg=ENSOjasavg-mean(ENSOjasavg);ENSOsonavg=ENSOsonavg-mean(ENSOsonavg);
    ENSOjasavg=ENSOjasavg';ENSOsonavg=ENSOsonavg';
    
    %Do the correlation
    for clust=1:numclusts
        ensojascor{clust}=corr(anomalousrankbycluster{clust},ENSOjasavg);
        ensosoncor{clust}=corr(anomalousrankbycluster{clust},ENSOsonavg);
    end
    %With 65 observations, abs. value of corr. coeff. must be >0.24 to be
    %significantly different from 0 at 95% confidence
end

if doheavysnowfallclusteringenso==1
    %How does the number of snowstorms (days with 6" or more) compare with
    %ENSO for the 73 cities in the snow race?
    data=csvread('NumDays6InorMoreSnowfallbyCity.csv');
    data=data(1:65,:); %only 65 years of valid data, 1951-2015
    
    %Correlate with ENSOjas and ENSOson (preceding the given winter)
    stormcor=0;
    for city=1:numcities
        stormcorjas(city)=corr(data(:,city+1),ENSOjasavg);
        stormcorson(city)=corr(data(:,city+1),ENSOsonavg);
    end
    
    %Make map with symbols, as above, but this time coded according to
    %whether correlation coefficient is pos & sig, pos but not sig, near
    %zero, neg but not sig, or neg & sig -- at 90% confidence, >0.20
    %so I will choose near zero as -0.10<x<0.10
    for city=1:numcities
        if stormcorjas(city)<=-0.20
            corcateg(city)=1;
        elseif stormcorjas(city)<=-0.10
            corcateg(city)=2;
        elseif stormcorjas(city)<0.10
            corcateg(city)=3;
        elseif stormcorjas(city)<0.20
            corcateg(city)=4;
        else
            corcateg(city)=5; 
        end
    end
    corcateg=corcateg';
    
    fg=figure(figc);figc=figc+1;
    latlim=[23 50];lonlim=[-128 -63];
    fgtitle=sprintf('Correlation of Annual Number of Snowstorms >=6" with ENSO');
    set(fg,'Color',[1 1 1]);title(fgtitle,'FontSize',16,'FontWeight','bold','FontName','Arial');
    axesm('mercator','MapLatLimit',latlim,'MapLonLimit',lonlim);axis off;
    framem off;gridm off; mlabel off; plabel off;
    load coast;
    states=shaperead('usastatelo', 'UseGeoCoords', true, 'Selector', ...
             {@(name) ~any(strcmp(name,{'Alaska','Hawaii'})), 'Name'});
    geoshow(states, 'DisplayType', 'polygon', 'DefaultFaceColor', 'none');
    tightmap;
    
    %First, a decoy to set up the legend
    markerlist={'v';'o';'s';'x';'*'};
    colorlist={colors('red');colors('orange');colors('green');colors('blue');colors('light purple')};
    decoycities=[58;60;55;56;64];
    for count=1:5
        city=decoycities(count);
        mark=markerlist{corcateg(city)};color=colorlist{corcateg(city)};
        pt1lat=refwithlatlon(city,1);pt1lon=refwithlatlon(city,2);
        h=geoshow(pt1lat,pt1lon,'DisplayType','Point','Marker',mark,...
            'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',11);
    end
    legend('Neg., Signif.','Neg., Not Signif.','Near Zero','Pos., Not Signif.','Pos., Signif.');
    %All the cities
    for city=1:numcities
        mark=markerlist{corcateg(city)};color=colorlist{corcateg(city)};
        pt1lat=refwithlatlon(city,1);pt1lon=refwithlatlon(city,2);
        h=geoshow(pt1lat,pt1lon,'DisplayType','Point','Marker',mark,...
            'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',11);
    end 
end

%Calculate and plot spatial patterns of total seasonal snowfall
if calceofs==1
    %First, exclude cities with any missing data
    numgoodcols=1;
    for i=1:numcities
        if min(allcities(:,i))>0
            allcitiescl(:,numgoodcols)=allcities(:,i);
            goodcollist(numgoodcols)=i;
            numgoodcols=numgoodcols+1;
        end
    end
    numgoodcols=numgoodcols-1;
    
    %Now, detrend & compute EOFs using code adopted from FullClimateDataScript
    allcitiescldetr=detrend(allcitiescl);
    %Multiply columns by a factor to take covariance between cities into
    %account, i.e. reduce their variance so that they don't dominate the
    %final varimax-rotated EOFs
    citycorrelmatrix=zeros(numgoodcols);
    for i=1:numgoodcols
        for j=1:numgoodcols
            citycorrelmatrix(i,j)=corr(allcitiescldetr(:,i),allcitiescldetr(:,j));
        end
    end
    %Reduce any correlation coefficients  >=0.5 by multiplying both cities'
    %values by a proportional factor to reduce their variance
    allcitiescldetradj=allcitiescldetr;
    for i=1:numgoodcols
        for j=1:numgoodcols
            if citycorrelmatrix(i,j)>=0.5 && i>j %b/c symmetric, only check half of the matrix
                multfactor=1-citycorrelmatrix(i,j)/2;
                disp(i);disp(j);disp(multfactor);
                allcitiescldetradj(:,i)=multfactor*allcitiescldetradj(:,i);
                allcitiescldetradj(:,j)=multfactor*allcitiescldetradj(:,j);
            end
        end
    end
    %Further normalize by dividing each city's values by its st dev
    for i=1:numgoodcols
        thiscitystdev=std(allcitiescldetradj(:,i));
        allcitiescldetradj(:,i)=allcitiescldetradj(:,i)./thiscitystdev;
    end
    
    %Apply EOF analysis
    [eigenvalues,eofcalc,eccalc,error,norms]=EOF(achmdetr); %eigenvalues;EOFs;expansion coeffs;error;norms (if normalizing)
    %Rotate EOFs using varimax formula
    [new_loadings,rotatmatrix]=varimax(eccalc);
    new_eofs=eofcalc*rotatmatrix; %columns of new_eofs are the true eofs we're looking for
    
    %Plot normalized eigenvalues
    eigenvaluesnorm=eigenvalues/sum(eigenvalues);
    figure(figc);clf;figc=figc+1;
    plot(eigenvaluesnorm);title('Eigenvalues'); %looks like 6 EOFs is a reasonable cutoff for physically-based analysis
                            %however they do only explain 38% of the variance
                            
    %Plot EOFs
    figure(figc);clf;figc=figc+1;
    imagescnan(new_eofs);colorbar;title('Rotated EOFs');
end

