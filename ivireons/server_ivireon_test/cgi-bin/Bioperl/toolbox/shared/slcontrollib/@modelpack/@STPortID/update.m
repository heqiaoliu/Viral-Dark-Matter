function update(this,Model,varargin) 
% UPDATE  method to set SISOTOOL model state object's 
% properties.
%
% this.update(Model,'varargin')
%
% Input:
%   Model    - a SISOTOOL model object that contains the parameter being
%              updated
%   varargin - a variable list of property value pairs or structure with
%              fields to set
%
% As SISOTOOL ports cannot be changed this method 
% is a no-op, but is required for consistency with the model API.
%
 
% Author(s): A. Stothert 22-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/09/18 02:29:05 $

%Check input argument types
if ~isa(Model,'modelpack.STModel');
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','Model','modelpack.STModel')
end
