function makeCurrent(hThis)

%Given a datatip, make it current for its dataCursorManager

%Copyright 2005-2007 The MathWorks, Inc.

hDataManager = get(hThis,'DataManagerHandle');

if isempty(hDataManager)
	return;
end

%Set the datatip to be the current datatip:
set(hDataManager,'CurrentDataCursor',hThis);
%If the property editor is open, make it show the information for the
%datatip
hManager = get(hThis,'DataManagerHandle');
if ~isempty(hManager) && ~isdeployed
    if usejava('awt')
        propedit(hManager,'-noselect','-noopen');
    end
end
