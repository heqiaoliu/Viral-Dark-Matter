function sldemo_lct_util(action, varargin)
% sldemo_lct_edit opens Legacy Code Demo source code in the editor

% Copyright 1990-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

lctPath = fileparts(which(mfilename));

switch action
  case 'edit'
    edit(fullfile(lctPath, varargin{1}))
end
