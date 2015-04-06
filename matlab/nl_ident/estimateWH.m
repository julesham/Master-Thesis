% clear; clc; close all;
% load('PA8');
u_first = squeeze(ilc_DPD.uj(1,1,:));
r_first = squeeze(ilc_DPD.u_ref(1,1,:));
for nn = 2:ilcM
    [ilc_DPD.uj(nn,1,:),ilc_DPD.yj(nn,1,:)] = compensateAWGDelay(squeeze(ilc_DPD.uj(nn,1,:)),squeeze(ilc_DPD.yj(nn,1,:)),squeeze(ilc_DPD.u_ref(nn,1,:)),u_first,r_first,ExcitedHarmILC);
    ilc_DPD.uj(nn,2,:) = ilc_DPD.uj(nn,1,:);
    ilc_DPD.yj(nn,2,:) = ilc_DPD.yj(nn,1,:);
end


U_ref = fft(ilc_DPD.u_ref,[],3)/sqrt(N);
Uj    =  fft(ilc_DPD.uj,[],3)/sqrt(N);
U_ref = U_ref(:,:,ExcitedHarmILC+1);
Uj = Uj(:,:,ExcitedHarmILC+1);

BLA_DPD = Robust_NL_Anal(Uj,U_ref); 
figure('Name','Best Linear Approximation'); title('BLA')
subplot(211);
hold all;
plot(db(BLA_DPD.mean)); title('BLA Amplitude')
plot(db(BLA_DPD.stdNL));
plot(db(BLA_DPD.stdn),'x');
subplot(212);
plot(angle(BLA_DPD.mean)/pi);title('BLA Phase'); ylim([-1 1]);


%%  estimate Wiener System
W = zeros(ilcM, N);

%  u_ref -> LIN - (w) -  SNL -> uj
% 1) Create w
for mm = 1:ilcM
    W(mm,ExcitedHarmILC+1) = BLA_DPD.mean.*squeeze(U_ref(mm,1,:)).';
end
w = 2*real(ifft(W,[],2));
% 2) Estimate polynomial p such that uj = p(w)
w_validation = w(ilcM,:);
w_training = w(1:ilcM-1,:);
u_validation = squeeze(ilc_DPD.uj(ilcM,1,:));
u_training = ilc_DPD.uj(1:ilcM-1,1,:);
u_training = reshape(u_training,1,[]);
w_training = reshape(w_training,1,[]);
%Which Order?
figure('Name','Wiener'); hold on;
for order = 1:10;
    p = polyfit(w_training,u_training,order);

error = mean( (polyval(p,w_training)-u_training).^2 );
plot(order,db(error),'ro');
error = mean( (polyval(p,w_validation)-u_validation.').^2 );
plot(order,db(error),'ko');
legend('Training error','Validation error'); xlabel('Polynom Order'); ylabel('db(MSE)')
end

%%  estimate HammerStein System
W = zeros(ilcM, N);

%  u_ref -> SNL - (w) -  LIN -> uj
for mm = 1:ilcM
    W(mm,ExcitedHarmILC+1) = (BLA_DPD.mean.^-1).*squeeze(Uj(mm,1,:)).';
end
w = 2*real(ifft(W,[],2));

% 2) Estimate polynomial p such that w = p(u_ref)
w_validation = w(ilcM,:);
w_training = w(1:ilcM-1,:);
u_validation = squeeze(ilc_DPD.u_ref(ilcM,1,:));
u_training = ilc_DPD.u_ref(1:ilcM-1,1,:);
u_training = reshape(u_training,1,[]);
w_training = reshape(w_training,1,[]);
%Which Order?
figure('Name','Hammerstein'); hold on;
for order = 1:10;
    p = polyfit(w_training,u_training,order);

error = mean( (polyval(p,w_training)-u_training).^2 );
plot(order,db(error),'ro');
error = mean( (polyval(p,w_validation)-u_validation.').^2 );
plot(order,db(error),'ko');
legend('Training error','Validation error'); xlabel('Polynom Order'); ylabel('db(MSE)')
end