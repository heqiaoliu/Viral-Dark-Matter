function h = loadobj(s)
%LOADOBJ Load the object H

%   @modem\@mskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:03:02 $

% Construct the new class
h = feval(s.class);

% Remove unnecessary and read-only fields
s = rmfield(s, 'class');

% Sort the fields
fn = {'Type', ...
      'M', ...
      'SamplesPerSymbol', ...
      'Precoding', ...
      'InputType'};
s = orderfields(s, fn);

% Set the remaining fields
set(h,s);


%-------------------------------------------------------------------------------

% [EOF]
