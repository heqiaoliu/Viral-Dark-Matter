function str = createVerDateCode
% CREATEVERDATECODE
 
% Author(s): John W. Glass 28-Jul-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:35:41 $

% Generate the header
str = '';
verMATLAB = ver('matlab');
verSCD = ver('slcontrol');
str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:GeneratedVersComment',verMATLAB.Version,verSCD.Version);
str{end+1} = '%';
str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:GeneratedDateComment',datestr(now));
