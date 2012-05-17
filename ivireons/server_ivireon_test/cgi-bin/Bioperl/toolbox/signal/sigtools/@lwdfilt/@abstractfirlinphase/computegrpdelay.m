function [G, W] = computegrpdelay(this, W, varargin)
%COMPUTEGRPDELAY   Calculate the group delay.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:19:56 $

if nargin < 2
    W = 8192;
end

num = this.Numerator;
% Remove leading and trailing zeros
startidx = find(num,1);
stopidx = find(num,1,'last');
if max(abs(num)) == 0,
    num = 0;
else
    % Remove leading and trailing zeros of b 
    num = num(startidx:stopidx);
end

% Compute group delay
if isempty(startidx), 
    G1 = 0;
else
    G1 = max(startidx-1,0); % Delay introduced by leading zeros
end
G2 = (length(num)-1)/2; % Delay of symmetric FIR filter
G = G1+G2;

if prod(size(W)) == 1,
    % NFFT
    [n, uc, fs, b] = freqzparse(W,varargin{:});
    
    W = freqz_freqvec(n,fs,strmatch(uc,{'whole','half'}));
    % freqz_freqvec returns a row, columnize
    W = W(:);
end

G = G*ones(size(W));

% [EOF]
