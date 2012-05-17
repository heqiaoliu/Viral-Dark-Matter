function srcStr = getSourceName(this)
%GETTITLESTR Constructs the title name for the Scope and returns a string.
%This method is called from Framework.updateTitleBar. Strip the source type
%information for now.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/02/17 18:59:15 $

hExt = this.Application.getExtInst('Core','General UI');
if isempty(hExt)
    
    % Print out debugging information.
    debugcb = @(h) fprintf('Summary: %s\nDetail: %s\n\n', h.Summary, h.Detail);
    iterator.visitImmediateChildren(this.Application.MessageLog, debugcb);
    h = extmgr.RegisterLib;
    iterator.visitImmediateChildren(h.MessageLog, debugcb);
    disp(this.Application.ExtDriver);
    which('scopext','-all');
    error('Spcuilib:scopes:ExtensionNotFound', 'General UI extenion not found.');
end
displ_full_src = get(findProp(hExt,'DisplayFullSourceName'),'value');
if displ_full_src
    dsrc = this.Name;
else
    dsrc = this.NameShort;
end
srcStr = sprintf('%s', dsrc);

% [EOF]
