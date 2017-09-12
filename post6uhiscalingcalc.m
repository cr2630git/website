%Some work on UHI scaling
x=10^2:10^7;
y1=2.96*log10(x)-6.41;
y2=2.01*log10(x)-4.06;
y3=1.93*log10(x)-4.76;
y4=1.91*log10(x)-1.73;
y5=1.42*log10(x)-2.02;

figure(100);clf;
semilogx(x,y1,'r');
hold on;
semilogx(x,y2,'b');
hold on;
semilogx(x,y3,'c');
hold on;
semilogx(x,y4,'k');
hold on;
semilogx(x,y5,'m');
legend('Oke 1973 (NA)','Oke 1973 (Eur)','Oke 1973 (QC)','Sundborg 1950 (Swe)', ...
    'Torok et al. 2001 (Austr)','Location','northwest');
xlabel('Log Population');
ylabel('Maximum Predicted UHI Strength (K)');
title('UHI Strength vs. Population from various studies','FontSize',14);