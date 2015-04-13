function [ILC_Measurements]= ilcFRF(ILC_Measurements,realisation)
% applies ilc algorithm to find an input that generates the wanted output
transientPeriods    = ILC_Measurements.T;
totalPeriods        = transientPeriods+1; % we ony need one measurement period!
N                   = length(ILC_Measurements.u_ref(realisation,:));
invG                = ILC_Measurements.BLAInfo.BLA_RO.mean.^-1;
ExcitedHarmBLA      = ILC_Measurements.BLAInfo.ExcitedHarmBLA;
DUT                 = ILC_Measurements.DUT;


uj = ILC_Measurements.u_ref(realisation,:).';                     % first iteration is reference input
y_ref = ILC_Measurements.y_ref(realisation,:).'; 
for ii = 1:ILC_Measurements.iterations
    
        fprintf('\tILC Iteration : %g/%g\n',ii,ILC_Measurements.iterations);  
        rr = repmat(uj,totalPeriods,1);
        [yj, um ]  = feval(ILC_Measurements.DUT, rr );
        
        yj = yj(transientPeriods*N+1:totalPeriods*N); % transient removal
        um = um(transientPeriods*N+1:totalPeriods*N);
        
      
      %%%
      % Delay Compensation
      %%%
      
        if strcmp(DUT,'SYS_VXI')
                     delay  = compensateAWGDelayv3(um,uj,ILC_Measurements.ExcitedHarmILC);
                     um     = circshift(um,-delay);
                     yj     = circshift(yj,-delay);
        end

        % Compute error
        e = y_ref-yj;
        
        % ILC rule : u_j+1 = u_j + G_BLA^-1*ej;
        E = fft(e);
        dU = zeros(N,1);
        dU(ExcitedHarmBLA+1) = (invG.').*E(ExcitedHarmBLA+1);
        du = 2*real(ifft(dU)); 
        uj = uj + du;
        



      %%%
      % Save Everything
      %%%
      ILC_Measurements.uj(realisation,ii,:) = uj;   %reference input
      ILC_Measurements.um(realisation,ii,:) = um;   % measured input
      ILC_Measurements.yj(realisation,ii,:) = yj;   % measured output
      ILC_Measurements.error(realisation,ii,:) = e;   % error y_ref-yj

end
        