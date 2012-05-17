function help(this, designmethod)
%HELP   Provide help for the specified design method.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:01:28 $

if nargin < 2
    help('fdesign');
elseif isdesignmethod(this.PulseShapeObj, designmethod)
    help(this.PulseShapeObj, designmethod);
else
    error(generatemsgid('invalidDesignMethod'), '%s is not a valid design method. Use DESIGNMETHODS to determine the methods \navailable for the current specifications. For more information type:\nhelp fdesign', designmethod);
end

% [EOF]
