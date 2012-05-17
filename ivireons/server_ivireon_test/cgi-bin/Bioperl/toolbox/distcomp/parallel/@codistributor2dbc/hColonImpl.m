function [LP, codistr] = hColonImpl(codistr, a, d, b)
; %#ok<NOSEM> % Undocumented
% Implementation of hColonImpl for codistributor2dbc.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/14 03:53:41 $

if d == 1
   len = max(0, b-a+d);
   classLP = class(len);
   [LP, codistr] = iGetComplete(codistr, len, classLP);
   if isempty(LP)
       return;
   end
    [e, f] = codistr.globalIndices(2, labindex);
    locStart = 1;
    % Loop over all the blocks that this lab stores.  
    % We set up locStart and locEnd such that LP(locStart:locEnd) stores each
    % block.
    for i = 1:length(e)
        % Use the global indices to identify the subrange of a:b for the current
        % block.
        currLen = f(i) - e(i);
        currA = a - 1 + cast(e(i), classLP);
        currB = currA + currLen;
        locEnd = locStart + currLen;
        LP(locStart:locEnd) = currA:currB;
        locStart = locEnd + 1;
    end
else
    % Note that the built-in colon operator is extremely careful when handling
    % floating point arithmetic, so we don't want to duplicate that logic
    % in here.
    v = a:d:b;
    classLP = class(v);
    len = length(v);
    [LP, codistr] = iGetComplete(codistr, len, classLP);
    if isempty(LP)
        return;
    end
    [e, f] = codistr.globalIndices(2, labindex);
    % Loop over all the blocks that this lab stores and extract from v into the
    % local part.
    locStart = 1;
    for i = 1:length(e)
        locEnd = locStart + (f(i) - e(i));
        LP(locStart:locEnd) = v(e(i):f(i));
        locStart = locEnd + 1;
    end
end
end % End of hColonImpl.

function [LP, codistr] = iGetComplete(codistr, len, classLP)
codistr = codistr.hGetCompleteForSize([1, len]);
LP = zeros(codistr.hLocalSize(), classLP);
end
