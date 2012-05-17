function hParent = set_Parent(this, hParent)
%SET_PARENT PreSet function for the 'Parent' property

%	@commgui\@shuttlectrl
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/05 17:45:30 $


if ~ishghandle(hParent, 'uipanel') && ~ishghandle(hParent, 'figure')
    error([this.getErrorId ':IllegalParent'], ...
        'Parent of COMMGUI.SHUTTLECTRL should be a figure or a uipanel.');
end

if this.Rendered
    % Unrender the old shuttle ctrl
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
