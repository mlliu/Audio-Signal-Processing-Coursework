speech = 2:8;
music = [1,9:12];
total_ser = 0;
count=0;
for i = speech
%filename = '../Project1Audio/audio2.mov';
filename = strcat('../Project1Audio/audio',int2str(i),'.mov');
[target,fs] = audioread(filename);

winLen = 1024;                   % window length (1 x 1)
step = 256;                     % skipping samples (1 x 1)
win = scaled_hamm_win(winLen,step);  % analysis window (winLen x 1)

Iter=1;
channel = size(target,2);
y=[];
k=3;
%%%% for each cahnnel 
for c =1: channel
    xc = target(:,c);
    % !! Ls must be even number due to our STFT/iSTFT implementation !!
    Ls = ceil((length(xc)+2*(winLen-step)-winLen)/step)*step+winLen;
    
    % zero padding at both ends for adjusting the signal length
    xc = [zeros(winLen-step,1);xc; ...
        zeros(Ls-length(xc)-2*(winLen-step),1);zeros(winLen-step,1)];
    
    %  spectrogram
    idx = (1:winLen)' + (0:step:Ls-winLen);
    spectrum = STFT(xc(idx),win);  
    magnitude = abs(spectrum);
    
    
    %sig_rtisi  = RTISI(magnitude,Iter,win,step,winLen);
    sig_rtisila  = RTISI_LA(magnitude,Iter,win,step,winLen,k);
    
    %%% G&L method
%      overlap = winLen-step;
%      spec_gl = stft(xc,fs,'Window',hamming(winLen,'periodic'),'OverlapLength',overlap);
%      magn_gl = abs(spec_gl);
%      sig_gl  = GL(magn_gl,fs,Iter,winLen,overlap);

 
    %%%%%% SER %%%%%%%%
    resignal = sig_rtisila;
    ser = SER(magnitude,resignal,win,winLen,step,Ls);
    count = count+1;
    total_ser = total_ser+ser;
    if c==1
        y =zeros(Ls,channel);
    end
    y(:,c) = resignal;
end
    

    %outname = strcat('../recon_signal/rtisi_la/audio',int2str(i),'.wav');
    %audiowrite('../tsm_audio/compress/audio2.wav',y,fs)
    %audiowrite(outname,y,fs)
end

 disp(total_ser/count);
% it = (0:length(sig_rtisila)-1)/fs;
% plot(xc(:,1)','LineWidth',1.5)
% hold on
% plot(resignal(:,1)','r--')
% hold off
% legend('Original Channel 1','Reconstructed Channel 1')


