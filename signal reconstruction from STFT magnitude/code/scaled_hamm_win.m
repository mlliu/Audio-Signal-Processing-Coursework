function win = scaled_hamm_win(winLen,step)
    % normalized window
    a=0.54;
    b=-0.46;
    win = zeros(winLen,1);
    coef = 2*sqrt(step)/sqrt((4*a^2+2*b^2)*winLen);
    for n =1:winLen 
        win(n) = coef*(a+b*cos(2*pi*n/winLen));
    end
end