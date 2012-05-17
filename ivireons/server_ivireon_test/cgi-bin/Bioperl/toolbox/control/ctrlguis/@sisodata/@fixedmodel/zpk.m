function D = zpk(this)
% Returns @zpkdata model of plant component.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2009/04/21 03:07:28 $

try 
    D = zpk(this.ModelData);
catch ME
    ctrlMsgUtils.error('Controllib:general:UnexpectedError', ...
        'The model cannot be converted to a zpk model.');
end