function val = getDisplayIcon(this)
%GETDISPLAYICON

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/03/17 22:08:10 $

val= '';
if(~isa(this.daobject, 'Stateflow.Object'));return;end;

val = this.daobject.getDisplayIcon;
      
if(~isempty(this.Signal))
  jval = java.lang.String(val);
  filename = strrep(char(jval.substring(jval.lastIndexOf('/') + 1)),'.png', ['Logged' this.Alert '.png']);
  val = fullfile('toolbox','fixedpoint','fixedpointtool','resources',filename);
end


% [EOF]
