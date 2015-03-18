function [uj,yj,y1,meanError,e,ILC_Measurements]= ilcFRF(DUT,y_ref,u_ref,iterationsILC,Q,L,BLA,transientPeriods,ExcitedHarmILC,ExcitedHarmBLA)
% applies ilc algorithm to find an input that generates the wanted output
totalPeriods = transientPeriods+1;
F_BLA = length(BLA); 
N = length(y_ref);
invG = BLA.^-1;
meanError = zeros(1,iterationsILC);
uj = u_ref;
[yj, ~ ] = feval(DUT, repmat(uj,totalPeriods,1) );  % 
yj = yj(transientPeriods*N+1:totalPeriods*N);       % Transient 
y1 = yj;


ILC_Measurements.uj = zeros(iterationsILC,N);
ILC_Measurements.um = zeros(iterationsILC,N);
ILC_Measurements.yj = zeros(iterationsILC,N);
ILC_Measurements.y_ref = y_ref;
ILC_Measurements.u_ref = u_ref;

for ii = 1:iterationsILC
        
        fprintf('ILC Iteration : %g/%g\n',ii,iterationsILC);  
        % Compute error
        e = y_ref-yj;
        meanError(ii) = mean(e.^2);
        
        % ILC rule : u_j+1 = u_j + G_BLA^-1*ej;
        E = fft(e);
        dU = zeros(N,1);
        dU(ExcitedHarmBLA+1) = (invG.').*E(ExcitedHarmBLA+1);
        du = 2*real(ifft(dU)); 
        uj = Q*(uj + L*du);
        
      rr = repmat(uj,totalPeriods,1);
      [yj, um ]  = feval(DUT, rr );
      yj = yj(transientPeriods*N+1:totalPeriods*N); % transient removal
      um = um(transientPeriods*N+1:totalPeriods*N);
      
      %%%
      % Delay Compensation
      %%%
      if strcmp(DUT,'SYS_VXI')
          if ii == 1
              % We first save the first realization, and will synchronize the
              % following ones with this one.
              u_first = um;
              r_first = uj;
          else
              [um,ym] = compensateAWGDelay(um,ym,rr,u_first,r_first,ExcitedHarmILC);
          end
      end

      %%%
      % Save Everything
      %%%
      ILC_Measurements.uj(ii,:) = uj;
      ILC_Measurements.um(ii,:) = um;
      ILC_Measurements.yj(ii,:) = yj;
end
        