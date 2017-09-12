%Reads recent reanalysis datasets and then makes near-real-time maps of them, 
%and of indices/statistics derived therefrom
%Note: in this script and its supporting documents, the terms 'indices' and 'scores' are used interchangeably
%Uses NCEP Surface Level datasets from ESRL PSD, which as of Jul 2016 were located at (e.g., for air temp.)
%http://www.esrl.noaa.gov/psd/cgi-bin/db_search/DBSearch.pl?Dataset=
%NCEP+Reanalysis+Surface+Level&Variable=Air+Temperature&group=0&submit=Search
    %The direct FTP URL to use, e.g. for 2016 and 'air', is
    %ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface/air.sig995.2017.nc
    %variables are 'air', 'uwnd', 'vwnd', 'rhum', 'prate', all 4x daily

%Methodology: discomfort index is sum of apparent-temperature deviation from 70 F,
%with the apparent temperature determined by wind chill (if cold) or heat index (if warm)
    %specifically, first the heat index is computed from a simple formula,
    %and the output averaged with temperature
    %if the result is >=80 F, a complex formula is used with special adjustments
    %for very dry and very moist conditions
    %if the result is >80 F and >=70 F, result stands as is
    %if the result is <70 F, it is discarded and wind chill is calculated instead
%heat-index equation: http://www.wpc.ncep.noaa.gov/html/heatindex_equation.shtml
%wind-chill equation: http://www.srh.noaa.gov/images/epz/wxcalc/windChill.pdf

%Current runtime: 
    %for conversion, about 1.5 sec per variable per year
    %for main computation loop, about 0.5 sec per year
    %for plots, about 3 sec per year for discomfort scores, and 10 sec per year for climatologies

%Runtime options
runonworkcomputer=1;

%To plot actual scores, set both setupanomalies and setuppercentiles to 0
vartoplotf=1;               %first variable to compute & plot on this run (using order of varlist)
vartoplotl=1;               %last " "
fpyear=1979;lpyear=2016;    %first and last possible years
yeariwf=1979;yeariwl=2016;  %years to compute scores over on this run
monthiwf=12;monthiwl=12;    %months to compute scores over (default: 1-12)
levelhere='995';            %if doing sigma levels, these show up in the filenames & so need to be accounted for
    %otherwise, make this ''

%Which loops to run
needtoconvert=0;            %whether to convert .nc files to .mat ones using function call
    vartoconvert={'prate'};       %if converting, name of variable(s) to convert right now (can only do one at a time)
domaincomputationloop=0;    %whether to calculate discomfort indices & climatologies
    saveasclimoavg=1;           %with the given period, whether to save these indices as a climatological average
plotclimo=0;                %whether to plot certain seasonal climatologies (also can be done in plotdiscomfindices)
setupdiscomfindicesanomalies=0;  %OLD DON'T USEwhether to *set up for plotting* anomalies of current-period discomfort indices
    %requires having already calculated and saved the relevant normals on an earlier run
setupdiscomfindicespercentiles=0;%whether to *set up for plotting* percentiles of current-period discomfort indices
    climoyearstart=1979;climomonthstart=monthiwf;
    climoyearstop=2016;climomonthstop=monthiwl;
        %^ years & months comprising the climo avg against which the anomaly/percentiles will be calculated
plotdiscomfindices=0;       %whether to plot discomfort indices/anomalies/percentiles
    plotpercentiles=0;      %1 for plotting percentiles, 0 for plotting scores
    regiontoplot='world';   %'usa' or 'world'
    addcitiesmarkers=0;         %whether to add markers for specified cities on map of discomfort indices
docitiescomputationloop=0;  %1 sec; whether to calculate discomfort scores and percentiles for each city
    %(as the weighted avg of its three gridpt neighbors as found in wncepgridptswrappermultiplecities)
computebestperiods=0;       %10 sec; whether to compute most-comfortable two-week periods for each US and world city
makemapcitiestransposed=0;  %SEE NOTES AT START OF LOOPwhether to make a map of the most-anomalous cities for the most-recent month
    %transposed to the city that's climatologically most like the whether the anomalous city has just been experiencing
    %to be able to do this: 1. have monthiwf==monthiwl; 2. have setupdiscomfindicespercentiles==1;
    %3. have docitiescomputationloop==1
    %IMPORTANT -- IF RUNNING MULTIPLE TIMES, KEEP DOMAINCOMPUTATIONLOOP, SETUPDISCOMFINDICESPERCENTILES, AND 
    %DOCITIESCOMPUTATIONLOOP==1
plotclimovideos=0;          %whether to make multiple plots (the bones of videos)
    climotop10eachmonth=0;  %about 3 min
    top10mostcomfeachyear=0;%about 6 min
    optimaldateseachcity=1;
besttimetovisiteachgridcell=0; %10 sec


    
%Other things that always need to be defined
if runonworkcomputer==1
    curDirpart1='/Users/craymon3/General_Academics/Website/Recent_Weather/';
    curDirpart2='Discomfort_Scores/NCEP_Data_for_Discomfort_Scores_6-Hourly_mat';
    savingDir='/Users/craymon3/General_Academics/Website/Recent_Weather/Discomfort_Scores/';
else
    curDirpart1='/Users/colin/Documents/General_Academics/Website/Recent_Weather/';
    curDirpart2='Discomfort_Scores/NCEP_Data_for_Discomfort_Scores_6-Hourly_mat';
    savingDir='/Users/colin/Documents/General_Academics/Website/Recent_Weather/Discomfort_Scores/';
end
curDir=strcat(curDirpart1,curDirpart2);
varlist={'air';'uwnd';'vwnd';'rhum'}; %don't change this

nceparrsz=[144 73];


%Convert from .nc to .mat, if necessary
if needtoconvert==1
    rawNcDir='/Volumes/ExternalDriveA/NCEP_Data_for_Discomfort_Scores_6-Hourly_raw_activefiles';
    if runonworkcomputer==1
        outputDirpart1='/Users/craymon3/General_Academics/Website/Recent_Weather/';
        outputDirpart2='Discomfort_Scores/NCEP_Data_for_Discomfort_Scores_6-Hourly_mat';
    else
        outputDirpart1='/Users/colin/Documents/General_Academics/Website/Recent_Weather/';
        outputDirpart2='Discomfort_Scores/NCEP_Data_for_Discomfort_Scores_6-Hourly_mat';
    end
    outputDir=strcat(outputDirpart1,outputDirpart2);
    maxNum=250; %maximum number of files to transcribe at once
    varName=char(vartoconvert);
    if strcmp(vartoconvert,'prate')
        varNameinFileName=strcat(varName,'.sfc.gauss');
    else
        varNameinFileName=strcat(varName,'.sig995');
    end
    ncepNcToMat(rawNcDir,outputDir,varName,varNameinFileName,'mono','4xdaily',maxNum);
end

%Other set-up that always needs to be done
varlistnames={'1000-hPa Temp.';'1000-hPa Zonal Wind';'1000-hPa Meridional Wind';'Relative Humidity';'Precipitation Rate'};
monthnames={'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'};
numyears=yeariwl-yeariwf+1;nummonthsperyear=monthiwl-monthiwf+1;

%Get ready to load in data, now in .mat format
variab=1;month=1; %doesn't matter, because lats & lons are all the same; 
    %just need to get one in case full reading is not done
curFile=load(char(strcat(curDir,'/',varlist{variab},'/',num2str(yeariwl),'/',varlist{variab},...
        '_',num2str(yeariwl),'_0',num2str(month),'_',levelhere,'.mat')));
llsource2=eval(['curFile.' char(varlist{variab}) '_' num2str(yeariwl) '_0' num2str(month) '_' levelhere]);
lat2=double(llsource2{1});lon2=double(llsource2{2});

%Compute and plot mean daily temp for DJF, MAM, JJA, SON
%This requires wrangling mat-files (lots of code but it's quick to compute)
%Can't use regional setting to find mystep because it relies on code designed for NARR, not NCEP, files
if domaincomputationloop==1
    disp('Executing the main computational loop');
    
    totaldiscomfscore=zeros(nceparrsz(1),nceparrsz(2));
    for month=monthiwf:monthiwl;tArrsaved{month}=zeros(144,73);end %set up monthly avg T
    for variab=vartoplotf:vartoplotl %which variables to plot (using order in varlist) 
        if strcmp(varlist(variab),'air')
            vararginnew={'variable';'temperature';'caxismax';35;'caxismin';15;...
                'contour';1;'mystep';2;'plotCountries';1;'colormap';'jet';'overlaynow';0};
            adj=273.15;scalarvar=1;
        elseif strcmp(varlist(variab),'hgt')
            vararginnew={'variable';'height';'contour';1;'mystep';10;'plotCountries';1;...
                'colormap';'jet';'overlaynow';0};
            adj=0;scalarvar=1;
        elseif strcmp(varlist(variab),'uwnd') || strcmp(varlist(variab),'vwnd')
            adj=0;scalarvar=0;
        elseif strcmp(varlist(variab),'rhum')
            vararginnew={'variable';'temperature';'caxismax';100;'caxismin';0;...
                'contour';1;'mystep';5;'plotCountries';1;'overlaynow';0};
            adj=0;scalarvar=1;
        end
        sumvar{variab}=0;monlen{variab}=0;
        djfvar=zeros(nceparrsz(1),nceparrsz(2));mamvar=zeros(nceparrsz(1),nceparrsz(2));
        jjavar=zeros(nceparrsz(1),nceparrsz(2));sonvar=zeros(nceparrsz(1),nceparrsz(2));
        annualvar=zeros(nceparrsz(1),nceparrsz(2));
        djfdays=0;mamdays=0;jjadays=0;sondays=0;annualdays=0;
        for year=yeariwf:yeariwl
            discomfscoretsbuilder=zeros(nceparrsz(1),nceparrsz(2));
            discomfscoretspart1builder=zeros(nceparrsz(1),nceparrsz(2));
            discomfscoretspart2builder=zeros(nceparrsz(1),nceparrsz(2));
            discomfscoretspart3builder=zeros(nceparrsz(1),nceparrsz(2));
            sumcontribhiabove80only=zeros(nceparrsz(1),nceparrsz(2));
            sumcontribhibetween70and80only=zeros(nceparrsz(1),nceparrsz(2));
            sumcontribhibelow70only=zeros(nceparrsz(1),nceparrsz(2));
            for month=monthiwf:monthiwl
                fprintf('Current year and month are %d, %d\n',year,month);
                if month<=9
                    curFile=load(char(strcat(curDir,'/',varlist(variab),'/',...
                        num2str(year),'/',varlist(variab),'_',num2str(year),...
                        '_0',num2str(month),'_',levelhere,'.mat')));
                    lastpartcur=char(strcat(varlist(variab),'_',num2str(year),'_0',num2str(month),'_995'));
                    %Need other variables as well to be able to calculate WBT & heat index
                    tFile=load(char(strcat(curDir,'/',varlist(1),'/',num2str(year),'/',...
                        varlist(1),'_',num2str(year),'_0',num2str(month),'_',levelhere,'.mat')));
                    lastpartt=char(strcat(varlist(1),'_',num2str(year),'_0',num2str(month),'_995'));
                    uwndFile=load(char(strcat(curDir,'/',varlist(2),'/',num2str(year),'/',...
                        varlist(2),'_',num2str(year),'_0',num2str(month),'_',levelhere,'.mat')));
                    lastpartuwnd=char(strcat(varlist(2),'_',num2str(year),'_0',num2str(month),'_995'));
                    vwndFile=load(char(strcat(curDir,'/',varlist(3),'/',num2str(year),'/',...
                        varlist(3),'_',num2str(year),'_0',num2str(month),'_',levelhere,'.mat')));
                    lastpartvwnd=char(strcat(varlist(3),'_',num2str(year),'_0',num2str(month),'_995'));
                    rhumFile=load(char(strcat(curDir,'/',varlist(4),'/',num2str(year),'/',...
                        varlist(4),'_',num2str(year),'_0',num2str(month),'_',levelhere,'.mat')));
                    lastpartrhum=char(strcat(varlist(4),'_',num2str(year),'_0',num2str(month),'_995'));
                else 
                    curFile=load(char(strcat(curDir,'/',varlist(variab),'/',...
                        num2str(year),'/',varlist(variab),'_',num2str(year),...
                        '_',num2str(month),'_',levelhere,'.mat')));
                    lastpartcur=char(strcat(varlist(variab),'_',num2str(year),'_',num2str(month),'_995'));
                    %Need other variables as well to be able to calculate WBT & heat index
                    tFile=load(char(strcat(curDir,'/',varlist(1),'/',num2str(year),'/',...
                        varlist(1),'_',num2str(year),'_',num2str(month),'_',levelhere,'.mat')));
                    lastpartt=char(strcat(varlist(1),'_',num2str(year),'_',num2str(month),'_995'));
                    uwndFile=load(char(strcat(curDir,'/',varlist(2),'/',num2str(year),'/',...
                        varlist(2),'_',num2str(year),'_',num2str(month),'_',levelhere,'.mat')));
                    lastpartuwnd=char(strcat(varlist(2),'_',num2str(year),'_',num2str(month),'_995'));
                    vwndFile=load(char(strcat(curDir,'/',varlist(3),'/',num2str(year),'/',...
                        varlist(3),'_',num2str(year),'_',num2str(month),'_',levelhere,'.mat')));
                    lastpartvwnd=char(strcat(varlist(3),'_',num2str(year),'_',num2str(month),'_995'));
                    rhumFile=load(char(strcat(curDir,'/',varlist(4),'/',num2str(year),'/',...
                        varlist(4),'_',num2str(year),'_',num2str(month),'_',levelhere,'.mat')));
                    lastpartrhum=char(strcat(varlist(4),'_',num2str(year),'_',num2str(month),'_995'));
                end
                curArr=eval(['curFile.' lastpartcur]);
                curArr{3}=curArr{3}-adj; %unit adjustment
                tArr=eval(['tFile.' lastpartt]);
                uwndArr=eval(['uwndFile.' lastpartuwnd]);vwndArr=eval(['vwndFile.' lastpartvwnd]);
                rhumArr=eval(['rhumFile.' lastpartrhum]);
                
                %Save tArr so later can refer to average T by month
                tArrsaved{month}=tArrsaved{month}+mean(tArr{3},3);
                
                hiortorwindchill=0;
                %Compute heat index & wind chill (if necessary)


                %Convert things to English units to be able to
                %calculate heat index & wind chill using NWS formulas
                tArr{3}=(tArr{3}-273.15)*9/5+32; %in F
                uwndArr{3}=2.23694*uwndArr{3};vwndArr{3}=2.23694*vwndArr{3}; %in mph
                totalwind=sqrt(uwndArr{3}.^2+vwndArr{3}.^2);


                %Simple HI calculation to start things off
                simplehi=0.5*(tArr{3}+61+((tArr{3}-68)*1.2)+(rhumArr{3}*0.094));
                hiortorwindchill=(simplehi+tArr{3})/2; %avg of T and simple HI
                hiortorwcv1=(simplehi+tArr{3})/2; %a copy of this that isn't overwritten

                
                %Use complex formula for high-HI values, giving it a weight of 2.5
                hiabove80=hiortorwcv1>=80;
                tArrhiabove80=tArr{3}.*hiabove80; %temperature where HI>=80, preserving dimensions
                rhumArrhiabove80=rhumArr{3}.*hiabove80; %RH " "
                %hiortorwindchill(hiabove80)=calchicomplexformula(tArrhiabove80,rhumArrhiabove80)-70;
                hiortorwindchill=calchicomplexformula(tArrhiabove80,rhumArrhiabove80);
                
                %Bring nonsensical values back to 0
                hiortorwindchill(hiortorwindchill<80)=0;
                %Finalize score
                finalscorepart1=2.5*double(hiortorwindchill)-70;
                %Again, bring nonsensical values back to 0
                hiortorwindchill(hiortorwindchill<0)=0;
                finalscorepart1(finalscorepart1<0)=0;
                
                %data={lat2;lon2;double(sum(hiortorwindchill(:,:,:),3))};
                finalscorepart1sum=sum(finalscorepart1,3);
                data={lat2;lon2;double(finalscorepart1sum)};
                %disp('HI>80 only, for Miami');disp(data{3}(113,27));

                
                
                %Leave the simple formula as is for moderate values, giving it a weight of 1
                b=(hiortorwcv1<80 & hiortorwcv1>=70);
                hibetween70and80=b.*hiortorwcv1;
                hiortorwindchill=hibetween70and80;
                
                %Bring nonsensical values back to 0
                hiortorwindchill(hiortorwindchill<70)=0;
                %finalscorepart2=hiortorwindchill-70;
                finalscorepart2=double(hibetween70and80)-70;
                %Again, bring nonsensical values back to 0
                hiortorwindchill(hiortorwindchill<0)=0;
                finalscorepart2(finalscorepart2<0)=0;
                
                finalscorepart2sum=sum(finalscorepart2,3);
                data={lat2;lon2;double(finalscorepart2sum)};
                %disp('HI>70 & <80 only, for Miami');disp(data{3}(113,27));
                
                

                %For low-HI values, scrap HI altogether and use wind chill, giving it a weight of 1.5
                hibelow70=hiortorwcv1<70;
                tArrhibelow70=tArr{3}.*hibelow70; %temperature where HI<70
                wndArrhibelow70=totalwind.*hibelow70; %sfc wind " "
                %hiortorwindchill=((35.74+(0.6215.*tArrhibelow70)-...
                %    (35.75.*wndArrhibelow70.^0.16)+...
                %    (0.4275.*tArrhibelow70.*wndArrhibelow70.^0.16)));
                validareas=tArrhibelow70~=0; %areas other than these had a simple HI>=70 and therefore
                %should have a score of 0 for this part
                finalscorepart3=((35.74+(0.6215.*tArrhibelow70)-...
                    (35.75.*wndArrhibelow70.^0.16)+...
                    (0.4275.*tArrhibelow70.*wndArrhibelow70.^0.16)));
                
                %Bring nonsensical values back to 0
                hiortorwindchill(hiortorwindchill>=70)=70; %so that the score is 0 for these areas
                hiortorwindchill(hiortorwindchill<-150)=70; %ditto
                finalscorepart3=1.5*(70-double(finalscorepart3));
                finalscorepart3=finalscorepart3.*validareas; %score of 0 for invalid areas
                finalscorepart3(finalscorepart3<0)=0;
                
                %data={lat2;lon2;double(sum(hiortorwindchill(:,:,:),3))};
                finalscorepart3sum=sum(finalscorepart3,3);
                data={lat2;lon2;double(finalscorepart3sum)};
                %disp('HI<70 only, for Miami');disp(data{3}(113,27));
                

                %Combine the three parts into one discomfort score
                discomfscore=finalscorepart1+finalscorepart2+finalscorepart3;
                %Save into both total and year-specific arrays
                totaldiscomfscore=totaldiscomfscore+double(sum(discomfscore(:,:,:),3)); %total so far
                discomfscoretsbuilder=discomfscoretsbuilder+double(sum(discomfscore(:,:,:),3)); %total so far THIS YEAR ONLY
                discomfscoretspart1builder=discomfscoretspart1builder+finalscorepart1sum; %total so far THIS YEAR ONLY
                discomfscoretspart2builder=discomfscoretspart2builder+finalscorepart2sum; %total so far THIS YEAR ONLY
                discomfscoretspart3builder=discomfscoretspart3builder+finalscorepart3sum; %total so far THIS YEAR ONLY
                
                %Averages of each variable independently
                if month==12 || month==1 || month==2
                    djfvar=djfvar+sumvar{variab};djfdays=djfdays+monlen{variab};
                elseif month==3 || month==4 || month==5
                    mamvar=mamvar+sumvar{variab};mamdays=mamdays+monlen{variab};
                elseif month==6 || month==7 || month==8
                    jjavar=jjavar+sumvar{variab};jjadays=jjadays+monlen{variab};
                else
                    sonvar=sonvar+sumvar{variab};sondays=sondays+monlen{variab};
                end
                annualvar=annualvar+sumvar{variab};annualdays=annualdays+monlen{variab};
            end
            %For each year, save all the discomfort scores & contributions thereto, 
            %so that percentiles can later be calculated relative to them
            discomfscorets(:,:,year-fpyear+1)=discomfscoretsbuilder;
            contribhiabove80ts(:,:,year-fpyear+1)=discomfscoretspart1builder;
            contribhibetween70and80ts(:,:,year-fpyear+1)=discomfscoretspart2builder;
            contribhibelow70ts(:,:,year-fpyear+1)=discomfscoretspart3builder;
        end
        
        %Plot climatologies
        if plotclimo==1
            if djfdays~=0
                numdjfm=round(djfdays/30);
                matrix=djfvar/djfdays;data={lat2;lon2;matrix};
                if scalarvar==1
                    plotModelData(data,mapregionclimo,vararginnew,'NCEP');
                    title(sprintf('Average Daily %s for DJF, %d-%d',char(varlistnames{variab}),yeariwf,yeariwl),...
                        'FontSize',16,'FontWeight','bold');
                end
            end
            if mamdays~=0
                nummamm=round(mamdays/30.667);
                matrix=mamvar/mamdays;data={lat2;lon2;matrix};
                if scalarvar==1
                    plotModelData(data,'usa-exp',vararginnew,'NCEP');figc=figc+1;
                    title(sprintf('Average Daily %s for MAM, %d-%d',char(varlistnames{variab}),yeariwf,yeariwl),...
                        'FontSize',16,'FontWeight','bold');
                end
            end
            if jjadays~=0
                numjjam=round(jjadays/30.667);
                matrix=jjavar/jjadays;data={double(lat2);double(lon2);double(matrix)};
                if scalarvar==1
                    plotModelData(data,'usa-exp',vararginnew,'NCEP');figc=figc+1;
                    title(sprintf('Average Daily %s for JJA, %d-%d',char(varlistnames{variab}),yeariwf,yeariwl),...
                        'FontSize',16,'FontWeight','bold');
                end
            end
            if sondays~=0
                numsonm=round(sondays/30.333);
                matrix=sonvar/sondays;data={lat2;lon2;matrix};
                if scalarvar==1
                    plotModelData(data,mapregionclimo,vararginnew,'NCEP');figc=figc+1;
                    title(sprintf('Average Daily %s for SON, %d-%d',char(varlistnames{variab}),yeariwf,yeariwl),...
                        'FontSize',16,'FontWeight','bold');
                end
            end
        end
    end
    for month=monthiwf:monthiwl;tArrsaved{month}=tArrsaved{month}./(yeariwl-yeariwf+1);end
    disp(clock);
    %If this period is intended as a climatological average, save totaldiscomfscore & discomfscoretsbuilder to a file
    if saveasclimoavg==1
        filenameprefix=strcat(savingDir,'discomfscorematrix',...
            num2str(yeariwf),'-',num2str(monthiwf),'to',num2str(yeariwl),'-',num2str(monthiwl));
        save(filenameprefix,'totaldiscomfscore','discomfscorets','contribhiabove80ts',...
            'contribhibetween70and80ts','contribhibelow70ts','tArrsaved');
    end
end
    

%If plotting anomalies of current-period discomfort indices from normal, set things up
%(i.e. this current period can't be considered a climo average or there will be zero anomaly!)
if setupdiscomfindicesanomalies==1
    if saveasclimoavg==1
        disp('Cannot calculate anomalies if the current period is the climatology!');
        return;
    end
    anomyesorno=' Anomaly';
    %Load the precalculated climo average
    precalcavg=load(strcat(savingDir,'discomfscorematrix',...
        num2str(climoyearstart),'-',num2str(climomonthstart),'to',num2str(climoyearstop),'-',num2str(climomonthstop)));
    precalcavg=(precalcavg.totaldiscomfscore)/(climoyearstop-climoyearstart+1);
    
    curperiodanom=totaldiscomfscore-precalcavg;
else
    anomyesorno='';
end

%If plotting percentiles relative to the climatological distribution, set things up
if setupdiscomfindicespercentiles==1
    if saveasclimoavg==1
        disp('Cannot calculate percentiles if the current period is the climatology! So, this will be skipped.');
    else
        anomyesorno=' Percentiles';
        percdiscomf=zeros(nceparrsz(1),nceparrsz(2));
        perchiabove80=zeros(nceparrsz(1),nceparrsz(2));
        perchibetween70and80=zeros(nceparrsz(1),nceparrsz(2));
        perchibelow70=zeros(nceparrsz(1),nceparrsz(2));

        %Load the precalculated (climatological) time series of discomfort scores
        discomfscoretsfile=load(strcat(savingDir,'discomfscorematrix',...
            num2str(climoyearstart),'-',num2str(climomonthstart),'to',num2str(climoyearstop),'-',num2str(climomonthstop)));
        discomfscorets=discomfscoretsfile.discomfscorets;
        climocontribhiabove80ts=discomfscoretsfile.contribhiabove80ts;
        climocontribhibetween70and80ts=discomfscoretsfile.contribhibetween70and80ts;
        climocontribhibelow70ts=discomfscoretsfile.contribhibelow70ts;

        %For each gridpoint, calculate the percentile of the discomfort index (+ its components) 
            %in the current period, relative to the climatology
        for i=1:nceparrsz(1)
            for j=1:nceparrsz(2)
                climodistribution=squeeze(discomfscorets(i,j,:));
                curperiodval=totaldiscomfscore(i,j);
                percdiscomf(i,j)=pctreltodistn(climodistribution,curperiodval);

                climodistribution=squeeze(climocontribhiabove80ts(i,j,1:37));
                curperiodval=contribhiabove80ts(i,j,38);
                perchiabove80(i,j)=pctreltodistn(climodistribution,curperiodval);

                climodistribution=squeeze(climocontribhibetween70and80ts(i,j,1:37));
                curperiodval=contribhibetween70and80ts(i,j,38);
                perchibetween70and80(i,j)=pctreltodistn(climodistribution,curperiodval);

                climodistribution=squeeze(climocontribhibelow70ts(i,j,1:37));
                curperiodval=contribhibelow70ts(i,j,38);
                perchibelow70(i,j)=pctreltodistn(climodistribution,curperiodval);
            end
        end
    end
end


%Plot discomfort scores (or anomalies, or percentiles) for the months & variables chosen
if plotdiscomfindices==1
    if plotpercentiles==0 %will plot scores if 0, percentiles if 1
        normalizeddiscomfscore=double(totaldiscomfscore)/(numyears*nummonthsperyear);
        data={lat2;lon2;normalizeddiscomfscore};numloops=1;wordinname='score';wordintitle='Scores';
    else
        data={lat2;lon2;double(percdiscomf)};wordinname='perc';wordintitle='Percentiles';
        numloops=1; %data for additional loops is assigned separately below, but not usually necessary
    end
    %Find the max discomfscore within the contiguous-US domain
    %maxcontigus=max(max(totaldiscomfscore(95:121,17:27)));
    camin=0; %default
    if plotpercentiles==1
        if ~strcmp(regiontoplot,'world')
            ms=5;cam=100;
        else
            ms=16;cam=100;
        end
    else
        if ~strcmp(regiontoplot,'world')
            if monthiwf==3 && monthiwl==5
                ms=400;cam=8000;
            elseif monthiwf==6 && monthiwl==8
                ms=1500;cam=30000;
            elseif monthiwf==9 && monthiwl==11
                ms=400;cam=12000;
            elseif monthiwf==12 && monthiwl==2
                ms=2000;cam=40000;
            elseif monthiwf==1 && monthiwl==12
                ms=400;cam=12000;
            elseif monthiwf==1 && monthiwl==2
                ms=400;cam=12000;
            elseif monthiwf==1 && monthiwl==6 || monthiwf==7 && monthiwl==12
                ms=400;cam=8000;
            elseif monthiwf==monthiwl
                ms=1000;cam=12000;
            else
                ms=2000;cam=100000;
            end
        else
           if monthiwf==3 && monthiwl==5
                ms=400;cam=8000;
            elseif monthiwf==6 && monthiwl==8
                ms=1500;cam=30000;
            elseif monthiwf==9 && monthiwl==11
                ms=400;cam=12000;
            elseif monthiwf==12 && monthiwl==2
                ms=2000;cam=40000;
            elseif monthiwf==1 && monthiwl==12
                ms=400;cam=12000;
            elseif monthiwf==1 && monthiwl==2
                ms=1250;cam=25000;
            elseif monthiwf==1 && monthiwl==6 || monthiwf==7 && monthiwl==12
                ms=400;cam=8000;
            elseif monthiwf==monthiwl
                ms=1000;cam=12000;
            else
                ms=2000;cam=100000;
            end
        end
    end
    for i=1:numloops %extra loops are in the case of percentile runs only
        if i==2
            data={lat2;lon2;double(perchiabove80)};
            addondescriptor=', Apparent Temperatures >80 Only';
        elseif i==3
            data={lat2;lon2;double(perchibetween70and80)};
            addondescriptor=', Apparent Temperatures >=70 and <80 Only';
        elseif i==4
            data={lat2;lon2;double(perchibelow70)};
            addondescriptor=', Apparent Temperatures <70 Only';
        else
            addondescriptor='';
        end
        vararginnew={'variable';'generic scalar';'contour';1;'mystep';ms;'plotCountries';1;...
                    'caxismax';cam;'caxismin';camin;'overlaynow';0};
        plotModelData(data,regiontoplot,vararginnew,'NCEP');
        curpart=1;highqualityfiguresetup;
        if yeariwf==yeariwl;secondyear='';else secondyear=strcat('-',num2str(yeariwl));end
        if monthiwf==monthiwl;secondmonth='';else secondmonth=strcat('-',char(monthnames(monthiwl)));end
        title(sprintf('Monthly-Avg Discomfort %s for %s%s, %s%s%s',wordintitle,char(monthnames(monthiwf)),...
            secondmonth,num2str(yeariwf),secondyear,addondescriptor),...
            'FontSize',20,'FontWeight','bold','FontName','Arial');
        %Add markers for select cities of interest
        if addcitiesmarkers==1
            citieslats=[42.44;40.59;45.39;39.39;37.13;39.19;39.95;42.29];
            citieslons=[-76.5;-105.08;-122.65;-82.10;-80.58;-78.16;-75.17;-85.59];
            for j=1:size(citieslats,1)
                h=geoshow(citieslats(j),citieslons(j),'DisplayType','Point','Marker','s',...
                'MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',7);hold on;
            end
        end
        if i==1 %the full score
            figname=strcat('discomf',wordinname,regiontoplot,...
            num2str(yeariwf),'-',num2str(monthiwf),'to',num2str(yeariwl),'-',num2str(monthiwl));
            curpart=2;figloc=savingDir;
            highqualityfiguresetup;
        end
    end
end

    

%Compute discomfort scores and percentiles for each city listed in rwstationsforcomfortindices.xlsx,
    %as well as monthly-average T (only if doing one month only)
%Can be run independently of all of the above sections, 
    %so long as a totaldiscomfscore and percentiles thereof have already been calculated
%To aid in troubleshooting: Boston (#21) is approx. 117,20; Miami (#97) is approx. 113,27
if docitiescomputationloop==1
    disp('Calculating discomfort scores for each US city >100,000');
    data=load(strcat(savingDir,'discomfortindicesncepgridpts.mat'));
    results=data.results;worldresults=data.worldresults;
        %the sets of 3 points and their weights that define each city of interest
        %calculated in wncepgridptswrappermultiplecities
    loclats=data.loclats;worldloclats=data.worldloclats;
    loclons=data.loclons;worldloclons=data.worldloclons;
    locnames=data.locnames;worldlocnames=data.worldlocnames;
    uscitiesdiscomfscores=zeros(size(results,2),1);worldcitiesdiscomfscores=zeros(size(results,2),1);
    uscitiesdiscomfpercs=zeros(size(results,2),1);worldcitiesdiscomfpercs=zeros(size(results,2),1);
    uscitiesavgT=zeros(size(results,2),1);worldcitiesavgT=zeros(size(results,2),1);
    for i=1:size(results,2)
        %For each city, discomfort score is the weighted average of the 
            %discomfort scores (or their percentiles) of the 3 gridpts closest to it
        %Same with monthly-avg T
        if results{i}(3,1)>0 && results{i}(3,2)>0
            uscitiesdiscomfscores(i)=totaldiscomfscore(results{i}(1,1),results{i}(1,2))*results{i}(1,3)+...
                totaldiscomfscore(results{i}(2,1),results{i}(2,2))*results{i}(2,3)+...
                totaldiscomfscore(results{i}(3,1),results{i}(3,2))*results{i}(3,3);
            if monthiwf==monthiwl;uscitiesavgT(i)=tArrsaved{monthiwf}(results{i}(1,1),results{i}(1,2))*results{i}(1,3)+...
                tArrsaved{monthiwf}(results{i}(2,1),results{i}(2,2))*results{i}(2,3)+...
                tArrsaved{monthiwf}(results{i}(3,1),results{i}(3,2))*results{i}(3,3);end
            if setupdiscomfindicespercentiles==1
                uscitiesdiscomfpercs(i)=percdiscomf(results{i}(1,1),results{i}(1,2))*results{i}(1,3)+...
                    percdiscomf(results{i}(2,1),results{i}(2,2))*results{i}(2,3)+...
                    percdiscomf(results{i}(3,1),results{i}(3,2))*results{i}(3,3);
            end
        else %only two valid gridpts were found for this city
            uscitiesdiscomfscores(i)=totaldiscomfscore(results{i}(1,1),results{i}(1,2))*results{i}(1,3)+...
                totaldiscomfscore(results{i}(2,1),results{i}(2,2))*results{i}(2,3);
            if monthiwf==monthiwl;uscitiesavgT(i)=tArrsaved(results{i}(1,1),results{i}(1,2))*results{i}(1,3)+...
                tArrsaved(results{i}(2,1),results{i}(2,2))*results{i}(2,3);end
            if setupdiscomfindicespercentiles==1
                uscitiesdiscomfpercs(i)=percdiscomf(results{i}(1,1),results{i}(1,2))*results{i}(1,3)+...
                percdiscomf(results{i}(2,1),results{i}(2,2))*results{i}(2,3);
            end
        end
    end
    for i=1:size(worldresults,2)
        %For each city, discomfort score is the weighted average of the 
            %discomfort scores (or their percentiles) of the 3 gridpts closest to it
        %Same with monthly-avg T
        if worldresults{i}(3,1)>0 && worldresults{i}(3,2)>0
            worldcitiesdiscomfscores(i)=totaldiscomfscore(worldresults{i}(1,1),worldresults{i}(1,2))*worldresults{i}(1,3)+...
                totaldiscomfscore(worldresults{i}(2,1),worldresults{i}(2,2))*worldresults{i}(2,3)+...
                totaldiscomfscore(worldresults{i}(3,1),worldresults{i}(3,2))*worldresults{i}(3,3);
            if monthiwf==monthiwl;worldcitiesavgT(i)=tArrsaved{monthiwf}(worldresults{i}(1,1),worldresults{i}(1,2))*worldresults{i}(1,3)+...
                tArrsaved{monthiwf}(worldresults{i}(2,1),worldresults{i}(2,2))*worldresults{i}(2,3)+...
                tArrsaved{monthiwf}(worldresults{i}(3,1),worldresults{i}(3,2))*worldresults{i}(3,3);end
            if setupdiscomfindicespercentiles==1
                worldcitiesdiscomfpercs(i)=percdiscomf(worldresults{i}(1,1),worldresults{i}(1,2))*worldresults{i}(1,3)+...
                    percdiscomf(worldresults{i}(2,1),worldresults{i}(2,2))*worldresults{i}(2,3)+...
                    percdiscomf(worldresults{i}(3,1),worldresults{i}(3,2))*worldresults{i}(3,3);
            end
        else %only two valid gridpts were found for this city
            worldcitiesdiscomfscores(i)=totaldiscomfscore(worldresults{i}(1,1),worldresults{i}(1,2))*worldresults{i}(1,3)+...
                totaldiscomfscore(worldresults{i}(2,1),worldresults{i}(2,2))*worldresults{i}(2,3);
            if monthiwf==monthiwl;worldcitiesavgT(i)=tArrsaved(worldresults{i}(1,1),worldresults{i}(1,2))*worldresults{i}(1,3)+...
                tArrsaved(worldresults{i}(2,1),worldresults{i}(2,2))*worldresults{i}(2,3);end
            if setupdiscomfindicespercentiles==1
                worldcitiesdiscomfpercs(i)=percdiscomf(worldresults{i}(1,1),worldresults{i}(1,2))*worldresults{i}(1,3)+...
                percdiscomf(worldresults{i}(2,1),worldresults{i}(2,2))*worldresults{i}(2,3);
            end
        end
    end
    uscitiesavgT=uscitiesavgT-273.15; %K to C
    worldcitiesavgT=worldcitiesavgT-273.15; %K to C
    
    %If this period is intended as a climatological average, save cities' discomfort scores to a file
    if saveasclimoavg==1
        uscitiesdiscomfscores=uscitiesdiscomfscores./(yeariwl-yeariwf+1);
        filename=strcat(savingDir,'discomfscoreandTcitiesclimo',...
            num2str(yeariwf),'-',num2str(monthiwf),'to',num2str(yeariwl),'-',num2str(monthiwl));
        save(filename,'uscitiesdiscomfscores','uscitiesavgT',...
            'worldcitiesdiscomfscores','worldcitiesavgT');
    end
    
    %Note: only if this period is not a climatological average are the percentiles are meaningful
    %--> make lists of the top 10 anomalously comfortable and uncomfortable cities
    %--> do this for both US and world cities
    %1. Find the top 10 most comfortable (i.e. lowest absolute discomfort score)
    usmostcomfortable=10^6*ones(10,2);
    for city=1:size(uscitiesdiscomfscores,1)
        if uscitiesdiscomfscores(city)<usmostcomfortable(10,1)
            usmostcomfortable(10,1)=uscitiesdiscomfscores(city);
            usmostcomfortable(10,2)=city;
            usmostcomfortable=sortrows(usmostcomfortable,1);
        end
    end
    for i=1:10;usmostcomfortablenames{i}=locnames{usmostcomfortable(i,2)};end
    worldmostcomfortable=10^6*ones(10,2);
    for city=1:size(worldresults,2)
        if worldcitiesdiscomfscores(city)<worldmostcomfortable(10,1)
            worldmostcomfortable(10,1)=worldcitiesdiscomfscores(city);
            worldmostcomfortable(10,2)=city;
            worldmostcomfortable=sortrows(worldmostcomfortable,1);
        end
    end
    for i=1:10;worldmostcomfortablenames{i}=worldlocnames{worldmostcomfortable(i,2)};end
    
    %2. Find the top 10 most UNcomfortable (i.e. highest absolute discomfort score)
    usmostuncomfortable=zeros(10,2);
    for city=1:size(uscitiesdiscomfscores,1)
        if uscitiesdiscomfscores(city)>usmostuncomfortable(10,1)
            usmostuncomfortable(10,1)=uscitiesdiscomfscores(city);
            usmostuncomfortable(10,2)=city;
            usmostuncomfortable=sortrows(usmostuncomfortable,-1);
        end
    end
    for i=1:10;usmostuncomfortablenames{i}=locnames{usmostuncomfortable(i,2)};end
    worldmostuncomfortable=zeros(10,2);
    for city=1:size(worldresults,2)
        if worldcitiesdiscomfscores(city)>worldmostuncomfortable(10,1)
            worldmostuncomfortable(10,1)=worldcitiesdiscomfscores(city);
            worldmostuncomfortable(10,2)=city;
            worldmostuncomfortable=sortrows(worldmostuncomfortable,-1);
        end
    end
    for i=1:10;worldmostuncomfortablenames{i}=worldlocnames{worldmostuncomfortable(i,2)};end
    
    if setupdiscomfindicespercentiles==1
        %3. Find the top 10 most anomalously comfortable (i.e. lowest percentiles of discomfort score)
        usmostanomcomfortable=10^6*ones(10,2);
        for city=1:size(uscitiesdiscomfpercs,1)
            if uscitiesdiscomfpercs(city)<usmostanomcomfortable(10,1)
                usmostanomcomfortable(10,1)=uscitiesdiscomfpercs(city);
                usmostanomcomfortable(10,2)=city;
                usmostanomcomfortable=sortrows(usmostanomcomfortable,1);
            end
        end
        for i=1:10;usmostanomcomfortablenames{i}=locnames{usmostanomcomfortable(i,2)};end
        worldmostanomcomfortable=10^6*ones(10,2);
        for city=1:size(worldresults,2)
            if worldcitiesdiscomfpercs(city)<worldmostanomcomfortable(10,1)
                worldmostanomcomfortable(10,1)=worldcitiesdiscomfpercs(city);
                worldmostanomcomfortable(10,2)=city;
                worldmostanomcomfortable=sortrows(worldmostanomcomfortable,1);
            end
        end
        for i=1:10;worldmostanomcomfortablenames{i}=worldlocnames{worldmostanomcomfortable(i,2)};end
        
        %4. Find the top 10 most anomalously UNcomfortable (i.e. highest percentiles of discomfort score)
        usmostanomuncomfortable=zeros(10,2);
        for city=1:size(uscitiesdiscomfpercs,1)
            if uscitiesdiscomfpercs(city)>usmostanomuncomfortable(10,1)
                usmostanomuncomfortable(10,1)=uscitiesdiscomfpercs(city);
                usmostanomuncomfortable(10,2)=city;
                usmostanomuncomfortable=sortrows(usmostanomuncomfortable,-1);
            end
        end
        for i=1:10;usmostanomuncomfortablenames{i}=locnames{usmostanomuncomfortable(i,2)};end
        worldmostanomuncomfortable=zeros(10,2);
        for city=1:size(worldresults,2)
            if worldcitiesdiscomfpercs(city)>worldmostanomuncomfortable(10,1)
                worldmostanomuncomfortable(10,1)=worldcitiesdiscomfpercs(city);
                worldmostanomuncomfortable(10,2)=city;
                worldmostanomuncomfortable=sortrows(worldmostanomuncomfortable,-1);
            end
        end
        for i=1:10;worldmostanomuncomfortablenames{i}=worldlocnames{worldmostanomuncomfortable(i,2)};end
    end
    filenameprefix=strcat(savingDir,'mostcomfanduncomfcities',...
        num2str(yeariwf),'-',num2str(monthiwf),'to',num2str(yeariwl),'-',num2str(monthiwl));
    if setupdiscomfindicespercentiles==1
        save(filenameprefix,'usmostcomfortablenames','usmostuncomfortablenames',...
        'usmostanomcomfortablenames','usmostanomuncomfortablenames',...
        'worldmostcomfortablenames','worldmostuncomfortablenames',...
        'worldmostanomcomfortablenames','worldmostanomuncomfortablenames');
    else
        save(filenameprefix,'usmostcomfortablenames','usmostuncomfortablenames',...
            'worldmostcomfortablenames','worldmostuncomfortablenames');
    end
end

%Compute best two-week period to visit each US and world city
if computebestperiods==1
    monthnames={'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'};
    monthmodifiers={'early';'late'};
    jancitiesdata=load('discomfscoreandTcitiesclimo1979-1to2016-1');
    febcitiesdata=load('discomfscoreandTcitiesclimo1979-2to2016-2');
    marcitiesdata=load('discomfscoreandTcitiesclimo1979-3to2016-3');
    aprcitiesdata=load('discomfscoreandTcitiesclimo1979-4to2016-4');
    maycitiesdata=load('discomfscoreandTcitiesclimo1979-5to2016-5');
    juncitiesdata=load('discomfscoreandTcitiesclimo1979-6to2016-6');
    julcitiesdata=load('discomfscoreandTcitiesclimo1979-7to2016-7');
    augcitiesdata=load('discomfscoreandTcitiesclimo1979-8to2016-8');
    sepcitiesdata=load('discomfscoreandTcitiesclimo1979-9to2016-9');
    octcitiesdata=load('discomfscoreandTcitiesclimo1979-10to2016-10');
    novcitiesdata=load('discomfscoreandTcitiesclimo1979-11to2016-11');
    deccitiesdata=load('discomfscoreandTcitiesclimo1979-12to2016-12');
    janusdata=jancitiesdata.uscitiesdiscomfscores;janworlddata=jancitiesdata.worldcitiesdiscomfscores;
    febusdata=febcitiesdata.uscitiesdiscomfscores;febworlddata=febcitiesdata.worldcitiesdiscomfscores;
    marusdata=marcitiesdata.uscitiesdiscomfscores;marworlddata=marcitiesdata.worldcitiesdiscomfscores;
    aprusdata=aprcitiesdata.uscitiesdiscomfscores;aprworlddata=aprcitiesdata.worldcitiesdiscomfscores;
    mayusdata=maycitiesdata.uscitiesdiscomfscores;mayworlddata=maycitiesdata.worldcitiesdiscomfscores;
    junusdata=juncitiesdata.uscitiesdiscomfscores;junworlddata=juncitiesdata.worldcitiesdiscomfscores;
    julusdata=julcitiesdata.uscitiesdiscomfscores;julworlddata=julcitiesdata.worldcitiesdiscomfscores;
    augusdata=augcitiesdata.uscitiesdiscomfscores;augworlddata=augcitiesdata.worldcitiesdiscomfscores;
    sepusdata=sepcitiesdata.uscitiesdiscomfscores;sepworlddata=sepcitiesdata.worldcitiesdiscomfscores;
    octusdata=octcitiesdata.uscitiesdiscomfscores;octworlddata=octcitiesdata.worldcitiesdiscomfscores;
    novusdata=novcitiesdata.uscitiesdiscomfscores;novworlddata=novcitiesdata.worldcitiesdiscomfscores;
    decusdata=deccitiesdata.uscitiesdiscomfscores;decworlddata=deccitiesdata.worldcitiesdiscomfscores;
    
    annualusdata=[janusdata febusdata marusdata aprusdata mayusdata junusdata...
        julusdata augusdata sepusdata octusdata novusdata decusdata];
    annualworlddata=[janworlddata febworlddata marworlddata aprworlddata mayworlddata junworlddata...
        julworlddata augworlddata sepworlddata octworlddata novworlddata decworlddata];
    
    for city=1:size(decusdata,1)
        [~,bestmonthuscities(city)]=min(annualusdata(city,:));
        if bestmonthuscities(city)>=2 && bestmonthuscities(city)<=11
            if annualusdata(city,bestmonthuscities(city)+1)<annualusdata(city,bestmonthuscities(city)-1)
                secondbestmonthuscities(city)=bestmonthuscities(city)+1;
            else
                secondbestmonthuscities(city)=bestmonthuscities(city)-1;
            end
        elseif bestmonthuscities(city)==1
            if annualusdata(city,bestmonthuscities(city)+1)<annualusdata(city,12)
                secondbestmonthuscities(city)=bestmonthuscities(city)+1;
            else
                secondbestmonthuscities(city)=12;
            end
        elseif bestmonthuscities(city)==12
            if annualusdata(city,1)<annualusdata(city,bestmonthuscities(city)-1)
                secondbestmonthuscities(city)=1;
            else
                secondbestmonthuscities(city)=bestmonthuscities(city)-1;
            end
        end
    end
    for city=1:size(decworlddata,1)
        [~,bestmonthworldcities(city)]=min(annualworlddata(city,:));
        if bestmonthworldcities(city)>=2 && bestmonthworldcities(city)<=11
            if annualworlddata(city,bestmonthworldcities(city)+1)<annualworlddata(city,bestmonthworldcities(city)-1)
                secondbestmonthworldcities(city)=bestmonthworldcities(city)+1;
            else
                secondbestmonthworldcities(city)=bestmonthworldcities(city)-1;
            end
        elseif bestmonthworldcities(city)==1
            if annualworlddata(city,bestmonthworldcities(city)+1)<annualworlddata(city,12)
                secondbestmonthworldcities(city)=bestmonthworldcities(city)+1;
            else
                secondbestmonthworldcities(city)=12;
            end
        elseif bestmonthworldcities(city)==12
            if annualworlddata(city,1)<annualworlddata(city,bestmonthworldcities(city)-1)
                secondbestmonthworldcities(city)=1;
            else
                secondbestmonthworldcities(city)=bestmonthworldcities(city)-1;
            end
        end
    end
    
    %Map of the best two-week period to visit each US and world city
    plotBlankMap(figc,'world');
    colormaptouse=colormaps('rainbow','more');
    for worldcity=1:size(worldresults,2)
        if bestmonthworldcities(worldcity)==1 && secondbestmonthworldcities(worldcity)==12 %early Jan
            citycolormap=colormaptouse(3,:);
        elseif bestmonthworldcities(worldcity)==1 && secondbestmonthworldcities(worldcity)==2 %late Jan
            citycolormap=colormaptouse(8,:);
        elseif bestmonthworldcities(worldcity)==2 && secondbestmonthworldcities(worldcity)==1 %early Feb
            citycolormap=colormaptouse(13,:);
        elseif bestmonthworldcities(worldcity)==2 && secondbestmonthworldcities(worldcity)==3
            citycolormap=colormaptouse(18,:);
        elseif bestmonthworldcities(worldcity)==3 && secondbestmonthworldcities(worldcity)==2
            citycolormap=colormaptouse(23,:);
        elseif bestmonthworldcities(worldcity)==3 && secondbestmonthworldcities(worldcity)==4
            citycolormap=colormaptouse(28,:);
        elseif bestmonthworldcities(worldcity)==4 && secondbestmonthworldcities(worldcity)==3
            citycolormap=colormaptouse(33,:);
        elseif bestmonthworldcities(worldcity)==4 && secondbestmonthworldcities(worldcity)==5
            citycolormap=colormaptouse(38,:);
        elseif bestmonthworldcities(worldcity)==5 && secondbestmonthworldcities(worldcity)==4
            citycolormap=colormaptouse(43,:);
        elseif bestmonthworldcities(worldcity)==5 && secondbestmonthworldcities(worldcity)==6
            citycolormap=colormaptouse(48,:);
        elseif bestmonthworldcities(worldcity)==6 && secondbestmonthworldcities(worldcity)==5
            citycolormap=colormaptouse(53,:);
        elseif bestmonthworldcities(worldcity)==6 && secondbestmonthworldcities(worldcity)==7
            citycolormap=colormaptouse(58,:);
        elseif bestmonthworldcities(worldcity)==7 && secondbestmonthworldcities(worldcity)==6
            citycolormap=colormaptouse(63,:);
        elseif bestmonthworldcities(worldcity)==7 && secondbestmonthworldcities(worldcity)==8
            citycolormap=colormaptouse(68,:);
        elseif bestmonthworldcities(worldcity)==8 && secondbestmonthworldcities(worldcity)==7
            citycolormap=colormaptouse(73,:);
        elseif bestmonthworldcities(worldcity)==8 && secondbestmonthworldcities(worldcity)==9
            citycolormap=colormaptouse(78,:);
        elseif bestmonthworldcities(worldcity)==9 && secondbestmonthworldcities(worldcity)==8
            citycolormap=colormaptouse(83,:);
        elseif bestmonthworldcities(worldcity)==9 && secondbestmonthworldcities(worldcity)==10
            citycolormap=colormaptouse(88,:);
        elseif bestmonthworldcities(worldcity)==10 && secondbestmonthworldcities(worldcity)==9
            citycolormap=colormaptouse(93,:);
        elseif bestmonthworldcities(worldcity)==10 && secondbestmonthworldcities(worldcity)==11
            citycolormap=colormaptouse(98,:);
        elseif bestmonthworldcities(worldcity)==11 && secondbestmonthworldcities(worldcity)==10
            citycolormap=colormaptouse(103,:);
        elseif bestmonthworldcities(worldcity)==11 && secondbestmonthworldcities(worldcity)==12
            citycolormap=colormaptouse(108,:);
        elseif bestmonthworldcities(worldcity)==12 && secondbestmonthworldcities(worldcity)==11
            citycolormap=colormaptouse(113,:);
        elseif bestmonthworldcities(worldcity)==12 && secondbestmonthworldcities(worldcity)==1
            citycolormap=colormaptouse(118,:);
        end
        geoshow(worldloclats(worldcity),worldloclons(worldcity),'DisplayType','Point','Marker','o',...
        'MarkerFaceColor',citycolormap,'MarkerEdgeColor',citycolormap,'MarkerSize',12);hold on;
    end
end

%Whether to make a map of the most-anomalous cities for the most-recent season
    %transposed to the city that's climatologically most like the whether the anomalous city has just been experiencing
    %(restricted to cities on the same side of the Continental Divide)
%i.e. it creates a map with several vectors pointing more or less north and south 
%Can only be run if previous loop has been, and if monthiwf=monthiwl (single month only)
%Exclude Alaska from this analysis since the only large city there is Anchorage
%PROBLEM IS THAT DATA IS TOO COARSE TO RESOLVE IMPORTANT CITY-BY-CITY DIFFERENCES
%MAYBE EASILY GET STATION DATA OR NARR?
if makemapcitiestransposed==1
    if ~monthiwf==monthiwl
        disp('Please run this loop for a single month only');return;
    end
    [pct1,loc1]=max(uscitiesdiscomfpercs); %most anomalously uncomfortable city
    if loc1==7;uscitiesdiscomfpercs(loc1)=1000;[pct1,loc1]=max(uscitiesdiscomfpercs);end %disallow Anchorage
    [pct2,loc2]=min(uscitiesdiscomfpercs); %most anomalously comfortable city
    if loc2==7;uscitiesdiscomfpercs(loc2)=1000;[pct2,loc2]=min(uscitiesdiscomfpercs);end %disallow Anchorage
    
    mostanomuncomfcityavgT=uscitiesavgT(loc1);
    mostanomcomfcityavgT=uscitiesavgT(loc2);
    
    %Find closest match among avg T of all cities for this month
    temp=load(strcat(savingDir,'discomfscoreandTcitiesclimo',...
        num2str(climoyearstart),'-',num2str(monthiwf),'to',num2str(climoyearstop),'-',num2str(monthiwl),'.mat'));
    citiesavgTclimo=temp.citiesavgT;
    
    mindiffanomuncomf=1000;mindiffanomcomf=1000;
    for i=1:size(uscitiesdiscomfscores,1)
        thisdiffanomuncomf=abs(mostanomuncomfcityavgT-citiesavgTclimo(i));
        if thisdiffanomuncomf<mindiffanomuncomf && i~=loc1
            mindiffanomuncomf=thisdiffanomuncomf;mindiffanomuncomfcity=i;
        end
        thisdiffanomcomf=abs(mostanomcomfcityavgT-citiesavgTclimo(i));
        if thisdiffanomcomf<mindiffanomcomf && i~=loc2
            mindiffanomcomf=thisdiffanomcomf;mindiffanomcomfcity=i;
        end
    end
    
    latuncomfcityfrom=loclats(loc1);lonuncomfcityfrom=loclons(loc1);
    latuncomfcityto=loclats(mindiffanomuncomfcity);lonuncomfcityto=loclons(mindiffanomuncomfcity);
    latcomfcityfrom=loclats(loc2);loncomfcityfrom=loclons(loc2);
    latcomfcityto=loclats(mindiffanomcomfcity);loncomfcityto=loclons(mindiffanomcomfcity);
    
    plotBlankMap(figc,'usa');figc=figc+1;
    curpart=1;highqualityfiguresetup;
    
    color=colors('red');
    h=geoshow(latuncomfcityfrom,lonuncomfcityfrom,'DisplayType','Point','Marker','s',...
        'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',15);hold on;
    h=geoshow(latuncomfcityto,lonuncomfcityto,'DisplayType','Point','Marker','o',...
        'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',15);
    geoshow([latuncomfcityfrom,latuncomfcityto],[lonuncomfcityfrom,lonuncomfcityto],...
        'DisplayType','line','color','k','linewidth',3);
    waypoints=[latuncomfcityfrom,lonuncomfcityfrom;latuncomfcityto,lonuncomfcityto];
    [temp1,temp2]=mfwdtran(waypoints(:,1),waypoints(:,2));
    arrow([temp1(1:(end-1)) temp2(1:(end-1))],[temp1(2:end) temp2(2:end)],'TipAngle',25);
    color=colors('blue');
    h=geoshow(latcomfcityfrom,loncomfcityfrom,'DisplayType','Point','Marker','s',...
        'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',15);
    h=geoshow(latcomfcityto,loncomfcityto,'DisplayType','Point','Marker','o',...
        'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',15);
    waypoints=[latcomfcityfrom,loncomfcityfrom;latcomfcityto,loncomfcityto];
    [temp1,temp2]=mfwdtran(waypoints(:,1),waypoints(:,2));
    arrow([temp1(1:(end-1)) temp2(1:(end-1))],[temp1(2:end) temp2(2:end)],'TipAngle',25);
    %colorbarc=2;titlec=7;
    %edamultipurposelegendcreator;
    curpart=2;figloc=savingDir;
    figname=strcat('mapcitiestransposed',num2str(yeariwl),num2str(monthiwf),'-',num2str(monthiwl));
    highqualityfiguresetup;
end


%Make multiple plots (the bones of videos) of such things as 
if plotclimovideos==1
    %I. Plot the climatological top 10 most-comfortable cities for each month
    if climotop10eachmonth==1
        citylats=zeros(12,10);citylons=zeros(12,10);figc=1;
        for month=1:12
            if month<=6
                filetouse=load(strcat(savingDir,'mostcomfanduncomfcities1979-',...
                    num2str(month),'to2016-',num2str(month),'.mat'));
            else
                filetouse=load(strcat(savingDir,'mostcomfanduncomfcities1979-',...
                    num2str(month),'to2015-',num2str(month),'.mat'));
            end
            mostcomfnamesthismonth=filetouse.mostcomfortablenames;
            mostuncomfnamesthismonth=filetouse.mostuncomfortablenames;
            data=load('discomfortindicesncepgridpts.mat');
            locnames=data.locnames;loclats=data.loclats;loclons=data.loclons;
            for comfort=1:1
                if comfort==1
                    mostnamesthismonth=mostcomfnamesthismonth;comfortword='Comfortable';
                else
                    mostnamesthismonth=mostuncomfnamesthismonth;comfortword='Uncomfortable';
                end
                %Get lat & lon of each city
                %This requires first finding the city in the locnames array already used
                %Start with comparing first 3 letters, looking at more only if necessary
                for i=1:10
                    n=3;nothingfoundyet=1;
                    tf=strncmpi(mostnamesthismonth{i}(1:n),locnames,3);
                    if sum(tf)==1 %this means we've found a unique match in the list of city names
                        [~,b]=max(tf); %city we're looking for in at row b of locnames
                        citylats(month,i)=loclats(b);
                        citylons(month,i)=loclons(b);
                        nothingfoundyet=0;
                    else %two cities start with the same three letters -- we must go deeper
                        while nothingfoundyet==1
                            n=n+1;
                            tf=strncmpi(mostnamesthismonth{i}(1:n),locnames,n);
                            if sum(tf)==1
                                [~,b]=max(tf); %city we're looking for in at row b of locnames
                                citylats(month,i)=loclats(b);
                                citylons(month,i)=loclons(b);
                                nothingfoundyet=0;
                            end
                        end
                    end  
                end
                %Plot these cities & title the plot according to the month it represents
                figure(figc);clf;plotBlankMap(figc,'usa-exp');figc=figc+1;
                curpart=1;highqualityfiguresetup;
                for i=1:10
                    h=geoshow(citylats(month,i),citylons(month,i),'DisplayType','Point','Marker','s',...
                    'MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',11);hold on;
                end
                %Also plot the cities' centroid
                citylatscontigusonly=(citylats>22 & citylats<50);
                citylatscontigusonly=citylatscontigusonly.*citylats;
                citylonscontigusonly=(citylons>-130);
                citylonscontigusonly=citylonscontigusonly.*citylons;
                clatctm=citylatscontigusonly(month,:); %citylatscontigusthismonth
                clonctm=citylonscontigusonly(month,:); %citylonscontigusthismonth
                centroidlat=mean(clatctm(clatctm~=0));centroidlon=mean(clonctm(clonctm~=0));
                h=geoshow(centroidlat,centroidlon,'DisplayType','Point','Marker','o',...
                    'MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',15);
                title(sprintf('%s 10 Most %s Contiguous-US Cities, with their Centroid',...
                    monthnames{month},comfortword),...
                    'FontName','Arial','FontSize',20,'FontWeight','bold');
                %Save result
                curpart=2;figloc=savingDir;figname=strcat(comfortword,'cities',num2str(month));
                highqualityfiguresetup;
            end
        end
    end
    
    %II. Plot the top 10 most comfortable cities in a given season for each year
    %Spring is season 1, summer 2, autumn 3, winter 4
    if top10mostcomfeachyear==1
        for season=2:4
            if season==1
                monthstart=3;monthstop=5;seasonname='Spring';yearstart=1979;yearstop=2016;
            elseif season==2
                monthstart=6;monthstop=8;seasonname='Summer';yearstart=1979;yearstop=2015;
            elseif season==3
                monthstart=9;monthstop=11;seasonname='Autumn';yearstart=1979;yearstop=2015;
            elseif season==4
                monthstart=1;monthstop=2;seasonname='Winter';yearstart=1979;yearstop=2016;
            end
            numyears=yearstop-yearstart+1;
            data=load(strcat(savingDir,'discomfscorematrix',num2str(yearstart),'-',num2str(monthstart),...
                'to',num2str(yearstop),'-',num2str(monthstop)));
            discomfscorets=data.discomfscorets;
            for year=1:numyears
                for i=1:size(results,2)
                    %For each city, discomfort score is the weighted average of the 
                    %discomfort scores of the 3 gridpts closest to it
                    if results{i}(3,1)>0 && results{i}(3,2)>0
                        citiesdiscomfscoretrend(i,year,season)=discomfscorets(results{i}(1,1),results{i}(1,2),year)*results{i}(1,3)+...
                            discomfscorets(results{i}(2,1),results{i}(2,2),year)*results{i}(2,3)+...
                            discomfscorets(results{i}(3,1),results{i}(3,2),year)*results{i}(3,3);
                    else %only two valid gridpts were found for this city
                        citiesdiscomfscoretrend(i,year,season)=discomfscorets(results{i}(1,1),results{i}(1,2),year)*results{i}(1,3)+...
                            discomfscorets(results{i}(2,1),results{i}(2,2),year)*results{i}(2,3);
                    end
                end
                %For each year, find the 10 most comfortable cities
                vec=[1:size(results,2)]';
                combovec=[citiesdiscomfscoretrend(:,year,season) vec];
                combovecsorted=sortrows(combovec);
                top10mostcomf=combovecsorted(1:10,2);
                citylatstrend{year,season}=loclats(top10mostcomf);
                citylonstrend{year,season}=loclons(top10mostcomf);
                %Plot these cities & their centroid, & save the figure, titling according to the year it represents
                %figure(figc);clf;plotBlankMap(figc,'usa-exp');figc=figc+1;
                %curpart=1;highqualityfiguresetup;
                %Only if showing everything (as above)
                %for i=1:10
                %    h=geoshow(citylatstrend(year,i),citylonstrend(year,i),'DisplayType','Point','Marker','s',...
                %    'MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',11);hold on;
                %end
                %Also plot the cities' centroid
                citylatscontigusonly=(citylatstrend{year,season}>22 & citylatstrend{year,season}<50);
                citylatscontigusonly=citylatscontigusonly.*citylatstrend{year,season};
                citylonscontigusonly=(citylonstrend{year,season}>-130);
                citylonscontigusonly=citylonscontigusonly.*citylonstrend{year,season};
                clatctm=citylatscontigusonly(:); %citylatscontigusthismonth
                clonctm=citylonscontigusonly(:); %citylonscontigusthismonth
                centroidlat(year,season)=mean(clatctm(clatctm~=0));centroidlon(year,season)=mean(clonctm(clonctm~=0));
                %h=geoshow(centroidlat(year),centroidlon(year),'DisplayType','Point','Marker','o',...
                %    'MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',15);
                %title(sprintf('10 Most Comfortable Contiguous-US Cities, with their Centroid: %s %d',...
                %    season,year+yearstart-1),'FontName','Arial','FontSize',20,'FontWeight','bold');
                %Save result
                %curpart=2;figloc=savingDir;figname=strcat('Comfortablecitiesbyyear',season);
                %highqualityfiguresetup;
            end
            %Plot 5-year-average centroids
            fiveyearperiodc=1;
            for year=1:5:numyears-4
                fiveyearavgcentroidlat(fiveyearperiodc,season)=mean(centroidlat(year:year+4,season));
                fiveyearavgcentroidlon(fiveyearperiodc,season)=mean(centroidlon(year:year+4,season));
                fiveyearperiodc=fiveyearperiodc+1;
            end

            for i=1:fiveyearperiodc-1
                figure(figc);clf;plotBlankMap(figc,'usa-exp');figc=figc+1;
                curpart=1;highqualityfiguresetup;
                h=geoshow(fiveyearavgcentroidlat(i,season),fiveyearavgcentroidlon(i,season),'DisplayType','Point','Marker','o',...
                    'MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',15);
                title(sprintf('Centroid of 10 Most Comfortable Contiguous-US Cities: %s %d-%d',...
                    seasonname,yearstart+5*(i-1),yearstart+5*(i-1)+4),...
                    'FontName','Arial','FontSize',20,'FontWeight','bold');
                %Save result
                curpart=2;figloc=savingDir;figname=strcat('ComfortableCentroid',...
                    seasonname,num2str(yearstart+5*(i-1)),'to',num2str(yearstart+5*(i-1)+4));
                highqualityfiguresetup;
            end
        end
        %Plot of the five-year-average centroid latitudes for each season, as a bit of a trend analysis
        fiveyearnames={'1979-1983';'1984-1988';'1989-1993';'1994-1998';'1999-2003';'2004-2008';'2009-2013'};
        figure(figc);clf;figc=figc+1;
        subplot(2,2,1);plot(fiveyearavgcentroidlat(:,1),'k','LineWidth',2);legend('Spring','Location','Northwest');
        curylim=ylim;ylimrange=curylim(2)-curylim(1);ylim([curylim(1) curylim(2)]);set(gca,'XTickLabel',[]);
        for i=1:7;text(i-0.5,curylim(1)-ylimrange/10,fiveyearnames{i},'FontSize',12,'FontWeight','bold','FontName','Arial');end
        set(gca,'FontSize',12,'FontWeight','bold','FontName','Arial');
        text(2,33.65,'Centroid of 10 Most Comfortable Contiguous-US Cities 1979-2015, by Season',...
            'FontName','Arial','FontSize',20,'FontWeight','bold');
        
        subplot(2,2,2);plot(fiveyearavgcentroidlat(:,2),'r','LineWidth',2);legend('Summer','Location','Northwest');
        curylim=ylim;ylimrange=curylim(2)-curylim(1);ylim([curylim(1) curylim(2)]);set(gca,'XTickLabel',[]);
        for i=1:7;text(i-0.5,curylim(1)-ylimrange/10,fiveyearnames{i},'FontSize',12,'FontWeight','bold','FontName','Arial');end
        set(gca,'FontSize',12,'FontWeight','bold','FontName','Arial');
        
        subplot(2,2,3);plot(fiveyearavgcentroidlat(:,3),'b','LineWidth',2);legend('Autumn','Location','Northwest');
        curylim=ylim;ylimrange=curylim(2)-curylim(1);ylim([curylim(1) curylim(2)]);set(gca,'XTickLabel',[]);
        for i=1:7;text(i-0.5,curylim(1)-ylimrange/10,fiveyearnames{i},'FontSize',12,'FontWeight','bold','FontName','Arial');end
        set(gca,'FontSize',12,'FontWeight','bold','FontName','Arial');
        
        subplot(2,2,4);plot(fiveyearavgcentroidlat(:,4),'g','LineWidth',2);legend('Winter','Location','Northwest');
        curylim=ylim;ylimrange=curylim(2)-curylim(1);ylim([curylim(1) curylim(2)]);set(gca,'XTickLabel',[]);
        for i=1:7;text(i-0.5,curylim(1)-ylimrange/10,fiveyearnames{i},'FontSize',12,'FontWeight','bold','FontName','Arial');end
        set(gca,'FontSize',12,'FontWeight','bold','FontName','Arial');
        
        figloc=savingDir;figname='seasontrendcentroidlats';print(strcat(figloc,figname),'-dpng','-r300');
    end
    
    %III. Plot the optimal date for every city (in the 2nd half of the year), color-coded
    if optimaldateseachcity==1
        for month=1:12
            if month<=6
                thismonthfile=load(strcat(savingDir,'discomfscorecities1979-',num2str(month),...
                    'to2016-',num2str(month),'.mat'));
            else
                thismonthfile=load(strcat(savingDir,'discomfscorecities1979-',num2str(month),...
                    'to2015-',num2str(month),'.mat'));
            end
            uscitiesdiscomfscores(:,month)=thismonthfile.citiesdiscomfscores;
        end
        %Now that all of the necessary data has been read in, find minimum in 2nd half of year
        for month=7:12
            for city=1:size(uscitiesdiscomfscores,1)
                [a,b]=min(uscitiesdiscomfscores(city,:)); %b is month of min.
                %Now, determine whether optimum is early or late in month by which adjoining month's
                %discomfort score is lower
                optimummontheachcity(city,1)=b;
                if b~=1 && b~=12
                    prevmondiscomfscore=uscitiesdiscomfscores(city,b-1);
                    nextmondiscomfscore=uscitiesdiscomfscores(city,b+1);
                    if prevmondiscomfscore<nextmondiscomfscore %optimum is early in the bth month
                        optimummontheachcity(city,2)=b-1;
                    else %optimum is late in the bth month
                        optimummontheachcity(city,2)=b+1;
                    end
                end
            end
        end
        %Plot each city's optimum, color-coded
        figure(figc);clf;plotBlankMap(figc,'usa-exp');figc=figc+1;
        curpart=1;highqualityfiguresetup;
        for city=1:size(uscitiesdiscomfscores,1)
            if optimummontheachcity(city,1)<=3 || optimummontheachcity(city,1)==12 ||...
                    (optimummontheachcity(city,1)==11 && optimummontheachcity(city,2)==12)
                color=colors('red');
            elseif (optimummontheachcity(city,1)==11 && optimummontheachcity(city,2)==10) ||...
                   (optimummontheachcity(city,1)==4 && optimummontheachcity(city,2)==3)
                color=colors('light red');
            elseif (optimummontheachcity(city,1)==10 && optimummontheachcity(city,2)==11) ||...
                   (optimummontheachcity(city,1)==4 && optimummontheachcity(city,2)==5)
                color=colors('orange');
            elseif (optimummontheachcity(city,1)==10 && optimummontheachcity(city,2)==9) ||...
                   (optimummontheachcity(city,1)==5 && optimummontheachcity(city,2)==4)
                color=colors('light green');
            elseif (optimummontheachcity(city,1)==9 && optimummontheachcity(city,2)==10) ||...
                   (optimummontheachcity(city,1)==5 && optimummontheachcity(city,2)==6)
                color=colors('green');
            elseif (optimummontheachcity(city,1)==9 && optimummontheachcity(city,2)==8) ||...
                   (optimummontheachcity(city,1)==6 && optimummontheachcity(city,2)==5)
                color=colors('dark green');
            elseif (optimummontheachcity(city,1)==8 && optimummontheachcity(city,2)==9) ||...
                   (optimummontheachcity(city,1)==6 && optimummontheachcity(city,2)==7)
                color=colors('light blue');
            elseif (optimummontheachcity(city,1)==8 && optimummontheachcity(city,2)==7) ||...
                   (optimummontheachcity(city,1)==7 && optimummontheachcity(city,2)==6)
                color=colors('blue');
            elseif optimummontheachcity(city,1)==7
                color=colors('violet');
            end
            h=geoshow(loclats(city),loclons(city),'DisplayType','Point','Marker','s',...
            'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',11);hold on;
        end
    end
end


%Best time of year to visit each gridcell, calculated for the whole globe
if besttimetovisiteachgridcell==1
    lsmask=ncread('lsmaskncep.nc','land');
    lowestdiscomfscorematrix=10^6.*ones(144,73);
    lowestdiscomfscoremonthlist=zeros(144,73);
    for month=1:12
        thismonthdata=load(strcat('discomfscorematrix1979-',num2str(month),'to2016-',num2str(month),'.mat'));
        discomfscorethismonth=thismonthdata.totaldiscomfscore;
        for i=1:144
            for j=1:73
                if discomfscorethismonth(i,j)<lowestdiscomfscorematrix(i,j)
                    lowestdiscomfscorematrix(i,j)=discomfscorethismonth(i,j);
                    lowestdiscomfscoremonthlist(i,j)=month;
                end
            end
        end
    end
    temp=load('-mat','hgt_1979_01_500_ncep');hgt_1979_01_500_ncep=temp(1).hgt_1979_01_500;
    nceplats=double(hgt_1979_01_500_ncep{1});nceplons=double(hgt_1979_01_500_ncep{2});
    
    figure(figc);figc=figc+1;curpart=1;highqualityfiguresetup;
    data={nceplats;nceplons;double(lowestdiscomfscoremonthlist)};underlaydata=data;
    region='world';datatype='NARR';
    vararginnew={'variable';'generic scalar';'contour';1;'mystepunderlay';1;'plotCountries';1;...
    'underlaycaxismin';1;'underlaycaxismax';12;'datatounderlay';data;...
    'underlayvariable';'generic scalar';'overlaynow';0;'anomavg';'avg';'centered';0};
    plotModelData(data,region,vararginnew,datatype);
    colormap(colormaps('12months','more','not'));colorbar;
    figname='besttimetovisiteachgridcell';
    curpart=2;figloc=savingDir;
    highqualityfiguresetup;
end
