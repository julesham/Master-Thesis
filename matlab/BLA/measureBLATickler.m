function [BLA_Measurements] = measureBLATickler(DUT,ExcitedHarmBLA,ExcitedHarmOutofBand,rms,N,T,P,M,ratioTickler)
%% Measures the BLA of the DUT using the robust method.
%  * Syntax *
%
%   [BLA_Measurements] = measureBLA(DUT,ExcitedHarm,rms,N,T,P,M)
%
% ** Arguments **
%
% * System *
%   * DUT : function handle or text with function name of system
%
% * Input Signal *
%   * ExcitedHarm : F x 1 vector containg all excited bin frequencies
%   * rms : rms of input MS
%   * N : samples per period
%
% * Experiment *
%   * T : # of transient periods
%   * P : # of measurement periods
%   * M : # of realizations
%
% * Output *
%   * BLA_Measurements : struct containing following variables:
%         * u   : M x (T+P)*N input measurements
%         * y   : M x (T+P)*N output measurements
%         * r   : M x  N input references
%         * N   : # of samples per period
%         * T , P : # of transient and measurement periods, respectively
%         * M   : # of realisations
%         * ExcitedHarm : F x 1 vector containg all excited bin frequencies
%         * rms : rms of input MS
%         * DUT : function handle or text with function name of system
ExcitedHarm = [ExcitedHarmBLA; ExcitedHarmOutofBand];
F_BB  = length(ExcitedHarmBLA);
F_OB  = length(ExcitedHarmOutofBand);
% F   = F_BB+F_OB;

BLA_Measurements.u = zeros(M, (P+T)*N);
BLA_Measurements.y = zeros(M, (P+T)*N);
BLA_Measurements.r = zeros(M,N);

BLA_Measurements.N = N;
BLA_Measurements.T = T;
BLA_Measurements.P = P;
BLA_Measurements.M = M;

BLA_Measurements.rms = rms;
BLA_Measurements.DUT = DUT;
BLA_Measurements.ExcitedHarm = ExcitedHarm;

h = figure('Name','BLA : Ref/Input/Output of System');
for mm = 1:M
    fprintf('Realisation in progress : %g/%g\n',mm,M)
    
    r = rms*CalcMultisine(ExcitedHarmBLA, N); % Make a new MS realization (size of ExcitedHarm)
    r = r + ratioTickler*rms*CalcMultisine(ExcitedHarmOutofBand,N);
    
    if strcmp(DUT,'SYS_VXI')
        while max(abs(r)) > 5
            fprintf('Overloading System, recomputing Multisine. \n ');
            r = rms*CalcMultisine(ExcitedHarmBLA, N); % Make a new MS realization (size of ExcitedHarm)
            r = r + ratioTickler*rms*CalcMultisine(ExcitedHarmOutofBand,N);
        end
    end
    
    rr = repmat(r,T+P,1);           % make multiple periods , transient + measurement periods
    [y,u] = feval(DUT,rr);          % pass trough system (can add noise!)
    
    
    figure(h);
    subplot(3,1,1); plot(r); title('Reference');ylim([min(r) max(r)]);
    subplot(3,1,2); plot(u); title('Input');    ylim([min(u) max(u)]);
    subplot(3,1,3); plot(y); title('Output');   ylim([min(y) max(y)]);
    shg;
    
    %%%
    % Output Everything
    %%%
    
    BLA_Measurements.u(mm, :) = u;
    BLA_Measurements.y(mm, :) = y;
    BLA_Measurements.r(mm, :) = r;
    
    %%%
    % Save Everything if Measuring
    %%%
    if strcmp(DUT,'SYS_VXI')
        filenameBLA = ['BLA_PA_',datestr(now,'dd_mmm_HH'),'h',datestr(now,'MM')];
        save(filenameBLA,'time','BLA_Measurements');
    end
    
end
close(h);