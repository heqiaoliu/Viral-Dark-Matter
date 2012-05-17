function [propVal,errmsg,pseudoData] = eml_getfiprop_helper(Ain,propName,aNotConst,aMaybeFloat)
% EML helper function that returns the property value of the fi A
% for its property PROPNAME    

% Copyright 2006-2009 The MathWorks, Inc.

nargchk(3,4,nargin);
if nargin==3
    aMaybeFloat = false;
end
errmsg = ''; propVal = [];
if ~isfi(Ain)
    if ~aMaybeFloat
        error('eml:fi:inputNotFi','Input must be an embedded.fi');
    else
        A = fi(Ain, 'datatypemode', class(Ain));
    end
else
    A = Ain;
end

try
    propVal = get(A,propName);
catch ME
    errmsg = ME.message;
end

if strcmpi(propName,'Data') && aNotConst
    pseudoData = true;
else
    pseudoData = false;
end

%------------------------------------------------------------------