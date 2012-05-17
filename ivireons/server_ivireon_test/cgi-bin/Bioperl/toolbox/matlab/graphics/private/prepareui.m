function pj = prepareui( pj, Fig )
%PREPAREUI Method to draw Uicontrol objects in output.
%   Mimics user interface objects as Images so they appear in output.
%   Takes screen captures of user interface objects and creates true  
%   color Images in the same location as the user interface objects so 
%   the uicontrols themselves seem to print (which they can not because
%   they are drawn by the windowing system, not MATLAB).
%
%   Ex:
%      pj = PREPAREUI( pj, h ); %modifies PrintJob object pj and creates
%                               %Images of Uicontrols in Figure h
%
%   See also PREPARE, RESTORE, PREPAREHG, RESTOREUI.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.8.4.13 $  $Date: 2009/02/18 02:18:41 $

error( nargchk(2,2,nargin) );

if (~useOriginalHGPrinting())
    error('MATLAB:Print:ObsoleteFunction', 'The function %s should only be called when original HG printing is enabled.', upper(mfilename));
end

%Early exit if the user has requested not to see controls in output.
if ~pj.PrintUI
    return
end

% Check if we have a valid java figure handle to proceed.
if ~isequal(size(Fig), [1 1]) || (~isempty(Fig) && ~isfigure(Fig))
    error('MATLAB:UIControl:PrintingNotSupported', ...
          'Need a handle to a Figure object.')
end

%Bail if device doesn't support TC images.
if  strcmp( pj.Driver, 'hpgl' ) || strcmp( pj.Driver, 'ill' )
    pj.UIData = [];
    return
end

% Get handles to all visible uicontrols and java component containers.
pj.UIData.UICHandles = [];
uichandles = findall(Fig, 'Visible', 'on');
for i = 1:length(uichandles)
    hc = handle(uichandles(i));
    if (isa(hc, 'uicontrol') || isa(hc, 'uitable') || isa(hc, 'hgjavacomponent'))
        % don't want to make a copy/image this
        pj.UIData.UICHandles = [pj.UIData.UICHandles; uichandles(i)];
    end
end

if isempty(pj.UIData.UICHandles)
    pj.UIData = [];
    return
end
    
% If we did find uicontrols and intend to proceed, make sure we are in java
% figures.
if (usejava('awt') ~= 1)
    error('MATLAB:UIControl:PrintingNotSupported', ...
          'Printing of uicontrols is not supported on this platform.');
end

pj.UIData.OldRootUnits=get(0,'Units');
pj.UIData.OldFigUnits=get(Fig,'Units');
pj.UIData.OldFigPosition=get(Fig,'Position');
pj.UIData.OldFigVisible=get(Fig,'Visible');
set( Fig, 'units', 'points' )
if ~strcmp('docked', get(Fig, 'windowstyle'))
    pj.UIData.MovedFigure = screenpos( Fig, get( Fig, 'position' ) );
else
    pj.UIData.MovedFigure = false;
end
pj.UIData.OldFigCMap=get(Fig,'Colormap');

set([0 Fig],'Units','pixels');

%%% UI Controls %%%

pj.UIData.AxisHandles = [];
Frame = [];

% Making the assumption that the bottom uicontrol is usually
% created first and underneath the others.
pj.UIData.UICHandles=flipud(pj.UIData.UICHandles);
pj.UIData.UICUnits=get(pj.UIData.UICHandles,{'Units'});

% This should not be necessary anymore since we depend on the
% getpixelposition API for uicontrol position. But, printing popupmenu
% uicontrol on the Mac (native) causes a hang if this is not done.
% Keep this for now till that issue is resolved of Mac supports java
% figures. Corresponding restore in restoreui.m
set(pj.UIData.UICHandles,'Units','pixels');

% Create images %
CapturedImages = [];
CaptureCount = 0;

% Ensure all changes are flushed before getting the component images.
drawnow; % drawnow;

for lp = 1:length(pj.UIData.UICHandles)
    h = pj.UIData.UICHandles(lp);
    hh = handle(h);
    himage =  hh.getPrintImage;
    
    if isempty(himage)
        % uicontrol did not return a bitmap. This should be an error, but
        % currently there is a bug due to which an unrealized uicontrol
        % does not print. So, ignore it silently for now. Downstream code
        % depends on an image of valid (>0) size.
        % TODO: This condition should error when  G#291605 is fixed. 
        continue;
    end

    CaptureCount = CaptureCount+1;
    CapturedImages{CaptureCount}.cdata = himage;
    CapturedImages{CaptureCount}.colormap = [];
    
    Frame{CaptureCount}.Pos = rectaroundcontrol(h);
    Frame{CaptureCount}.Units = pj.UIData.UICUnits{lp};

    % Take the min of the size of uicontrol (stored in Frame above) and the
    % size of the bitmap image returned by Java. This is so that we get the
    % correct segment of image out of the bitmap for popupmenu uicontrols
    % if the size of the control is smaller or bigger than what is on
    % screen.
    hc = size(CapturedImages{CaptureCount}.cdata); hc = [hc(2) hc(1)];
    minrect = min(hc, ceil(Frame{CaptureCount}.Pos(3:4)));
    
    % Clamp down the image and the Frame size to the minrect so that the
    % image is not clipped in unpleasant ways (under OpenGL).
    CapturedImages{CaptureCount}.cdata = CapturedImages{CaptureCount}.cdata(...
        1:minrect(2), 1:minrect(1), :);
    Frame{CaptureCount}.Pos(3:4) = minrect;
end

% Draw each image to stand in for the uicontrols
for lp=1:length(Frame)
    if ~isempty(CapturedImages{lp})
        if ~isempty( CapturedImages{lp}.colormap )
            CapturedImages{lp}.cdata = ind2rgb(CapturedImages{lp}.cdata, ...
                                               CapturedImages{lp}.colormap);
            CapturedImages{lp}.colormap = [];
        end

        pj.UIData.AxisHandles(lp)=axes('Parent',Fig, ...
            'Units'         ,'pixels'        , ...
            'Position'      ,Frame{lp}.Pos,    ...
            'Tag'           ,'PrintUI'         ...
            );
        %call low level command so NextPlot has no affect, fix Axes.
        image('cdata',CapturedImages{lp}.cdata, ...
              'Parent',pj.UIData.AxisHandles(lp));
        set(pj.UIData.AxisHandles(lp), ...
            'Units'          ,Frame{lp}.Units, ...
            'Visible'        ,'off'       , ...
            'ColorOrder'     ,[0 0 0]     , ...
            'XTick'          ,[]          , ...
            'XTickLabelMode' ,'manual'    , ...
            'YTick'          ,[]          , ...
            'YTickLabelMode' ,'manual'    , ...
            'YDir'           ,'reverse'   , ...
            'XLim'           ,[0.5 (Frame{lp}.Pos(3))+0.5], ...
            'YLim'           ,[0.5 (Frame{lp}.Pos(4))+0.5]  ...
            );
    else
        pj.UIData.AxisHandles(lp) = -1;
        warning('MATLAB:Print:UIcontrolScreenCaptureFailed', ...
                'Screen capture failed - UIcontrol will not appear in output.');
    end %if ~isempty(capturedimages)
end % for lp

set(Fig, 'Units', pj.UIData.OldFigUnits );
set(0,   'Units', pj.UIData.OldRootUnits);

% Make uicontrols invisible because Motif on Sol2 sometimes seg-v's
% if the uicontrols are visible while resizing in normalized units.
% note we don't store the old visible state since we searched for visible
% uicontrols in the findobj above.
set(pj.UIData.UICHandles,'visible','off');
drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% RectAroundControl %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rect = rectaroundcontrol( ch )
%RECTAROUNDCONTROL Get rectangle that tightly bounds UiControl
%
% rect = get(ch,'position');
% For every iteration up the hierarchy we seem to be losing a pixel in X
% and Y. So contained components may not show the edges correctly. Need to
% revisit.
rect = getpixelposition(ch, true);

if ~strcmp('uicontrol', get(ch, 'Type'))
    % It may be a uicontainer for a javacomponent.
    return;
end

%A little fudgying is required since pop-up menus do not obey their
%position property. They are of a fixed height across all platforms
%irrespective of the height set in the position property.
if strcmp( 'popupmenu', get(ch,'style') )
    oldUnits = get(ch, 'Units');
    set(ch, 'Units', 'pixels');
    pix_ext = get(ch,'extent');
    set(ch, 'Units', oldUnits);

    rect(2) = rect(2) + rect(4) - pix_ext(4) - 2;
    rect(4) = pix_ext(4) + 2;
end
