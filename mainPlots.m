%% Figures
figure('name','Measured BLA and I/O Spectra');
subplot(2,2,1);
    hold all;
    x = ExcitedHarmBLA/N;
    plot(x,db(BLA_IO.mean),'k',x,db(BLA_IO.stds),'b');
    plot(x,db(BLA_IO.stdNL),'r',x,db(BLA_IO.stdn),'g');
    legend('BLA IO','NL w.r.t one real','total variance','noise variance');
    title('I/O')
subplot(2,2,2);
hold all;
    x = ExcitedHarmBLA/N;
    plot(x,db(BLA_RO.mean),'k',x,db(BLA_RO.stds),'b');
    plot(x,db(BLA_RO.stdNL),'r',x,db(BLA_RO.stdn),'g');
    legend('BLA RO','NL w.r.t one real','total variance','noise variance');
    title('R/O')
subplot(2,2,3);
    hold all;
    x = ExcitedHarmBLA/N;
    plot(x,db(U_BLA.mean),'k',x,db(U_BLA.stdNL),'r');
    title('Input Spectrum')
    
subplot(2,2,4);
    hold all;
    x = ExcitedHarmBLA/N;
    plot(x,db(Y_BLA.mean),'k',x,db(Y_BLA.stdNL),'r');
    title('Output Spectrum')
    
% figure;
% freq = ExcitedHarmBLA/N;
% plot(freq,db(estBLA),freq,db(BLA.mean),freq,db(estBLA.'-BLA.mean));
% legend('Estimated BLA', 'FRF','');

% Time Domain Plots  

figure('name','ILC : Time Domain');
subplot(311);
    plot(db(meanError),'x'); xlabel('Iteration'); ylabel('db(MSE)');
    title('MSE of y_d - y_j');
subplot(312); 
    hold all;
    plot(y_ref,'-');
    plot(yj,'x');
    xlabel('time'); ylabel('Amplitude');
    legend('y_d','yj');
    title('Comparison y_d and y_j ');
subplot(313);
    plot(e,'x'); xlabel('time'); ylabel('error');
    title('y_d - y_j');

% Frequency Domain Plots  

figure('name','ILC : Frequency Domain');

subplot(211); hold all;
    freq = (0:N-1)/N;
    plot(freq,db(fft(y_ref)/N),'o');
    plot(freq,db(fft(yj)/N),'.');
    plot(freq,db(fft(y1)/N),'.');
    xlabel('freq'); ylabel('Amplitude');
    legend('y_d = BLA(u\_ref)','y\_j','y1 = SYS(u\_ref)');
    title('Comparison y_d and y_j ');

subplot(212);
    plot(freq,db(fft(e)/sqrt(N)),'.'); xlabel('freq'); ylabel('error');
    title('y_d - y_j') ;