function [h,hAx] = getView(this,hAx,inChannel,outChannel)
% GETVIEW create graphical representation of the requirement
%
% [h,hAx] = getView(this,hAx,idxIn,idxOut)
%
% Inputs:
%     this       - srorequirement.pzlocation object
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
 
% Author(s): A. Stothert 20-Aug-2007
% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:06 $

if nargin < 2
    %No parent axis provided create one
    tmp = pzplot(rss(3));
    tmp.rmresponse(tmp.Responses(1))
    hAx = getaxes(tmp,'2d');
    hAx = hAx(1);
    h = plotconstr.pzlocation('Parent',hAx);
else
    %Have parent axis, use to determine what type of view to create.
    if ishghandle(hAx)
        %Constructing view from an axes handle, create view directly on
        %passed axes
    elseif isa(hAx,'resppack.respplot')
        %Constructing view from a respplot object, may have been passed IO
        %channel pair.
        if nargin<3, inChannel = 1; end
        if nargin<4, outChannel = 1; end
        hAx = getaxes(hAx,'2D');
        hAx = hAx(inChannel,outChannel);
    elseif isa(hAx,'sisogui.grapheditor')        
        %Constructing view from a SISOTool editor
        hAx = getaxes(hAx,'2d');
        hAx = hAx(1);
    else
        ctrMsgUtils.error('Controllib:graphicalrequirements:errAxisHandle')
    end
        
    %Create appropriate view for the requirement and passed axes
    h = plotconstr.pzlocation('Parent',hAx);    
end

h.setData(this)
h.initialize;
h.activate = true;
end
