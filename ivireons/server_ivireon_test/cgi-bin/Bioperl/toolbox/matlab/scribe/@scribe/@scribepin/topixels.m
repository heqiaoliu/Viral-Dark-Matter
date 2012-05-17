function [p] = topixels(hThis)
%    toPixels - Obtain the pixel coordinates of the pin with respect to 
% the figure

%   Copyright 1984-2006 The MathWorks, Inc.

ax = hThis.DataAxes;
vert = hThis.DataPosition;

if strcmp(get(ax,'XScale'),'log')
    if all(get(ax,'XLim') > 0)
        vert(:,1) = log10(vert(:,1));
    else
        vert(:,1) = -log10(-vert(:,1));
    end
end
if strcmp(get(ax,'YScale'),'log')
    if all(get(ax,'YLim') > 0)
        vert(:,2) = log10(vert(:,2));
    else
        vert(:,2) = -log10(-vert(:,2));
    end
end
if strcmp(get(ax,'ZScale'),'log')
    if all(get(ax,'ZLim') > 0)
        vert(:,3) = log10(vert(:,3));
    else
        vert(:,3) = -log10(-vert(:,3));
    end
end

% Transform vertices from data space to pixel space. This code
% is based on HG's gs_data3matrix_to_pixel internal c-function.

% Get needed transforms
xform = get(ax,'x_RenderTransform');
offset = get(ax,'x_RenderOffset');
scale = get(ax,'x_RenderScale');

% Equivalent: nvert = vert/scale - offset;
nvert(:,1) = vert(:,1)./scale(1) - offset(1);
nvert(:,2) = vert(:,2)./scale(2) - offset(2);
nvert(:,3) = vert(:,3)./scale(3) - offset(3);

% Equivalent xvert = xform*xvert;
w = xform(4,1) * nvert(:,1) + xform(4,2) * nvert(:,2) + xform(4,3) * nvert(:,3) + xform(4,4);
xvert(:,1) = xform(1,1) * nvert(:,1) + xform(1,2) * nvert(:,2) + xform(1,3) * nvert(:,3) + xform(1,4);
xvert(:,2) = xform(2,1) * nvert(:,1) + xform(2,2) * nvert(:,2) + xform(2,3) * nvert(:,3) + xform(2,4);

% w may be 0 for perspective plots 
ind = find(w==0);
w(ind) = 1; % avoid divide by zero warning
xvert(ind,:) = 0; % set pixel to 0

p(:,1) = xvert(:,1) ./ w;
p(:,2) = xvert(:,2) ./ w;
