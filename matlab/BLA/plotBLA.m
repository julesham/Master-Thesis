N = BLA_Measurements.N;
ExcitedHarmBLA = BLA_Measurements.ExcitedHarm;
%% Figures
figure('name','Measured BLA and I/O Spectra');
subplot(2,2,1);
hold all;
    freqplot = ExcitedHarmBLA/N;
    plot(freqplot,db(BLA_RO.mean),'k',freqplot,db(BLA_RO.stds),'b');
    plot(freqplot,db(BLA_RO.stdNL),'r',freqplot,db(BLA_RO.stdn),'g');
    xlabel('Frequency f/fs '); ylabel('Amplitude [dB]');
    legend('BLA RO','NL w.r.t one real','total variance','noise variance','Location','Best');
    title('Reference to Output')
subplot(2,2,2);
hold all;
    freqplot = ExcitedHarmBLA/N;
    plot(freqplot,unwrap(angle(BLA_RO.mean))*180/pi,'k');
    title('Reference to Output - Phase')
    xlabel('Frequency f/fs '); ylabel('Phase [deg]');
subplot(2,2,3);
    hold all;
    plot(freqplot,db(U_BLA.mean),'k',freqplot,db(U_BLA.stdNL),'r');
    title('Input Spectrum')
    xlabel('Frequency f/fs '); ylabel('Amplitude [dB]');
subplot(2,2,4);
    hold all;
    plot(freqplot,db(Y_BLA.mean),'k',freqplot,db(Y_BLA.stdNL),'r');
    title('Output Spectrum')
    xlabel('Frequency f/fs '); ylabel('Amplitude [dB]');

