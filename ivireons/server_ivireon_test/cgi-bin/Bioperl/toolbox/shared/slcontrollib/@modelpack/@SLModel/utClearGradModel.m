function utClearGradModel(this) 
% UTCLEARGRADMODEL  Utility to clear a gradient model used by 'refined'
% getSensitivity.
%
 
% Author(s): A. Stothert 17-Jul-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 14:00:42 $

%Clear the Gradient model, will be recreated as needed
if ~isempty(this.GradModel) && ishandle(this.GradModel)
   this.GradModel.delete;
   this.GradModel = [];
end
