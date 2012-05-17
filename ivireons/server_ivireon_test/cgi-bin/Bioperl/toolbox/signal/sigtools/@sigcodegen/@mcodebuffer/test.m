function test = test(this, test)
%TEST Tests the MATLAB code by running it.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/01/25 22:53:17 $

if nargin < 2, test = testinit(class(this)); end

try
    eval(this.string);
    test = qeverify(test, {true, true});
catch ME
    disp(sprintf('MATLAB code errored out with : %s', ME.message));
    test = qeverify(test, {true, false});
end

% [EOF]
