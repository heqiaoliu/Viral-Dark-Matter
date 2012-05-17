function hMdl = utCreateGradMAPI(this)
% UTCREATEGRADMAPI  Return a Model API object for the gradient model
%
 
% Author(s): A. Stothert 21-Jul-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 14:00:54 $

if isempty(this.hModel) || ~ishandle(this.hModel)
   this.hModel = modelpack.SLModel(this.GradModel);
end
hMdl = this.hModel;