function short = setShort(h,short)
%SETSHORT   Sets the shortened length value of the object.

% @fec\algbase

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/08/20 16:21:59 $

% Make sure code is not shortened by too much

if(short < 0)
    error([getErrorId(h), ':shortNeg'],'ShortenedLength must be greater than 0.');
end

if ( h.k - short <= 0)
    error([getErrorId(h), ':tooShort'],'K - ShortenedLength must be greater than 0.');
end

if(floor(short) ~= short)
    error([getErrorId(h), ':intVal'],'ShortenedLength must be an integer.');
end

h.Type = algType(h,h.N,h.K,short,h.PuncturePattern);
