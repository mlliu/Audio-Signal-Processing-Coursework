function sig = iSTFT(C,win)

% hWL = floor(winLen/2);
% C = C.*exp(+2i*pi*(mod((0:hWL)'*(0:size(C,2)-1)*skip,winLen)/winLen));
% sigr = fftshift(ifft([C;zeros(size(C)-[2,0])],'symmetric'),1).*win;
% idx = (1:winLen)' + (0:skip:Ls-winLen);
% idx2 = repmat(1:size(C,2),winLen,1);
% sigr = full(sum(sparse(idx(:),idx2(:),sigr(:)),2));
% sigr = circshift(sigr,-winLen/2);

sig = ifft(C).*win;

end