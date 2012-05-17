function out = util_is_builtin_or_fxp_type(dtypeStr, aliasThruDtypeStr)

%   Copyright 2009 The MathWorks, Inc.

    out = false;
    
    if nargin<2
        aliasThruDtypeStr = dtypeStr;
    end
    
    if sl('sldtype_is_builtin', dtypeStr) || ...
       ~strcmp(dtypeStr, aliasThruDtypeStr) || ...
       ((strncmp(dtypeStr, 'sfix', 4) ||...
             strncmp(dtypeStr, 'ufix', 4) ||...
             strncmp(dtypeStr, 'flt', 3) || ...
             sldvshareprivate('util_is_enum_type',dtypeStr)))

        out = true;    
    end
% LocalWords:  sldtype
