function [h,hAx] = getView(this,hAx,inChannel,outChannel)
% GETVIEW create graphical representation of the requirement
%
% [h,hAx] = getView(this,hAx,idxIn,idxOut)
%
% Inputs:
%     this       - srorequirement.svdgain object
%     hAx        - optional axis handle where the requirement view is to be
%                  displayed. Can be an hg axis object or a respplot.plot object
%     inChannel  - Optional scalar indicating the input channel the view is for,
%                  only used for MIMO respplot.plot objects. If omitted the
%                  first input channel is assumed.
%     outChannel - Optional scalar indicating the output channel the view is for,
%                  only used for MIMO respplot.plot objects. If omitted the
%                  first input channel is assumed.
%
% Outputs:
%    h   - handle to created view, a plotconstr.designcontr object
%    hAx - handle to the axis the view is parented to.

% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:50:15 $

if nargin < 2
    %No parent axis provided create one
    tmp = bodeplot(rss(3));
    set(tmp,'phasevisible','off')
    tmp.rmresponse(tmp.Responses(1))
    hAx = getaxes(tmp,'2d');
    hAx = hAx(1);
    h = plotconstr.bodegain('Parent',hAx);
else
    %Have parent axis, use to determine what type of view to create.
    if ishghandle(hAx)
        %Constructing view from an axes handle, create view directly on
        %passed axes
        xunits = 'rad/sec';
        yunits = 'db';
    elseif isa(hAx,'resppack.respplot')
        %Constructing view from a respplot object, may have been passed IO
        %channel pair.
        if nargin<3, inChannel = 1; end
        if nargin<4, outChannel = 1; end
        xunits = hAx.Axes.XUnits;
        yunits = hAx.Axes.YUnits;
        hAx = getaxes(hAx,'2D');
        hAx = hAx(inChannel,outChannel);
    elseif isa(hAx,'sisogui.grapheditor')        
        %Constructing view from a SISOTool editor
        xunits = hAx.Axes.XUnits;
        yunits = hAx.Axes.YUnits{1};
        hAx = getaxes(hAx,'2d');
        hAx = hAx(1);
    else
        ctrMsgUtils.error('Controllib:graphicalrequirements:errAxisHandle')
    end
        
    %Create appropriate view for the requirement and passed axes
    h = plotconstr.bodegain('Parent',hAx);    
    h.setDisplayUnits('xUnits',xunits)
    h.setDisplayUnits('yUnits',yunits)
end

h.setData(this)
h.initialize;
h.activate = true;
end
