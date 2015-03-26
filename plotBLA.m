%% Figures
figure('name','Measured BLA and I/O Spectra');
subplot(2,2,1);
    hold all;
    freqplot = ExcitedHarmBLA/N;
    plot(freqplot,db(BLA_IO.mean),'k',freqplot,db(BLA_IO.stds),'b');
    plot(freqplot,db(BLA_IO.stdNL),'r',freqplot,db(BLA_IO.stdn),'g');
    legend('BLA IO','NL w.r.t one real','total variance','noise variance');
    title('I/O')
subplot(2,2,2);
hold all;
    freqplot = ExcitedHarmBLA/N;
    plot(freqplot,db(BLA_RO.mean),'k',freqplot,db(BLA_RO.stds),'b');
    plot(freqplot,db(BLA_RO.stdNL),'r',freqplot,db(BLA_RO.stdn),'g');
    legend('BLA RO','NL w.r.t one real','total variance','noise variance');
    title('R/O')
subplot(2,2,3);
    hold all;
    freqplot = ExcitedHarmBLA/N;
    plot(freqplot,db(U_BLA.mean),'k',freqplot,db(U_BLA.stdNL),'r');
    title('Input Spectrum')
    
subplot(2,2,4);
    hold all;
    freqplot = ExcitedHarmBLA/N;
    plot(freqplot,db(Y_BLA.mean),'k',freqplot,db(Y_BLA.stdNL),'r');
    title('Output Spectrum')
    
% figure;
% freq = ExcitedHarmBLA/N;
% plot(freq,db(estBLA),freq,db(BLA.mean),freq,db(estBLA.'-BLA.mean));
% legend('Estimated BLA', 'FRF','');
