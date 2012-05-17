function [serialized, width, height, az, el, bgcolor] = savewebfigure(hnd)
% Serialize the specified figure
serialized = handle2struct(hnd);

% Get height/width
position = get(hnd, 'Position');
width = position(3);
height = position(4);

% Get camera angle
currentAxes = get(hnd, 'CurrentAxes');
if isempty(currentAxes) 
    error('MATLAB:savewebfigure:FigureWithoutAxes',...
          'SAVEWEBFIGURE must be called on a figure with at least one axes');
end
v = get(currentAxes, 'View');
az = v(1);
el = v(2);

% Get background color
bgcolor = get(hnd, 'Color');
rgbspec = [1 0 0;0 1 0;0 0 1;1 1 1;0 1 1;1 0 1;1 1 0;0 0 0];
cspec = 'rgbwcmyk';
if ischar(bgcolor),
  k = find(cspec==bgcolor(1));
  if isempty(k)
      error('MATLAB:savewebfigure:InvalidColorString','Unknown color string.'); 
  end
  if k~=3 || length(bgcolor)==1,
    bgcolor = rgbspec(k,:);
  elseif length(bgcolor)>2,
    if strcmpi(bgcolor(1:3),'bla')
      bgcolor = [0 0 0];
    elseif strcmpi(bgcolor(1:3),'blu')
      bgcolor = [0 0 1];
    else
      error('MATLAB:savewebfigure:UnknownColorString', 'Unknown color string.');
    end
  end
  bgcolor = bgcolor(ones(length(fig),1),:);
end
