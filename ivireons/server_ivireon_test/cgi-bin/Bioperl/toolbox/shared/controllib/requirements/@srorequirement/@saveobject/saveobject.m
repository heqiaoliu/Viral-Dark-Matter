function this = saveobject(varargin)
%SAVEOBJECT object constructor
%

% Author(s): A. Stothert
% Revised:
%   Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:39 $

this = srorequirement.saveobject;

%Set defaults
this.Name            = 'Unknown';
this.UserDescription = {'Unrecognized requirement'};
this.isEnabled       = false;

%Set properties
if nargin
   this.class = varargin{1};
end
if nargin > 1
   this.fldData = varargin{2};
   fldNames = fieldnames(this.fldData);
   %Make sure data is in mdl saveable form!
   for ct = 1:numel(fldNames)
      if islogical(this.fldData.(fldNames{ct}))
         bVal = double(this.fldData.(fldNames{ct}));
         this.fldData.(fldNames{ct}) = [];
         this.fldData.(fldNames{ct}) = bVal;
      end
   end
end
if nargin > 2
   this.Source = varargin{3};
end
if nargin > 3
   this.Data = varargin{4};
end
