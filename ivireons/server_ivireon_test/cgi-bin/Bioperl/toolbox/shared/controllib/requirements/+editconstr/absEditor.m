classdef absEditor < editconstr.absInteractiveConstr 
% ABSEDITOR  Abstract parent class for all constraint editor classes
%
 
% Author(s): A. Stothert 23-Dec-2008
% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:30:57 $

methods(Access = 'protected')
    function this = absEditor(SrcObj)
        this = this@editconstr.absInteractiveConstr(SrcObj);
    end
end
end
