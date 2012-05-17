function status = utPlot(this,ax,h,robj)
% add response of model h.Model's output robj.OutputName to all axes ax.
% ax is usually a single handle, but may be two entries in case a non-GUI
% plot is updated as a result of pressing "Apply" button.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:09 $

status = true;

[range,y,thisnl] = h.generateNLData(robj,this.NumSample);
if isempty(y)
    status = false;
    return;
end

if h.isActive
    vis = 'on';
else
    vis = 'off';
end

if ~robj.is2D
    % 3D (mesh) plot
    %Alternative: surf(axk,range{1},range{2},y'); shading(axk,'interp')
    thisCol = h.Color;
    [irow,icol] = size(y);
    colmat = [];
    colmat(:,:,1) = repmat(thisCol(1),icol,irow);
    colmat(:,:,2) = repmat(thisCol(2),icol,irow);
    colmat(:,:,3) = repmat(thisCol(3),icol,irow);
    for k = 1:length(ax)
        mesh(ax(k),range{1},range{2},y',colmat,'tag',h.ModelName,'userdata',class(thisnl),'vis',vis);
        %hold(ax(k),'on')
    end
else
    % 2D plot
    for k = 1:length(ax)
        plot(ax(k),range{1},y,'Color',h.Color,'tag',h.ModelName,'userdata',class(thisnl),'vis',vis);
        %hold(ax(k),'on')
    end
end
