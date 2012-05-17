function h = targetselector(board, proc)
%TARGETSELECTOR Construct a target selector object
%   SIGGUI.TARGETSELECTOR Construct a target selector object with the
%   default settings.
%
%   SIGGUI.TARGETSELECTOR(BOARD) Construct a target selector object with
%   BOARD used as the default board selected.
%
%   SIGGUI.TARGETSELECTOR(BOARD,PROC) Construct a target selector object
%   with PROC used as the default processor selected.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/13 00:26:48 $


% Instantiate the object
h = siggui.targetselector;

if nargin > 0, set(h, 'BoardNumber', board); end
if nargin > 1, set(h, 'ProcessorNumber', proc); end

set(h, 'Version', 1);

% [EOF]
