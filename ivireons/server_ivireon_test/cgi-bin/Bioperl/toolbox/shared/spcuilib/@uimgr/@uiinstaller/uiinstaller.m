function h = uiinstaller(p)
%UIINSTALLER Install multiple source trees under destination groups.
%   UIINSTALLER(P) installs UIMgr source nodes into destination group
%   addresses as described by an installation plan P,
%     P = {sourceNode1, dstGroupAddr1; ...
%          sourceNode2, dstGroupAddr2; ...
%          ... };
%   Zero or more source nodes and destination addresses may be
%   described in the cell-matrix.
%
%   Each source node is presumed to require installation into a different
%   location within a destination UIMgr tree.  Multiple destinations are
%   typically required for a GUI plug-in, where the source nodes may
%   describe multiple menus, buttons, and status bar plug-in's, each of
%   which must be parented to potentially different tree nodes in the
%   target application.
%
%   Use the VERIFY method to confirm that the uiinstaller object is
%   error-free and that the destination addresses are valid.
%
%   EXAMPLE
%      % Assume you have a tree of buttons, menus, and status options
%      % described in three UIMgr groups which extends the operation
%      % of a GUI by adding a new printing service.
%      %
%      % Each of the UI groups of the printing service gets installed
%      % to a different address of the application UI.
%      %
%      % Create the UI installer object for the new printing service:
%      hButtons = uimgr.uibuttongroup('NewPrintButtons',buttons);
%      hMenus   = uimgr.uimenugroup('NewPrintMenus',menus);
%      hStatus  = uimgr.uistatusgroup('NewPrintStatus',status_options);
%
%      % Collect the various UI groups into a master group,
%      % and link them to destination addresses within the
%      % final target application GUI:
%      plan = {hButtons, 'Toolbars/MainToolbar/PrintServices';
%              hMenus,   'Menu/File/PrintServices';
%              hStatus,  'StatusBar');
%      printSvcUI = uimgr.uiinstaller(plan);
%
%      % Typically an application GUI will have printSvcGUI available
%      % to it via some type of plug-in extension object.  When the
%      % service is enabled, the printing service UI is installed using
%      % the install method:
%      dstUI = <application-specific>;
%      install(printSvcUI,dstUI);
%
%      % Note that render() must be invoked on dstUI in
%      % order to see the changes to the application.
%
%  See also UIMGR.UIGROUP

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/05/09 23:41:03 $

% For this class, we guarantee the creation of fully-formed and
% valid objects by requiring all arguments at instantiation.
%
% Reason: this object is generally created by a plug-in, although
% the plug-in does not install itself - a target application does
% that.  Thus, only at intall-time would an error be found in the
% properties of this object.  That's a bit late.
%
% We wish to extend as much error-checking as possible to the plug-in
% writer, so we throw an error if there are problems in instantiation.
%
% As it is, we cannot "test" the destination addresses, since we do
% not hold the target application in this object ... so those names
% cannot be checked until install-time.  But we can check that:
%   - DSTNAMES is a cell-array of strings,
%   - SRCGROUP is a uimgr.uigroup, and
%   - the number of names in DSTNAMES matches the number
%     of children in SRCGROUP.

h = uimgr.uiinstaller;
if nargin>0
    h.Plan = p;
end

% [EOF]
