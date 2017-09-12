%Calculates and plots to see if hotter days are indeed more likely (as I hypothesize) to be part of a chain of hot days
%("intense heat waves are longer-lasting")
%Consider incorporating this script into findmaxtwbt once complete
alldata={};thisdaypct=0;thisdayadjorno=0;
for stn=1:maxnumstns
    %Get all daily maxes for each month for each stn
    totalc=1;
    for month=1:6
        monlen=monthlengthsdays(month);
        for year=1:35
            alldata{stn,month}(totalc:totalc+monlen-1)=dailymaxtstruc{stn,year,month};
            totalc=totalc+monlen;
        end
        totalc=1;
    end

    %Get data for each hot day and its percentile among all days of its month, and determine whether
        %an adjacent day was also in the top 100
    %SHOULD USE PCTRELTODISTN
    for row=1:100
        thist=topXXtbystn{stn}(row,1);
        thisyear=topXXtbystn{stn}(row,2);
        thismon=topXXtbystn{stn}(row,3);
        thisday=topXXtbystn{stn}(row,4);
        
        thismondata=[alldata{stn,thismon-5+1}'];temp=isnan(thismondata);thismondata(temp)=0;
        othercol=[1:size(thismondata,1)]';
        twocolarr=[thismondata othercol];
        twocolarr=sortrows(twocolarr,-1);
        
        thismondata=[thismondata;thist];
        othercol=[othercol;max(othercol)+1];
        twocolarr=[thismondata othercol];
        twocolarr=sortrows(twocolarr,-1);
        
        [a,b]=max(twocolarr(:,2));
        thisdaypct(stn,row)=100*(1-b/max(othercol));
        
        %whether a day adjacent to this one was also in the top 100
        adjday=0;
        if row>=2
            prevrowyear=topXXtbystn{stn}(row-1,2);
            prevrowmon=topXXtbystn{stn}(row-1,3);
            prevrowday=topXXtbystn{stn}(row-1,4);
            if prevrowyear==thisyear && prevrowmon==thismon && prevrowday==thisday-1 %ignore month changes
                adjday=1;
            end
        end
        if row<=99
            nextrowyear=topXXtbystn{stn}(row+1,2);
            nextrowmon=topXXtbystn{stn}(row+1,3);
            nextrowday=topXXtbystn{stn}(row+1,4);
            if nextrowyear==thisyear && nextrowmon==thismon && nextrowday==thisday+1 %ignore month changes
                adjday=1;
            end
        end
        thisdayadjorno(stn,row)=adjday;
    end  
end

%Average over all stations, binning days into percentile bins at 1% intervals (100, 99, 98, etc)
    %to be able to make a nice smooth curve of pctile of a day vs probability an adjacent day was also in the top 100
thisdaypctrounded=round(thisdaypct);
sumadjornoeachpct=zeros(12,1); %because we know now pctiles are going to go from 89 to 100
counteachpct=zeros(12,1);
for stn=1:maxnumstns
    for row=1:100
        relpct=thisdaypctrounded(stn,row)-88;
        sumadjornoeachpct(relpct)=sumadjornoeachpct(relpct)+thisdayadjorno(stn,row);
        counteachpct(relpct)=counteachpct(relpct)+1;
    end
end
avgadjornoeachpct=sumadjornoeachpct./counteachpct;

%CONCLUSION: THERE'S NO EVIDENCE IN THIS DATASET TO SUPPORT THE HYPOTHESIS THAT INTENSE HEAT WAVES ARE LONGER