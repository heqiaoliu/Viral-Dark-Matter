function varargout = dspfwiz(file)
%DSPFWIZ Filter Realization Wizard graphical user interface.
%   Automatically generates filter architecture models in a
%   Simulink subsystem block using individual sum, gain, and
%   delay blocks, according to user-defined specifications.
%
%   See also DSPLIB.


%    Copyright 1995-2005 The MathWorks, Inc.
%    $Revision: 1.1.8.3 $  $Date: 2005/12/22 19:05:13 $

persistent h;

% Check if Simulink is installed
[b, errstr, errid] = issimulinkinstalled;
if ~b
    error(generatemsgid(errid), errstr);
end

% If the stored handle h is no longer valid, recreate fdatool
if isempty(h) | ~isa(h, 'sigtools.fdatool') | ~isrendered(h) %#ok

    if nargin < 1
        file = 'fwizdef.mat';
    end

    % Launch FDATool
    opts.visstate = 'off';
    opts.ready    = false;
    h = fdatool(opts);

    old_tag = get(h.FigureHandle, 'Tag');
    set(h.FigureHandle, 'Tag', 'Initializing');
    
    % Set the sidebar to the dspfwiz panel
    hsb  = find(h, '-class', 'siggui.sidebar');
    indx = string2index(hsb, 'dspfwiz');

    set(hsb, 'CurrentPanel', indx);
    
    set(h.FigureHandle, 'Tag', old_tag);

    % Set up the Realize Model panel
    load(h, file, 'force', 'nooverwrite');

    % Make everything on FDATool visible
    set(h, 'Visible', 'On');
else
    
    % If the handle is still valid, make it visible and bring it to the
    % front.
    set(h, 'Visible', 'On');
    figure(h.FigureHandle);
end

if nargout
    varargout = {h};
end

mlock;

% [EOF] dspfwiz.m
