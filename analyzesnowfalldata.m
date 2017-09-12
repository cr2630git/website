%Analyzes US cities' snowfall data
computetrendsofvalues=1;
computetrendsofstdevs=0;
computelargeststorms=0;
makemapoftrends=1;

numcities=73;
numyears=104;

citynames{1}='Akron OH';citynames{2}='Albuquerque NM';citynames{3}='Allentown PA';
citynames{4}='Amarillo TX';citynames{5}='Anchorage AK';citynames{6}='Ann Arbor MI';
citynames{7}='Aurora IL';citynames{8}='Baltimore MD';citynames{9}='Billings MT';
citynames{10}='Boise ID';citynames{11}='Boston MA';citynames{12}='Boulder CO';
citynames{13}='Bridgeport CT';citynames{14}='Buffalo NY';citynames{15}='Cedar Rapids IA';
citynames{16}='Chicago IL';citynames{17}='Cincinnati OH';citynames{18}='Cleveland OH';
citynames{19}='Colorado Springs CO';citynames{20}='Columbia MO';citynames{21}='Columbus OH';
citynames{22}='Davenport IA';citynames{23}='Dayton OH';citynames{24}='Denver CO';
citynames{25}='Des Moines IA';citynames{26}='Detroit MI';citynames{27}='Edison NJ';
citynames{28}='Erie PA';citynames{29}='Evansville IN';citynames{30}='Fargo ND';
citynames{31}='Fort Collins CO';citynames{32}='Fort Wayne IN';citynames{33}='Grand Rapids MI';
citynames{34}='Green Bay WI';citynames{35}='Indianapolis IN';citynames{36}='Joliet IL';
citynames{37}='Kansas City MO';citynames{38}='Lansing MI';citynames{39}='Lexington KY';
citynames{40}='Lincoln NE';citynames{41}='Louisville KY';citynames{42}='Lowell MA';
citynames{43}='Madison WI';citynames{44}='Manchester NH';citynames{45}='Milwaukee WI';
citynames{46}='Minneapolis MN';citynames{47}='New York NY';citynames{48}='Omaha NE';
citynames{49}='Peoria IL';citynames{50}='Philadelphia PA';citynames{51}='Pittsburgh PA';
citynames{52}='Providence RI';citynames{53}='Provo UT';citynames{54}='Pueblo CO';
citynames{55}='Reno NV';citynames{56}='Rochester MN';citynames{57}='Rochester NY';
citynames{58}='Rockford IL';citynames{59}='Salt Lake City UT';citynames{60}='Seattle WA';
citynames{61}='Sioux Falls SD';citynames{62}='South Bend IN';citynames{63}='Spokane WA';
citynames{64}='Springfield IL';citynames{65}='Springfield MA';citynames{66}='St Louis MO';
citynames{67}='Syracuse NY';citynames{68}='Toledo OH';citynames{69}='Topeka KS';
citynames{70}='Washington DC';citynames{71}='Waterbury CT';citynames{72}='Wichita KS';
citynames{73}='Worcester MA';

citylats=[41.04;35.04;40.65;35.23;61.17;42.29;41.78;39.17;45.81;43.57;42.36;39.99;41.16;42.94;41.88;42.00;39.04;...
    41.41;38.80;38.94;39.99;41.47;39.91;39.83;41.53;42.23;40.47;42.08;38.04;46.93;40.61;40.97;42.88;44.48;39.73;...
    41.60;39.12;42.78;38.04;40.85;38.18;42.64;43.14;42.93;43.11;44.88;40.78;41.31;40.67;39.87;40.48;41.72;40.25;...
    38.29;39.48;43.90;43.12;42.19;40.78;47.44;43.59;41.71;47.62;41.94;39.84;38.75;43.11;41.59;39.07;38.85;41.51;...
    37.65;42.27];
citylons=[-81.46;-106.62;-75.45;-101.70;-150.03;-83.71;-88.31;-76.68;-108.54;-116.24;-71.01;-105.27;-73.13;-78.74;...
    -91.72;-87.93;-84.67;-81.85;-104.70;-92.32;-82.88;-90.52;-84.22;-104.66;-93.65;-83.33;-74.44;-80.18;-87.52;...
    -96.81;-105.13;-85.21;-85.52;-88.14;-86.28;-88.09;-94.60;-84.58;-84.61;-96.75;-85.74;-71.36;-89.35;-71.44;...
    -88.03;-93.23;-73.97;-95.90;-89.68;-75.23;-80.21;-71.43;-111.65;-104.50;-119.77;-92.49;-77.68;-89.09;-111.97;...
    -122.31;-96.73;-86.32;-117.53;-72.68;-89.68;-90.37;-76.10;-83.80;-95.63;-77.03;-72.94;-97.43;-71.87];

%Compute trends and their significance for all cities iff they have >=50 years of data e.g. 1967-2016
if computetrendsofvalues==1
    data=csvread('rwHistoricalSnowfallforMatlab.csv'); %rows are years, columns 1-73 are cities
    validfirstyears=[86;20;90;30;19;16;103;29;24;29;25;88;93;28;73;17;4;1;86;86;1;1;23;10;29;23;1;2;36;...
        31;72;1;1;1;32;81;64;48;1;86;34;101;1;101;30;90;1;1;1;1;37;87;69;34;93;29;15;88;17;96;32;103;85;...
        1;92;1;39;93;36;1;101;43;92];
    pvalue=0;lowerconfslope=0;upperconfslope=0;
    for city=1:numcities
        if numyears-validfirstyears(city)+1>=50 %enough non-missing data
            r=corr((validfirstyears(city)+1:numyears+1)',data(validfirstyears(city)+1:numyears+1,city));
            sx=std((validfirstyears(city)+1:numyears+1)');
            sy=std(data(validfirstyears(city)+1:numyears+1,city));
            b=r*sy/sx;
            syminusx=sy*sqrt((1-r^2)*(numyears-validfirstyears(city))/(numyears-validfirstyears(city)-1));
            sb=syminusx/(sx*sqrt(numyears-validfirstyears(city)));
            t=b/sb;
            df=(numyears-validfirstyears(city)+1);
            tdist2T=@(t,df) (1-betainc(df/(df+t^2),df/2,0.5)); %2-tailed p-value fct
            pvalue(city)=1-tdist2T(t,df);
            alpha=0.05; %desired significance level
            tcrit=findtcrit(alpha,df); %critical t-value with a 2-sided distribution
            lowerconfslope(city)=b-tcrit*sb;
            upperconfslope(city)=b+tcrit*sb;
        end
    end
    if size(pvalue,2)<numcities;pvalue=[pvalue 0];lowerconfslope=[lowerconfslope 0];upperconfslope=[upperconfslope 0];end
    %Cities with significant increases with 95% confidence: Anchorage, Ann Arbor, Cincinnati, Cleveland, Columbus,
    %Davenport IA, Detroit, Edison, Fargo, Fort Wayne, Grand Rapids, Green Bay, Madison, Peoria, Rochester NY
    %Cities with significant decreases with 95% confidence: Denver
end

%Split these data into 20-year chunks, compute standard deviations for each chunk, and analyze time series
%to see if variability has increased
if computetrendsofstdevs==1
    data=csvread('rwHistoricalSnowfallforMatlab.csv'); %rows are years, columns 1-73 are cities
    validfirstyears=[86;20;90;30;19;16;103;29;24;29;25;88;93;28;73;17;4;1;86;86;1;1;23;10;29;23;1;87;36;...
        31;72;1;1;1;32;81;64;48;1;86;34;101;1;101;30;90;1;1;1;1;37;87;69;34;93;29;15;88;17;96;32;103;85;...
        1;92;1;39;93;36;1;101;43;92];
    pvalueforstdev=0;lowerconfslopeforstdev=0;upperconfslopeforstdev=0;
    for city=1:numcities
        if numyears-validfirstyears(city)+1>=50 %enough non-missing data
            i=0;
            while validfirstyears(city)+20+i<=numyears %at least 20 years of data exist starting this year
                i=i+1;
                stdev20years=std(data(validfirstyears(city)+1+i:validfirstyears(city)+20+i,city));
                %disp(i);disp(city);disp(data(validfirstyears(city)+1+i:validfirstyears(city)+20+i,city));
                stdevs(validfirstyears(city)+20+i,city)=stdev20years;
            end
            %See if there are trends in the stdevs -- i.e. change in variability
            r=corr((validfirstyears(city)+21:numyears+1)',stdevs(validfirstyears(city)+21:numyears+1,city));
            sx=std((validfirstyears(city)+21:numyears+1)');
            sy=std(stdevs(validfirstyears(city)+21:numyears+1,city));
            b=r*sy/sx;
            syminusx=sy*sqrt((1-r^2)*(numyears-validfirstyears(city)+20)/(numyears-validfirstyears(city)-1)+19);
            sb=syminusx/(sx*sqrt(numyears-validfirstyears(city)+20));
            t=b/sb;
            df=(numyears-validfirstyears(city)-19);
            tdist2T=@(t,df) (1-betainc(df/(df+t^2),df/2,0.5)); %2-tailed p-value fct
            pvalueforstdev(city)=1-tdist2T(t,df);
            alpha=0.1; %desired significance level
            tcrit=findtcrit(alpha,df); %critical t-value with a 2-sided distribution
            lowerconfslopeforstdev(city)=b-tcrit*sb;
            upperconfslopeforstdev(city)=b+tcrit*sb;
        end
    end
    if size(pvalueforstdev,2)<numcities
        pvalueforstdev=[pvalueforstdev 0];lowerconfslopeforstdev=[lowerconfslopeforstdev 0];
        upperconfslopeforstdev=[upperconfslopeforstdev 0];
    end
    
    %Cities with significant increases in variability with 95% confidence: Amarillo, Cleveland, Philadelphia
    %Additionally, with 90% confidence: Boston, Columbus, Edison NJ, Fargo, Lexington (decr), Madison,
    %Milwaukee (decr), Syracuse
end

%See what storms have contributed the most to total seasonal snowfall
if computelargeststorms==1
    data=csvread('citiesdailysnowfalldataallyears.csv');
    %Columns are year|month|day|NYC|Syracuse|Buffalo|Boulder|Chicago|Fargo|Boston|Anchorage
    snowsums=0;biggeststorms=0;percentbiggeststormofseason=0;
    for city=1:8
        snowsumthisseason=0;seasonc=0;maxdailysnowfallthisseason=0;
        for i=1:size(data,1)
            todayssnowfall=data(i,city+3);
            if todayssnowfall>=0.1;snowsumthisseason=snowsumthisseason+todayssnowfall;end %measurable snowfall, no traces
            if todayssnowfall>maxdailysnowfallthisseason
                maxdailysnowfallthisseason=todayssnowfall;
            end
            if data(i,2)==6 && data(i,3)==30 %end of a snow season
                seasonc=seasonc+1;
                snowsums(seasonc,city)=snowsumthisseason;
                biggeststorms(seasonc,city)=maxdailysnowfallthisseason;
                if snowsumthisseason>=12
                    percentbiggeststormofseason(seasonc,city)=100*maxdailysnowfallthisseason/snowsumthisseason;
                else
                    percentbiggeststormofseason(seasonc,city)=0;
                end
                snowsumthisseason=0;maxdailysnowfallthisseason=0;
            end
        end
    end
    figure(figc);clf;figc=figc+1;
    colorshere=varycolor(8);
    for i=1:8
        plot((1951:2016)',percentbiggeststormofseason(:,i),'Color',colorshere(i,:),'LineWidth',2);hold on;
    end
    xlabel('Year','FontSize',14,'FontName','Arial','FontWeight','bold');
    ylabel('Percent','FontSize',14,'FontName','Arial','FontWeight','bold');
    set(gca,'FontSize',14,'FontName','Arial','FontWeight','bold');
    title('Percent of Seasonal Snowfall Occurring in Biggest Single-Day Total, Seasons >=12" Only',...
        'FontSize',16,'FontName','Arial','FontWeight','bold');
    legend('New York','Syracuse','Buffalo','Boulder','Chicago','Fargo','Boston','Anchorage','FontSize',13,'Location','northwest',...
        'FontName','Arial','FontWeight','bold');
end

%Make map of cities with increasing trend, decreasing trend, no trend, or not enough data
if makemapoftrends==1
    suffix={'';'forstdev'};choicehere=1; %1 if doing actual totals, 2 if doing variability
    suffix=char(suffix{choicehere});
    pvaluecutoff=[0.05;0.10];
    
    %Set up figure and category lists
    fg=figure(figc);clf;figc=figc+1;
    latlim=[23 50];lonlim=[-128 -63];
    if choicehere==1
        fgtitle=sprintf('Trends in Total Seasonal Snowfall');
    elseif choicehere==2
        fgtitle=sprintf('Trends in Seasonal-Snowfall Variability');
    end
    set(fg,'Color',[1 1 1]);title(fgtitle,'FontSize',16,'FontWeight','bold','FontName','Arial');
    axesm('mercator','MapLatLimit',latlim,'MapLonLimit',lonlim);axis off;
    framem off;gridm off; mlabel off; plabel off;
    load coast;
    states=shaperead('usastatelo', 'UseGeoCoords', true, 'Selector', ...
             {@(name) ~any(strcmp(name,{'Alaska','Hawaii'})), 'Name'});
    geoshow(states, 'DisplayType', 'polygon', 'DefaultFaceColor', 'none');
    tightmap;
    plotcateg=0;
    pvaluetouse=eval(['pvalue' suffix ';']);
    lowerconfslopetouse=eval(['lowerconfslope' suffix ';']);
    upperconfslopetouse=eval(['upperconfslope' suffix ';']);
    for city=1:numcities
        if pvaluetouse(city)>0 && pvaluetouse(city)<pvaluecutoff(choicehere) %significant trend
            if lowerconfslopetouse(city)>0 %positive trend
                plotcateg(city)=1;
            else %negative trend
                plotcateg(city)=2;
            end
        elseif pvaluetouse(city)>=0.05 %no trend
            plotcateg(city)=3;
        elseif pvaluetouse(city)==0 %not enough data
            plotcateg(city)=4;
        end
    end
    
    %First, a decoy to set up the legend
    if choicehere==1;selectedcities=[57;24;67;1];elseif choicehere==2;selectedcities=[4;39;2;1];end
    markerlist={'*';'v';'s';'x'}; %positive|negative|none|not enough data
    colorlist={colors('blue');colors('red');colors('green');colors('light purple')}; %color-symbol pairs are more distinctive
    for count=1:4
        city=selectedcities(count);
        mark=markerlist{count};color=colorlist{count};
        pt1lat=citylats(city);pt1lon=citylons(city);
        h=geoshow(pt1lat,pt1lon,'DisplayType','Point','Marker',mark,...
            'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',14);
    end
    legend('Positive Trend','Negative Trend','No Trend','Not Enough Data');
    set(gca,'FontSize',14,'FontName','Arial','FontWeight','bold');
    
    %Now, actually plot all the cities
    for city=1:numcities
        mark=markerlist{plotcateg(city)};color=colorlist{plotcateg(city)};
        pt1lat=citylats(city);pt1lon=citylons(city);
        h=geoshow(pt1lat,pt1lon,'DisplayType','Point','Marker',mark,...
            'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',14);
    end 
end
