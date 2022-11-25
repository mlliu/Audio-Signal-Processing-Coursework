close all; clear all; clc;
%% read audio signal
audiofile = '../audio/Sample1.wav';
%for ii =1:10
%    audiofile = strcat('../audio/Sample',int2str(ii),'.wav');
textfile = '../audio/Sample1.txt';
[in_aud,fs] = audioread(audiofile);

%x = mean(x, 2); % mono
%% normalize and pre-EmphasisFilter
in_aud = 0.9*in_aud/max(abs(in_aud)); % normalize
%in_aud = filter([1 -0.95],1,in_aud);
%% parameters
p = 48; % lpc order
frame_len=30; % frame length ms
step_len=20; % step length ms

% convert from time [ms] to number of samples
winLen=floor(frame_len*fs/1000);
step=floor(step_len*fs/1000);
window = hann((winLen),'periodic'); % hamming
%window = ones(winLen,1);

%% get the frequency of audio signal per 10ms from txt file
freq = importdata(textfile);
%period = floor(fs./freq);


%% frame and add window
len=length(in_aud);
count = floor((len-winLen)/step)+1;

frames = zeros(winLen, count);
for i = 1:count
    frames(:, i) = window .* in_aud( (1:winLen) + (i-1)*step );
end
%% finds the coefficients and gains for each frame,
[a,g] = lpc(frames,p);
gain = sqrt(g);

%walk through each frame, check voiced or unvoiced
%walk through each frame, record pitch
%% pitch detector
freq = pitch_detector_FFT(in_aud, winLen, step,window);
%F = pitchDetector(in_aud, winLen, step,window,fs);
%% synthesis

    offset = 0;
    syn_aud = zeros(step*count, 1);
    impulse = zeros(step*count, 1);
    
    for i = 1:count
        
        % create source
        if freq(i) > 0 % pitched
        %if freq(i+winLen/step-1)~=0
            excitation = zeros(step,1);
            
            period = round(1/freq(i)); %FFT
            
            pulse = triangle_pulse(period);
            pts = (offset+1):period:step;
            
            if ~isempty(pts)
                offset = period + pts(end) - step;
                %src(pts) = sqrt(period);
                for start = pts
                 
                    start = start+(i-1)*step;
                    impulse(start:start+period-1) = pulse; % impulse train, compensate power
                end
            end
            
        else
            excitation = randn(step, 1); % noise
            impulse (step*(i-1) + (1:step))= excitation;
            offset = 0;
        end
        
        % filter
        %syn_aud( step*i + (1:step) ) = filter(1, a(i,:), gain(i)*src);
        %impulse (step*i + (1:step))= src;
    end
    for i =1: count
        excitation = impulse(step*(i-1)+(1:step));
        syn_aud( step*i + (1:step) ) = filter(1, a(i,:), gain(i)*excitation);
    end

%% deEmphasisFilter
%syn_aud = filter(1,[1 -0.95],syn_aud);
subplot(2,1,1);
plot(in_aud);
title('Input Audio Signal');
subplot(2,1,2);
plot(syn_aud);
title('LPC-decoded Audio Signal');
sound(syn_aud,fs)
%% write audio
% outname = strcat('../syn_audio_triangle_pulse/Sample',int2str(ii),'_',int2str(p),...
%     '_',int2str(frame_len) ,'ms_',int2str(step_len),'ms.wav');
% 
% audiowrite(outname,syn_aud,fs)

%end