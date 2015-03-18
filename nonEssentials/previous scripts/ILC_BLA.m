%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ILC on a nonlinear system                                                %%
%                                                                           %%
% Illustrated on a continuous-time Wiener-Hammerstein system consisting     %%
% of the cascade of                                                         %%
%                                                                           %%
%   1. a second order system:           G1(s) = 1/(1 + s/(Q*w0) + s^2/w0^2) %%
%   2. a static nonlinear function:     5*tanh(x/5)                         %%
%   3. a first order system:            G2(s) = 1/(1 + Tau*s)               %%
%                                                                           %%
%                                                                           %% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition of the Wiener-Hammerstein system %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% second order system G1(s)
f0 = 1000;								% resonance frequency at 1 kHz
Q = 3;									% quality factor

% first order system G2(s)
Tau = 1/(2*pi*300);						% 3 dB point at 300 Hz

% sampling frequency: 12.5 times oversampling to avoid alias problems
fs = 5e4;								% 50 kHz


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition actuator characteristic %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 2th order Chebyshev filter with a passband ripple of 6 dB and
% a cutoff frequency of 2000 Hz

[bcheb, acheb] = cheby1(4, 6, 2*pi*2000, 's');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition Nonlinear characteristic %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NLScaling = 20;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition random phase multisine experiment % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% random phase multisine parameters
fmax = 2e3;							% maximal frequency 2 kHz
F = 500;								% number of frequencies (0, fmax]
N = fs/fmax*F;							% number of points per period
ExcitedHarm = 1:1:F;                  % excited harmonics multisine
Ampl = ones(size(ExcitedHarm));         % amplitudes random phase multisine
freq = ExcitedHarm*fs/N;                    % excited frequencies multisine
rms = 2;                                % rms value multisine

% parameters experiment
P = 2;                                  % number of consecutive periods multisine
M = 25;                                  % number of independent repeated experiments
Rall = zeros(M, F);                     % reference spectrum for all realisations
Uall = zeros(M, P, F);                  % input spectrum for all realisations and all periods
Yall = zeros(M, P, F);                  % output spectrum for all realisations and all periods


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Disturbing input/output noise %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stdu = 0*rms/10;
stdy = 0*sqrt(N/2/F)/50;                   % output noise standard deviation


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation of P periods of the steady state %
% response of the Winer-Hamerstein system to  %
% M random multisine excitations              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calculation of the linear transfer functions in the WH-model from DC to Nyquist
% at the resolution of the multisine period
freqN = (0:1:N/2)*fs/N;
sN =  2*pi*freqN*sqrt(-1);
Gfirst = 1./polyval([1/(2*pi*f0)^2 1/(Q*2*pi*f0) 1], sN);
Gsecond = 5./polyval([Tau 1], sN);
Gactuator = polyval(bcheb, sN) ./ polyval(acheb, sN);

for mm = 1:M
	
	home;
	mm;
   
	% calculate the reference signal r(t)
    r = CalcMultisine(ExcitedHarm, N);          % rms value = 1
    r = rms * r.';
	
    % calculate the noiseless output u0(t) of the actuator
    R = fft(r);
    U0 = zeros(1,N);
    U0(1:N/2+1) = Gactuator.*R(1:N/2+1);
    % take 2 times real part since the complex conjugate was not added in U0
    u0 = 2*real(ifft(U0));
 
	% calculate the noiseless output y0(t) of the Wiener-Hammerstein system	
	[y0, z] = WH_NL(u0, Gfirst, 'tanh', NLScaling, Gsecond);
	
	% calculate scaled input output spectra at the excited frequencies
	U0 = fft(u0);
	U0 = U0(2:F+1)/sqrt(N);                     % select the excited frequencies
	Y0 = fft(y0);
	Y0 = Y0(2:F+1)/sqrt(N);                     % select the excited frequencies
	
	for pp = 1:P
		% add measurement noise on input spectrum
		Uall(mm, pp, :) = U0 + stdu*(randn(size(U0)) + sqrt(-1)*randn(size(U0)))/sqrt(2);
        
		% add measurement noise on output spectrum
		Yall(mm, pp, :) = Y0 + stdy*(randn(size(Y0)) + sqrt(-1)*randn(size(Y0)))/sqrt(2);
	end % pp
    
    % reference signal mm th realisation
	Rall(mm, :) = R(2:F+1)/sqrt(N);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nonlinear analysis based on the FRFs, the IO spectra without reference, %
% and the IO spectra with reference signal                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% calculate the mean FRF, its sample variance, the noise variance, and the
% variance of the stochastic nonlinear contributions in case the reference
% signal is available
[G_ref, Y_ref, U_ref, CYU_ref] = Robust_NL_Anal(Yall, Uall, Rall);

 plot(freq, db(G_ref.mean), 'k', freq, db(G_ref.stdNL), 'r', freq, db(G_ref.stdn), 'g', freq, db(G_ref.stds), 'b')
 xlabel('Frequency (Hz)'); ylabel('G_{BLA}(j\omega_k) (dB)');title('With reference signal: total variance (red), noise variance (green), stochastic NL distortion (blue)');


%% ILC

    u_ref = CalcMultisine(ExcitedHarm, N).';    
    
    U = fft(u_ref);
    Y_ref = zeros(size(U));
    Y_ref(1:F) = G_ref.mean.*U(1:F);
    y_ref = 2*real(ifft(Y_ref)); % we want a perfect gain
    
    uj = zeros(1,N);
    Yj = zeros(size(y_ref));
    invG = G_ref.mean.^-1;
    iterationsILC = 30;
    meanError = zeros(1,iterationsILC);
    
    for i = 1:iterationsILC
            [yj, z] = WH_NL(uj, Gfirst, 'tanh', NLScaling, Gsecond);
            % Compute error
            e = y_ref-yj;
            meanError(i) = mean(e.^2);
            % ILC rule : u_j+1 = u_j + G_BLA^-1*ej;
            E = fft(e);
            dU = zeros(1,N);
            dU(1:F) = invG.*E(1:F);
            du = 2*real(ifft(dU)); 
            
            Q  = 1;
            L = 0.5;
            uj = Q*(uj + L*du);
    end
    
    figure;
        subplot(311);
            plot(db(meanError),'x'); xlabel('Iteration'); ylabel('db(MSE)')
            title('MSE of y_{desired} - y_j')

        subplot(312); hold all;
            i = 50:250;
            plot(y_ref(i),'-');
            plot(yj(i),'x');
            xlabel('time'); ylabel('Amplitude')
            legend('y_{ref}','yj')
            title('Comparison y_d and y_{ref} ')
            
        subplot(313);
            plot(e,'x'); xlabel('time'); ylabel('error')
            title('y_{desired} - y_j')

            fprintf('L = %g \nMSE : %g dB \n',L,db(meanError(end)));
    
        figure;

        subplot(211); hold all;
            i = 50:250;
            plot(db(fft(y_ref)),'-');
            plot(db(fft(yj)),'x');
            xlabel('freq'); ylabel('Amplitude')
            legend('y_{ref}','yj')
            title('Comparison y_d and y_{ref} ')
            
        subplot(212);
            plot(db(fft(e)),'x'); xlabel('freq'); ylabel('error')
            title('y_{desired} - y_j')              