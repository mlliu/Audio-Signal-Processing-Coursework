close all; clear all; clc;
%% read audio signal
 %audiofile = '../part2/part2.wav';
 audiofile = '../audio/Sample1.wav';
% for ii =1:10
%     audiofile = strcat('../audio/Sample',int2str(ii),'.wav');
textfile = '../audio/Sample1.txt';
[in_aud,fs] = audioread(audiofile);

%x = mean(x, 2); % mono
%% normalize and pre-EmphasisFilter
in_aud = 0.9*in_aud/max(abs(in_aud)); % normalize
%in_aud = filter([1 -0.95],1,in_aud);
%% parameters

p_voiced = 16; % lpc order for voiced frame
p_unvoiced = 6; %lpc order for unvoiced frame
frame_len=40; % frame length ms
step_len=30; % step length ms

% convert from time [ms] to number of samples
winLen=floor(frame_len*fs/1000);
step=floor(step_len*fs/1000);
%% window 
window = hann((winLen),'periodic'); 
%window = hamming((winLen),'periodic');
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
%  [a,g] = lpc(frames,p);
%  gain = sqrt(g);

%walk through each frame, check voiced or unvoiced
%walk through each frame, record pitch
%% pitch detector
freq = pitch_detector_FFT(in_aud, winLen, step,window);
%freq = pitchDetector_xcorr(in_aud, winLen, step,window,fs);
%% synthesis
    offset = 0;
    syn_aud = zeros(step*count, 1);
    impulse = zeros(step*count, 1);
    total_a = [];
    total_gain = [];
    
    for i = 1:count
        frame = frames(:,i);
        % create source
        if freq(i) > 0 % pitched
        %if freq(i+winLen/step-1)~=0
            excitation = zeros(step,1);
            %period = round(fs/freq(i+winLen/step-1));
            period = round(1/freq(i)); %FFT
            
            
            position = (offset+1):period:step;
            
            if ~isempty(position)
                %update offset
                offset = period + position(end) - step;
                %the power of impulse need to be sqrt(period)
                excitation(position) = sqrt(period); 
            end
            %finds the coefficients and gains for each frame,
            [a,g] = lpc(frame,p_voiced);
            gain = sqrt(g);
            total_a =[total_a a];
            total_gain = [total_gain gain];
            
        else
            excitation = randn(step, 1); % noise
            offset = 0;
            [a,g] = lpc(frame,p_unvoiced);
            gain = sqrt(g);
            total_a =[total_a a];
            total_gain = [total_gain gain];
        end
        
        % filter
        %syn_aud( step*i + (1:step) ) = filter(1, a(i,:), gain(i)*src);
        % reconstruct the signal 
        syn_aud( step*i + (1:step) ) = filter(1, a, gain*excitation);
        impulse (step*i + (1:step))= excitation;
    end

%% deEmphasisFilter

subplot(2,1,1);
plot(in_aud);
title('Input Audio Signal');
subplot(2,1,2);
plot(syn_aud);
title('LPC-decoded Audio Signal');
% sound(in_aud,fs)
pause(1);
 sound(syn_aud,fs)
%% write audio
% outname = strcat('../syn_audio/Sample',...
%     int2str(ii),'received.wav');
% 
% outname = strcat('../part2/part2_',...
%     'received.wav');
%   audiowrite(outname,syn_aud,fs)

 %end
% disp(length(in_aud)/fs)
% disp(length(total_a) +length(total_gain)*2)