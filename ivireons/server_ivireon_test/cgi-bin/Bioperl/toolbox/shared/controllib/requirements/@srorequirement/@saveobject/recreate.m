function [ok,obj] = recreate(this)
%RECERATE method to recreate object from structure
%

% Author(s): A. Stothert
% Revised:
%   Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:38 $

ok = false;         %default assume recreation failed
try
   obj = feval(this.class);
   obj.loadObject(this)
   ok = true;
catch E
   obj = this;
   ctrlMsgUtils.warning('Controllib:graphicalrequirements:warnRecreateClassNotDefined',this.class)
end

