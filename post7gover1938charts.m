%Creation of graphs from Gover 1938 data
mortanomaly1925na=[2.5;5.0;-0.5];mortanomaly1925nc=[1.3;0.3;-1.3];
mortanomaly1925s=[-0.4;1.5;1.7];mortanomaly1925w=[0.1;1.1;0.4];

%2-month averages to account for delay in mortality
mortanomaly1925na2=[3.75;2.25];mortanomaly1925nc2=[0.8;-0.5];
mortanomaly1925s2=[0.55;1.6];mortanomaly1925w2=[0.6;0.75];

temp1925na=[91;80;84];temp1925nc=[89;80;83];
temp1925s=[92;90;95];temp1925w=[65;69;74];

tempanomaly1925na=[18;5;7];tempanomaly1925nc=[15;4;5];
tempanomaly1925s=[7;3;7];tempanomaly1925w=[-3;-1;3];

tempcombo1925na=[109;85;91];tempcombo1925nc=[104;84;88];
tempcombo1925s=[99;93;102];tempcombo1925w=[62;68;77];


mortanomaly1931na=[0.3;-0.7;-0.3];mortanomaly1931nc=[1.1;3.6;0.5];
mortanomaly1931s=[0.3;1.7;1.0];mortanomaly1931w=[-0.1;-0.9;0.9];

mortanomaly1931na2=[-0.2;-0.5];mortanomaly1931nc2=[2.35;2.05];
mortanomaly1931s2=[1.0;1.35];mortanomaly1931w2=[-0.5;0.0];

temp1931na=[80;83;80];temp1931nc=[85;91;82];
temp1931s=[93;95;93];temp1931w=[78;79;80];

tempanomaly1931na=[1;3;-1];tempanomaly1931nc=[5;10;0];
tempanomaly1931s=[4;5;3];tempanomaly1931w=[5;5;5];


mortanomaly1934na=[0.0;-0.2;0.1];mortanomaly1934nc=[0.6;5.0;0.7];
mortanomaly1934s=[0.0;1.5;-0.4];mortanomaly1934w=[0.0;0.5;-0.3];

mortanomaly1934na2=[-0.1;-0.05];mortanomaly1934nc2=[2.8;2.85];
mortanomaly1934s2=[0.75;0.55];mortanomaly1934w2=[0.25;0.1];

temp1934na=[87;84;83];temp1934nc=[91;91;86];
temp1934s=[96;94;92];temp1934w=[77;80;79];

tempanomaly1934na=[4;1;1];tempanomaly1934nc=[7;7;3];
tempanomaly1934s=[6;3;2];tempanomaly1934w=[0;3;1];


mortanomaly1936na=[1.3;2.3;0.9];mortanomaly1936nc=[3.5;13.2;2.0];
mortanomaly1936s=[0.1;2.4;1.0];mortanomaly1936w=[2.1;1.9;0.8];

mortanomaly1936na2=[1.8;1.6];mortanomaly1936nc2=[8.35;7.6];
mortanomaly1936s2=[1.25;1.7];mortanomaly1936w2=[2.0;1.35];

temp1936na=[89;85;79];temp1936nc=[96;95;85];
temp1936s=[93;93;92];temp1936w=[76;81;82];

tempanomaly1936na=[7;2;-4];tempanomaly1936nc=[13;11;1];
tempanomaly1936s=[3;3;1];tempanomaly1936w=[-1;4;5];


mortanomaly1937na=[0.8;3.4;0.9];mortanomaly1937nc=[0.9;1.0;-0.3];
mortanomaly1937s=[0.1;-0.2;0.0];mortanomaly1937w=[1.1;0.1;0.6];

mortanomaly1937na2=[2.1;2.15];mortanomaly1937nc2=[0.95;0.35];
mortanomaly1937s2=[-0.05;-0.1];mortanomaly1937w2=[0.6;0.35];

temp1937na=[89;83;83];temp1937nc=[89;86;84];
temp1937s=[90;93;91];temp1937w=[77;76;80];

tempanomaly1937na=[8;1;0];tempanomaly1937nc=[7;3;0];
tempanomaly1937s=[0;3;1];tempanomaly1937w=[2;-1;3];


%Make scatterplots
figure(1);clf;
scatter(temp1925na,mortanomaly1925na,'r','filled'); hold on;
xlim([65 95]);ylim([-2 15]);
xlabel('Weekly Maximum Temperature (F)');
ylabel('Annualized Weekly Mortality Anomaly per 1,000 Population');
scatter(temp1925nc,mortanomaly1925nc,'m','filled');
scatter(temp1925s,mortanomaly1925s,'b','filled');
scatter(temp1925w,mortanomaly1925w,'k','filled');
legend('Northeast','Great Lakes','South','West Coast','Location','Northwest');

scatter(temp1931na,mortanomaly1931na,'r','filled'); hold on;
scatter(temp1931nc,mortanomaly1931nc,'m','filled');
scatter(temp1931s,mortanomaly1931s,'b','filled');
scatter(temp1931w,mortanomaly1931w,'k','filled');

scatter(temp1934na,mortanomaly1934na,'r','filled'); hold on;
scatter(temp1934nc,mortanomaly1934nc,'m','filled');
scatter(temp1934s,mortanomaly1934s,'b','filled');
scatter(temp1934w,mortanomaly1934w,'k','filled');

scatter(temp1936na,mortanomaly1936na,'r','filled'); hold on;
scatter(temp1936nc,mortanomaly1936nc,'m','filled');
scatter(temp1936s,mortanomaly1936s,'b','filled');
scatter(temp1936w,mortanomaly1936w,'k','filled');

scatter(temp1937na,mortanomaly1937na,'r','filled'); hold on;
scatter(temp1937nc,mortanomaly1937nc,'m','filled');
scatter(temp1937s,mortanomaly1937s,'b','filled');
scatter(temp1937w,mortanomaly1937w,'k','filled');


figure(2);clf;
scatter(tempanomaly1925na,mortanomaly1925na,'r','filled'); hold on;
xlim([-5 20]);ylim([-2 15]);
xlabel('Weekly Maximum-Temperature Anomaly (F)');
ylabel('Annualized Weekly Mortality Anomaly per 1,000 Population');
scatter(tempanomaly1925nc,mortanomaly1925nc,'g','filled');
scatter(tempanomaly1925s,mortanomaly1925s,'b','filled');
scatter(tempanomaly1925w,mortanomaly1925w,'k','filled');
legend('Northeast','Great Lakes','South','West Coast','Location','Northwest');

scatter(tempanomaly1931na,mortanomaly1931na,'r','filled'); hold on;
scatter(tempanomaly1931nc,mortanomaly1931nc,'g','filled');
scatter(tempanomaly1931s,mortanomaly1931s,'b','filled');
scatter(tempanomaly1931w,mortanomaly1931w,'k','filled');

scatter(tempanomaly1934na,mortanomaly1934na,'r','filled'); hold on;
scatter(tempanomaly1934nc,mortanomaly1934nc,'g','filled');
scatter(tempanomaly1934s,mortanomaly1934s,'b','filled');
scatter(tempanomaly1934w,mortanomaly1934w,'k','filled');

scatter(tempanomaly1936na,mortanomaly1936na,'r','filled'); hold on;
scatter(tempanomaly1936nc,mortanomaly1936nc,'g','filled');
scatter(tempanomaly1936s,mortanomaly1936s,'b','filled');
scatter(tempanomaly1936w,mortanomaly1936w,'k','filled');

scatter(tempanomaly1937na,mortanomaly1937na,'r','filled'); hold on;
scatter(tempanomaly1937nc,mortanomaly1937nc,'g','filled');
scatter(tempanomaly1937s,mortanomaly1937s,'b','filled');
scatter(tempanomaly1937w,mortanomaly1937w,'k','filled');


figure(3);clf;
scatter(tempanomaly1925na(1:2),mortanomaly1925na2,'r','filled'); hold on;
xlim([-5 20]);ylim([-2 10]);
xlabel('Weekly Maximum-Temperature Anomaly (F)');
ylabel('Annualized Weekly Mortality Anomaly per 1,000 Population');
scatter(tempanomaly1925nc(1:2),mortanomaly1925nc2,'g','filled');
scatter(tempanomaly1925s(1:2),mortanomaly1925s2,'b','filled');
scatter(tempanomaly1925w(1:2),mortanomaly1925w2,'k','filled');
legend('Northeast','Great Lakes','South','West Coast','Location','Northwest');

scatter(tempanomaly1931na(1:2),mortanomaly1931na2,'r','filled'); hold on;
scatter(tempanomaly1931nc(1:2),mortanomaly1931nc2,'g','filled');
scatter(tempanomaly1931s(1:2),mortanomaly1931s2,'b','filled');
scatter(tempanomaly1931w(1:2),mortanomaly1931w2,'k','filled');

scatter(tempanomaly1934na(1:2),mortanomaly1934na2,'r','filled'); hold on;
scatter(tempanomaly1934nc(1:2),mortanomaly1934nc2,'g','filled');
scatter(tempanomaly1934s(1:2),mortanomaly1934s2,'b','filled');
scatter(tempanomaly1934w(1:2),mortanomaly1934w2,'k','filled');

scatter(tempanomaly1936na(1:2),mortanomaly1936na2,'r','filled'); hold on;
scatter(tempanomaly1936nc(1:2),mortanomaly1936nc2,'g','filled');
scatter(tempanomaly1936s(1:2),mortanomaly1936s2,'b','filled');
scatter(tempanomaly1936w(1:2),mortanomaly1936w2,'k','filled');

scatter(tempanomaly1937na(1:2),mortanomaly1937na2,'r','filled'); hold on;
scatter(tempanomaly1937nc(1:2),mortanomaly1937nc2,'g','filled');
scatter(tempanomaly1937s(1:2),mortanomaly1937s2,'b','filled');
scatter(tempanomaly1937w(1:2),mortanomaly1937w2,'k','filled');