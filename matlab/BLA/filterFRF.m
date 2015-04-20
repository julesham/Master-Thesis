function y = filterFRF(FRF,ExcitedHarmBLA,u)
% Filters the u signal trough the FRF
% FRF should be a G.mean from the FDT Toolbox
% u is a N x 1 input sequence

    N = length(u);
    FRF = FRF.';
    U = fft(u);
    Y = zeros(N,1);
    Y(ExcitedHarmBLA+1) = FRF.*U(ExcitedHarmBLA+1);

y = 2*real(ifft(Y)); % desired output
