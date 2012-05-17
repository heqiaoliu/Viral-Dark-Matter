function help(this, designmethod)
%HELP   Provide help for the specified design method.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/30 17:34:05 $

if nargin < 2
    help('fdesign');
elseif isdesignmethod(this, designmethod)
    help(this.CurrentSpecs, designmethod);
else
    error(generatemsgid('invalidDesignMethod'), '%s is not a valid design method. Use DESIGNMETHODS to determine the methods \navailable for the current specifications. For more information type:\nhelp fdesign', designmethod);
end

% [EOF]
