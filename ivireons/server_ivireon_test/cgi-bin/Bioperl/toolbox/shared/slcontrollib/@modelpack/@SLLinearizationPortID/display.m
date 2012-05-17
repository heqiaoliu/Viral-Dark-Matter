function display(this)
% DISPLAY Show object properties in a formatted form

% Author(s): Bora Eryilmaz, John Glass
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 18:54:24 $

% Display the title string
str = sprintf('\nLinearization IOs: \n--------------------------');

for ct = 1:length(this)
  h = this(ct);

  block    = modelpack.strdisp(h.getBlock);
  type     = h.getType;
  portno   = h.getPortNumber;
  openloop = h.isOpenLoop;

  % Display the current IO blockname
  str = sprintf( '%s\n(%d) Block %s, Port %d has with the following properties:', ...
                 str, ct, block, portno );

  % Display the properties for various IO combinations
  if strcmp( type, 'Input')
    % For this case the loop opening will always proceed the input perturbation.
    if openloop
      str = sprintf('%s\n    - A Loop Opening', str);
    else
      str = sprintf('%s\n    - No Loop Opening', str);
    end
    str = sprintf('%s\n    - An Input Perturbation', str);
  elseif strcmp( type, 'Output')
    % For this case the loop opening will always follow the output measurment.
    str = sprintf('%s\n    - An Output Measurement', str);
    if openloop
      str = sprintf('%s\n    - A Loop Opening', str);
    else
      str = sprintf('%s\n    - No Loop Opening', str);
    end
  elseif strcmp( type, 'InOut')
    % For this case the loop opening is first, the input perturbation is
    % second, and then the output measurement is third.
    if openloop
      str = sprintf('%s\n    - A Loop Opening', str);
    else
      str = sprintf('%s\n    - No Loop Opening', str);
    end
    str = sprintf('%s\n    - An Input Perturbation', str);
    str = sprintf('%s\n    - An Output Measurement', str);
  elseif strcmp( type, 'OutIn')
    % For this case the output measurement is first, the loop opening
    % is second, and the input perturbation is third.
    str = sprintf('%s\n    - An Output Measurement', str);
    if openloop
      str = sprintf('%s\n    - A Loop Opening', str);
    else
      str = sprintf('%s\n    - No Loop Opening', str);
    end
    str = sprintf('%s\n    - An Input Perturbation', str);
  else
    % For this case the output measurement is first, the loop opening
    % is second, and the input perturbation is third.
    if openloop
      str = sprintf('%s\n    - A Loop Opening', str);
    else
      str = sprintf('%s\n    - No Loop Opening', str);
    end
  end

  str = sprintf('%s\n ', str);
end

disp(str)
