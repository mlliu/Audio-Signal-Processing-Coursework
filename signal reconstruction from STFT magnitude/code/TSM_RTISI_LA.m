%function y=TSM_RTISI_LA(x,fs,winLen,h_s,s)
clear all;clc;
clear;
filename = '../Project1Audio/audio1.mov';
[x,fs] = audioread(filename);
N = length(x);
t = (0:N-1)/fs;

s = 2;              % time-stretch factor
h_s = 512;      % hop size of the synthesis window. H_S
winLen = 1024;      % length of window



syn_step = h_s;
ana_step = h_s/s;
syn_win = scaled_hamm_win(winLen,syn_step);
ana_win = scaled_hamm_win(winLen,ana_step);


channel = size(x,2);   % number of channel
Iter = 10;
k=3;


input_length = size(x,1);
%output_length = ceil(input_length *s);

for c =1: channel

    xc = x(:,c);
    % !! Ls must be even number due to our STFT/iSTFT implementation !!
    Ls = ceil((length(xc)+2*(winLen-ana_step)-winLen)/ana_step)*ana_step+winLen;
    
    % zero padding at both ends for adjusting the signal length
    xc = [zeros(winLen-ana_step,1);xc; ...
        zeros(Ls-length(xc)-2*(winLen-ana_step),1);zeros(winLen-ana_step,1)];
    
    %  spectrogram using ana_win
    idx = (1:winLen)' + (0:ana_step:Ls-winLen);
    spectrum = STFT(xc(idx),ana_win);  
    magnitude = abs(spectrum);

    % reconstruct signal using RTISI_LA using syn_win
    yc = RTISI_LA_function(magnitude,Iter,syn_win,syn_step,winLen,k);

    %append yc to corresponding channel
    if c==1
    y =zeros(size(yc,1),channel);
    end
    y(:,c) = yc;

end
%end
%h_a = h_s/s;%Hop size of the analusis window

% y = [];
% for c = 1: channel
%     xc = x(:,c);
%     spectrum = stft(xc,fs,'Window',hamming(winlen,'periodic'),'OverlapLength',winlen-h_a);
%     magnitude = abs(spectrum);
%     %sphase = spectrum./(abs(spectrum)+eps); %eps 
%     yc = RTISI_LA(magnitude,Iter,win,step,winLen,k);
%     %yc = GL(magnitude,fs,10,1024,winlen-h_s);
%     y(:,c) = yc;
% end
% end
% function y=TSM_RTISI_LA(x,winLen,h_s,s)
% % clear all;clc;
% % clear;
% % filename = '../Project1Audio/audio9.mov';
% % [x,fs] = audioread(filename);
% % s = 2;              % time-stretch factor
% % h_s = 512;      % hop size of the synthesis window. H_S
% % winLen = 1024;      % length of window
% 
% Iter = 10;
% channel = size(x,2);   % number of channel
% h_a = h_s/s;%Hop size of the analusis window
% 
% y = [];
% for c = 1: channel
%     xc = x(:,c);
% 
%     Ls = ceil((length(xc)+2*(winLen-h_a)-winLen)/h_a)*h_a+winLen;
%     xc = [zeros(winLen-h_a,1);xc; ...
%         zeros(Ls-length(xc)-2*(winLen-h_a),1);zeros(winLen-h_a,1)];
% 
%     %  spectrogram
%     ana_win = scaled_hamm_win(winLen,h_a);
%     idx = (1:winLen)' + (0:h_a:Ls-winLen);
%     spectrum = STFT(xc(idx),ana_win);  
%     magnitude = abs(spectrum);
% 
% 
%     % spectrum = stft(x,fs,'Window',hamming(winlen,'periodic'),'OverlapLength',winlen-h_a);
%     % magnitude = abs(spectrum);
%     % sphase = spectrum./(abs(spectrum)+eps); %eps 
%     syn_win  = scaled_hamm_win(winLen,h_s);
%     yc = RTISI(magnitude,Iter,syn_win,h_s,winLen);
% 
%     y(:,c) = yc;
% end