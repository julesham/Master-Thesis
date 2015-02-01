
function [u,e] = ILC(num,den,Q,L,yd,iter,noise)
% [u,e] = ILC(num,den,Q,L,yd,iter,noise)
% Updates the input with rule u(j+1) = Q*(u(j) + L*e(j+1))
% with the error(j) = y(j) - yd 
% y(j) is the response of the systen P(z) = num/den of input u(j)
% iter : number of iterations the algorithm
% noise( boolean ) : add noise with  average = 0 and std = 0.01

    N = length(yd);
    n = 0:N-1; 
    figure; hold on;
    title('Evolution of error'); xlabel('Iteration'); xlim([0 iter]);
    u = zeros(N,1); % init
    for j = 0:iter
        y = filter(num,den,u)+0.01*noise*randn(N,1); % get response from input
        e  = yd-y;                % compute error
        u(1:N-1) = Q*( u(1:N-1) + L*e(2:N) );         % update input
        % plot norm of error
        plot(j,db(norm(e)),'xk');
    end
    figure;
    subplot(2,1,1); plot(n,u); title('Input'); xlabel('Time')
    subplot(2,1,2); hold on; plot(n,yd,'s'); plot(n,y,'x'); 
    legend('Desired output', 'Output','Location','best');
end
