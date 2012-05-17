function h = exportfilt2hw(varargin)
%EXPORTFILT2HW Constructor for an export2hardware object
%   SIGGUI.EXPORTFILT2HW(FILTOBJ) Construct an exportheader object with the
%   filter FILTOBJ.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2009/07/27 20:32:10 $

h = siggui.exportfilt2hw;

msg = h.exportheader_construct(varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

addcomponent(h, siggui.targetselector);

settag(h);

% [EOF]
