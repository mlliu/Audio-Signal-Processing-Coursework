function pitch = pitchDetector_xcorr(in_aud, winLen, step,window,fs)
%     clc; clear all;
%     audiofile = '../audio/Sample2.wav';
%     [in_aud fs] = audioread(audiofile);
%     frame_len=30; % frame length ms
%     step_len=10; % step length ms
%     
%     % convert from time [ms] to number of samples
%     winLen=floor(frame_len*fs/1000);
%     step=floor(step_len*fs/1000);
%     window = hann((winLen),'periodic'); % hamming



    %% frame and add window
    len=length(in_aud);
    count = floor((len-winLen)/step)+1;
    
    frames = zeros(winLen, count);
    for i = 1:count
        frames(:, i) = window .* in_aud( (1:winLen) + (i-1)*step );
    end
    
    %% set the limit for the pitch period
    max_period = round(1/90*fs);
    min_period = round(1/140*fs);
    
    pitch =[];
    for k = 1 : count
        
        frame = frames(:,k);
         
        %auto-correlation for each frame
        [corr ~] = xcorr(frame, frame);
        %for those negative correlation values, set the to 0
        corr(find(corr < 0)) = 0; 
        % find the fist zero after center
        center_peak_width = find(corr(winLen:end) == 0 ,1);
        %center of rxx is located at length(frame)+1
        if center_peak_width == winLen
            center_peak_width = winLen-1;
        end
        % cancel off the central peak 
        corr(winLen-center_peak_width : winLen+center_peak_width  ) = min(corr);
        % find the second highest peak
        [a loc] = max(corr);
        % the distance between the second highest peak with the central
        % peak is the period
        period = abs(loc - length(frame)+1); 
        
        %limit 
        if min_period < period && period < max_period
            pitch =[pitch,1/period];
        else
            pitch =[pitch,0];
        end

         
    
    end
 
end