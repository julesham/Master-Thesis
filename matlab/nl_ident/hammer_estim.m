function [BLA, p] = hammer_estim(ILC_Measurements)
    %
    %  Making a Standalone DPD
    %
    % Estimating a Hammerstein System  
    %  y_ref    ->    uj
    % ---|NL|---|LIN|---
    % (u)     (w)     (y)
    time.fs = 10e6/2^2;
    [~, time.N] = size(ILC_Measurements.u_ref);
    %% Step 1 : LIN = BLA
    BLA = linearPart(ILC_Measurements);
    %% Step 2 : SNL is function f that satisfies f(y_ref) = w;
    % Compute w
    M = ILC_Measurements.ilcM;
    W = zeros(time.N,M);
    uj = squeeze( ILC_Measurements.uj(:,end,:) ).'; % N x M
    Uj = fft(uj);
    for mm = 1:M
        W(ILC_Measurements.ExcitedHarmILC+1,mm) = (BLA.mean.^-1).'.*Uj(ILC_Measurements.ExcitedHarmILC+1,mm);
    end
    w     = 2*real(ifft(W));
    
    
    
    y_ref = ILC_Measurements.y_ref.';
    p     = polyfit(y_ref,w,4);
    
    %
    %
    %
    figure('Name','Hammerstein');
    hold all;
    freq = ILC_Measurements.ExcitedHarmILC./time.N*time.fs;
    subplot(2,2,1); plot(freq,db(BLA.mean),freq,db(BLA.stdNL)); title('BLA DPD Amplitude');
    subplot(2,2,3); plot(freq,angle(BLA.mean)); title('BLA DPD Phase')
    x = ILC_Measurements.y_ref(1,:);
    subplot(2,2,[2 4]); plot(x,polyval(p,x)); title('Static Nonlinearity')
    
end

function BLA = linearPart(ILC_Measurements)
    % ILC_Measurements.y_ref is M x N 
    y_ref   = ILC_Measurements.y_ref;
    [M ,~]  = size(y_ref);
    
    % ILC_Measurements.uj is  M x iter x N, we select the last iteration
    uj      = squeeze( ILC_Measurements.uj(:,end,:) );


    % Convert to frequency domain
    U = fft(y_ref,[],2);
    Y = fft(uj,[],2);

    % Select Excited frequencies
    ExcitedHarm = ILC_Measurements.ExcitedHarmILC;
    Uexc = U(:,ExcitedHarm+1);
    Yexc = Y(:,ExcitedHarm+1);
    
    % Convert to appropriate format for FrequencyDomainToolbox 
    % /!\ Engineering trick: artificially two periods are created by
    % replicating the same period twice, FrequencyDomainToolbox does not allow single period
    % measurements
    F = length(ExcitedHarm);
    Yall = nan(M,2,F);  Uall = nan(M,2,F);
    Yall(:,1,:) = Yexc; Yall(:,2,:) = Yexc;
    Uall(:,1,:) = Uexc; Uall(:,2,:) = Uexc;

    BLA = Robust_NL_Anal(Yall, Uall,Uall);% where Yall, Uall are  M x P x F matrices of output, input spectra
end