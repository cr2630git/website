%Pull data from selected U.S. snowfall stations using ACIS framework
%Goal is to calculate mean snowfall as basis for anomaly rankings

%Current runtime: about 15 sec per station

%Set key variables
%Station IDs are those from the Coop naming system
%Choose one of {1,2,3,4,5} to do at a time
chosennum=1;

sizes=[31;5;2;3;1];numstns=sizes(chosennum);
startdates={'1955-10-01';'1968-10-01';'2005-10-01';'1994-10-01';'1980-10-01'};
startdate=startdates{chosennum};
stopdate='2015-05-31';
numyearsall=[60;47;10;21;35];numyears=numyearsall(chosennum);
stnids1=['456898','059175','051660','051959','050909','484910','420072','207366','303087',...
    '300608','303961','303851','308910','308962','307329','275639','276818','435416',...
    '199923','043551','045311','040943','486845','508525','505769','204104','061762',...
    '477892','173892','175311','105708']; %1955-56 to 2014-15 (60 years)
stnids2=['203744','453730','455133','243378','111549']; %1968-69 to 2014-15 (47 years)
stnids3=['301625','306525']; %2005-06 to 2014-15 (10 years)
stnids4=['045280','426644','036393']; %1994-95 to 2014-15 (21 years)
stnids5=['315923']; %1980-81 to 2014-15 (35 years)
stnlats1=[46.79;39.87;39.37;38.87;39.49;43.49;40.59;46.48;43.31;43.53;43.85;43.58;42.74;...
    42.69;42.43;44.27;44.26;44.525;42.27;36.74;40.54;38.21;44.46;59.45;62.96;46.47;41.40;...
    46.36;46.12;45.65;44.89];
stnlats2=[46.67;48.20;48.60;45.03;41.995];
stnlats3=[42.65;42.46];
stnlats4=[37.65;40.67;35.82];
stnlats5=[35.76];
stnlons1=[-121.74;-105.76;-106.19;-106.98;-106.0;-110.76;-111.64;-84.36;-76.39;-75.95;-75.72;...
    -75.52;-78.51;-78.22;-78.19;-71.30;-71.26;-72.815;-71.87;-118.96;-121.58;-119.01;-110.83;...
    -135.31;-155.61;-90.19;-73.42;-91.83;-67.79;-68.69;-116.10];
stnlons2=[-88.38;-120.77;-120.43;-110.70;-87.93];
stnlons3=[-78.71;-79.00];
stnlons4=[-118.96;-111.51;-93.77];
stnlons5=[-82.27];
stnelevs1=[5427;9108;11294;8865;9580;6210;8730;722;360;660;1800;1763;1090;1820;1600;6271;...
    2010;3950;1000;6600;5750;8370;7360;35;333;1430;405;1130;476;406;5025];
stnelevs2=[1670;3218;2141;5275;662];
stnelevs3=[1535;1210];
stnelevs4=[7804;6824;1390];
stnelevs5=[6240];

%Use the chosen arrays
stnids=eval(sprintf('stnids%u',chosennum));
stnlats=eval(sprintf('stnlats%u',chosennum));
stnlons=eval(sprintf('stnlons%u',chosennum));
stnelevs=eval(sprintf('stnelevs%u',chosennum));

sumstodate=zeros(numstns,1);
for city=1:4
    currentsid=stnids((city-1)*6+1:(city-1)*6+6);
    %disp(currentsid);
    newsid=sprintf('http://data.rcc-acis.org/StnData?sid=%s&sdate=%s&edate=%s&elems=snow&duration=std&smry=sum&season_start=10-01&output=csv',...
        currentsid,startdate,stopdate);
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
    sumtodate=sum(resultsholder);
    sumstodate(city)=sumtodate;
end

%Put it all together in a new matrix for display
displaymatrix1{1,1}='Rainier Paradise Rng WA';displaymatrix1{2,1}='Winter Park CO';displaymatrix1{3,1}='Climax CO';
displaymatrix1{4,1}='Crested Butte CO';displaymatrix1{5,1}='Breckenridge CO';displaymatrix1{6,1}='Jackson WY';
displaymatrix1{7,1}='Alta UT';displaymatrix1{8,1}='Sault Ste Marie AP MI';displaymatrix1{9,1}='Fulton NY';
displaymatrix1{10,1}='Bennetts Bridge NY';displaymatrix1{11,1}='Hooker 12 NNW NY';displaymatrix1{12,1}='Highmarket NY';
displaymatrix1{13,1}='Wales NY';displaymatrix1{14,1}='Warsaw 6 SW NY';displaymatrix1{15,1}='Rushford NY';
displaymatrix1{16,1}='Mt Washington NH';displaymatrix1{17,1}='Pinkham Notch NH';displaymatrix1{18,1}='Mt Mansfield VT';
displaymatrix1{19,1}='Worcester MA';displaymatrix1{20,1}='Grant Grove CA';displaymatrix1{21,1}='Manzanita Lake CA';
displaymatrix1{22,1}='Bodie CA';displaymatrix1{23,1}='Old Faithful WY';displaymatrix1{24,1}='Skagway AK';
displaymatrix1{25,1}='McGrath AP AK';displaymatrix1{26,1}='Ironwood MI';displaymatrix1{27,1}='Danbury CT';
displaymatrix1{28,1}='Solon Springs WI';displaymatrix1{29,1}='Houlton AP ME';displaymatrix1{30,1}='Millinocket AP ME';
displaymatrix1{31,1}='McCall ID';
displaymatrix2{1,1}='Herman MI';displaymatrix2{2,1}='Holden Village WA';displaymatrix2{3,1}='Mazama WA';
displaymatrix2{4,1}='Gardiner MT';displaymatrix2{5,1}='Chicago OHare AP IL';
displaymatrix3{1,1}='Colden 1 W NY';displaymatrix3{2,1}='Perrysburg NY';
displaymatrix4{1,1}='Mammoth Lakes CA';displaymatrix4{2,1}='Park City UT';displaymatrix4{3,1}='St Paul AR';
displaymatrix5{1,1}='Mt Mitchell NC';

dispmatrixtouse=eval(sprintf('displaymatrix%u',chosennum)); 
for i=1:numstns;dispmatrixtouse{i,2}=sumstodate(i)/numyears;end

%Show the world!
disp(dispmatrixtouse);