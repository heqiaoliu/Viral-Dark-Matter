function data=generate(hWIN)
%GENERATE(hWIN) Generates the functiondefined window

%   Author(s): V.Pellissier
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2008/04/21 16:30:53 $

if isempty(hWIN.Parameters),
    try
        data = feval(hWIN.MATLAB_expression, hWIN.length);
    catch ME
        throw(ME);
    end
else
    params = hWIN.Parameters;
    if ~iscell(params),
        params = {params};
    end
    try
        data = feval(hWIN.MATLAB_expression, hWIN.length, params{:});
    catch ME
        throw(ME);
    end
end

% [EOF]
