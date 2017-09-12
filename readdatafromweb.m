%Newest stab at reading snowfall data from html tables
%Current runtime: about 45 sec per month

%Because this is not a function, have to manually adjust code based on current month
%Snowfall year defined as Jul 1-Jun 30
curyear=2017;
curmon=5;
mostrecentday=16;
if curmon>=7;prevyear=curyear;else prevyear=curyear-1;end


%List of locations I want to sum snowfall for
locationlist={'british-columbia/cypress-mountain';'british-columbia/mt-washington-alpine-resort';
    'british-columbia/big-white';'british-columbia/whistler-blackcomb';
    'british-columbia/revelstoke-mountain';'british-columbia/mount-seymour';
    'alberta/sunshine-village';'alberta/lake-louise';'alberta/castle-mountain';'alberta/marmot-basin';'alberta/ski-banff-norquay';
    'ontario/blue-mountain';'ontario/mt-st-louis-moonstone';'ontario/hidden-valley';'ontario/mt-pakenham';
    'quebec/le-massif';'quebec/tremblant';'quebec/massif-du-sud';
    'alaska/alyeska-resort';'alaska/eaglecrest-ski-area';'alaska/hilltop-ski-area';
    'washington/alpental';'washington/stevens-pass-resort';'washington/crystal-mountain';'washington/49-degrees-north';
    'washington/white-pass';'washington/bluewood';'washington/mt-baker';'washington/mt-spokane-ski-and-snowboard-park';
    'washington/the-summit-at-snoqualmie';'washington/mission-ridge';
    'oregon/mt-bachelor';'oregon/willamette-pass';'oregon/timberline-lodge';
    'oregon/anthony-lakes-mountain-resort';'oregon/hoodoo-ski-area';'oregon/mt-hood-ski-bowl';
    'california/mammoth-mountain-ski-area';'california/tahoe-donner';'california/squaw-valley-usa';
    'california/sugar-bowl-resort';'california/ski-china-peak';'california/soda-springs';
    'california/homewood-mountain-resort';'california/mount-shasta-board-ski-park';
    'california/heavenly-mountain-resort';'california/kirkwood';'california/bear-valley';'california/snow-summit';
    'california/dodge-ridge';
    'nevada/diamond-peak';'nevada/mt-rose-ski-tahoe';'nevada/las-vegas-ski-and-snowboard-resort';
    'idaho/sun-valley';'idaho/magic-mountain-ski-area';'idaho/pomerelle-mountain-resort';
    'montana/whitefish-mountain-resort';'montana/montana-snowbowl';'montana/lost-trail-powder-mtn';'montana/maverick-mountain';
    'montana/bridger-bowl';
    'wyoming/jackson-hole';'wyoming/grand-targhee-resort';'wyoming/snow-king-resort';'wyoming/white-pine-ski-area';
    'utah/alta-ski-area';'utah/snowbasin';'utah/solitude-mountain-resort';
    'utah/deer-valley-resort';'utah/park-city-mountain-resort';
    'colorado/winter-park-resort';'colorado/aspen-snowmass';'colorado/breckenridge';'colorado/monarch-mountain';
    'colorado/wolf-creek-ski-area';'colorado/silverton-mountain';'colorado/steamboat';'colorado/copper-mountain-resort';
    'colorado/telluride';'colorado/crested-butte-mountain-resort';'colorado/keystone';'colorado/beaver-creek';
    'new-mexico/taos-ski-valley';
    'minnesota/wild-mountain-ski-snowboard-area';'minnesota/welch-village';'minnesota/lutsen-mountains';
    'wisconsin/trollhaugen';'wisconsin/cascade-mountain';
    'michigan/caberfae-peaks-ski-golf-resort';'michigan/nubs-nob-ski-area';'michigan/crystal-mountain';
    'new-york/bristol-mountain';'new-york/hunter-mountain';'new-york/gore-mountain';'new-york/labrador-mt';
    'new-york/kissing-bridge';'new-york/peekn-peak';
    'massachusetts/jiminy-peak';'massachusetts/blandford-ski-area';
    'vermont/smugglers-notch-resort';'vermont/stowe-mountain-resort';'vermont/killington-resort';'vermont/jay-peak';
    'new-hampshire/bretton-woods';'new-hampshire/loon-mountain';
    'maine/sugarloaf';'maine/sunday-river';
    'western-norway/roldal';
    'central-norway/oppdal';
    'eastern-norway/hemsedal';'eastern-norway/hafjell';'eastern-norway/beitostolen';
    'jamtlands-lan/are';
    'pyrenees/piau-engaly';
    'northern-alps/alpe-dhuez';'northern-alps/flaine';'northern-alps/val-thorens';
    'northern-alps/tignes';'northern-alps/chamonix-mont-blanc';'northern-alps/avoriaz';
    'northern-alps/la-clusaz';'northern-alps/les-menuires';'northern-alps/meribel';'northern-alps/les-2-alpes';
    'valais/saas-fee';'valais/crans-montana-aminona';'valais/verbier';'valais/zermatt';
    'central-switzerland/engelberg';
    'bernese-oberland/gstaad-mountain-rides';'bernese-oberland/wengen';
    'graubunden/laax';'graubunden/engadin-st-moritz';'graubunden/davos-klosters';
    'oberbayern/zugspitze';'oberbayern/garmisch-classic-skigebiet';
    'schwarzwald/feldberg-wintersportzentrum';
    'allgau/balderschwang';
    'salzburg/kaprun-kitzsteinhorn';
    'tyrol/soelden';'tyrol/kaunertaler-gletscher';'tyrol/pitztaler-gletscher';'tyrol/st-anton-am-arlberg';
    'tyrol/stubaier-gletscher';'tyrol/hintertuxer-gletscher';
    'suedtirol/solda-sulden';
    'aosta-valley/cervinia-breuil';'aosta-valley/courmayeur';'aosta-valley/pila';
    'trentino/madonna-di-campiglio';'trentino/andalo-fai-della-paganella';'trentino/canazei-belvedere';
    'lombardia/livigno';'lombardia/bormio';
    'veneto/cortina-dampezzo';
    'carinthia/moelltaler-gletscher';
    'low-tatras-north/jasna-nizke-tatry-chopok-sever';
    'krkonose/harrachov'};

%Start the script, summing up spring snowfall first and then going back to
%sum up fall as well

seasonsum={};snowfalldays={};snowfallvalues={};firstdayvec={};
for location=1:size(locationlist,1)
%for location=1:1
    
    thislocsnowfallsum=0;
    %%%%%%First, for the spring%%%%%
    if curmon<=6
        url_string=sprintf('http://www.onthesnow.com/%s/historical-snowfall.html?&y=%d&q=snow&v=list',...
            locationlist{location},curyear);
        strofdata=urlread(url_string);

        temp=strfind(strofdata,strcat('Jan  1'));
        if isempty(temp) %no data listed thus far in year for this location
            thislocsnowfallsum=0;
        else
            firstdayvec{1}=strfind(strofdata,strcat('Jan  1'));firstdayvec{1}=firstdayvec{1}(1); %find table entry for first day of Jan
            if curmon>=2
                firstdayvec{2}=strfind(strofdata,strcat('Feb  1'));firstdayvec{2}=firstdayvec{2}(1); %find table entry for first day of Feb
                if curmon>=3
                    firstdayvec{3}=strfind(strofdata,'Mar  1');firstdayvec{3}=firstdayvec{3}(1); %find table entry for first day of Mar
                    if curmon>=4
                        firstdayvec{4}=strfind(strofdata,'Apr  1');firstdayvec{4}=firstdayvec{4}(1); %find table entry for first day of Apr
                        if curmon>=5
                            firstdayvec{5}=strfind(strofdata,'May  1');firstdayvec{5}=firstdayvec{5}(1); %find table entry for first day of May
                        end
                    end
                end
            end

            %Find last entry of current (possibly incomplete) month
            phr=sprintf('%d, %d',mostrecentday,curyear);
            lastentry=strfind(strofdata,phr);lastentry=lastentry(size(lastentry,2));
            firstdayvec{curmon+1}=lastentry+100;

            %Now we know e.g. all Jan snowfall data is somewhere in strofdata between elements
            %firstday{1} and firstday{2}
            hint='<span>'; %this comes just before every snowfall measurement

            %Compile snowfall data for each month
            %%%%First, for the spring%%%%%
            for mon=1:curmon
                snowfalldays{mon}=strfind(strofdata(firstdayvec{mon}:firstdayvec{mon+1}),hint); %all the snowfall days for this month
                snowfalldays{mon}=snowfalldays{mon}+firstdayvec{mon}; %readjust so overall strofdata indices are correct
                %disp('line 115');disp(snowfalldays{mon});

                if size(snowfalldays{mon},1)>0 %there are any snowfall obs in this month
                    snowfallvalues{mon}=zeros(size(snowfalldays{mon},2),1);
                    for i=1:size(snowfalldays{mon},2)
                        firstdigit=str2double(strofdata(snowfalldays{mon}(i)+5));
                        seconddigit=str2double(strofdata(snowfalldays{mon}(i)+6)); %only potential
                        thirddigit=str2double(strofdata(snowfalldays{mon}(i)+7)); %only potential (& a 100" snowfall is exceedingly rare)

                        %Simple test to determine how many of those digits are actually real snowfall values 
                        %and not letters, spaces, or punctuation
                        if firstdigit+1>0
                            numdigits=1; %nonzero snowfall
                            if seconddigit+1>0
                                numdigits=2; %double-digit snowfall
                                if thirddigit+1>0
                                    numdigits=3; %triple-digit snowfall
                                end
                            end
                        else %e.g. 'trace'
                            numdigits=0;
                        end

                        %Reconstruct the snowfall value for this day
                        if numdigits==1
                            snowfallvalues{mon}(i)=firstdigit;
                        elseif numdigits==2
                            snowfallvalues{mon}(i)=firstdigit*10+seconddigit;
                        elseif numdigits==3
                            snowfallvalues{mon}(i)=firstdigit*100+seconddigit*10+thirddigit;
                        else
                            snowfallvalues{mon}(i)=0;
                        end
                        %disp('line 141');disp(snowfallvalues{mon}(i));
                    end
                    thislocsnowfallsum=thislocsnowfallsum+nansum(snowfallvalues{mon});
                    %disp('line 143');disp(mon);disp(thislocsnowfallsum);
                end
            end
            %disp(thislocsnowfallsum);
        end   
    end
    
    
    %%%%%%Second, for the fall%%%%%
    url_string=sprintf('http://www.onthesnow.com/%s/historical-snowfall.html?&y=%d&q=snow&v=list',...
        locationlist{location},prevyear);
    strofdata=urlread(url_string);
    
    if curmon<=6 %i.e. spring
        curmonfall=12;
    else
        curmonfall=curmon;
    end
    
    montostartat=9;
    
    somethingfound=0;
    if somethingfound==0 || curmonfall>=9
        firstdayvec{9}=strfind(strofdata,'title="Sep');
        if isempty(firstdayvec{9}) %no Sep entries listed
            montostartat=10;somethingfound=0;
        else
            firstdayvec{9}=firstdayvec{9}(1);somethingfound=1;
        end
        %disp('line 177');
    end
    %if somethingfound==0 || curmonfall==10
    if curmonfall>=10
        firstdayvec{10}=strfind(strofdata,'title="Oct');
        if isempty(firstdayvec{10}) && montostartat==11 %no Oct entries
            montostartat=11;somethingfound=0;
        else
            somethingfound=1;
            firstdayvec{10}=firstdayvec{10}(1);
        end
        %disp('line 187');
    end
    if curmonfall>=11
        firstdayvec{11}=strfind(strofdata,'title="Nov');
        if isempty(firstdayvec{11}) && montostartat==12 %no Nov entries
            montostartat=12;somethingfound=0;
        else
            somethingfound=1;
            firstdayvec{11}=firstdayvec{11}(1);
        end
        %disp('line 197');
    end
    if curmonfall>=12
        firstdayvec{12}=strfind(strofdata,'title="Dec');
        if isempty(firstdayvec{12}) %no Dec entries
            montostartat=1;somethingfound=0;
        else
            somethingfound=1;
            firstdayvec{12}=firstdayvec{12}(1);
        end
        %disp('line 207');
    end
    
    %disp(montostartat);
    

    
    
    %Find first table entry for each month
    if ~isempty(firstdayvec{9});firstdayvec{9}=firstdayvec{9}(1);end
    if size(firstdayvec,2)>=10
        if ~isempty(firstdayvec{10})
            firstdayvec{10}=firstdayvec{10}(1);
        end
    end
    if size(firstdayvec,2)>=11
        if ~isempty(firstdayvec{11})
            firstdayvec{11}=firstdayvec{11}(1);
        end
    end
    if size(firstdayvec,2)>=12
        if ~isempty(firstdayvec{12})
            firstdayvec{12}=firstdayvec{12}(1);
        end
    end

    %Find last entry of current (possibly incomplete) month
    phr=sprintf('%d, %d',mostrecentday,prevyear);
    lastentry=strfind(strofdata,phr);lastentry=lastentry(size(lastentry,2));
    if curmonfall==12
        firstdayvec{1}=lastentry+100;
    else
        firstdayvec{curmonfall+1}=lastentry+100;
    end

    %Now we know e.g. all Nov snowfall data is somewhere in strofdata between elements
    %firstday{11} and firstday{12}
    hint='<span>'; %this comes just before every snowfall measurement

    %Compile snowfall data for each month
    for mon=montostartat:curmonfall
        if mon~=12
            snowfalldays{mon}=strfind(strofdata(firstdayvec{mon}:firstdayvec{mon+1}),hint); %all the snowfall days this month
        else
            snowfalldays{mon}=strfind(strofdata(firstdayvec{mon}:firstdayvec{12}+3000),hint); %to be sure to include data at the tail end of Dec
        end
        snowfalldays{mon}=snowfalldays{mon}+firstdayvec{mon}(1); %re-adjust so overall strofdata indices are correct
        %disp('line 176');disp(mon);disp(snowfalldays{mon});
        
        if size(snowfalldays{mon},1)>0 %there are any snowfall obs in this month
            snowfallvalues{mon}=zeros(size(snowfalldays{mon},2),1);
            for i=1:size(snowfalldays{mon},2)
                firstdigit=str2double(strofdata(snowfalldays{mon}(i)+5));
                seconddigit=str2double(strofdata(snowfalldays{mon}(i)+6)); %only potential
                thirddigit=str2double(strofdata(snowfalldays{mon}(i)+7)); %only potential (& a 100" snowfall is exceedingly rare)

                %Simple test to determine how many of those digits are actually real snowfall values 
                %and not letters, spaces, or punctuation
                if firstdigit+1>0
                    numdigits=1; %nonzero snowfall
                    if seconddigit+1>0
                        numdigits=2; %double-digit snowfall
                        if thirddigit+1>0
                            numdigits=3; %triple-digit snowfall
                        end
                    end
                else %perhaps the snowfall measurement is 'Trace'
                    numdigits=0;
                end

                %Reconstruct the snowfall value for this day
                if numdigits==1
                    snowfallvalues{mon}(i)=firstdigit;
                elseif numdigits==2
                    snowfallvalues{mon}(i)=firstdigit*10+seconddigit;
                elseif numdigits==3
                    snowfallvalues{mon}(i)=firstdigit*100+seconddigit*10+thirddigit;
                else
                    snowfallvalues{mon}(i)=0;
                end
            end
            thislocsnowfallsum=thislocsnowfallsum+nansum(snowfallvalues{mon});
            %if rem(location,10)==0;fprintf('Mon is %d\n',mon);fprintf('Current snowfall sum is %d\n',thislocsnowfallsum);end
        end
    end
    
    
    
    %Sum up snowfall values for this location across the entire winter season
    seasonsum{location,1}=thislocsnowfallsum;
    seasonsum{location,2}=locationlist{location};
end

%Sort and show the world!
[trash,idx]=sort([seasonsum{:,1}],'descend');
seasonsumsorted=seasonsum(idx,:);
disp(seasonsumsorted);
