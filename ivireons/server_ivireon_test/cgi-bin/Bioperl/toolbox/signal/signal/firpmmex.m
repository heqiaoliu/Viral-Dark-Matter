function [h,err,res] = firpmmex(order, ff, aa, varargin)
%FIRPMMEX   

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:04:43 $

[nfilt,ff,grid,des,wt,ftype,sign_val,hilbert,neg] = firpminit(order, ff, aa, varargin{:});

[h,err,iext,ret_code,iters] = remezmex(nfilt,ff,grid,des,wt,ftype);
err = abs(err);
h = h * sign_val;

if (ret_code ~= 0) 
    handleErrorCode (ret_code, iters(1));
elseif any(err < 100*max(abs(des))*eps)
    warning(generatemsgid('machineAccuracy'),'Required numerical precision was near machine accuracy.  Check result.');
end

%
% arrange 'results' structure
%
if nargout > 2
    res.fgrid = grid(:);
    res.H = freqz(h,1,res.fgrid*pi);
    if neg  % asymmetric impulse response
        linphase = exp(sqrt(-1)*(res.fgrid*pi*(order/2) - pi/2));
    else
        linphase = exp(sqrt(-1)*res.fgrid*pi*(order/2));
    end
    if hilbert == 1  % hilbert
        res.error = real(des(:) + res.H.*linphase);
    else
        res.error = real(des(:) - res.H.*linphase);
    end
    res.des = des(:);
    res.wt = wt(:);
    res.iextr = iext(1:end);
    res.fextr = grid(res.iextr);  % extremal frequencies
    res.fextr = res.fextr(:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Handle error codes 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handleErrorCode (ret_code, iters)
if ret_code == -1
    error('%s\n%s\n%s\n%s%s', ...
        'Approximation error was not computable:', ...
        '1) Check the specifications.', ...
        '2) Transition region could be much too narrow or too wide for filter order.', ...
        '3) For multiband filters, try making the transition regions', ...
        ' more similar in width.');
elseif ret_code == -2     
    msg=sprintf(['Design is not converging.  Number of iterations was %d\n', ...
        '1) Check the resulting filter using freqz.\n', ...
        '2) Check the specifications.\n', ...
        '3) Filter order may be too large or too small.\n', ...
        '4) For multiband filters, try making the transition regions', ...
        ' more similar in width.\n', ...
        'If err is very small, filter order may be too high'], iters);
    warning(generatemsgid('notConverging'),msg);
elseif ret_code == -5
    error(generatemsgid('SignalErr'),'Unable to initialize.  Check specifications or try increasing LGRID.');
end

% [EOF]
