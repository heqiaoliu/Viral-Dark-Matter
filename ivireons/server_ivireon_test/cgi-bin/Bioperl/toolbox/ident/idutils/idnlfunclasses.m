function cls = idnlfunclasses
%IDNLFUNCLASSES returns the list of available nonlinearity estimator classes
%
%IDNLFUNCLASSES is used for nonlinearity estimator name autofill.  

% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/06/07 14:43:34 $

% Author(s): Qinghua Zhang


cls = {'wavenet', 'sigmoidnet', 'customnet', 'pwlinear', 'linear', ...
       'unitgain', 'saturation', 'deadzone', 'neuralnet', ...
       'treepartition', 'poly1d'};
 
% FILE END
