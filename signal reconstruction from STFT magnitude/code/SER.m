function result = SER(magnitude,re_sig,win,winLen,step,Ls)

% magnitude : magnitude of original signal
% re_sig : reconstructed signal

%%%%%%%%%  spectrogram   %%%%%%%%
idx = (1:winLen)' + (0:step:Ls-winLen);
spectrum = STFT(re_sig(idx),win);  
re_magn = abs(spectrum);




%%%%%%%%%   SER  %%%%%%%%%%%%%
numerator = sum(magnitude.^2,"all");
denominator = sum((magnitude - re_magn).^2,"all");
result = 10*log10(numerator/denominator);

end
