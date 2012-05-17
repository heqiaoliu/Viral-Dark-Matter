function update(this,Model,varargin) 
% UPDATE  method to set SISOTOOL model state object's 
% properties.
%
% this.update(Model,varargin)
% 
% Input:
%   Model    - a SISOTOOL model object that contains the parameter being
%              updated
%   varargin - a variable list of property value pairs or structure with
%              fields to set
 
% Author(s): A. Stothert 22-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/09/18 02:29:09 $

%Check input argument types
nVarIn = numel(varargin);
if ~isa(Model,'modelpack.STModel');
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','Model','modelpack.STModel');
end
if ~iscell(varargin) || ...
      ~(rem(nVarIn,2)==0 || nVarIn==1&&isstruct(varargin{1}))
   ctrlMsgUtils.error('SLControllib:modelpack:errPropertyValuePairs')
end

%Now check that we have valid properties to set
ValidProps = {'ts','dimension'};
if nVarIn > 1
   %List of property value pairs
   inProps = {varargin{1:2:end}};
else
   inProps = fieldnames(varargin);
end
if isempty(intersect(ValidProps,lower(inProps)))
   ctrlMsgUitls.error('SLControllib:modelpack:stErrorProperty','{''ts''|''dimension''}');
end

%Everything's ok set the properties
if nVarIn > 1
   %List of property value pairs
   set(this,varargin{:});
else
   %Structure of property value pairs
   set(this,varargin)
end
