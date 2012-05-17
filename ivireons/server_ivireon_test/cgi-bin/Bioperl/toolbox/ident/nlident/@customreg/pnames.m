function [Props,AsgnVals] = pnames(nlobj, flag)
%PNAMES  All CUSTOMREG public properties and their assignable values
%
%   [PROPS,ASGNVALS] = PNAMES(R) returns the list PROPS of
%   public properties of the object R, as well as the
%   assignable values ASGNVALS for these properties.  Both
%   PROPS and ASGNVALS are cell vector of strings, and PROPS
%   contains the true case-sensitive property names.
%
%   PNAMES(SYS,'readonly') returns the read-only properties only.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:52:43 $

% Author(s): Qinghua Zhang

no = nargout;
ni = nargin;

readonlyflag = false;
if ni>1 && ischar(flag)
    if strcmpi(flag, 'readonly')
        readonlyflag = true;
    else
        ctrlMsgUtils.error('Ident:general:wrongPnamesFlag')
    end
end

if readonlyflag
    Props = {};
else
    Props = {'Function', ...
        'Arguments', ...
        'Delays', ...
        'Vectorized', ...
        'TimeVariable'};
end

if no>1
    if readonlyflag
        AsgnVals = {};
    else
        AsgnVals = { ...
            'Function handle of the custom regressor function', ...
            'Function arguments in terms of model input and/or output names, a cell array of strings', ...
            'Delays of model input/output when used as regressor function arguments, a real vector', ...
            'Vectorization status of the custom regressor, true or false', ...
            'The time variable used in regressor expressions, a string'};
    end
end

% FILE END

