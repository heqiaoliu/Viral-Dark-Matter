function display(opaque_array)
%DISPLAY Display a Java object.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.13.4.8 $  $Date: 2009/03/30 23:41:16 $

if strcmp(get(0, 'FormatSpacing'), 'loose')
    loose = 1;
else
    loose = 0;
end;

%
% Name or ans
%
if loose ~= 0
    disp(' ');
end;

if isempty(inputname(1))
    disp('ans =');
else
    disp([inputname(1) ' =']);
end;

if loose ~= 0
    disp(' ');
end;

if ~isjava(opaque_array) && isempty(opaque_array)
    sz = size(opaque_array);
    if length(sz) == 2
        disp(['    ', class(opaque_array), ': ', ...  
              num2str(sz(1)), '-by-', num2str(sz(2))]);
    elseif length(sz) == 3
        disp(['    ', class(opaque_array), ': ', ...  
              num2str(sz(1)), '-by-', num2str(sz(2)), '-by-', num2str(sz(3))]);
    else
        disp(['    ', class(opaque_array), ': ', ...
              num2str(length(sz)), '-D']);
    end
        
    if loose ~= 0
        disp(' ');
    end;
end
try 
    %This try/catch is needed because objects may overload disp but not
    %display, and rely on display to call the builtin disp if the object's
    %disp method errors.  This behavior is relied upon.
    disp(opaque_array);
catch exc %#ok<NASGU>
    builtin('disp', opaque_array);
end





