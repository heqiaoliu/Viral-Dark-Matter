function postEdit(f)

% Copyright 2008 The MathWorks, Inc.

% Customize the enabled state of figure Edit menu submenus when in Brushing
% Mode

% Disable the Delete menu
mDelete = findall(f,'Tag','figMenuEditDelete');
if ~isempty(mDelete)
    set(mDelete,'Enable','off');
end

% Enable the copy menu if any objects in the figure are brushed
mCopy = findall(f,'Tag','figMenuEditCopy');
if ~isempty(mCopy)
    if feature('HGUsingMATLAbClasses') 
        bobj = findobj(f,'-function',...
              @(x) isprop(x,'BrushData') && ~isempty(get(x,'Brushdata')) && ...
                any(x.Brushdata(:)>0),...
                'HandleVisibility','on');
    else  
        bobj = findobj(f,'-Property','Brushdata','HandleVisibility','on');         
        bobj = findobj(bobj,'flat','-function',...
        @(x) ~isempty(get(x,'Brushdata')) && any(x.Brushdata(:)>0));
    end
    if ~isempty(bobj)
        set(mCopy,'Enable','on')
    else
        set(mCopy,'Enable','off')
    end
end