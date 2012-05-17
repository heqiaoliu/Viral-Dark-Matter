function w = blackman(varargin)
%BLACKMAN   Blackman window.
%   BLACKMAN(N) returns the N-point symmetric Blackman window in a column
%   vector.
%   BLACKMAN(N,SFLAG) generates the N-point Blackman window using SFLAG
%   window sampling. SFLAG may be either 'symmetric' or 'periodic'. By 
%   default, a symmetric window is returned. 
%
%   See also  HAMMING, HANN, WINDOW.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.14.4.1 $  $Date: 2007/12/14 15:03:49 $

% Check number of inputs
error(nargchk(1,2,nargin,'struct'));

[w,msg] = gencoswin('blackman',varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

% [EOF] blackman.m
