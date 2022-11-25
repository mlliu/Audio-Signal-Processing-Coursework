function sigr = GLA(magnitude,Iter,win,step,winLen)

X = magnitude;
A = magnitude;
Pc2 = @(X) A.*sign(X);
Pc1 = @(X) STFT(iSTFT(X,win),win);

for m = 1:Iter
    
    X = Pc1(Pc2(X));
    
end

sigr = iSTFT(X,win);
end
