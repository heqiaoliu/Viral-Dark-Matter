function cmd = firceqriplp_maskinfo(h, d)
%FIRCEQRIPLP_MASKINFO

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/07/11 14:56:00 $

cmd = ft_maskinfo(h, d);

cmd.bands{2}.drawpatch    = false;
cmd.bands{2}.magfcn       = 'rolloff';
cmd.bands{2}.slope        = get(d, 'stopbandSlope');
cmd.bands{2}.drawfreqbars = false;

% [EOF]
