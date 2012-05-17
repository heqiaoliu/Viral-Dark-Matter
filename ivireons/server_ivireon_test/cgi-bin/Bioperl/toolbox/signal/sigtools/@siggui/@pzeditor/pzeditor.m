function h = pzeditor(filtobj, den)
%PZEDITOR Construct a PZEDITOR

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2008/05/31 23:28:14 $

error(nargchk(0,2,nargin,'struct'));

h = siggui.pzeditor;

attachlisteners(h);

if nargin,
    if isnumeric(filtobj),
        if nargin > 1,
            filtobj = dfilt.df2t(filtobj, den);
        else
            filtobj = dfilt.dffir(filtobj);
        end
    end
    
    h.Filter = filtobj; 
end
set(h, 'AnnounceNewSpecs', 'On');

% ---------------------------------------------------------
function attachlisteners(h)

hL = handle.listener(h, h.findprop('Gain'), ...
    'PropertyPostSet', @pzvalue_listener);

set(hL, 'CallbackTarget', h);
set(h, 'Listeners', hL);

% [EOF]
