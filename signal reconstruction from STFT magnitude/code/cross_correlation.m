%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cross correlation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mycc = cross_correlation(x1,x2,winlen)
% cross correlation is essentially the same as convolution with the first
% signal being reverted. In principle we also need to take the complex
% conjugate of the reversed x, but since audio signals are real valued we
% can skip this operation.
%cc = conv(x1(length(x1):-1:1),x2);

% restrict the cross correlation result to just the relevant values.
% Values outside of this range are related to deltas bigger or smaller
% than our tolerance allows
%cc = cc(winlen:end - winlen + 1);

% x1 : next x
% x2 : natural progression of x_m
%we iterate through each possible x_next
%and compute the similarity with natural progession
mycc = [];
for i  = 1:length(x1)-winlen+1
    newcc = sum(x1(i:i+winlen-1).*x2);
    %disp(newcc);
    mycc = [mycc, newcc];
   
end
%mycc = flip(transpose(mycc));
%isequal(mycc,cc)
end