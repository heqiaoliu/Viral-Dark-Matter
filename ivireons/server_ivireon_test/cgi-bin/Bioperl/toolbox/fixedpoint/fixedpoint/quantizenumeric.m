function y = quantizenumeric(x,signed,wordlength,fractionlength,roundmode,overflowmode)
% QUANTIZENUMERIC Quantize numeric data
%
%    Y = QUANTIZENUMERIC(X,S,W,F,R) quantizes the value X using
%    signedness S, word length W, fraction length F and roundmode R. The 
%    overflowmode is 'saturate'.
%
%    Y = QUANTIZENUMERIC(X,S,W,F,R,O) quantizes the value X using
%    signedness S, word lnegth W, fraction length F, roundmode R and
%    overflowmode O.
%
%    The allowed roundmodes are:
%     'ceil', 'convergent', 'fix', 'floor', 'nearest' & 'round'.
%
%    The allowed overflow modes are:
%     'saturate' and 'wrap'.
%
%    Example:
%
%    x = randn(1,100)*pi;
%    y = quantizenumeric(x,1,16,14,'nearest');
%
%   See also FI, QUANTIZER

%   Copyright 2009-2010 The MathWorks, Inc.

error(nargchk(5,6,nargin,'struct'));

if isequal(nargin,5)
    y = embedded.fi.quantizenumeric(x,signed,wordlength,fractionlength,roundmode);
else % nargin == 6
    y = embedded.fi.quantizenumeric(x,signed,wordlength,fractionlength,roundmode,overflowmode);
end
