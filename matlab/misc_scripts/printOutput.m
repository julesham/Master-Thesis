fprintf('System used = %s \n',DUT);  
% fprintf('MSE between periods of y = %E\n',transientError);  
fprintf('Iterations ILC = %g \n',iterationsILC);  
E = fft(e)/sqrt(time.N);
MSEBLA = mean( 2*real(ifft(E(ExcitedHarmBLA+1))*sqrt(time.N)).^2 );
fprintf('MSE over BLA freq = %g dB \n',db(MSEBLA));
fprintf('Script ended in %g sec.\n',toc);