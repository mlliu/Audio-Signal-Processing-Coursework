%function resignal =RTISI(magnitude,Iter,win,step,winLen)


clear all;clc;
clear;
filename = '../Project1Audio/audio2.mov';
[target,fs] = audioread(filename);

winLen = 1024;                   % window length (1 x 1)
step = 256;                     % skipping samples (1 x 1)
win = scaled_hamm_win(winLen,step);  % analysis window (winLen x 1)

Iter=10;
% !! Ls must be even number due to our STFT/iSTFT implementation !!
Ls = ceil((length(target)+2*(winLen-step)-winLen)/step)*step+winLen;

% zero padding at both ends for adjusting the signal length
target = [zeros(winLen-step,1);target; ...
    zeros(Ls-length(target)-2*(winLen-step),1);zeros(winLen-step,1)];

%  spectrogram
idx = (1:winLen)' + (0:step:Ls-winLen);
spectrum = STFT(target(idx),win);  
magnitude = abs(spectrum);



%for each frame
total_frame = size(magnitude,2);
resignal = zeros(winLen+(total_frame-1)*step,1);%store reconstructed signal,initialize as 0


%iterate through each frame
for m = 1: total_frame

    %generate phrase information based on partial frame
    start = (m-1)*step+1;
    magn_m = magnitude(:,m); % magnitude spectrum of frame m

    %initialize
    if m==1
        phase = ones(size(magn_m)); %initial phase =0
    else
        y_m_1 = resignal(start:start+winLen-1);

        spec_m_1 = STFT(y_m_1,win);
        phase = sign(spec_m_1);
        if phase == zeros(size(magn_m))
            phase = ones(size(magn_m));
        end
        %initial phrase
        %phase = spec_m_1./(abs(spec_m_1)+eps); %eps ;
        
    end
    
    %start iteration
    for i = 1: Iter
        xi = magn_m.*phase;
        
        signal = iSTFT(xi,win); %Ls = winlen
        next_xi = STFT(signal,win);%Ls = winlen
        phase = sign(next_xi);

    end
    xi = magn_m.*phase;
    y_m = iSTFT(xi,win);
    
    
    %overlap-add it to resignal
    resignal(start:start+winLen-1) = resignal(start:start+winLen-1) + y_m;
end

 ser = SER(magnitude,resignal,win,winLen,step,Ls);
 disp(ser);
it = (0:length(resignal)-1)/fs;
plot(target(:,1)','LineWidth',1.5)
hold on
plot(resignal(:,1)','r--')
hold off
legend('Original Channel 1','Reconstructed Channel 1')
%end