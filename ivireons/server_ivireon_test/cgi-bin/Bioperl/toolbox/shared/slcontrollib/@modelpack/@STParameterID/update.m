function update(this,Model,varargin) 
% UPDATE  method to set SISOTOOL model parameter object's 
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
% $Revision: 1.1.8.3 $ $Date: 2007/09/18 02:28:59 $

%Check input argument types
nVarIn = numel(varargin);
if ~iscell(varargin) || ...
      ~(rem(nVarIn,2)==0 || nVarIn==1&&isstruct(varargin{1}))
   ctrlMsgUtils.error('SLControllib:modelpack:errPropertyValuePairs')
end

%Now check that we have valid properties to set
ValidProps = {'locations','dimension'};
if nVarIn > 1
   %List of property value pairs
   inProps = {varargin{1:2:end}};
else
   %Structure of property value pairs
   inProps = fieldnames(varargin{1});
end
if isempty(intersect(ValidProps,lower(inProps)))
   ctrlMsgUtils.error('SLControllib:modelpack:stErrorProperty','{''locations''|''dimension''}')
end

%Everything's ok set the properties
if nVarIn > 1
   %List of property value pairs
   set(this,varargin{:});
else
   %Structure of property value pairs
   set(this,varargin{1})
end

   