function mplayinst(blk,isConnect)
%MPLAYINST Create an instance of MPlay for Signal and Scope Manager.
%   MPLAYINST(BLK, ISCONNECT) creates an instance of an 'MPlayIO' object, which
%   in turn creates an instance of MPlay.  If block already is managing
%   an 'MPlayIO' object, the current instance of MPlay is brought forward.
%   BLK is the current block from which this call is invoked.
%   ISCONNECT is a boolean that if true, means this is a call to
%   connect/disconnect, and if false indicates this is an OpenFunction call.
%   NOTE: This function assumes it is being called from the
%         OpenFunction of the MPlay library block if the second argument is
%         not passed in or is passed in as false. Otherwise the function assumes 
%         it is a call to update the signals connected to the Mplay (due to a
%          call to connect or disconnect)

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.7 $  $Date: 2009/08/23 19:40:12 $

debug = false;

% If the second argument is not passed, assume that this is
% an OpenFunction call rather than a call to connect/disconnect.
if nargin<1, blk=gcbh; isConnect=false; end
if nargin==1, isConnect=false; end

% If the block is in a library, do not create an instance of MPlay
% Just silently skip out:
hParent = get_param(blk,'Parent');
if strcmpi( get_param(hParent,'BlockDiagramType'), 'library' )
    if debug
        disp('MPlay block opened from a library - not launching scope');%#ok
    end
    return
end

% Get IO Manager object from block user data
ioObj = get_param(blk,'userdata');

% Is this a valid handle to an instance of MPlay?
hFig = [];
isValid = ~isempty(ioObj);
if isValid
    hMPlay = ioObj.hMPlay;
    isValid = ~isempty(hMPlay) && isa(hMPlay, 'uiscopes.Framework');
    if isValid
        hFig = hMPlay.Parent;
        isValid = ishghandle(hFig);
    end
end

% Determine whether the figure is visible.
isVisible = get(hFig,'Visible');

if isValid
    % Bring current MPlay window forward
    if debug
        disp('Using existing MPlay'); %#ok
    end
    figure(hFig);
else
    % create an instance of 'MPlayIO', which
    % in turn creates an instance of mplay:
    if debug
        disp('Creating new MPlay'); %#ok
    end
    ioObj = MPlayIO.MPlay(blk);
    
    % Store object in block user data
    set_param(blk,'userdata',ioObj);

end

% Make a call to mplayconnect only if there is a call to connect 
% or disconnect signals from the MPlayIO. Skip this if the mplay 
% figure is only brought forward e.g. during a call to "Open Viewer"
if (~(strcmp(get_param(blk,'iotype'), 'none')) && isConnect)
    % g487269-if the mplay window was already closed during the 
    % call to connect or disconnect, hide it in case the window 
    % was brought forward above,
    if (strcmp(isVisible,'off') && strcmp(get(hFig,'Visible'),'on'))
        set(hFig,'Visible','off')
    end
  % Connect MPlay to selected Simulink signals
  MPlayIO.mplayconnect(blk);
end
  % Turn the listener on after connected (g368739, g559815)
  ioObj.hListen.Enabled = 'on';
% [EOF]
