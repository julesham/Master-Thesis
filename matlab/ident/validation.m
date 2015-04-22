%%%
% Estimation and Validation of DPD Model
%%%

% Definition of MODEL struct
% MODEL.type = WFIR / Wiener / HFIR / NLFIR / NARMA
% MODEL.parameters ; vector will all parameters
% y = steadyStateResponse(MODEL,u) gives the second of two periods response model to input u
close all;

N = time.N; 
ExcitedHarmILC = ILC_Measurements.ExcitedHarmILC;
DUT = 'SYS_H';
P = 1; 
T = 3;

%% Validation
% Get reference output
y_ref = ILC_Measurements.y_ref(2,:).';
% Real Data (Converged I/O and )
uj = squeeze(ILC_Measurements.uj(1,end,:));
yj = squeeze(ILC_Measurements.yj(1,end,:));
y1 = squeeze(ILC_Measurements.yj(1,1,:));

% ** Wiener Model **
Wiener.type = 'Wiener';
[BLA_DPD, p] = wiener_estim(ILC_Measurements);
Wiener.parameters = [BLA_DPD.mean(:) ; p(:)];
Wiener.ExcitedHarm = ILC_Measurements.ExcitedHarmILC;

ujModel1 = steadyStateResponse(Wiener,y_ref);

signal = repmat(ujModel1,T+P,1);
[ yjBLA, ujmeas1 ] = feval(DUT,signal);  % Response of SYS
yjBLA(1:T*N)       = [];              % eliminate transients

% ** WFIR Model **
WFIR.type = 'WFIR';
[hfir,pfir]     = WFIR_estim(ILC_Measurements);
WFIR.parameters = [hfir(:);pfir(:)];
WFIR.orderH     = length(hfir);
ujWFIR = steadyStateResponse(WFIR,y_ref);

signal = repmat(ujWFIR,T+P,1);
[ yjWFIR, ~ ] = feval(DUT,signal);
yjWFIR(1:T*N) = []; % eliminate transients

% ** HFIR Model **
HFIR.type = 'HFIR';
[hfir,pfir]     = WFIR_estim(ILC_Measurements);
HFIR.parameters = [hfir(:);pfir(:)];
HFIR.orderH     = length(hfir);
ujHFIR = steadyStateResponse(HFIR,y_ref);

signal = repmat(ujHFIR,T+P,1);
[ yjHFIR, ~ ] = feval(DUT,signal);
yjHFIR(1:T*N) = []; % eliminate transients

%% Optimise
fprintf('Optimisation\n');
    optLSQ = optimset('TolX',1e-15,'TolFun',1e-15,'MaxIter',1e3,'MaxFunEvals',1000*N,'PlotFcns',@fOptimPlotResNorm ,...
        'Jacobian','off','Algorithm','levenberg-marquardt','DerivativeCheck','off');
    
    model = WFIR;
    cost = @(parameters) modelCost(model,parameters,ILC_Measurements);
    WFIR.parameters = lsqnonlin(cost,model.parameters,[],[],optLSQ);
    
    model = HFIR;
    cost = @(parameters) modelCost(model,parameters,ILC_Measurements);
    HFIR.parameters = lsqnonlin(cost,model.parameters,[],[],optLSQ);
    

% Response of FIR
ujOptWFIR = steadyStateResponse(WFIR,y_ref);
% Pass trough system
signal = repmat(ujOptWFIR,T+P,1);
[ yjoptWFIR, ~ ] = feval(DUT,signal);
yjoptWFIR(1:T*N) = []; % eliminate transients

%%
u = CalcMultisine(ExcitedHarmILC,N);
ujOptWFIR = steadyStateResponse(WFIR,y_ref);


%%
% Response of FIR
ujOptHFIR = steadyStateResponse(HFIR,y_ref);
% Pass trough system
signal = repmat(ujOptHFIR,T+P,1);
[ yjoptHFIR, ~ ] = feval(DUT,signal);
yjoptHFIR(1:T*N) = []; % eliminate transients

%%%
% Plots
%%%
freq = (0:N-1)/N;
figure; hold all; 
plot(freq,db(fft(yj)));
plot(freq,db(fft(yjoptHFIR)),'+');
plot(freq,db(fft(y1)));
Y_ref = fft(y_ref);
plot(ExcitedHarmILC/N,db(Y_ref(ExcitedHarmILC+1)),'o');
title('Output Spectrum of PA'); legend('ILC','HFIR OPT','no compensation','Ideal Response')

figure; hold all; 
plot(freq,db(fft(yj)));
plot(freq,db(fft(yjoptWFIR)),'+');
plot(freq,db(fft(y1)));
Y_ref = fft(y_ref);
plot(ExcitedHarmILC/N,db(Y_ref(ExcitedHarmILC+1)),'o');
title('Output Spectrum of PA'); legend('ILC','WFIR OPT','no compensation','Ideal Response')

figure; hold all; 
plot(freq,db(fft(yj)));
plot(freq,db(fft(yjWFIR)),'+');
plot(freq,db(fft(y1)));
Y_ref = fft(y_ref);
plot(ExcitedHarmILC/N,db(Y_ref(ExcitedHarmILC+1)),'o');
title('Output Spectrum of PA'); legend('ILC','FIR','no compensation','Ideal Response')


figure; freq = (0:N-1)/N;
hold all; plot(freq,(ujModel1-uj));plot(freq,(ujWFIR-uj));plot(freq,(ujOptWFIR-uj));legend('BLA', 'FIR','optimFIR');
title('|uj_{MODEL}-uj_{ILC}|')