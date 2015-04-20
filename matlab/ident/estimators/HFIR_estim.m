function [hfir, p] = HFIR_estim(ILC_Measurements)
    %
    %  Making a Standalone DPD
    %
    % Estimating a Hammerstein System  
    %  y_ref    ->    uj
    % ---|NL|---|FIR|---
    % (u)     (w)     (y)
    time.fs = 10e6/2^2;
    [~, time.N] = size(ILC_Measurements.u_ref);
    %% Step 1 : De-embed signals
    BLA = linearPart(ILC_Measurements);
    M = ILC_Measurements.ilcM;
    W = zeros(time.N,M);
    u = ILC_Measurements.y_ref.'; % N x M
    U = fft(u);
    for mm = 1:M
        W(ILC_Measurements.ExcitedHarmILC+1,mm) = BLA.mean.'.*U(ILC_Measurements.ExcitedHarmILC+1,mm);
    end
    w     = 2*real(ifft(W));
    y     = squeeze(ILC_Measurements.uj(:,end,:)).';
    
    %% Step 2 : Model both parts
    % FIR from w to uj
    for order = 1:3
    [hfir,e] = modelFIR(w ,y,order );
    hold all; plot(order,db(e'*e),'x');
    end
    figure; hold all;
    for order = 3
        p     = polyfit(u,w,order);
        error = y - polyval(p,u);
        MSE = norm( error(:) ).^2/length( error(:) );
        plot(order,db(MSE),'o')
    end
    
%     figure('Name','Wiener');
%     hold all;
%     freq = ILC_Measurements.ExcitedHarmILC./time.N*time.fs;
%     subplot(2,2,1); plot(freq,db(BLA.mean),freq,db(BLA.stdNL)); title('BLA DPD Amplitude');
%     subplot(2,2,3); plot(freq,angle(BLA.mean)); title('BLA DPD Phase')
%     x = ILC_Measurements.y_ref(1,:);
%     subplot(2,2,[2 4]); plot(x,polyval(p,x)); title('Static Nonlinearity')
    
end

function BLA = linearPart(ILC_Measurements)
    % ILC_Measurements.y_ref is M x N 
    y_ref   = ILC_Measurements.y_ref;
    u_ref   = ILC_Measurements.u_ref;
    [M ,~]  = size(y_ref);
    
    % ILC_Measurements.uj is  M x iter x N, we select the last iteration
    uj      = squeeze( ILC_Measurements.uj(:,end,:) );


    % Convert to frequency domain
    R = fft(u_ref,[],2);
    U = fft(y_ref,[],2);
    Y = fft(uj,[],2);

    % Select Excited frequencies
    ExcitedHarm = ILC_Measurements.ExcitedHarmILC;
    Rexc = R(:,ExcitedHarm+1);
    Uexc = U(:,ExcitedHarm+1);
    Yexc = Y(:,ExcitedHarm+1);
    
    % Convert to appropriate format for FrequencyDomainToolbox 
    % /!\ Engineering trick: artificially two periods are created by
    % replicating the same period twice, FrequencyDomainToolbox does not allow single period
    % measurements
    F = length(ExcitedHarm);
    Yall = nan(M,2,F);  
    Uall = nan(M,2,F); 
    Rall = nan(M,2,F);
    
    Rall(:,1,:) = Rexc; Rall(:,2,:) = Rexc;
    Yall(:,1,:) = Yexc; Yall(:,2,:) = Yexc;
    Uall(:,1,:) = Uexc; Uall(:,2,:) = Uexc;
    

    BLA = Robust_NL_Anal(Yall, Uall, Rall);% where Yall, Uall are  M x P x F matrices of output, input spectra
end