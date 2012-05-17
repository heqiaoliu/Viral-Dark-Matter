function h = loadobj(s)
%LOADOBJ Load the object H

%   @modem\@genqammod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:48 $

% Construct the new class
h = feval(s.class);

% Remove unnecessary and read-only fields
s = rmfield(s, {'class', 'M'});

% Sort the fields
fn = {'Type', ...
      'Constellation', ...
      'InputType'};
s = orderfields(s, fn);

% Set the remaining fields
set(h,s);


%-------------------------------------------------------------------------------

% [EOF]
