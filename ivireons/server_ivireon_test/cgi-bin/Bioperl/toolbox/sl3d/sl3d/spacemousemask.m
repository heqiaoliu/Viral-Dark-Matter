function spacemousemask
%SPACEMOUSEMASK Mask callback for Space Mouse driver.
%
%   Not to be called directly.

%   Copyright 1998-2009 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/02 22:31:25 $  $Author: batserve $

% enable mask items according to OutputType
% set new InitialRotation default if OutputType changed
switch(get_param(gcbh, 'OutputType'))
  case 'Speed';
     masken = {'on', 'on', 'on', 'on', 'on', 'off', 'off', 'on', 'on', 'off', 'off', 'off','off'};

  case 'Position';
    limiten = get_param(gcbh, 'EnableLimit');
    masken = {'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', limiten, limiten};
    if length(str2num(get_param(gcbh, 'InitialRotation'))) ~= 3    %#ok<ST2NM> need str2num for vectors
      set_param(gcbh, 'InitialRotation', '[0 0 0]');
    end;

  case 'Viewpoint coordinates';
    masken = {'on', 'on', 'on', 'on', 'on', 'off', 'off', 'on', 'on', 'on', 'on', 'off','off'};
    if length(str2num(get_param(gcbh, 'InitialRotation'))) ~= 4    %#ok<ST2NM> need str2num for vectors
      set_param(gcbh, 'InitialRotation', '[0 0 1 0]');
    end;

end;
set_param(gcbh, 'MaskEnables', masken);

% replace USB by USB1 - USB is now obsolete
if strcmp(get_param(gcbh, 'Port'), 'USB')
  set_param(gcbh, 'Port', 'USB1');
end
