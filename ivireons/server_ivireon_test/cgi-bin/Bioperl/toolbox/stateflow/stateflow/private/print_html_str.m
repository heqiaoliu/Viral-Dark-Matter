function status = print_html_str(str, jobName)

% Copyright 2002-2008 The MathWorks, Inc.
%   $Revision: 1.4.4.5 $  $Date: 2008/12/01 08:06:53 $
  
status = 0;

try
  if(usejava('jvm') && usejava('awt') && usejava('swing'))
    % proceed
  else
    % no java. dont bother doing anything.
    return;
  end

  com.mathworks.mlwidgets.html.HTMLRenderer.printHtml(jobName,str);
    
catch ME
    disp(ME.message);
    status = 1;
end






