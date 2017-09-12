%Calculation of temps for Paris and New Delhi heat waves of 2003 and 2015
%respectively
data=csvread('post7parisnewdelhidata.csv');
[rows,cols]=size(data);

%Fill in missing days with missing-value code of -9999 (as opposed to
%skipping the row entirely and creating havoc)
currentday=data(1,3);
for i=2:rows
    pastday=currentday;
    currentday=data(i,3);
    if pastday+1~=currentday
        