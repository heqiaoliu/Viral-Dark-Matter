function srcStr = getSourceName(this)
%GETSOURCENAME gets the name of the source.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/02/17 18:59:21 $

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
    srcStr = this.Name;
else
    srcStr = this.NameShort;
end
