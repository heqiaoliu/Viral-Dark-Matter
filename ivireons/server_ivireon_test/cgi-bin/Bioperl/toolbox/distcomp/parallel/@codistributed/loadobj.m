function A = loadobj(A)
;%#ok

%LOADOBJ Overloaded for codistributed arrays
%   
%   See also LOADOBJ, CODISTRIBUTED.


%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/12/03 19:00:58 $

aDist = getCodistributor(A);
storedNumLabs = aDist.hNumLabs();
if storedNumLabs ~= numlabs
    warning('distcomp:codistributed:InvalidNumberOfLabs', ...
            ['The number of labs must be the same when loading a ' ...
             'codistributed array as it was when the array was saved.  ' ...
             'This array was saved with numlabs equal to %d, but numlabs ' ...
             'is now %d.'], storedNumLabs, numlabs);
end
