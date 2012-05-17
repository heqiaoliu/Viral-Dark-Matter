function [errstr,P,f] = svburg(x,Fs,valueArray)
%SVBURG spectview Wrapper for Burg method.
%  [errstr,P,f] = SVBURG(x,Fs,valueArray) computes the power spectrum P
%  at frequencies f using the parameters passed in via valueArray:
%
%   valueArray entry     Description
%    ------------         ----------
%          1                Order
%          2                Nfft

%   Copyright 1988-2008 The MathWorks, Inc.
% $Revision: 1.8.4.1 $

errstr = '';
P = [];
f = [];

order = valueArray{1};
nfft  = valueArray{2};
evalStr = '[P,f] = pburg(x,order,nfft,Fs);';

try
    eval(evalStr);
catch ME
    errstr = {'Sorry, couldn''t evaluate pburg; error message:'
               ME.message };
    return
end

[P,f] = svextrap(P,f,nfft);

