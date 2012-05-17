function updateAlgorithmProperties(this,Model,varargin)
% update algorithm properties when initial model changes or model type
% (idnlarx or idnlhw) changes.
% Model: idnlarx or idnlhw model
% varargin: optionally pass a handle to nlgui as 3rd input

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/02/23 17:15:59 $

import com.mathworks.toolbox.ident.nnbbgui.*;

algobj = this.getAlgorithmOptions(varargin{:});
algobj.alg2obj(Model);

p = NonlinPropInspector.getInstance;
if p.isVisible && strcmpi(char(p.getViewType),'algorithm')
    p.getPropertyViewPanel.setObject(java.lang.Object); %todo: refresh bug
    p.getPropertyViewPanel.setObject(algobj);
end
