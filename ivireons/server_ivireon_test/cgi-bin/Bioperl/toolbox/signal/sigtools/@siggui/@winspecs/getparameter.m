function param = getparameter(this)
%GETPARAMETER   Get the parameter.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/08/22 20:33:28 $

window = get(this, 'Window');

if isa(window, 'sigwin.parameterizewin')
    p = getparamnames(window);
    if ~iscell(p)
        param{1}=p;
        param{2}='';
    else
        param = p;
    end
else
    param = '';
end

% [EOF]
