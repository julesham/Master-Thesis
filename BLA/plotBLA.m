N = BLA_Measurements.N;
ExcitedHarmBLA = BLA_Measurements.ExcitedHarm;
%% Figures
figure('name','Measured BLA and I/O Spectra');
subplot(2,2,1:2);
hold all;
    freqplot = ExcitedHarmBLA/N;
    plot(freqplot,db(BLA_RO.mean),'k',freqplot,db(BLA_RO.stds),'b');
    plot(freqplot,db(BLA_RO.stdNL),'r',freqplot,db(BLA_RO.stdn),'g');
    legend('BLA RO','NL w.r.t one real','total variance','noise variance','Location','BestOutSide');
    title('Reference to Output')
subplot(2,2,3);
    hold all;
    plot(freqplot,db(U_BLA.mean),'k',freqplot,db(U_BLA.stdNL),'r');
    title('Input Spectrum')
    
subplot(2,2,4);
    hold all;
    plot(freqplot,db(Y_BLA.mean),'k',freqplot,db(Y_BLA.stdNL),'r');
    title('Output Spectrum')

