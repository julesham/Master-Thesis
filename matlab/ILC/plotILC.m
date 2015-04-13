
meanSquareError = mean(ILC_Measurements.error.^2,3).';
y_ref   = ILC_Measurements.y_ref(end,:).';                % y_ref of  last iteration
yj      = squeeze(ILC_Measurements.yj(end,end,:));      % yj, last realization , last iteration
e       = y_ref - yj;
y1      = squeeze(ILC_Measurements.yj(end,1,:));
% Time Domain Plots  

figure('name','ILC : Time Domain');
subplot(311);
    plot(db(meanSquareError),'--s'); xlabel('Iteration'); ylabel('db(MSE)');
    title('MSE of y_d - y_j, each color is a different realisation');
subplot(312); 
    hold all;
    plot(y_ref);
    plot(yj);
    plot(y1)
    xlabel('time'); ylabel('Amplitude');
    legend('y_d','yj','y1');
    title('Comparison y_d and y_j ');
subplot(313);
    plot(e,'x'); xlabel('time'); ylabel('error');
    title('y_d - y_j');

% Frequency Domain Plots  

figure('name','ILC : Frequency Domain');

subplot(211); 
    hold all;
    freq = ((0:time.N-1)/time.N);
    plot(freq,(db(fft(y_ref)/sqrt(time.N))),'o');
    plot(freq,(db(fft(yj)/sqrt(time.N))),'.');
    plot(freq,(db(fft(y1)/sqrt(time.N))),'.');
    xlabel('freq'); ylabel('Amplitude');
    legend('y_d = BLA(u\_ref)','y\_j','y1 = SYS(u\_ref)');
    title('Comparison y_d and y_j ');
    ylim([min( db( fft(yj)/sqrt(time.N) ) ), 20  ])
subplot(212);
    plot(freq,db(fft(e)/sqrt(time.N)),'.'); xlabel('freq'); ylabel('error');
    title('y_d - y_j') ;