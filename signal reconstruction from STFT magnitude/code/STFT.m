function C = STFT(sig,win)
%stft for each frame

%sigLC = circshift(sig,winLen/2);
%idx = (1:winLen)' + (0:skip:Ls-winLen);
%C = fft(ifftshift(sigLC(idx).*win,1));
%C = fft(ifftshift(sig(idx).*win,1));
%hWL = floor(winLen/2);
%C = C(1:hWL+1,:).*exp(-2i*pi*(mod((0:hWL)'*(0:size(C,2)-1)*skip,winLen)/winLen));

%disp(length(sig));
C = fft(win.*sig);

end
