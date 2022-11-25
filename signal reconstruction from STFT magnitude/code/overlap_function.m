function result = overlap_function(signal,winlen,step)
%this function is used to overlap signal
num_frame = size(signal,2);
length = winlen+(num_frame-1)*step;%the length of overlappped signal
result = zeros(length,1);

%iterate through each frame
for i =1:num_frame
    start = (i-1)*step+1;
    result(start:start+winlen-1) = result(start:start+winlen-1)+signal(:,i);
end

end