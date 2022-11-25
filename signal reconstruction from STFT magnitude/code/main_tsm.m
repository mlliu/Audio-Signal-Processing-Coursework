clear all;clc;
clear;
for i =1:12
    filename = strcat('../Project1Audio/audio',int2str(i),'.mov');
    [x,fs] = audioread(filename);
    N = length(x);
    t = (0:N-1)/fs;
    
    s = 2;              % time-stretch factor
    h_s = 512;      % hop size of the synthesis window. H_S
    winlen = 1024;      % length of window
    tolerance = 512;    % tolerance delta
    
    % y=wsola(x,winlen,h_s,s,tolerance);
    y=TSM_RTISI_LA(x,fs,winlen,h_s,s);
    outname = strcat('../tsm_audio/RTISI_LA/expand',int2str(i),'.wav');
    %audiowrite('../tsm_audio/compress/audio2.wav',y,fs)
    audiowrite(outname,y,fs)
end
% i=9;
% winlen = 1024;
% overlap = 512;
% orig_filename = strcat('../Project1Audio/audio',int2str(i),'.mov');
% compress_filename = strcat('../tsm_audio/compress',int2str(i),'.wav');
% expand_filename = strcat('../tsm_audio/expand',int2str(i),'.wav');
% [orig,~] = audioread(orig_filename);
% [comp,~] = audioread(compress_filename);
% [expa,fs] = audioread(expand_filename);
% 
% [orig_spectrum,f0,t0] = stft(orig,fs,'Window',hamming(winlen,'periodic'),'OverlapLength',overlap);
% [comp_spectrum,f1,t1] = stft(comp,fs,'Window',hamming(winlen,'periodic'),'OverlapLength',overlap);
% [expa_spectrum,f2,t2] = stft(expa,fs,'Window',hamming(winlen,'periodic'),'OverlapLength',overlap);
% 
% %%%%%%%%%%%% plot %%%%%%%%%%%%%%%
% figure;
% imagesc(t0, f0, 20*log10((abs(orig_spectrum(:,:,1)))));xlabel('Samples'); ylabel('Freqency');
% colorbar;