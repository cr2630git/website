%Pull data from U.S. stations using ACIS framework

%To display results: 
%for cities, just type 'displaymatrix' at the command line
%for all locations, just type 'dm2sorted' at the command line

runremotely=0;

if runremotely==1
    addpath('/cr/cr2630/Scripts/GeneralPurposeScripts');
end

%Current total runtime for city calculations: about 6 min per month
calccitiessnowfallthisyear=1;
calccitiesavgsnowfalltodate=1;
%Total runtime for all-location calculations: about 1 min per month
calclocssnowfallthisyear=1;

%Set key variables
%Station IDs are those from the Coop naming system
numcities=73;numlocs=293;
seasonstartdate='2016-10-01';
todaysdate='2017-05-22';lastrundate='2017-05-16';


%Metadata for cities 100K+
citysids1=['330058','290234','360106','410211','500280','200230','110338','180465','240807','101022','190770',...
    '050848','060806','301012','138062','111549','151855','331657','051778','231801','331786',...
    '115751','332075','052220','132203','202103','286055','362682','122738','322859','053005','123037',...
    '203333','473269','124259','117457','234358','204641','154746','254795','154954','194313','474961','275211','475479'];
citysids2=['215435','305801','256255','116711','366889','366993','376698','427064','056740',...
    '266779','217004','307167','117382','427598','457473','397667','128187','457938','118179','069704',...
    '237455','308383','338357','148167','448906','068330','148830','199923'];
citylats=[41.04;35.04;40.65;35.23;61.17;42.29;41.78;39.17;45.81;43.57;42.36;39.99;41.16;...
    42.94;41.85;42.00;39.04;41.405;38.81;38.94;39.99;41.47;39.91;39.76;41.53;42.23;...
    40.47;42.08;38.04;46.93;40.61;40.97;42.88;44.48;39.73;41.60;39.30;42.78;38.04;40.85;38.18;42.64;...
    43.14;42.93;42.955;44.88;40.78;41.31;40.67;39.87;40.48;41.72;40.25;38.29;39.48;43.90;...
    43.12;42.19;40.78;47.44;43.58;41.71;47.62;39.84;41.94;38.75;43.11;41.59;39.07;...
    38.85;41.69;37.65;42.27];
citylons=[-81.46;-106.62;-75.45;-101.7;-150.03;-83.71;-88.31;-76.68;-108.54;-116.24;-71.01;-105.27;-73.13;...
-78.74;-91.68;-87.93;-84.67;-81.85;-104.69;-92.32;-82.88;-90.52;-84.22;-104.87;-93.65;-83.33;...
-74.44;-80.18;-87.52;-96.81;-105.13;-85.21;-85.52;-88.14;-86.28;-88.085;-94.73;-84.58;-84.61;-96.75;-85.74;-71.36;...
-89.35;-71.44;-87.90;-93.23;-73.97;-95.90;-89.68;-75.23;-80.21;-71.43;-111.65;-104.50;-119.77;-92.49;...
-77.68;-89.09;-111.97;-122.31;-96.75;-86.32;-117.53;-89.68;-72.68;-90.37;-76.10;-83.80;-95.63;...
-77.03;-73.06;-97.43;-71.87];
cityelevs=[1208;390;120;900;660;156;3581;2814;12;5484;5;716;790;662;869;770;6181;720;810;...
592;1000;5286;957;631;86;730;900;5004;791;803;687;790;640;1005;841;1190;110;866;225;670;...
872;130;982;650;10;1203;60;4570;4720;1304;539;730;4225;370;1428;773;2353;594;190;531;413;...
669;876;10;538;1000];
cityvalidstarts=[1948;1931;1944;1941;1955;1880;1896;1939;1937;1940;1936;1898;1948;1943;1998;1959;1948;...
1941;1955;1997;1948;1955;1948;1955;1939;1959;1968;1926;1948;1942;1955;1939;1964;1889;1943;1992;...
1979;1959;1887;1972;1945;1978;1939;1963;1938;1938;1912;1948;1943;1948;1948;1932;1980;1954;1937;1928;1926;...
1951;1948;1945;1906;1896;1893;1901;1949;1938;1950;1955;1946;1941;2000;1954;1948];
%I have some data going back further, but since values here are coming
%directly from ACIS I can't patch together stations

if calccitiessnowfallthisyear==1
    sumstodate=zeros(numcities,1);sumssincelastrun=zeros(numcities,1);
    for loopnum=1:2
        if loopnum==1;startdate=seasonstartdate;end
        if loopnum==2;startdate=lastrundate;end
        for city=1:numcities
            if city<=45
                currentsid=citysids1((city-1)*6+1:(city-1)*6+6);
            else
                currentsid=citysids2((city-46)*6+1:(city-46)*6+6);
            end
            %disp(currentsid);
            newsid=sprintf('http://data.rcc-acis.org/StnData?sid=%s&sdate=%s&edate=%s&elems=snow&duration=std&smry=sum&season_start=10-01&output=csv',...
                currentsid,startdate,todaysdate);
            monmin=urlread(newsid);
            A=strread(monmin,'%s','delimiter',sprintf('\n')');
            newA=char(A);
            [nr,nc]=size(newA);
            %Parse resultant string (i.e. equivalent of Excel text-to-columns) and
            %convert to numbers from strings
            resultsholder=zeros(nr,1);
            for i=2:nr %because 1st row is station name
                [newstr,matches]=strsplit(newA(i,:),'\s*,\s*','DelimiterType','RegularExpression');
                result=newstr(2);result=char(result);
                modresult=strrep(result,'T','0'); %because traces are not actually summed
                numericresult=str2double(modresult);
                if isnan(numericresult)
                    numericresult=0; %just make missing data zeros on the assumption that they are anyway
                end
                resultsholder(i)=numericresult;
            end

            %And, the pièce de résistance... quick season-to-date summations
            if loopnum==1
                sumtodate=sum(resultsholder);sumstodate(city)=sumtodate;
            elseif loopnum==2
                sumsincelastrun=sum(resultsholder);sumssincelastrun(city)=sumsincelastrun;
            end
        end
    end

    %Put it all together in a new matrix for display
    displaymatrix=cell(numcities,4);
    displaymatrix{1,1}='Akron OH';displaymatrix{2,1}='Albuquerque NM';displaymatrix{3,1}='Allentown PA';
    displaymatrix{4,1}='Amarillo TX';displaymatrix{5,1}='Anchorage AK';displaymatrix{6,1}='Ann Arbor MI';
    displaymatrix{7,1}='Aurora IL';displaymatrix{8,1}='Baltimore MD';displaymatrix{9,1}='Billings MT';
    displaymatrix{10,1}='Boise ID';displaymatrix{11,1}='Boston MA';displaymatrix{12,1}='Boulder CO';
    displaymatrix{13,1}='Bridgeport CT';displaymatrix{14,1}='Buffalo NY';displaymatrix{15,1}='Cedar Rapids IA';
    displaymatrix{16,1}='Chicago IL';displaymatrix{17,1}='Cincinnati OH';displaymatrix{18,1}='Cleveland OH';
    displaymatrix{19,1}='Colorado Springs CO';displaymatrix{20,1}='Columbia MO';displaymatrix{21,1}='Columbus OH';
    displaymatrix{22,1}='Davenport IA';displaymatrix{23,1}='Dayton OH';displaymatrix{24,1}='Denver CO';
    displaymatrix{25,1}='Des Moines IA';displaymatrix{26,1}='Detroit MI';displaymatrix{27,1}='Edison NJ';
    displaymatrix{28,1}='Erie PA';displaymatrix{29,1}='Evansville IN';displaymatrix{30,1}='Fargo ND';
    displaymatrix{31,1}='Fort Collins CO';displaymatrix{32,1}='Fort Wayne IN';displaymatrix{33,1}='Grand Rapids MI';
    displaymatrix{34,1}='Green Bay WI';displaymatrix{35,1}='Indianapolis IN';displaymatrix{36,1}='Joliet IL';
    displaymatrix{37,1}='Kansas City MO';displaymatrix{38,1}='Lansing MI';displaymatrix{39,1}='Lexington KY';
    displaymatrix{40,1}='Lincoln NE';displaymatrix{41,1}='Louisville KY';displaymatrix{42,1}='Lowell MA';
    displaymatrix{43,1}='Madison WI';displaymatrix{44,1}='Manchester NH';displaymatrix{45,1}='Milwaukee WI';
    displaymatrix{46,1}='Minneapolis MN';displaymatrix{47,1}='New York NY';displaymatrix{48,1}='Omaha NE';
    displaymatrix{49,1}='Peoria IL';displaymatrix{50,1}='Philadelphia PA';displaymatrix{51,1}='Pittsburgh PA';
    displaymatrix{52,1}='Providence RI';displaymatrix{53,1}='Provo UT';displaymatrix{54,1}='Pueblo CO';
    displaymatrix{55,1}='Reno NV';displaymatrix{56,1}='Rochester MN';displaymatrix{57,1}='Rochester NY';
    displaymatrix{58,1}='Rockford IL';displaymatrix{59,1}='Salt Lake City UT';displaymatrix{60,1}='Seattle WA';
    displaymatrix{61,1}='Sioux Falls SD';displaymatrix{62,1}='South Bend IN';displaymatrix{63,1}='Spokane WA';
    displaymatrix{64,1}='Springfield IL';displaymatrix{65,1}='Springfield MA';displaymatrix{66,1}='St Louis MO';
    displaymatrix{67,1}='Syracuse NY';displaymatrix{68,1}='Toledo OH';displaymatrix{69,1}='Topeka KS';
    displaymatrix{70,1}='Washington DC';displaymatrix{71,1}='Waterbury CT';displaymatrix{72,1}='Wichita KS';
    displaymatrix{73,1}='Worcester MA';
end

%Calculate average to date for each city
%Valid starting year varies by city
if calccitiesavgsnowfalltodate==1
    sumsbyyear={};
    numvalidyears=zeros(numcities,1);avgsnowfalltodate=zeros(numcities,1);
    for city=1:numcities
        firstyear=cityvalidstarts(city);lastyear=2014;numvalidyears(city)=lastyear-firstyear+1;
        if rem(city,10)==0
            fprintf('Calculating averages for city %d\n',city);
        end
        for year=firstyear:lastyear
            startdate=strcat(num2str(year),'-10-01');
            if str2double(todaysdate(6))==1
                enddate=strcat(num2str(year),todaysdate(5:10));
            elseif str2double(todaysdate(6))==0
                enddate=strcat(num2str(year+1),todaysdate(5:10));
            end
            if city<=45
                currentsid=citysids1((city-1)*6+1:(city-1)*6+6);
            else
                currentsid=citysids2((city-46)*6+1:(city-46)*6+6);
            end
            newsid=sprintf('http://data.rcc-acis.org/StnData?sid=%s&sdate=%s&edate=%s&elems=snow&duration=std&smry=sum&season_start=10-01&output=csv',...
                currentsid,startdate,enddate);
            monmin=urlread(newsid);
            A=strread(monmin,'%s','delimiter',sprintf('\n')');newA=char(A);
            [nr,nc]=size(newA);
            %Parse resultant string (i.e. equivalent of Excel text-to-columns) and
            %convert to numbers from strings
            resultsholder=zeros(nr,1);
            for i=2:nr %because 1st row is station name
                [newstr,matches]=strsplit(newA(i,:),'\s*,\s*','DelimiterType','RegularExpression');
                result=newstr(2);result=char(result);
                modresult=strrep(result,'T','0'); %because traces are not actually summed
                numericresult=str2double(modresult);
                if isnan(numericresult);numericresult=0;end
                resultsholder(i)=numericresult;
            end

            %And, the pièce de résistance... quick season-to-date sums for each year
            sumtodate=sum(resultsholder);
            sumsbyyear{city}(year-firstyear+1)=sumtodate;
        end
        avgsnowfalltodate(city)=sum(sumsbyyear{city})/numvalidyears(city);
    end
end

%Create the display matrix
%First column is city name; second column is snowfall to date;
%third column is % of normal; fourth column is snowfall since last run
if calccitiessnowfallthisyear==1 && calccitiesavgsnowfalltodate==1
    for i=1:numcities
        snowrecordsthiscity=zeros(size(sumsbyyear{i},2),2);
        displaymatrix{i,2}=sumstodate(i);
        %Percent of normal
        percentofnormal(i)=100*sumstodate(i)/avgsnowfalltodate(i);
        displaymatrix{i,3}=percentofnormal(i);
        %Alternatively, percentile
        snowrecordsthiscity(:,1)=sumsbyyear{i}';
        snowrecordsthiscity(:,2)=1:size(sumsbyyear{i},2);
        snowrecordsthiscity(size(sumsbyyear{i},2)+1,1)=sumstodate(i);
        snowrecordsthiscity(size(sumsbyyear{i},2)+1,2)=size(sumsbyyear{i},2)+1;
        srtcsorted=sortrows(snowrecordsthiscity,1);
        [a,b]=max(srtcsorted(:,2)); %inverse rank of this year's snowfall to date (~percentile)
        prctile=100*b/(size(sumsbyyear{i},2)+1);
        %Only adjustment that needs to be made is if snowfall to date is
        %zero, it will always be ranked at the bottom of the zeros because
        %it is the most recent -- so place it in the middle of the zeros instead
        if sumstodate(i)==0
            if srtcsorted(2,1)==0 %i.e. there's more than one zero year (if not, this year is indeed a record low)
                b=round(b/2);prctile=100*b/(size(sumsbyyear{i},2)+1);
            end
        end
        %Translate from percentiles into groups, where
        %1--record high, 2--2nd-4th highest, 3--above avg (0.67+), 4--near avg (0.33-0.67),
        %5--below avg (0.33-), 6--2nd-4th lowest, 7--record low
        if prctile==100
            group=1;
        elseif b>=size(sumsbyyear{i},2)+1-3
            group=2;
        elseif prctile>=66.6
            group=3;
        elseif prctile>=33.3
            group=4;
        elseif b>=5
            group=5;
        elseif b>=2
            group=6;
        else
            group=7;
        end
        displaymatrix{i,3}=group;
        displaymatrix{i,4}=sumssincelastrun(i);
    end

    %Show the world!
    disp(displaymatrix);
end



%Snowfall calculation among stations that are candidates for the snowiest
%in the country -- in alphabetical order within the original list and the
%addendum

%First, the metadata for possible snowiest stations
alllocids={'200050';'300093';'500235';'500237';'420061';'480140';'420072';'500243';'290407';'500352';...
    '300317';'200497';'500546';'480603';'300608';'200710';'200718';'270690';'500754';'500761';...
    '200758';'200771';'040741';'040931';'480865';'101079';'450844';'041018';'050909';'041072';...
    '021001';'421008';'301012';'051186';'291389';'501240';'501251';'423046';'171175';'101514';...
    '421260';'291630';'291664';'191318';'041700';'501684';'501926';'501987';'051660';'502102';...
    '301625';'271647';'502177';'502227';'051948';'051959';'262119';'422057';'102577';'502568';...
    '502587';'292700';'502642';'452384';'052790';'502968';'303025';'172878';'303087';'503212';...
    '243378';'293488';'053261';'503275';'503294';'503299';'263205';'503304';'353402';'023582';...
    '053496';'173261';'053530';'043551';'203421';'043669';'473332';'503475';'503502';'303590';...
    '203585';'043891';'203744';'303851';'453730';'503672';'303961';'473800';'044211';'124244';...
    '204104';'434120';'484910';'304207';'274329';'434261';'504092';'354403';'504621';'504988';...
    '505076';'485355';'274556';'124837';'105177';'044881';'354835';'194131';'304808';'245080';...
    '045026';'045280';'425402';'045311';'355221';'455133';'105708';'505757';'505769';'045679';...
    '505894';'486428';'486440';'455659';'045933';'435416';'275639';'245961';'106388';'506496';...
    '506586';'356252';'486845';'056205';'046597';'056258';'487031';'306376';'426644';'507141';...
    '306525';'206583';'276818';'046961';'507513';'507738';'306745';'306867';'456858';'047195';...
    '456898';'246918';'297323';'177238';'436995';'427686';'357554';'207364';'207407';'508375';...
    '427846';'307749';'508525';'048273';'488315';'508584';'048762';'207891';'058064';'438169';...
    '108937';'048760';'509014';'509314';'358536';'428771';'178792';'049298';'308910';'308962';...
    '208706';'049490';'208774';'248858';'509793';'059175';'509869';'509941';'109950';'489905';...
    '048380';'COPK0005';'MTDL0001';'AKAB0028';'ORJS0018';'050372';'COJF0276';'200361';'450456';'050754';...
    'COGL0010';'COSU0040';'481220';'041277';'351546';'051713';'NYER0077';'COJF0222';'COGN0018';'052294';...
    'CASK0010';'WYFM0004';'NYER0050';'COCC0005';'CASK0004';'AKFN0013';'COPK0015';'202804';'CASK0009';'463251';...
    'NYER0063';'COJF0331';'COJF0267';'053446';'054135';'COCC0007';'ORDG0012';'424467';'NYOS0001';'COPK0039';...
    'CAMD0022';'SDLW0006';'COLK0010';'456894';'IDBS0006';'MIOD0003';'COMZ0033';'COGN0050';'COCF0020';'MTPK0010';...
    'CAPM0002';'245712';'WALW0015';'ORCC0064';'315923';'395870';'MTCC0008';'MIBN0001';'305714';'396427';...
    'COMN0001';'356426';'CAAM0005';'COGN0059';'206680';'MTCB0005';'207188';'COLR0371';'057309';'207350';...
    '057460';'427729';'WACM0002';'057656';'ORDS0035';'WYLN0002';'CAPC0001';'458508';'428119';'108676';...
    '308248';'208043';'AKMS0012';'NMTS0025';'058204';'COLK0027';'058501';'COBO0202';'NYJF0026';'WYTT0022';...
    '299820';'CASR0003';'503504'};
dm2=cell(numcities,2);
    dm2{1,1}='Ahmeek MI';dm2{2,1}='Allegany SP NY';dm2{3,1}='Alpine AK';
    dm2{4,1}='Alpine Creek Lodge AK';dm2{5,1}='Alpine UT';dm2{6,1}='Alta NY';
    dm2{7,1}='Alta UT';dm2{8,1}='Alyeska AK';dm2{9,1}='Angel Fire NM';
    dm2{10,1}='Annette Island AK';dm2{11,1}='Bennington NY';dm2{12,1}='Baraga 7NW MI';
    dm2{13,1}='Barrow AK';dm2{14,1}='Bedford WY';dm2{15,1}='Bennetts Bridge NY';
    dm2{16,1}='Benton Harbor MI';dm2{17,1}='Bergland Dam MI';dm2{18,1}='Berlin NH';
    dm2{19,1}='Bethel AK';dm2{20,1}='Bettles AK';dm2{21,1}='Beulah 7SSW MI';
    dm2{22,1}='Big Bay 9SW MI';dm2{23,1}='Big Bear Lake CA';dm2{24,1}='Boca CA';
    dm2{25,1}='Bondurant WY';dm2{26,1}='Bonners Ferry ID';dm2{27,1}='Boundary Dam WA';
    dm2{28,1}='Bowman Dam CA';dm2{29,1}='Breckenridge CO';dm2{30,1}='Bridgeport CA';
    dm2{31,1}='Grand Canyon N Rim AZ';dm2{32,1}='Bryce Canyon NP UT';dm2{33,1}='Buffalo NY';
    dm2{34,1}='Cabin Creek CO';dm2{35,1}='Canjilon NM';dm2{36,1}='Cannery Creek AK';
    dm2{37,1}='Canyon Island AK';dm2{38,1}='Capitol Reef NP UT';dm2{39,1}='Caribou ME';
    dm2{40,1}='Cascade ID';dm2{41,1}='Cedar City 5E UT';dm2{42,1}='Cerro NM';
    dm2{43,1}='Chama NM';dm2{44,1}='Charlemont MA';dm2{45,1}='Chester CA';
    dm2{46,1}='Chicken AK';dm2{47,1}='Denali SP AK';dm2{48,1}='Circle Hot Spgs AK';
    dm2{49,1}='Climax CO';dm2{50,1}='Cold Bay AK';dm2{51,1}='Colden 1W NY';
    dm2{52,1}='Colebrook NH';dm2{53,1}='Cordova AK';dm2{54,1}='Craig AK';
    dm2{55,1}='Creede CO';dm2{56,1}='Crested Butte CO';dm2{57,1}='Dagget Pass NV';
    dm2{58,1}='Deer Creek Dam UT';dm2{59,1}='Dixie North ID';dm2{60,1}='Dry Creek AK';
    dm2{61,1}='Dutch Harbor AK';dm2{62,1}='Eagle Nest NM';dm2{63,1}='Eagle River Nature Ctr AK';
    dm2{64,1}='Easton WA';dm2{65,1}='Evergreen CO';dm2{66,1}='Fairbanks AK';
    dm2{67,1}='Franklinville NY';dm2{68,1}='Fort Kent ME';dm2{69,1}='Fulton NY';
    dm2{70,1}='Galena AK';dm2{71,1}='Gardiner MT';dm2{72,1}='Gascon NM';
    dm2{73,1}='Georgetown CO';dm2{74,1}='Gilmore Creek AK';dm2{75,1}='Glacier Bay AK';
    dm2{76,1}='Glen Alps AK';dm2{77,1}='Glenbrook NV';dm2{78,1}='Glennallen AK';
    dm2{79,1}='Government Camp OR';dm2{80,1}='Grand Canyon S Rim AZ';dm2{81,1}='Grand Lake CO';
    dm2{82,1}='Grand Lake Stream ME';dm2{83,1}='Grant CO';dm2{84,1}='Grant Grove CA';
    dm2{85,1}='Greenland 6N MI';dm2{86,1}='Groveland CA';dm2{87,1}='Gurney WI';
    dm2{88,1}='Gustavus AK';dm2{89,1}='Haines AK';dm2{90,1}='Hamburg NY';
    dm2{91,1}='Harbor Beach MI';dm2{92,1}='Hell Hole CA';dm2{93,1}='Herman MI';
    dm2{94,1}='Highmarket NY';dm2{95,1}='Holden Village WA';dm2{96,1}='Homer 8NW AK';
    dm2{97,1}='South Rutland NY';dm2{98,1}='Hurley WI';dm2{99,1}='Idyllwild CA';
    dm2{100,1}='Indiana Dunes IN';dm2{101,1}='Ironwood MI';dm2{102,1}='Island Pond VT';
    dm2{103,1}='Jackson WY';dm2{104,1}='Jamestown NY';dm2{105,1}='Jefferson NH';
    dm2{106,1}='Jeffersonville VT';dm2{107,1}='Juneau AK';dm2{108,1}='Keno OR';
    dm2{109,1}='Keystone Ridge AK';dm2{110,1}='Kodiak AK';dm2{111,1}='Kotzebue AK';
    dm2{112,1}='Lamar Ranger Stn WY';dm2{113,1}='Lancaster NH';dm2{114,1}='Laporte IN';
    dm2{115,1}='Leadore ID';dm2{116,1}='Lee Vining CA';dm2{117,1}='Lemolo Lake OR';
    dm2{118,1}='Lenox Dale MA';dm2{119,1}='Little Valley NY';dm2{120,1}='Livingston 12S MT';
    dm2{121,1}='Lodgepole CA';dm2{122,1}='Mammoth Lakes CA';dm2{123,1}='Manti UT';
    dm2{124,1}='Manzanita Lake CA';dm2{125,1}='Marion Forks OR';dm2{126,1}='Mazama WA';
    dm2{127,1}='McCall ID';dm2{128,1}='McCarthy AK';dm2{129,1}='McGrath AK';
    dm2{130,1}='Mineral CA';dm2{131,1}='Moose Pass AK';dm2{132,1}='Moose WY';
    dm2{133,1}='Moran WY';dm2{134,1}='Mt Adams Ranger Stn WA';dm2{135,1}='Mt Hamilton CA';
    dm2{136,1}='Mt Mansfield VT';dm2{137,1}='Mt Washington NH';dm2{138,1}='Mystic Lake MT';
    dm2{139,1}='New Meadows Ranger Stn ID';dm2{140,1}='Nome AK';dm2{141,1}='Northway AK';
    dm2{142,1}='Odell Lake OR';dm2{143,1}='Old Faithful WY';dm2{144,1}='Ouray CO';
    dm2{145,1}='Pacific House CA';dm2{146,1}='Pagosa Springs CO';dm2{147,1}='Pahaska WY';
    dm2{148,1}='Palermo NY';dm2{149,1}='Park City UT';dm2{150,1}='Pelican AK';
    dm2{151,1}='Perrysburg NY';dm2{152,1}='Pickford MI';dm2{153,1}='Pinkham Notch NH';
    dm2{154,1}='Placerville CA';dm2{155,1}='Port Alcan AK';dm2{156,1}='Port San Juan AK';
    dm2{157,1}='Portageville NY';dm2{158,1}='Pulaski NY';dm2{159,1}='Quillayute AP WA';
    dm2{160,1}='Quincy CA';dm2{161,1}='Rainier Ranger Stn WA';dm2{162,1}='Red Lodge MT';
    dm2{163,1}='Red River NM';dm2{164,1}='Robbinston ME';dm2{165,1}='Rutland VT';
    dm2{166,1}='Santaquin UT';dm2{167,1}='Santiam Jct OR';dm2{168,1}='Sault Ste Marie MI';
    dm2{169,1}='Scottville MI';dm2{170,1}='Seward AK';dm2{171,1}='Silver Lake UT';
    dm2{172,1}='Silver Springs NY';dm2{173,1}='Skagway AK';dm2{174,1}='Skyline Ridge CA';
    dm2{175,1}='Snake River WY';dm2{176,1}='Snettisham AK';dm2{177,1}='South Lake Tahoe CA';
    dm2{178,1}='Stevensville MI';dm2{179,1}='Sugar Loaf Dam CO';dm2{180,1}='Sutton VT';
    dm2{181,1}='Swan Valley ID';dm2{182,1}='Tahoma CA';dm2{183,1}='Tanana AK';
    dm2{184,1}='Tok AK';dm2{185,1}='Toketee Falls OR';dm2{186,1}='Tooele UT';
    dm2{187,1}='Topsfield ME';dm2{188,1}='Verdi CA';dm2{189,1}='Wales NY';
    dm2{190,1}='Warsaw NY';dm2{191,1}='Watton MI';dm2{192,1}='Weaverville CA';
    dm2{193,1}='Wellston MI';dm2{194,1}='West Yellowstone MT';dm2{195,1}='Whitestone Farms AK';
    dm2{196,1}='Winter Park CO';dm2{197,1}='Wiseman AK';dm2{198,1}='Yakutat AK';
    dm2{199,1}='Yellowpine ID';dm2{200,1}='Yellowstone NP N Ent WY';dm2{201,1}='Yosemite NP S Ent CA';
    dm2{202,1}='Alma CO';dm2{203,1}='Anaconda 7.4NW MT';dm2{204,1}='Anchorage 11.9SSE AK';
    dm2{205,1}='Applegate 8.3SSW OR';dm2{206,1}='Aspen CO';dm2{207,1}='Aspen Springs CO';
    dm2{208,1}='Auburn MI';dm2{209,1}='Baring WA';dm2{210,1}='Gunnison CO';
    dm2{211,1}='Black Hawk CO';dm2{212,1}='Breckenridge 3.3SE CO';dm2{213,1}='Burgess Junction WY';
    dm2{214,1}='Calaveras CA';dm2{215,1}='Chemult OR';dm2{216,1}='Cochetopa Creek CO';
    dm2{217,1}='Colden 2.4ENE NY';dm2{218,1}='Conifer 5.7SW CO';dm2{219,1}='Crested Butte 6.2N CO';
    dm2{220,1}='Divide CO';dm2{221,1}='Dorris CA';dm2{222,1}='Dubois 9.7WNW WY';
    dm2{223,1}='East Aurora NY';dm2{224,1}='Empire CO';dm2{225,1}='Etna CA';
    dm2{226,1}='Fairbanks 7NNE AK';dm2{227,1}='Fairplay CO';dm2{228,1}='Filion MI';
    dm2{229,1}='Forks of Salmon CA';dm2{230,1}='Frost WV';dm2{231,1}='Glenwood NY';
    dm2{232,1}='Golden 12.5NW CO';dm2{233,1}='Golden 9.4WNW CO';dm2{234,1}='Gould CO';
    dm2{235,1}='Hourglass Rsvr CO';dm2{236,1}='Idaho Springs CO';dm2{237,1}='Idleyld Park OR';
    dm2{238,1}='Kamas UT';dm2{239,1}='Lacona NY';dm2{240,1}='Lake George 7.2WNW CO';
    dm2{241,1}='Laytonville 9.8NNW CA';dm2{242,1}='Lead 5.5SSW SD';dm2{243,1}='Leadville 6.3S CO';
    dm2{244,1}='Longmire Rainier Ranger Stn WA';dm2{245,1}='Lowman 9.6ENE ID';dm2{246,1}='Luzerne MI';
    dm2{247,1}='Mancos 11ENE CO';dm2{248,1}='Marble CO';dm2{249,1}='Maysville CO';
    dm2{250,1}='McLeod 12.8SW MT';dm2{251,1}='Meadow Valley 5.6WSW CA';dm2{252,1}='Millegan 14SE MT';
    dm2{253,1}='Mineral WA';dm2{254,1}='Mt Hood Village OR';dm2{255,1}='Mt Mitchell NC';
    dm2{256,1}='Mt Rushmore SD';dm2{257,1}='Neihart MT';dm2{258,1}='New Buffalo MI';
    dm2{259,1}='Newcomb NY';dm2{260,1}='Pactola Dam SD';dm2{261,1}='Pagosa Springs 9.1NNW CO';
    dm2{262,1}='Paisley OR';dm2{263,1}='Pioneer 6.4NE CA';dm2{264,1}='Pitkin CO';
    dm2{265,1}='Port Huron MI';dm2{266,1}='Red Lodge 3.0SW MT';dm2{267,1}='Rudyard MI';
    dm2{268,1}='Rustic 9.2S CO';dm2{269,1}='Ruxton Park CO';dm2{270,1}='Sandusky MI';
    dm2{271,1}='Sargents CO';dm2{272,1}='Scofield-Skyline Mine UT';dm2{273,1}='Sequim 5.4SW WA';
    dm2{274,1}='Silverton CO';dm2{275,1}='Sisters OR';dm2{276,1}='Smoot WY';
    dm2{277,1}='Soda Springs CA';dm2{278,1}='South Fork Rsvr WA';dm2{279,1}='Spanish Fork Power House UT';
    dm2{280,1}='Stanley ID';dm2{281,1}='Stillwater Rsvr NY';dm2{282,1}='Tahquamenon Falls SP MI';
    dm2{283,1}='Talkeetna 7.6S AK';dm2{284,1}='Taos 11.3ESE NM';dm2{285,1}='Telluride CO';
    dm2{286,1}='Twin Lakes CO';dm2{287,1}='Twin Lakes Rsvr CO';dm2{288,1}='Ward CO';
    dm2{289,1}='Mannsville NY';dm2{290,1}='Wilson WY';dm2{291,1}='Wolf Canyon NM';
    dm2{292,1}='Wrightwood CA';dm2{293,1}='Haines 40NW AK';

if calclocssnowfallthisyear==1
    sumstodate2=zeros(numlocs,1);
    startdate=seasonstartdate;
    for loc=1:numlocs
        if loc==round2(numlocs/2,1,'ceil');disp('Halfway done with all-location snowfall sums');end
        currentsid=char(alllocids(loc,:));%disp(currentsid);
        newsid=sprintf('http://data.rcc-acis.org/StnData?sid=%s&sdate=%s&edate=%s&elems=snow&duration=std&smry=sum&season_start=10-01&output=csv',...
            currentsid,startdate,todaysdate);
        monmin=urlread(newsid);
        A=strread(monmin,'%s','delimiter',sprintf('\n')');
        newA=char(A);
        [nr,nc]=size(newA);
        %Parse resultant string (equivalent of Excel text-to-columns) and convert to numbers
        resultsholder=zeros(nr,1);
        for i=2:nr %because 1st row is station name
            [newstr,matches]=strsplit(newA(i,:),'\s*,\s*','DelimiterType','RegularExpression');
            result=newstr(2);result=char(result);
            modresult=strrep(result,'T','0'); %because trace values are not actually summed
            numericresult=str2double(modresult);
            if isnan(numericresult)
                numericresult=0; %just make missing data zeros on the assumption that they are anyway
            end
            resultsholder(i)=numericresult;
        end

        %And, the pièce de résistance... quick season-to-date summations
        sumtodate=sum(resultsholder);sumstodate2(loc)=sumtodate;
    end
    
    for i=1:numlocs;dm2{i,2}=sumstodate2(i);end
    
    [trash,idx]=sort([dm2{:,2}],'descend');
    dm2sorted=dm2(idx,:);

    %Save resulting sorted array
    save('rw_datapulling_results','dm2sorted');
end