function val = getDisplayIcon(this)
%GETDISPLAYICON

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/06/20 07:54:07 $

val= '';
if(~isa(this.daobject, 'Stateflow.Object'));return;end;

val = this.daobject.getDisplayIcon;
if ~isempty(strfind(val,'truthtable'))
    val = strrep(val,'truthtable','StateflowData');
end
%if we have no need to annotate this result return the default icon
if(isempty(this.Signal) && isempty(this.Alert)); return; end
jval = java.lang.String(val);
%use the icon with blue antenna if this result has a signal
if(~isempty(this.Signal))
  filename = strrep(char(jval.substring(jval.lastIndexOf('/') + 1)),'.png', ['Logged' this.Alert '.png']);
  val = fullfile('toolbox','fixedpoint','fixedpointtool','resources',filename);
else
  filename = strrep(char(jval.substring(jval.lastIndexOf('/') + 1)),'.png', [this.Alert '.png']);
  val = fullfile('toolbox','fixedpoint','fixedpointtool','resources',filename);  
end

% [EOF]
