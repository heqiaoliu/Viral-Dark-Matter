function [f, g, r] = unitfcn(nlobj, x)
%UNITFUN : customnet unit function
%
%  This function calls the function pointed by the function handle stored
%  in nlobj.UnitFcn.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:52:39 $

% Author(s): Qinghua Zhang

if isempty(nlobj.UnitFcn)
    ctrlMsgUtils.error('Ident:idnlfun:emptyUnitFcn')
end

try
    switch nargout
        case 1
            f = nlobj.UnitFcn(x);
        case 2
            [f, g] = nlobj.UnitFcn(x);
        case 3
            [f, g, r] = nlobj.UnitFcn(x);
    end
catch E
    ctrlMsgUtils.error('Ident:idnlfun:customnetinvalidUnitFcn',E.message)
end

% FILE END
