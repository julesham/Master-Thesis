%
% Validate the model
%
[BLA_DPD, p] = wiener_estim(ILC_Measurements);


y_ref = ILC_Measurements.y_ref(1,:).';

% Real Data 
uj = squeeze(ILC_Measurements.uj(1,end,:));
yj = squeeze(ILC_Measurements.yj(1,end,:));
y1 = squeeze(ILC_Measurements.yj(1,1,:));
% Model
W     = zeros(4096,1);
Y_ref = fft(y_ref);
W(ExcitedHarmILC+1)= (BLA_DPD.mean.').*Y_ref(ExcitedHarmILC+1); 
w = 2*real(ifft(W));

ujModel = polyval(p,w);

signal = repmat(ujModel,5,1);
[ yjmeas, ujmeas ] = SYS_WH(signal);

yjmeas = yjmeas(4*4096+1:end);


figure;
hold all;
plot(db(fft(yj)),'.');
plot(db(fft(yjmeas)),'.');
plot(db(fft(y1)));
plot(db(fft(y_ref)),'o');


legend('yj from ILC','y from DPD','without compensation','y_ref');
