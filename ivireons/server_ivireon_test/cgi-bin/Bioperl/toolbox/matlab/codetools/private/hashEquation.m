function s = hashEquation(a)
% HASHEQUATION  Converts an arbitrary string into one suitable for a filename.
%   HASHEQUATION(A) returns a string usitable for a filename.

% Matthew J. Simoneau
% Copyright 1984-2007 The MathWorks, Inc. 
% $Revision: 1.1.6.3 $  $Date: 2007/12/14 14:49:34 $

if isempty(a)
    a = ' ';
end

% Get the MD5 hash of the string as two UINT64s.
messageDigest = java.security.MessageDigest.getInstance('MD5');
h = messageDigest.digest(double(a));
q = typecast(h,'uint64');

% Extract middle of the base10 representation of the first UINT64.
t = sprintf('%020.0f',q(1));
s = ['eq' t(6:2:15)];