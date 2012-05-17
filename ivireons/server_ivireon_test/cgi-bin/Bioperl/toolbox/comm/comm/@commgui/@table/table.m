function this = table(varargin)
%TABLE Construct a communications GUI TABLE object
%   OUT = COMMGUI.TABLE(ARGS) <long description>

%	@commgui\@table
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:17:31 $

this = commgui.table;

% Set default prop values
this.Type = 'Comm GUI Table';

% If there are arguments, initialize the object accordingly
if nargin ~= 0
    initPropValuePairs(this, varargin{:});
end

render(this);

setappdata(this.Parent, 'CommGUITable', this);

%-------------------------------------------------------------------------------
% [EOF]
