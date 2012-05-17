function puncpat = setPuncPat(h,puncpat)
%SETPUNCPAT   Sets the puncture pattern value of the object.

% @fec\algbase

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/08/20 16:21:58 $

if(h.nSet && h.kSet)
    if(~isvector(puncpat) )
        error([getErrorId(h) ':PuncVecMessage'],...
            'The puncture pattern must be a row or column vector');
    end
    if(length(puncpat) ~= (h.N - h.K))
        error([getErrorId(h) ':PuncLen'],...
            'Puncture pattern must have length N-K')
    end

    if ~isempty(find(nonzeros(puncpat)~=1,1))
        error([getErrorId(h) ':PuncBinaryMessage'], ...
            'The puncture pattern must be binary.');
    end
    if sum(puncpat==0) > 2*h.t
        error([getErrorId(h) ':tooManyPuncs'],['The Puncture pattern should have' ...
            ' less than 2*T zeros.']);
    end

    if sum(puncpat==0) == 2*h.t
        warning([getErrorId(h) ':numpuncs'],['The puncture pattern has exactly 2*T' ...
            ' zeros, the code will not be able to correct any errors.']);
    end
end
puncpat = puncpat(:)'; % Force to be row vector
h.Type = algType(h,h.N,h.K,h.ShortenedLength,puncpat);


