function fi_datatype_override_demo_plot(b,a,x,y,varargin)
%FI_DATATYPE_OVERRIDE_DEMO_PLOT  Plot function for fi doubles override demo.
%    FI_DATATYPE_OVERRIDE_DEMO_PLOT(B,A,X,Y,YDBL,PLOT_TITLE)  See
%    FI_DATATYPE_OVERRIDE_DEMO for examples of use.

%    Copyright 2005 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $

clf
n = length(x);
H = abs(fft(double(b),2*n)./fft(double(a),2*n));
H = H(1:n);
f = linspace(0,1,n);
if (isfi(y) && isfixed(y))
    subplot(3,1,[1 2]);
    ydbl = varargin{1};
    plot(f,x,'c-',f,ydbl,'bo-',f,y,'gs-',f,H,'r--')
    ylabel('Amplitude')
    legend('Input','Floating point output','Fixed point output','Frequency response')
    title(get_plot_title(varargin{:}))

    err = double(y) - double(ydbl);
    subplot(3,1,3);
    plot(f,err,'r')
    ylabel('Amplitude')
    legend('error')
    figure(gcf)
else
    % Floating-point and scaled double only
    plot(f,x,'c-',f,y,'bo-',f,H,'r--')
    ylabel('Amplitude')
    if isfi(y) && isscaleddouble(y)
        legend('Input','Scaled double output','Frequency response')
    else
        legend('Input','Floating point output','Frequency response')
    end
    title(get_plot_title(varargin{:}))
end

xlabel('Time (s) & Normalized Instantaneous Frequency (1 = Fs/2)')

function plot_title = get_plot_title(varargin)
plot_title='';
for k=1:length(varargin), 
    if ischar(varargin{k}), 
        plot_title = varargin{k}; 
        break; 
    end
end
