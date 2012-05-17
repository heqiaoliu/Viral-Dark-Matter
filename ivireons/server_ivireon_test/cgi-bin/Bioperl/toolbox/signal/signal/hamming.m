function w = hamming(varargin)
%HAMMING   Hamming window.
%   HAMMING(N) returns the N-point symmetric Hamming window in a column vector.
% 
%   HAMMING(N,SFLAG) generates the N-point Hamming window using SFLAG window
%   sampling. SFLAG may be either 'symmetric' or 'periodic'. By default, a 
%   symmetric window is returned. 
%
%   See also BLACKMAN, HANN, WINDOW.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.14.4.1 $  $Date: 2007/12/14 15:05:01 $

% Check number of inputs
error(nargchk(1,2,nargin,'struct'));

[w,msg] = gencoswin('hamming',varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end


% [EOF] hamming.m
