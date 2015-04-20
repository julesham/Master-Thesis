clear; close all;

N = 1000;
P = 10;
hid = [7 -3 10 6];
r = (0:N-1).';
u = repmat(r,P,1);

y = conv(u,hid);

u = u((P-1)*N+1:P*N);
y = y((P-1)*N+1:P*N);


h = modelFIR(u,y,10);