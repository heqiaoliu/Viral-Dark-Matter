function helpview(map_path, varargin)
%HELPVIEW Helpview wrapper.
%   UISERVICES.HELPVIEW accepts the same inputs as helptools/helpview.  It
%   converts tokens in the help file path to static path information.
%
%   Tokens             Static path
%   $DOCROOT$          The current documentation root (docroot)
%   $MLROOT$           The MATLAB root (matlabroot)
%
%   % Examples
%   uiservices.helpview('$DOCROOT$\toolbox\vipblks\vipblks.map', 'mplay_frame')
%
%   See also helptools/helpview.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/06 13:32:49 $

map_path = strrep(map_path, '$DOCROOT$', docroot);
map_path = strrep(map_path, '$MLROOT$',  matlabroot);

helpview(map_path, varargin{:});

% [EOF]
