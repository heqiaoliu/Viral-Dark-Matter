function thisloadobj(this, s)
%THISLOADOBJ   Load this object.

%   Author(s): P. Costa
%   Copyright 1999-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/07/09 18:13:52 $

ParamNames = getparamnames(this);

if iscell(ParamNames)
    for paramI = 1:length(ParamNames)
        oneName = ParamNames{paramI};
        set(this, oneName, s.(oneName));
    end
else
    set(this,ParamNames,s.(ParamNames));
end

end 
  

% [EOF]
