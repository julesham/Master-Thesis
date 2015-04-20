function A = estim_NLFIR(ILC_Measurements)
u  = ILC_Measurements.y_ref.';
y  = squeeze( ILC_Measurements.uj(:,end,:) ).';

[Ny, ~]  = size(y);
[Nu, Ru]  = size(u);
K   = nan(Ny,M);
Ktotal = [];
for rr = 1:Ru
        for k = 1:Ny 
            for m = 1:M
                ind = k-m+1;
                if ind < 1; ind = ind+Nu; end
                K(k,m) = u(ind,rr);
            end
        end
        Ktotal = [Ktotal ; K];
end
% y = K*h
h = Ktotal\y(:);
eTot = [];
for rr=1:Ru
 ym = conv(h,repmat(u(:,rr),2,1));
 ym = ym(Ny+1:2*Ny);    
 err = y(:,rr)-ym;
 eTot = [eTot , err];
end

e = norm(eTot(:))^2./numel(eTot);

end