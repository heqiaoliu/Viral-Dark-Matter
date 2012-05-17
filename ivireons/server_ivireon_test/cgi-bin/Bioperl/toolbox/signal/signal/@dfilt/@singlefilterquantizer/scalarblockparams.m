function p = scalarblockparams(this)
%SCALARBLOCKPARAMS   Return the parameters for the gain block.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:31:26 $

p.ParameterDataTypeMode     = 'Specify via dialog';
p.ParameterScalingMode      = 'Use specified scaling';
p.OutputDataTypeScalingMode = 'Specify via dialog';
p.ParameterDataType         = 'float(''single'')';
p.ParameterScaling          = '1';
p.VecRadixGroup             = 'Use Specified Scaling';
p.OutDataType               = 'float(''single'')';
p.OutScaling                = '1';
p.LockScale                 = 'on' ;
p.RndMeth                   = 'Nearest';  % Zero|Nearest|Ceiling|Floor
p.DoSatur                   = 'on';

% [EOF]
