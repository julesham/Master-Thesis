function [Yall,Uall,Rall,U_ref_all] = processBLAMeasurements(BLA_Measurements)
    % * Syntax *
    % [Yall,Uall,Rall,U_ref_all] = processBLAMeasurements(BLA_Measurements)
    %
    % * Description *
    % Processes the measureBLA() output to get the spectra needed for the
    % Robust_NL_Anal() function

    % Renaming variables for lighter code
    N = BLA_Measurements.N; % Samples per period
    M = BLA_Measurements.M; % Independent Realisations
    P = BLA_Measurements.P; % Measurement Periods
    T = BLA_Measurements.T; % Transient Periods

    ExcitedHarm = BLA_Measurements.ExcitedHarm; % Excited Harmonics (1 -> 1*fs/N is excited)


    %%%
    % Transient Removal
    %%%

    u = BLA_Measurements.u(:,T*N+1:end);
    y = BLA_Measurements.y(:,T*N+1:end);

    %%%
    % Reshaping Matrices to Discern Periods
    %%%

    u = reshape(u.',N,P,M);
    y = reshape(y.',N,P,M);
    r = BLA_Measurements.r.';
    %%%
    % Delay Compensation (sync everything to first realisation)
    %%%
    for mm = 1:M
        if strcmp(BLA_Measurements.DUT,'SYS_VXI')
            delay = compensateAWGDelayv3(u(1:N,P,mm), r(1:N,mm),ExcitedHarm);
            u(1:N,1:P,mm) = circshift(u(1:N,1:P,mm),-delay);
            y(1:N,1:P,mm) = circshift(y(1:N,1:P,mm),-delay);
        end
    end

    %%%
    % Format Change to fit FrequencyDomainToolbox format
    %%%
    u = permute(u,[3 2 1]); % from N x P x M to M x P x N
    y = permute(y,[3 2 1]); % from N x P x M to M x P x N
    r = r.';                % from N x M to M x N

    %%%
    % Frequency Domain Conversion
    %%%

    R = fft(r,[],2)./sqrt(N);    % Total Spectrum
    Y = fft(y,[],3)./sqrt(N);
    U = fft(u,[],3)./sqrt(N);

    Rall = R(:,ExcitedHarm+1);  % Select Excited Harmonics
    Uall = U(:,:,ExcitedHarm+1);
    Yall = Y(:,:,ExcitedHarm+1);

    U_ref_all = nan(M,P,length(ExcitedHarm));

    for pp = 1:P
        U_ref_all(:,pp,:) = Rall;
    end
