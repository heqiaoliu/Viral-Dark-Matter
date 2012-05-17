function path = getDisplayIcon(hMsg) 
%  getDisplayIcon
%
%  Returns the path of an icon that indicates the type of this 
%  message.

%  Copyright 2008 The MathWorks, Inc.

  
  resource_dir = 'toolbox/shared/dastudio/resources/diagviewer/';
  
  type = lower(hMsg.type);
  
  switch type
    case 'error'
      path = [resource_dir 'error_icon.gif'];
    case 'warning'
      path = [resource_dir 'warning_icon.gif'];
    case 'log'
      path = [resource_dir 'info_icon.gif'];
    case 'info'
      path = [resource_dir 'info_icon.gif'];
    case 'diagnostic'
      path = [resource_dir 'info_icon.gif'];
    otherwise
      path = '';
  end
          
                  
end