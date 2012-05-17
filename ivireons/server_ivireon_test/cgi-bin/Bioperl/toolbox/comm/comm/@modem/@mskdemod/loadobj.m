function h = loadobj(s)
%LOADOBJ Load the object H

%   @modem\@mskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:02:47 $

% Construct the new class
h = feval(s.class);

% Remove unnecessary and read-only fields
s = rmfield(s, 'class');

% Sort the fields
fn = {'Type', ...
      'M', ...
      'SamplesPerSymbol', ...
      'Precoding', ...
      'OutputType', ...
      'DecisionType', ...
      'NoiseVariance'};
s = orderfields(s, fn);

% Set the remaining fields
set(h,s);

%-------------------------------------------------------------------------------
% [EOF]
