%Reads in snow-cover data, calculates integrated values over the year, and
%computes spatial correlation of these with ENSO indices

%Current runtime:
%for reading in data, 9 min
%for adjustments, <1 min
%for correlation, 1 min

%Runtime options
readindata=1;
docorrelmaps=1;
startyear=1979;stopyear=2014;

curDir='/Users/colin/Desktop/General_Academics/Website/Recent_Weather';
validjanc=0;validfebc=0;validmarc=0;validaprc=0;validmayc=0;validjunc=0;validjulc=0;validaugc=0;
validsepc=0;validoctc=0;validnovc=0;validdecc=0;
varlist={'snowc'};variab=1;totalsnowcbyyear={};

%ENSO monthly index values, 7/1950 to 7/2015
ensofull=load('indicesmonthlyenso.txt','r');
enso=ensofull(349:780,:); %1/1979 to 12/2014
%cols are nino1+2;nino3;nino4;nino3.4,
%where each region's values (unnormalized) are followed by its monthly anomaly

%totalsnowcbyyear-sums for calendar years, 1979-2014
%totalsnowcbywinter-sums for winters, 1979-80 to 2013-14
numyears=stopyear-startyear+1;numwinters=numyears-1;



%Read in data and define main vectors
if readindata==1
    disp(clock);winter=0;
    for year=startyear:stopyear
        narrryear=year-startyear+1;
        for mon=1:12
            count=1;totalbymonth=0;curArrDaily={};
            if mon==6;validjunc=validjunc+1;monlen=30;elseif mon==7;validjulc=validjulc+1;monlen=31;
            elseif mon==8;validaugc=validaugc+1;monlen=31;elseif mon==1;validjanc=validjanc+1;monlen=31;
            elseif mon==2 && rem(year,4)==0;validfebc=validfebc+1;monlen=29;
            elseif mon==2;validfebc=validfebc+1;monlen=28;elseif mon==3;validmarc=validmarc+1;monlen=31;
            elseif mon==4;validaprc=validaprc+1;monlen=30;elseif mon==5;validmayc=validmayc+1;monlen=31;
            elseif mon==9;validsepc=validsepc+1;monlen=30;elseif mon==10;validoctc=validoctc+1;monlen=31;
            elseif mon==11;validnovc=validnovc+1;monlen=30;elseif mon==12;validdecc=validdecc+1;monlen=31;
            end
            %Actually read in data
            fprintf('Current year and month are %d, %d\n',year,mon);
            %disp(narrryear);disp(winter);
            if mon<=9
                curFile=load(char(strcat(curDir,'/',varlist(variab),'/',...
                    num2str(year),'/',varlist(variab),'_',num2str(year),...
                '_0',num2str(mon),'_01.mat')));
                lastpart=char(strcat(varlist(variab),'_',num2str(year),'_0',num2str(mon),'_01'));
            else 
                curFile=load(char(strcat(curDir,'/',varlist(variab),'/',...
                    num2str(year),'/',varlist(variab),'_',num2str(year),...
                '_',num2str(mon),'_01.mat')));
                lastpart=char(strcat(varlist(variab),'_',num2str(year),'_',num2str(mon),'_01'));
            end
            curArr=eval(['curFile.' lastpart]);curArr{3}=curArr{3};

            %Convert NaN's to zeros so that summation can take place properly
            tempflip=curArr{3};
            tempflip(isnan(tempflip))=0;
            curArr{3}=tempflip;

            curArrDaily{1}=curArr{1};curArrDaily{2}=curArr{2};
            for i=1:8:monlen*8 %to get daily set, keep only first of the 8 3-hourly values for each day
                curArrDaily{3}(:,:,count)=curArr{3}(:,:,i);
                count=count+1;
            end

            totalbymonth=totalbymonth+sum(curArrDaily{3}(:,:,:),3); %sum over all the days of the month
            %disp(max(max(totalbymonth)));
            totalsnowcbymon{narrryear,mon}=totalbymonth;
            if mon==1
                totalsnowcbyyear{narrryear}=totalsnowcbymon{narrryear,mon};
            else
                totalsnowcbyyear{narrryear}=totalsnowcbyyear{narrryear}+totalsnowcbymon{narrryear,mon};
            end
            if mon==7
                winter=winter+1;
                totalsnowcbywinter{winter}=totalsnowcbymon{narrryear,mon};
            else
                if winter>=1 && winter<=numwinters %i.e. not Jan-June 1979 or Jul-Dec 2014
                    totalsnowcbywinter{winter}=totalsnowcbywinter{winter}+totalsnowcbymon{narrryear,mon};
                    if winter==1
                        totalsnowcallwinters=totalsnowcbywinter{winter};
                    else
                        totalsnowcallwinters=totalsnowcallwinters+totalsnowcbywinter{winter};
                    end
                end
            end
        end
    end
    disp(clock);

    %Convert sums to fractional coverages for each year/winter
    for year=1:numyears
        if rem(year,4)==2 %leap year since e.g. year 2 is 1980
            pctsnowcbyyear{year}=totalsnowcbyyear{year}/366;
        else
            pctsnowcbyyear{year}=totalsnowcbyyear{year}/365;
        end
        pctsnowcbyyear{year}=flipud(pctsnowcbyyear{year});
    end
    for winter=1:numwinters
        if rem(winter,4)==1 %leap year since e.g. winter 1 is 1979-1980
            pctsnowcbywinter{winter}=totalsnowcbywinter{winter}/366;
        else
            pctsnowcbywinter{winter}=totalsnowcbywinter{winter}/365;
        end
        pctsnowcbywinterflip{winter}=flipud(pctsnowcbywinter{winter});
    end

end



%Do point-by-point correlation between integrated snow cover and JAS/SON/NDJ/JFM ENSO,
%and put *this* into a mappable matrix as well
if docorrelmaps==1
    for ensoregion=1:4 %1:4 are 1+2;3;4;3.4
        for monthset=1:3 %1:3 are JAS; SON; NDJ
            startmon=monthset*2+4;stopmon=monthset*2+6;
            col=(ensoregion+1)*2;
            enso=ensofull(:,col);count=1;
            ensomonthsavg=0;
            
            ensoregions={'Nino 1+2';'Nino 3';'Nino 4';'Nino 3.4'};
            ensoseasons={'JAS';'SON';'NDJ';'JFM'};

            for i=1:12:size(enso,1)-11
                ensomonthsavg(count)=mean(enso(i+startmon:i+stopmon)); %i.e. Jul-Sep
                count=count+1;
            end
            %ensojasavg=ensojasavg';
            ensomonthsavg=ensomonthsavg(1:numwinters)'; %1979-2013 (i.e. fall before each winter)
            %Correlation!!
            tempflip=0;temp=0;corrmatrixflip=zeros(277,349);corrmatrix=zeros(277,349);
            for i=1:277
                for j=1:349
                    %Get years' values at this point into a single vector
                    for winter=1:numwinters
                        tempflip(winter)=pctsnowcbywinterflip{winter}(i,j); %flipped with N at top
                        temp(winter)=pctsnowcbywinter{winter}(i,j); %unflipped
                    end
                    if size(tempflip,1)==1;tempflip=tempflip';end
                    if size(temp,1)==1;temp=temp';end
                    
                    %if max(temp)>0;disp('line 153');disp(max(temp));end
                    corrmatrixflip(i,j)=corr(squeeze(tempflip),squeeze(ensomonthsavg));
                    corrmatrix(i,j)=corr(squeeze(temp),squeeze(ensomonthsavg));
                end
            end

            %Mask out where <3% of days, on average, have snow cover
            for i=1:277
                for j=1:349
                    if totalsnowcallwinters(i,j)<numwinters*365*3/100
                        corrmatrix(i,j)=NaN;
                    end
                end
            end
            disp(ensoregion);disp(monthset);
            disp(totalsnowcallwinters(250,220));disp(numwinters*365*3/100);
            disp(corrmatrix(250,220));

            %Graph the result in a map that looks nicer than imagesc!!
            lsmask=ncread('land.nc','land')';
            
            data={curArrDaily{1};curArrDaily{2};corrmatrix};region='usa';
            vararginnew={'contour';1;'mystep';0.1;'plotCountries';1;...
            'colormap';'jet';'overlaynow';0};
            plotModelData(data,region,vararginnew);
            title(sprintf('Correlation between Winter-Integrated Snow Depth and %s %s, 1979-2014',...
                char(ensoseasons{monthset}),char(ensoregions{ensoregion})),'FontSize',16,'FontWeight','bold',...
                'FontName','Arial');
        end
    end
end
