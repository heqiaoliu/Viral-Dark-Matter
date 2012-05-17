function resizefcn(this, varargin)
% Layout the uis if figure is different from default
% H - Input is the handle to the object after all children have been added
% IdealSize - Size at which the figure would ideally have been created

%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/13 00:25:44 $

siggui_resizefcn(this, varargin{:});

% Get the children (if any), ignore dialogs
hC = find(allchild(this), '-depth', 0, '-not', '-isa', 'siggui.dialog');

for indx = 1:length(hC),
    if isrendered(hC(indx))
        resizefcn(hC(indx), varargin{:});
    end
end


% [EOF]
