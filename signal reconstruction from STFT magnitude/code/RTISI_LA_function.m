function resignal =RTISI_LA_function(magnitude,Iter,win,step,winLen,k)


% clear all;clc;
% clear;
% filename = '../Project1Audio/audio2.mov';
% [target,fs] = audioread(filename);
% 
% winLen = 1024;                   % window length (1 x 1)
% step = 256;                     % skipping samples (1 x 1)
% 
% win = scaled_hamm_win(winLen,step);  % analysis window (winLen x 1)
% 
% Iter=10;
% % !! Ls must be even number due to our STFT/iSTFT implementation !!
% Ls = ceil((length(target)+2*(winLen-step)-winLen)/step)*step+winLen;
% 
% % zero padding at both ends for adjusting the signal length
% target = [zeros(winLen-step,1);target; ...
%     zeros(Ls-length(target)-2*(winLen-step),1);zeros(winLen-step,1)];
% 
% %  spectrogram
% idx = (1:winLen)' + (0:step:Ls-winLen);
% spectrum = STFT(target(idx),win);  
% magnitude = abs(spectrum);


%look aheah steps
k=3;
ratio = winLen/step-1;
%for each frame
total_frame = size(magnitude,2);
resignal = zeros(winLen+(total_frame-1)*step,1);%store reconstructed signal,initialize as 0
%use to normalize
z = zeros(winLen+(total_frame-1)*step,1);

committed_signal=[];
buffer_signal=[];
buffer_magn=[];
buffer_phase=[];
%iterate through each frame
for m = 1: total_frame-k
    buffer_magn = magnitude(:,m:m+k);
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
        if i==1
            %get signal for frame m
            xi = magn_m.*phase;
            signal = iSTFT(xi,win); %Ls = winlen
            buffer_signal = [committed_signal,signal];
            %get signal for frame m+1,m+2,m+3
            for extra = 1:k
                %get the current overlap signal
                overlap_signal = overlap_function(buffer_signal,winLen,step);
                %select the last 3 step and pad zero after it,which is the
                %partial fram
                partial_frame = [overlap_signal(end-step*ratio+1:end);zeros(step,1)];
                %use the partial frame to estimate initial phase
                spec_m_1 = STFT(partial_frame,win);
                phase = sign(spec_m_1);
                if phase == zeros(size(magn_m))
                    phase = ones(size(magn_m));
                end
                %initial phase * magn and do ifft get the signal, concatenate
                %it to buffer signal
                xi = buffer_magn(:,extra+1).*phase;
                signal = iSTFT(xi,win);
                buffer_signal = [buffer_signal,signal];
    
            end
           
        else
            %overlap all signal in the buffer signal
            overlap_signal = overlap_function(buffer_signal,winLen,step);
            %read signal for frame m+1,m+2,m+3 from overlap_signal
            idx = (1:winLen)' + (0:step:length(overlap_signal)-winLen);
            idx = idx(:,end-k:end); 
            %fft get the phase information
            next_xi = STFT(overlap_signal(idx),win); 
            phase = sign(next_xi);
            %times magn and do ifft to get the signal for frame m+1,m+2,m+3,and
            
            xi = buffer_magn.*phase;
            signal = iSTFT(xi,win);
            %put them in the buffer signal
            buffer_signal = [committed_signal,signal];
    
        end
    end
    %overlap signal
    overlap_signal = overlap_function(buffer_signal,winLen,step);
    %select the frame m, label it committed and output
    y_m = overlap_signal(end-step*k-winLen+1:end-step*k);
    if m>k
        committed_signal = committed_signal(:,2:end);
    end
    committed_signal = [committed_signal,y_m];

    %overlap-add it to resignal
    norm = k*(ratio+1)-1;
    resignal(start:start+winLen-1) = resignal(start:start+winLen-1) + y_m/11;
    
end

% ser = SER(magnitude,resignal,win,winLen,step,Ls);
% disp(ser);
% it = (0:length(resignal)-1)/fs;
% plot(target(:,1)','LineWidth',1.5)
% hold on
% plot(resignal(:,1)','r--')
% hold off
% legend('Original Channel 1','Reconstructed Channel 1')
end