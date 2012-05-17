function cshelpcontextmenu(hObj, varargin)
%CSHELPCONTEXTMENU Add context sensitive help for the frame

% Author(s): J. Schickler
% Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.2.4.1 $ $Date: 2008/08/01 12:25:48 $

% Add the CSH to all HG objects at this level
siggui_cshelpcontextmenu(hObj, varargin{:});

hC = allchild(hObj);

for indx = 1:length(hC),
    
    % Add the CSH to all the HG objects at the contained level
    if isrendered(hC(indx))
        cshelpcontextmenu(hC(indx), varargin{:});
    end
end

% [EOF]
