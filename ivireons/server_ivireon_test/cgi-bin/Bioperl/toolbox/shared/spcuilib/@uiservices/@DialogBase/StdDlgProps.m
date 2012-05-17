function dlgstruct = StdDlgProps(this,dlgstruct)
%StdDlgProps Add commmon dialog schema entries
%   to all dialogs.

% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2010/05/20 03:08:23 $

% Note: if nargin < 1,
%    we don't need to do anything special
%    accept the input dlgstruct only when present
%    create a new dlgstruct if none passed in
%
% Callers may call this FIRST, then override these
% Or, callers may call this LAST, and have these setting prevail

% No need to set .DialogTitle here, since 'show' method does this
% explicitly each time it is executed.  But it is an error if this
% field is not specified, and if we set it to a default then the
% dialog title bar will "flash".  So we compute it properly:

dlgstruct.DialogTitle    = strrep([this.TitlePrefix this.TitleSuffix], ...
    sprintf('\n'), ' ');
dlgstruct.DisplayIcon    = fullfile('toolbox','shared','dastudio','resources','MatlabIcon.png');
dlgstruct.HelpMethod     = this.HelpMethod;
dlgstruct.HelpArgs       = this.HelpArgs; % e.g., {'mplay'}
dlgstruct.PreApplyMethod = 'preApply';
dlgstruct.CloseMethod    = 'closedlg';
dlgstruct.ExplicitShow   = true;  % so dialog comes up invisible

% [EOF]
