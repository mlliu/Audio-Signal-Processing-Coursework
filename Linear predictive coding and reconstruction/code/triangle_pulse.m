function[sig]=triangle_pulse(period)
%period = 100;
sig = zeros(period,1);
w = period/4*3;
t = -w/2+1:w/2;
s  = 0.4;
x = tripuls(t,w,s);
sig(period/4+1:end) = x*sqrt(period);
%plot(sig)