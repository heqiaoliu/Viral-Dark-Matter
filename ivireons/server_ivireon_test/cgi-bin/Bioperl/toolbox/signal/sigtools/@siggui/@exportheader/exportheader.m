function hEH = exportheader(varargin)
%EXPORTHEADER Construct an exportheader object
%   SIGGUI.EXPORTHEADER(FILTOBJ) Construct an exportheader object with the
%   filter FILTOBJ.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2007/12/14 15:18:32 $

%Instantiate the exportheader object
hEH = siggui.exportheader;

msg = hEH.exportheader_construct(varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

% [EOF]
