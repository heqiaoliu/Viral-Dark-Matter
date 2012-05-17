function lnkfvtool2mask(hBlk)
%LNKFVTOOL2MASK Callback for linking FVTool to a block mask.
%   LINKEDFVTOOL_CB(HBLK) will launch a new FVTool or re-use an existing
%   FVTool from a block mask. The handle to FVTool will be stored in the
%   UserData of the block in a field of a structure called 'fvtool', e.g.,
%   ud.fvtool.
%   
%   In order to enable the launching of FVTool, you must do the following:
%
%   1. Store a filter object in the block's UserData in a structure whose
%   field is: 'filter', e.g., ud.filter
%   
%   2. Requires that an 'On'/'Off' parameter be defined in the block mask with a
%   variable name of 'launchFVT'.
%
%   3. This function must be defined as the 'callback' for the 'launchFVT'
%   parameter from the Mask Editor.
%   
%   4. This function must be called from the 'init' portion of the mask
%   helper function so that FVTool will be updated based on changes to the
%   filter parameters.
%
%   See also FVTOOLWADDNREPLACE.

%   Author(s): J. Schickler, P. Costa
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/03/09 19:35:26 $

error(nargchk(0,1,nargin,'struct'));
if nargin < 1, hBlk = gcbh; end

ud = get_param(hBlk, 'UserData');

% Because Simulink will always evaluate the function (since it's defined as
% a callback), return when there is no filter stored in the UserData.
if ~isfield(ud,'filter') || isempty(ud.filter),
    return; 
end
filtobj = ud.filter;

% Get the Figure & FVTool handles
if isfield(ud,'fvtool') && ~isempty(ud.fvtool) && isa(ud.fvtool,'double') ...
        && ishghandle(ud.fvtool) && isappdata(ud.fvtool,'CICBlock_FVToolObjectHandle'),
    hFig = ud.fvtool;
    hFVT = getappdata(hFig,'CICBlock_FVToolObjectHandle');
else
    hFVT = fvtoolwaddnreplace(filtobj);
    hFig = double(hFVT);
    setappdata(hFig, 'CICBlock_FVToolObjectHandle', hFVT);
    % Store the Figure Handle and not the handle to FVTool.
    ud.fvtool = hFig;
end


% Adding/Replacing filters
if strcmpi(get(hFVT, 'LinkMode'), 'replace'),
    hFVT.setfilter(filtobj);
else
    hFVT.addfilter(filtobj);
end

% Visibility
if strcmpi(get_param(hBlk, 'launchFVT'), 'off')
    set(hFVT, 'Visible', 'Off');
else
    set(hFVT, 'Visible', 'On');
end

% Cache UD back in the block
set_param(hBlk, 'UserData', ud);

% [EOF]
