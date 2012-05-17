function y = rectpulse(x,Nsamp)
% RECTPULSE Rectangular pulse shaping.
%   Y = RECTPULSE(X,NSAMP) returns Y, a rectangular pulse shaped version of X,
%   with NSAMP samples per symbol. This function replicates each symbol in
%   X NSAMP times. To insert zeros between each sample of X, see UPSAMPLE.
%   For two-dimensional signals, the function treats each column as 1
%   channel.
%
%   See also INTDUMP, UPSAMPLE, GAUSSFIR.

%    Copyright 1996-2009 The MathWorks, Inc.
%    $Revision: 1.1.6.4 $  $Date: 2009/04/21 03:04:55 $

%Check x, Nsamp
if( ~isnumeric(x))
    error('comm:rectpulse:Xnum','X must be numeric.');
end

if(~isreal(Nsamp) || ~isscalar(Nsamp) ||  Nsamp<=0 || (ceil(Nsamp)~=Nsamp) || ~isnumeric(Nsamp) )
    error('comm:rectpulse:nsamp','NSAMP must be a positive integer.');
end

[wid, len] = size(x);
if ( (wid == 1) && (len~=1) )
    y = reshape(ones(Nsamp,1)*reshape(x, 1, wid*len),wid, len*Nsamp);
else
    y = reshape(ones(Nsamp,1)*reshape(x, 1, wid*len),wid*Nsamp, len);
end

% --- EOF --- %
