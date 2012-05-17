function hParent = set_Parent(this, hParent)
%SET_PARENT PreSet function for the 'Parent' property

%	@commgui\@table
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/05 17:45:31 $


if ~ishghandle(hParent, 'uipanel')
    error([this.getErrorId ':IllegalParent'], ...
        'Parent of COMMGUI.TABLE should be a uipanel.');
end

% Set the table size
pos = get(hParent, 'Position');
this.TableWidth = pos(3);
this.TableHeight = pos(4);

if this.Rendered
    % Unrender the old table
    unrender(this);

    % Set the PrivParent property.  Note that Parent is the phantom property of
    % PrivParent
    this.PrivParent = hParent;

    % Rerender to the new parent
    render(this);
else
    % Set the PrivParent property.  Note that Parent is the phantom property of
    % PrivParent
    this.PrivParent = hParent;
end

%-------------------------------------------------------------------------------
% [EOF]
