function this = RequirementTool(varargin)
%REQVIEWER Construct a Requirement viewer object

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:50:41 $

this = checkpack.RequirementTool;

this.initTool(varargin{:});
end