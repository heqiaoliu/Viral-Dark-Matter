function varargout = legacychannelsim(state_in)
%LEGACYCHANNELSIM Toggles random number generation mode for channel objects
%   B = LEGACYCHANNELSIM returns FALSE if the R2009b and later versions of
%   random number generator is used by RAYLEIGHCHAN and RICIANCHAN functions are
%   used, which is the default. It returns TRUE if pre-R2009b versions are used.
%   See Release Notes for more information.
%
%   LEGACYCHANNELSIM(TRUE) reverts the random number generation mode for channel
%   objects to pre-2009b version.
%   
%   LEGACYCHANNELSIM(FALSE) sets the random number generation mode for channel
%   objects to 2009b and later versions.
%
%   OLDMODE = LEGACYCHANNELSIM(NEWMODE) sets the random number generation mode
%   for channel objects to NEWMODE and returns the previous mode, OLDMODE.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/23 07:48:10 $


error(nargchk(0,1,nargin,'struct'));

persistent state

if isempty(state),
    state = false;
end

if nargout,
    varargout = {state};
end

if nargin>0,
    validateattributes(state_in, {'logical'}, {'scalar'}, mfilename, 'NEWMODE')

    state = state_in;
end

mlock;


