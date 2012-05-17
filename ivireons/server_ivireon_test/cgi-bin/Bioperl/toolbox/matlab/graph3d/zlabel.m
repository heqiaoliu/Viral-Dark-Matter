function hh = zlabel(varargin)
%ZLABEL Z-axis label.
%   ZLABEL('text') adds text above the Z-axis on the current axis.
%
%   ZLABEL('txt','Property1',PropertyValue1,'Property2',PropertyValue2,...)
%   sets the values of the specified properties of the zlabel.
%
%   ZLABEL(AX,...) adds the zlabel to the specified axes.
%
%   H = ZLABEL(...) returns the handle to the text object used as the label.
%
%   See also XLABEL, YLABEL, TITLE, TEXT.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.11.4.11 $  $Date: 2009/12/11 20:34:22 $

error(nargchk(1,inf,nargin,'struct'));

[ax,args,nargs] = axescheck(varargin{:});
if isempty(ax)
  % call zlabel recursively or call method of Axes subclass
  h = zlabel(gca,varargin{:}); 
  if nargout > 0, hh = h; end
  return;
end

if nargs > 1 && (rem(nargs-1,2) ~= 0)
  error('MATLAB:zlabel:InvalidNumberOfInputs','Incorrect number of input arguments')
end

string = args{1};
if isempty(string), string=''; end;
pvpairs = args(2:end);

if isappdata(ax,'MWBYPASS_zlabel')
    fcn = getappdata(ax,'MWBYPASS_zlabel');
    h = feval(fcn{:},string,pvpairs{:});

  %---Standard behavior
else
    h = get(ax,'ZLabel');

    if feature('hgUsingMATLABClasses') == 0
        set(h, 'FontAngle',  get(ax, 'FontAngle'), ...
               'FontName',   get(ax, 'FontName'), ...
               'FontUnits',  get(ax, 'FontUnits'),...
               'FontSize',   get(ax, 'FontSize'), ...
               'FontWeight', get(ax, 'FontWeight'));
    else
        set(h,'FontAngleMode','auto',...
            'FontNameMode','auto',...
            'FontUnitsMode','auto',...
            'FontSizeMode','auto',...
            'FontWeightMode','auto');
    end

    set(h, 'String', string, pvpairs{:});
   
end

if nargout > 0
  hh = h;
end
