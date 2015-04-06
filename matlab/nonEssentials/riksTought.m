load('measurement2.mat','Yall','Rall','Uall','ExcitedHarmBLA','N');
size(Yall)
size(Rall)
YY=squeeze(Yall(:,1,:)); % take one period
size(YY)
YR = YY./Rall; % Project on reference
YRmean=mean(YR,1); % Take mean along realizations
YRstd=std(YR,[],1); % idem for std
% figure;plot(db([YRmean.', YRstd.']));shg
% figure;plot(db(YR.'));shg
disp(pi*250/2048)

UU=squeeze(Uall(:,1,:));
UR = UU./Rall;

% figure;plot(ExcitedHarmBLA/N,angle(YR.')/pi); title('Output Phase'); ylabel('x\pi radians')
figure;plot(ExcitedHarmBLA/N,angle(UR.')/pi); title('Input Phase'); ylabel('x\pi radians')
figure;plot(ExcitedHarmBLA/N,angle( ( UR(1,:)./UR(2,:) ).' ),'x'); ylabel('x\pi radians')

polyfit(ExcitedHarmBLA/N*2*pi,angle( ( UR(1,:)./UR(2,:) ).' ),1)