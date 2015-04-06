function y_ref = filterFRF(FRF,ExcitedHarmBLA,u_ref)
    N = length(u_ref);
    FRF = FRF.';
    U = fft(u_ref);
    Y_ref = zeros(N,1);
    Y_ref(ExcitedHarmBLA+1) = FRF.*U(ExcitedHarmBLA+1);

y_ref = 2*real(ifft(Y_ref)); % desired output
