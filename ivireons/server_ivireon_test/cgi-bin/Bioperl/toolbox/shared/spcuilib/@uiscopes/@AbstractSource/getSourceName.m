function srcStr = getSourceName(this)
%GETTITLESTR COnstructs the title name for the Scope and returns a string.
%This method is called from Framework.updateTitleBar

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/12/11 21:11:40 $

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
displ_full_src = getPropValue(hExt,'DisplayFullSourceName');
if displ_full_src
    dsrc = this.Name;
else
    dsrc = this.NameShort;
end
srcStr = sprintf('%s: %s', this.Type, dsrc);


% [EOF]
