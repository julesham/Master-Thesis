function [b,a,costML] = modelSelection(BLA_RO,ExcitedHarm,N,NA,NB)
F = length(ExcitedHarm)';
%% Parameters Esitmation

costs = nan(length(NA),length(NB));
costML = costs;
figure;


for naBla = NA;
    for nbBla = NB;
        [b{naBla+1,nbBla+1}, a{naBla+1,nbBla+1}, cost] = estimateParamBLA(BLA_RO,ExcitedHarm,N,naBla,nbBla);
        
%         if max(abs(roots(a{naBla+1,nbBla+1}))) < 1 % if stable
        if true    
        costs(naBla+1,nbBla+1) =  cost;
        p = log(2*(1+1)*F)*(naBla+nbBla)/(2*F-naBla-nbBla);
        costML(naBla+1,nbBla+1) = (2*F/(2*F-naBla-nbBla))*(cost+p);
        z = exp(1j*ExcitedHarm/N*2*pi);
        Gmodel = polyval(b{naBla+1,nbBla+1},z)./polyval(a{naBla+1,nbBla+1},z);
            
            
            clf;
            subplot(211); hold all; 
            plot(db(Gmodel)); 
            plot(db(BLA_RO.mean)); 
            title([num2str(naBla),'/',num2str(nbBla)]);
            
            subplot(212); hold all; 
            plot(angle(Gmodel)); 
            plot(angle(BLA_RO.mean)); 
            title([num2str(naBla),'/',num2str(nbBla)]);
            shg;
        end
    end
end
figure; bar3(((costs)));  xlabel('na'); ylabel('nb'); title('Yahou')
figure; bar3(((costML))); xlabel('na'); ylabel('nb'); title('ML')
