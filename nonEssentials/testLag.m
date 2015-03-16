N = 1024;
ExcitedHarm = 1:floor(N/8);
r = 0.3*CalcMultisine(ExcitedHarm,N);

EXP = 2;
TRAN = 3;
UR = zeros(EXP,N);
for experiment = 1:EXP
    rr = repmat(r,TRAN+1,1);
    [y,u] = SYS_VXI(rr);      % measure an experiment
    y = y(TRAN*N+1:end);
    u = u(TRAN*N+1:end);
    UR(experiment,:) = fft(y)./fft(r);    % Compute the phase difference between input and
                             % reference
end

subplot(211); plot((db(UR).')); xlim([min(ExcitedHarm) max(ExcitedHarm)]); shg
subplot(212); plot((angle(UR).'));xlim([min(ExcitedHarm) max(ExcitedHarm)]); shg