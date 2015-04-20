    
clc; clear; close all;
    load syncMaster; 
    N = length(y);
    
    figure;
    subplot(212); plot(ExcitedHarm/N,zeros(size(ExcitedHarm)));
    for ii = 0:8
        
        u_shifted = circshift(u,[ii 0]);

        UR_1 = fft(u_shifted)./fft(signal);
        UR_1 = UR_1(ExcitedHarm+1);         % trim unwanted frequencies
        phase_first = unwrap( angle(UR_1) );
        ExcitedHarm_first = ExcitedHarm; % Excited Harmonics used for this measurement
    
    subplot(211); hold all; plot(ExcitedHarm_first/N,db(UR_1)); xlabel('f [cycles/sample]'); ylabel('Amp (dB)');
    subplot(212); hold all; plot(ExcitedHarm_first/N,phase_first*180/pi); xlabel('f [cycles/sample]'); ylabel('Phase (deg)');
    end