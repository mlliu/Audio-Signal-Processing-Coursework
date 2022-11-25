function signal =GL(magnitude,fs,iter,winlen,overlap)
% magnitue : magnitude (winlen x number of frame)
% Iter: iteration number (1 x1)
% winlen: analysis window length (winlen x1)
% overlap: window overlap

    
    %magnitude = abs(spectrum);
    %phase = randn(size(magnitude)).*2*pi*1i; % randomly initialize, the shape is same with music
    %phase = phase./(abs(phase)+eps); %
    %phase = 0.001*spectrum./(abs(spectrum)+eps);
    phase = ones(size(magnitude));
    for m = 1:iter
        xi = magnitude.*phase;
        signal = istft(xi,fs,'Window',hamming(winlen,'periodic'),'OverlapLength',overlap);
        next_xi = stft(signal,fs,'Window',hamming(winlen,'periodic'),'OverlapLength',overlap);
        phase = next_xi./abs(next_xi+eps);
    end
    xi = magnitude.*phase;
    signal = istft(xi,fs,'Window',hamming(winlen,'periodic'),'OverlapLength',overlap);
    %signal = real(signal);
end