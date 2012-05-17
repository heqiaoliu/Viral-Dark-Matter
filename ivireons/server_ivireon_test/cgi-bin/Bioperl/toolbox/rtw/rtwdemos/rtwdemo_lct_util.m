function rtwdemo_lct_util(action, varargin)
% rtwdemo_lct_edit opens Legacy Code Demo source code in the editor

% Copyright 1990-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $

rtwDemoPath = fileparts(which('rtwdemo_lct_util'));

switch action
  case 'edit'
    edit(fullfile(rtwDemoPath, varargin{1}))
end
