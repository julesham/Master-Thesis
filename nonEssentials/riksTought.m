load('../measurement8.mat')
size(Yall)
size(Rall)
YY=squeeze(Yall(:,1,:));
size(YY)
YR = YY./Rall;
YRmean=mean(YR,1);
YRstd=std(YR,[],1);
% figure;plot(db([YRmean.', YRstd.']));shg
% figure;plot(db(YR.'));shg
figure;plot(ExcitedHarmBLA/N,unwrap(angle(YR.'))); title('Output Phase')
% disp(pi*250/2048)

UU=squeeze(Uall(:,1,:));
UR = UU./Rall;
figure;plot(ExcitedHarmBLA/N,unwrap(angle(UR.'))); title('Input Phase')