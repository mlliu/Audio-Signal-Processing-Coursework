

function pitch = pitch_detector_FFT(in_aud, winLen, step,window)
% audiofile = '../audio/Sample1.wav';
% [in_aud,fs] = audioread(audiofile);
% 
% %% normalize and pre-EmphasisFilter
% in_aud = 0.9*in_aud/max(abs(in_aud)); % normalize
% %in_aud = filter([1 -0.95],1,in_aud);
% %% parameters
% p = 6; % lpc order
% frame_len=30; % frame length ms
% step_len=15; % step length ms
% 
% % convert from time [ms] to number of samples
% winLen=floor(frame_len*fs/1000);
% step=floor(step_len*fs/1000);
% window = hann((winLen),'periodic'); % hamming
    %% frame and add window
    
    len=length(in_aud);
    count = floor((len-winLen)/step)+1;
    
    frames = zeros(winLen, count);
    for i = 1:count
        frames(:, i) = window .* in_aud( (1:winLen) + (i-1)*step );
    end
    fs=1;
    np = 5;

    %% set limit to the pitch freqency and power
     min_power = -30;
     max_freq = 0.125;
     max_harm = 0.5;
    
    freq = zeros(np, count); % frequencies

    for i = 1:count
        frame = frames(:,i);
        %compute the power of the frame
        power(i) = 10*log10(mean(frame.^2));
        
        % compute the spectrum
        points = 4*2^nextpow2(length(frame));
        spec = abs(fft(frame, points));
        spec = spec(1:points/2);
        spec = spec/max(spec); % normalize
        
        % find peak frequency
        [~, l] = findpeaks(spec, 'npeaks', np, 'sortstr', 'descend');
        axis = ((1:points)-1)/points*fs;
        freq(:,i) = sort( axis(l) );
    
        
    end

    % check for harmonics
    f0 = freq(1,:);
    fm = freq./( ones(np, 1) * f0 );
    diff = fm - (1:np)' * ones(1, count);
    diff = diff(1:floor(np/2),:);
    ddf = max(abs(diff));
    
    % check unvoiced frames and set them as 0
    pitch = freq(1,:); %fundamental frequency
    for i =1:count
        if pitch(i)>max_freq
            pitch(i)=0;
        end
        if power(i)< min_power
            pitch(i)=0;
        end
        if ddf(i)>max_harm
            pitch(i)=0;
        end

    end
end