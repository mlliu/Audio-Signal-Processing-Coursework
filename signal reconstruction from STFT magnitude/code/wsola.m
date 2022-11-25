%function y=wsola(x,winlen,h_s,s,tolerance)
clear all;clc;
clear;
filename = '../Project1Audio/audio2.mov';
[x,fs] = audioread(filename);
N = length(x);
t = (0:N-1)/fs;

s = 1/2;              % time-stretch factor
h_s = 512;      % hop size of the synthesis window. H_S
winlen = 1024;      % length of window
tolerance = 512;    % tolerance delta
winlen_half = round(winlen/2);

channel = size(x,2);   % number of channel
w = hann(winlen);   %hann window

input_length = size(x,1);
output_length = ceil(input_length *s);
h_a = h_s/s;%Hop size of the analusis window


%position of synthesis window
syn_win_pos = 1:h_s:output_length+winlen_half;
%position of analysis window
%ana_win_pos = 1:h_a:input_length+winlen_half; %Hop size of the analusis window
ana_win_pos = round(interp1([1,output_length],[1,input_length],syn_win_pos,'linear','extrap'));
ana_hop = [0 ana_win_pos(2:end)-ana_win_pos(1:end-1)];

%zero pad x, to avoid exceed the range of x
before_pad = zeros(winlen_half+tolerance,channel);
after_pad = zeros(2*winlen+tolerance,channel);
x = [before_pad;x;after_pad];

%add the ana_win_pos with tolerance, because we pad x with extra tolerance
ana_win_pos = ana_win_pos+tolerance;

%initialize output
y = zeros(output_length,channel);

%start iteration
%iterate through each channel and each frame
num_frame = length(syn_win_pos);
for c = 1: channel
    xc = x(:,c);
    yc = zeros(output_length+2*winlen,1);
    %record the overlapping window for normalization
    z = zeros(output_length+2*winlen,1);
    
    %shift of the current analysis window position
    delta = 0;
    
    %process n-1 frame
    for i  = 1: num_frame-1
        syn_win_range = syn_win_pos(i):syn_win_pos(i)+winlen-1;
        ana_win_range = ana_win_pos(i)+delta:ana_win_pos(i)+winlen-1+delta;

        %overlap and add
        yc(syn_win_range) = yc(syn_win_range) + xc(ana_win_range).*w;
        z(syn_win_range) = z(syn_win_range) + w;

        %the natural progression of the xm'
        natural_progession = xc(ana_win_range+h_s);

        next_ana_win_range = ana_win_pos(i+1)-tolerance...
            :ana_win_pos(i+1)+winlen-1+tolerance;
        
        
        x_next = xc(next_ana_win_range);

        %cross correlation, get the most similar one
        cc = cross_correlation(x_next,natural_progession,winlen);
        [~,maxind] = max(cc);
        %maxind is the distance from left edge to the starting point
        % so minus tolerance will give ue the delta
        delta = maxind - tolerance-1;
    
    end
    % process the nth frame
    syn_win_range = syn_win_pos(end):syn_win_pos(end)+winlen-1;
    ana_win_range = ana_win_pos(i)+delta:ana_win_pos(i)+winlen-1+delta;
    
    yc(syn_win_range) = yc(syn_win_range) + xc(ana_win_range).*w;
    z(syn_win_range) = z(syn_win_range) + w;
    
    %normalize the signal by dividing by the added windows
    z(z<10^-3) = 1; % avoid potential division by zero
    yc = yc./z;


    %remove zero pading at the beginning
    yc = yc(winlen_half:end);

    %remove zero padding at the end
    yc = yc(1:output_length);

    y(:,c) = yc;


end
%end