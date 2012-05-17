function [LP, codistr] = hColonImpl(codistr, a, d, b) 
; %#ok<NOSEM> % Undocumented
% Implementation of hColonImpl for codistributor1d.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/07/14 03:53:32 $

if d == 1
    len = max(0, b-a+d);
    classLP = class(len);
else
    v = a:d:b;
    classLP = class(v);
    len = length(v);
end
codistr = codistr.hGetCompleteForSize([1, len]);

if codistr.Dimension ~= 2
    % The entire local part resides on one of the labs. 
    if codistr.Partition(labindex) ~= 0
        LP = a:d:b;
    else
        LP = zeros(codistr.hLocalSize(), classLP);
    end
    return;
end

last = sum(codistr.Partition(1:labindex));
first = last - codistr.Partition(labindex) + 1;
if d == 1
    LP = a - 1 + cast(first:last, classLP);
else
    LP = v(first:last);
end

end % End of hColonImpl.

