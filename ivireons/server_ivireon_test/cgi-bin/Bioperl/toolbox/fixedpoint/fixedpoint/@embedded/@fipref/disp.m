function disp(this)
%DISP   Display object
%   Refer to the MATLAB DISP reference page for more information.
%
%   See also DISP

%   Thomas A. Bryan, 6 March 2003
%   Copyright 1999-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/04/05 22:16:17 $
s = get(this);
if isequal(this.DataTypeOverride,'ForceOff')
    s = rmfield(s,'DataTypeOverrideAppliesTo');
end
disp(s)
