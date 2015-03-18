
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

subplot(211); 
    hold all;
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