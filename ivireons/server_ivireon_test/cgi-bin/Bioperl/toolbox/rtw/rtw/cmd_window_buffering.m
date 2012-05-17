function prevState = cmd_window_buffering(newstate)
%CMD_WINDOW_BUFFERING - Turn command window buffering 'on' or 'off' on the PC
%
%       Copyright 1994-2006 The MathWorks, Inc.
%       $Revision: 1.7.2.4 $

  if isunix
      DAStudio.error('RTW:utility:platformNotSupported','unix');
  end

  text = evalc('system_dependent(7);');

  if ~isempty(findstr(text,'buffering disabled'))
    prevState = 'on';
  else
    prevState = 'off';
  end

  switch newstate
   case 'on'
    if ~strcmp(prevState,'off')
      evalc('system_dependent(7);');
    end
   case 'off'
    if ~strcmp(prevState,'on')
      evalc('system_dependent(7);');
    end
    otherwise
      DAStudio.error('RTW:utility:cmdWindowBufferingIllegalState');
   end

%endfunction cmd_window_buffering
