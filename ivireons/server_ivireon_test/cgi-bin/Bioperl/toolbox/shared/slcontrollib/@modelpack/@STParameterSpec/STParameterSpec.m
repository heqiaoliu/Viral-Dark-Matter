function this = STParameterSpec(ID, FormatOptions) 
% STPARAMETERSPEC  constructor for SISOTOOL parameter specification object
%
% h = modelpack.STParameterSpec(ID, [FormatOptions]) 
%
% Input:
%    ID            - a SISOTOOL Parameter ID object 
%    FormatOptions - optional cell array specifying formats for this spec
%

% Author(s): A. Stothert 01-Aug-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/12/14 15:01:47 $

% Create object
this = modelpack.STParameterSpec;

% No argument constructor call
ni = nargin;
if (ni == 0)
   return
end

if (ni < 1) || ~isa(ID, 'modelpack.STParameterID')
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','ID','modelpack.STParameterID')
end

% Set invariant properties
this.setID(ID); %Sets the name property
this.Version = 1.0;

%Set passed arguments
if ni >=  2
   this.FormatOptions = FormatOptions;
end

