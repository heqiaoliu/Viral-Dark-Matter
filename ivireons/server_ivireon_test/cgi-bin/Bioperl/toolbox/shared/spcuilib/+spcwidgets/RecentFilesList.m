classdef (CaseInsensitiveProperties = true,...
            TruncatedProperties = true, ...
            Sealed = true) RecentFilesList < handle
    %RecentFilesList   Define the RecentFilesList class.
    
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.3 $  $Date: 2010/05/20 03:07:40 $

    properties (SetAccess = private)     
        DefaultMaxFiles = 10;
        PrefsGroup = 'RecentFilesPrefs';
        PrefsRecentFiles = 'RecentFiles';
        PrefsRecentChooseFile = 'RecentChooseFile';                        
    end
    
    properties
        SelectedItem;
        InitialMenu;
        Menus;
        LoadCallback;
        SaveCallback;
        EmptyListMsg = '<no recent files>';
        MenuStrNmax = 25;
        MenuStrNpre = 3;
        % ---------------------------------------------------
        % Properties for maintaining recently opened file
        % for file browser dialog
        LoadFileObj;
        LoadFileTitle = 'Choose file';
        SaveFileTitle = 'Save file';
        FileFilterSpec = {'*.txt','Text files (*.txt)'; ...
                  '*.*',  'All Files (*.*)'};
    end        

    methods

        function this = RecentFilesList(grp,prf)
            %RecentFilesList Construct a RecentFilesList object.
            %   RecentFilesList(GRP) instantiates a RecentFilesList object
            %   that manages a list of recently opened files or projects.  The
            %   list is persistent and stored in a user preference  The entries
            %   can be any string, and not just the names of files or projects.
            %
            %   A group name GRP must be specified during the constructor call;
            %   see SETPREF for details on preference group naming conventions.
            %   The group name should be specific to the application, and may be
            %   the name of a preference group already in use by the application.
            %   This preference group is used to store the list of recent files.
            %   The name of the file list, used within this preference group, may
            %   optionally be specified by a second argument to the constructor,
            %         obj = RecentFilesList(GRP,PRF)
            %   By default, PRF='RecentFiles'.  Changing the file list name is useful
            %   if more than one file list is utilized within one application.
            %
            %   Whenever the application opens a file that should be tracked
            %   by this list, call the setMostRecent method to add the file.
            %   If the file is already in the list, it is recalled to the top
            %   of the list and is not added again to the list.
            %
            %   The maximum number of files in the list can be changed, initially
            %   or during use, by the setMax method.  getMax returns the current
            %   maximum number of items retained in the list.  The list entries can be
            %   reset to unused at any time using the resetList method.
            %   List entries can be obtained using the getAllRecent and getMostRecent
            %   methods.
            %
            %   The RecentFilesList object can automatically manage a collection of
            %   uimenu entries to make the file history more easily available on menus.
            %   See the connectMenu method for more details.
            
            mlock;
            
            % A preferences group name must be specified
            % during constructor call
            if nargin<1
                error('spcwidgets:NoPrefsGroup',['A preferences group name must be specified.\n', ...
                    'See "setpref" for details on naming conventions.']);
            end
            
            this.PrefsGroup = grp;
            if nargin>1
                this.PrefsRecentFiles = prf;
            end
            
            initPrefs(this);
            
            % File chooser manager object
            this.LoadFileObj = spcwidgets.LoadFile;
        end
        
        function createMenus(h, mItem) %AllocMenus(h,mItem)
            %creatMenu Creates/reallocates uimenu objects
            %   h.creatMenu(mItem) creates or re-creates uimenu objects corresponding
            %   to recent file list.  Disconnects any menus currently connected to
            %   object.
            
            % Check that mItem is a uimenu
            if ~uimgr.isHandle(mItem) || ~strcmp(get(mItem,'type'),'uimenu')
                error('spcwidgets:InvalidHandle', ...
                    'mItem is not a valid uimenu handle');
            end
            
            firstPos = get(mItem,'position'); % ordinal of first menu item
            mParent = get(mItem,'parent');    % parent of first menu item
            
            % We cannot install the file list into the top-level toolbar
            if ~strcmp(get(mParent,'type'),'uimenu')
                error('spcwidgets:InvalidMenuLevel', ...
                    'Cannot install menu system into top-level menu bar');
            end
            
            % Do not attempt disconnection until we're reasonably sure
            % we can successful connect (i.e., put after error-checking above)
            if ~isempty(h.InitialMenu)
                h.disconnectMenu; % disconnect existing menus
            end
            
            % Cache user's initial menu
            % Non-empty signifies object's control of a current menu system
            h.InitialMenu = mItem;
            
            % Preallocate space for maximum # of uimenu handles
            N = h.getMax;
            h.Menus = zeros(1,N);
            
            % Take over original menu, add additional
            %
            % Create Nmax-1 additional menus, assuming a maximum of Nmax items in list
            % The strategy is to make invisible the unused menu entries
            %
            % If the first menu item in the controlled menu list happens
            % to be 1st in the menu, don't use a separator ... there's
            % nothing to separate it from!
            if firstPos==1, sep='off';
            else            sep='on';
            end
            label_fmt = '%d <empty>';
            h.Menus(1) = mItem;
            set(mItem,...
                'separator',sep, ...
                'label',sprintf(label_fmt,1), ...
                'vis','on');
            for i=2:N
                % Create additional menu items
                h.Menus(i) = uimenu('parent',mParent, ...
                    'Position',firstPos-1+i, ...
                    'label',sprintf(label_fmt,i), ...
                    'vis','off');
            end
            
            % Set the callback of the parent menu to update the child menus
            %
            % This should be done as a last step, once the menus have been
            % created.  Now, whenever the parent menu is opened, the child
            % menus are updated to the latest global list.  This way, multiple
            % clients (GUI instances) can coordinate with one global list of
            % recent items.
            %
            set(mParent,'callback',@(s,e)updateMenus(h));
        end
        
        function [fname,cancel] = chooseFile(h)
            %chooseFile Opens file choice dialog, executes file callback
            %  [fname,cancel] = chooseFile(h) opens file chooser dialog.
            %  If not cancelled, file is added to recent file list.
            %
            %  Maintains recently opened file name to have subsequent selections
            %  automatically open the file browser the same directory.
            
            % Setup LoadFile object before opening dialog
            % in case these properties have recently changed
            %
            c = h.LoadFileObj;
            c.FilterSpec = h.FileFilterSpec;
            c.Title      = h.LoadFileTitle;
            
            grp = h.PrefsGroup;
            prf = h.PrefsRecentChooseFile;
            if ispref(grp, prf)
                initialDir = getpref(grp, prf);
            else
                initialDir = pwd;
            end
            c.InitialDir = initialDir;
            
            cancel = ~c.select;  % use "choose file" UI
            if cancel
                fname='';
            else
                % Store selected directory as most recent "selected file"
                setpref(grp,prf,c.InitialDir);  % updated with new path
                
                % Record file as the most recent item chosen
                fname = c.fullfile;
                h.SelectedItem = fname;
                setMostRecent(h, fname);
                
                % Execute callback, with no additional args supplied here, if present
                cbFcn = h.LoadCallback;
                if ~isempty(cbFcn)
                    cbFcn();
                end
            end
        end
        
        function connectMenu(h, mItem)
            %connectMenu Insert menu items for recent file list
            %  connectMenu(mItem,cbFcn) causes the uimenu handle mItem to be
            %  "owned" by the RecentFilesList object, and it is replaced by a set of
            %  uimenu entries, one menu per non-empty entry in the recent file list.
            %
            %  A menu separator is turned on for the first menu item, and additional
            %  menu items are created and inserted immediately after the mItem menu;
            %  all these menu items are managed by the RecentFilesList object.
            %
            %  Menu items have numeric accelerators assigned to each, with the
            %  first item having "1" as its menu accelerator, and the name of the
            %  file.  If the recent file list is empty, one menu entry is retained,
            %  in a disabled state, with the label "1 <no recent files>".
            createMenus(h, mItem); % Disconnect old, (re)allocate new menus
            updateMenus(h);       % Initial update of labels, visibility
        end
        
        function disconnectMenu(h)
            %disconnectMenu Disconnect object from user menu system.
            
            % InitialMenu property indicates whether we are currently
            % managing any user menus:
            %
            if ~isempty(h.InitialMenu)
                % 1st entry is Menu is a copy of the original (user) menu
                %  - do not delete user's menu instance!
                %  - remove callback, reset label
                %  - make visible, but disable it
                if uimgr.isHandle(h.Menus(1))
                    set(h.Menus(1), ...
                        'label','<no longer used>', ...
                        'callback','', ...
                        'enable','off', ...
                        'vis','on');
                    
                    % All other menus in list were added by this object
                    %  - delete them
                    delete(h.Menus(2:end));
                end
                
                % Reset list of menu handles, removing references to the
                % deleted menus, and to the user-specific menu handle
                h.Menus = [];
                
                % Remove reference to initial menu, signifying that we
                % no longer have an active connection to user menus
                h.InitialMenu = [];
            end
        end
        
        function [items,N] = getAllRecent(h,includeEmpty)
            %getAllRecent Returns list of all recent items in list.
            %   If includeEmpty is true, return maximum number of entries
            %     in the list, even if some are unused.
            %   If includeEmpty is false or omitted, return only
            %     the non-empty entries.
            %   Optionally returns number of entries used, especially
            %     useful when returning all (max #) items in list.
            
            % This is the full list, including empty slots
            grp = h.PrefsGroup;
            prf = h.PrefsRecentFiles;
            if ispref(grp, prf)
                items = getpref(grp, prf);
            else
                items = {};
            end
            shortList = (nargin<2) || ~includeEmpty;
            if shortList || (nargout>1)
                % Find number of nonempty items, N, assumed to
                % appear consecutively at top of list
                %
                % Note:
                %   - items can be a simple cell-array of strings, such
                %     as file names, along with unused/empty entries
                %     e.g., {'file1','file2','',''}
                %
                %   - items can be more complex cell-array of cells,
                %     as long as the inner cells have the first entry
                %     as a string.  The string is used to populate the
                %     menus.  If an entry is unused, the inner cell
                %     must be empty so that the 'isempty' test below
                %     properly registers empty entry.
                %     { {'item1',data1}, {'item2',data2}, {}, {} }
                %
                i = find(cellfun('isempty',items),1);
                if isempty(i)  % no empty slots - all are being used
                    N = numel(items);
                else
                    N = i-1;   % empty slot found - all before it are filled
                end
                if shortList
                    % Include only non-empty items
                    items = items(1 : N);
                end
            end
        end
        function N = getMax(h)
            %getMax Return maximum number of files retained in list
            
            % Count all files in list, including empty slots
            %    true -> return all, including empties
            N = numel(h.getAllRecent(true));
        end
        
        function items = getMostRecent(h)
            %getMostRecent Returns name of most recent items
            %   If no recent item (i.e., list is empty), returns empty
            
            % This is the full list, including empty slots
            items = h.getAllRecent;
            if isempty(items)
                items = '';
            else
                items = items{1};
            end
        end
        
        function initPrefs(h,maxNum)
            %initPrefs Create/check/initialize Preferences entries
            %   for RecentProjectList.  Also RESIZES maximum number
            %   in existing list by extending or truncating as needed.
            
            % If maxNum not passed in, leave number of recorded projects
            % as-is (if prefs exist).  If prefs do not exist, use defaultMaxNum.
            if nargin<2
                maxNum = -1;  % signal: leave as-is
            end
            
            % Initialize RecentFiles preference
            %   - Reset to maximum number of entries
            %   - If prefs exists but are invalid, replace them
            %   - If it exists but is not at the maximum, truncate/extend
            %
            % Check if preference entry has previously been created
            %
            grp = h.PrefsGroup;
            prf = h.PrefsRecentFiles;
            if ispref(grp,prf)
                % Preference exists - check that it is valid
                v = getpref(grp,prf);
                
                % Must be a cell-vector
                % It might not be a cellstr, because we support
                % cells containing an inner cell with a string,
                % such as { {'one',data}, {'two',data} }
                % in addition to {'one','two'}
                %
                if ~iscell(v) || ~isvector(v)
                    %
                    % Invalid pref - remove then replace
                    % h.resetList;  % done during the add process
                    addnewpref = true;
                else
                    % Preference exists as a cell array of strings
                    % Truncate/extend # elements if requested
                    %
                    addnewpref = false;
                    
                    % If an existing cell-vector of strings in the preference happens
                    % to be a row instead of a column, force into a column.  This will
                    % prevent an error during concat below, and enforce the spec.
                    v = v(:);
                    
                    if (maxNum ~= -1)
                        nCurr = numel(v);
                        if nCurr > maxNum
                            % truncate
                            v = v(1:maxNum);
                        elseif nCurr < maxNum
                            % extend
                            v=[v;emptyStringVec(maxNum-nCurr)];
                        end
                        h.setList(v);
                    end
                end
            else
                addnewpref = true;
            end
            if addnewpref
                % Create default values for preference
                if maxNum == -1
                    maxNum = h.DefaultMaxFiles;
                end
                h.resetList(maxNum);
            end
            
            % Initialize PrefsRecentChooseFile
            %
            prf = h.PrefsRecentChooseFile;
            if ispref(grp,prf)
                % exists - check that it's valid
                v = getpref(grp,prf);
                if ~ischar(v)
                    addnewpref = true;
                end
            else
                addnewpref = true;
            end
            if addnewpref
                initDir = fullfile(pwd,filesep);
                setpref(grp,prf,initDir);
            end
            
            % Re-create menus, if they're being used
            %
            if ~isempty(h.InitialMenu)
                updateMenus(h);
            end
        end
        
        function resetList(h,maxNum)
            %resetList Resets entries in list to empty strings.
            %   If maxNum passed, changes number of entries as well.
            
            if nargin<2
                % Reset existing num entries
                maxNum = h.getMax;
            end
            h.setList(emptyStringVec(maxNum));
        end
        
        function [fname,cancel] = saveFile(h)
            %saveFile Opens file save dialog, executes file callback
            %  [fname,cancel] = saveFile(h) opens file save dialog.
            %  If not cancelled, file is added to recent file list.
            %
            %  Maintains recently saved file name to have subsequent selections
            %  automatically open the file browser the same directory.
            
            % Setup LoadFile object before opening dialog
            % in case these properties have recently changed
            %
            c = h.LoadFileObj;
            c.FilterSpec = h.FileFilterSpec;
            c.Title      = h.SaveFileTitle;
            
            grp = h.PrefsGroup;
            prf = h.PrefsRecentChooseFile;
            if ispref(grp, prf)
                initDir = getpref(grp, prf);
            else
                initDir = pwd;
            end
            c.InitialDir = initDir;
            cancel = ~c.select(true);  % use "save file" UI
            if cancel
                fname='';
            else
                % Store selected directory as most recent "selected file"
                setpref(grp,prf,c.InitialDir);  % updated with new path
                
                % Log this as the most recent choice
                fname = c.fullfile;
                h.SelectedItem = fname;  % stash in RecentFilesList object
                
                setMostRecent(h, fname);
                % xxx executeCallback(h.SaveCallback,fname);
                
                % Execute callback, with no additional args supplied here, if present
                cbFcn = h.SaveCallback;
                if ~isempty(cbFcn)
                    cbFcn();
                end
            end
        end
        
        function setList(h,files)
            %setList Set list back into preferences
            
            % Set the list of files into the preference
            grp = h.PrefsGroup;
            prf = h.PrefsRecentFiles;
            setpref(grp,prf,files);
            
            % If menus are being managed, update them now:
            updateMenus(h);
            
        end
        
        function setMax(h,maxNum)
            %setMax Set maximum number of files retained in list
            %   Extend or truncate as needed            
            h.initPrefs(maxNum);            
        end
        
        function setMaxPref(h,eventStruct)
            %setMaxPref Sets recent files list length property from preference listener.            
            if isa(ev, 'event.PropertyEvent')
                listLen = eventStruct.AffectedObject.(eventStruct.Source.Name);
            else
                listLen = eventStruct.NewValue;
            end            
                        
            %h.RecentFilesListLength = listLen;
            h.setMax(listLen);
        end
        
        function setMostRecent(h,item)
            %setMostRecent Sets most recent item
            %   If new, it adds it to the list
            %   If existing, it moves it to the top of the list
            
            % Note: we do not check for the existence of the item
            %       (presuming it's a file name)
            %       the item is recorded verbatim; the caller
            %       should use "which(file)" to pass a fully qualified
            %       path name if desired
            %
            % There are two supported items:
            %    - char strings, like 'filename' (could be empty strings)
            %    - cells, could be empty cells
            %      if not empty, the first entry of the inner cell must
            %      be a string ... this string is used for comparisons
            %      to determine "same" or "different"
            
            if isempty(item)
                error('spcwidgets:AddEmptyItem', 'Cannot add an empty item');
            end
            
            % Get all files, including empties, to maintain
            % the list length
            items = h.getAllRecent(true);
            N = numel(items);
            
            % Two cases:
            %   - strings
            %   - cells with 1st entry a string
            if iscell(item)
                % item is a cell
                % assume 1st entry in cell is comparison string
                item_name = item{1};
                all_names = getItemNames(items);
                idx = strmatch(item_name,all_names,'exact');
            else
                % item is a simple string
                idx = strmatch(item,items,'exact');
            end
            
            if isempty(idx)
                % No match (new file, or empty list)
                % Add to top of list, drop off last/oldest item
                items = [{item}; items(1:N-1)];
            else
                % Single match - reorder list
                % Setup index vector
                % Example: 4th entry is now first
                %   original: [1 2 3 4 5 6]
                %        new: [4 1 2 3 5 6]
                %
                % If multiple matches, duplicates already exist in list
                % Remove all duplicates, moving just one match to top of list
                all_idx = 1:N;
                all_idx(idx) = [];  % remove all dupes in list - usually, one
                all_idx = [idx(1) all_idx];  % add first matching index
                items = items(all_idx);
            end
            h.setList(items);            
        end
        
        % ----------------------------------------------
        function set.PrefsGroup(h, grp)
            % Set the name of the preferences group
            % It should not be changed during use of the class instance
            if ~ischar(grp)
                error('spcwidgets:MustBeString', 'Preference group name must be a string');
            end
            h.PrefsGroup = grp;
        end
        
        % ----------------------------------------------
        function set.PrefsRecentFiles(h,prf)
            % Set the name of the file list preference
            % It should not be changed during use of the class instance
            if ~ischar(prf)
                error('spcwidgets:MustBeString', 'File list preference name must be a string');
            end
            h.PrefsRecentFiles = prf;
        end                
    end

    methods (Access = 'protected')
        
        function updateMenus(h)
            %updateMenus - PRIVATE METHOD
            % Get list of recent files
            % Make visible this many menus,
            %   and update labels and callbacks accordingly
            
            if isempty(h.InitialMenu)
                % This is not an error; the object makes calls here
                % from various points, regardless of menu connection state
                %
                % At this point, we know we're not connected to any user menus
                return
            end
            [items,Ncurr] = h.getAllRecent;
            if Ncurr > numel(h.Menus)
                error('spcwidgets:assert', 'Number of files in list exceeds number of menus')
            end
            
            if Ncurr==0
                % No items - display one disabled menu
                set(h.Menus(1), ...
                    'vis','on', ...
                    'enable','off', ...
                    'label',['1 ' h.EmptyListMsg]);
                % Turn off all remaining menus
                set(h.Menus(2:end),'vis','off');
            else
                itemNames = getItemNames(items);
                for i=1:Ncurr
                    dispName = strTruncate(itemNames{i},h.MenuStrNmax,h.MenuStrNpre);
                    
                    labelStr = sprintf('%d %s', i, dispName);
                    % Add menu accelerator char before 1st (numeric) digit,
                    % for numbers 1-9.  "10 <name>" starts with "1", and would
                    % be ambiguous with "1 <name>", hence the limit.
                    if i < 10
                        labelStr = ['&' labelStr]; %#ok
                    end
                    
                    set(h.Menus(i), ...
                        'callback', @(s,e)localRecentFileMenuCb(h,i), ...
                        'vis','on', ...
                        'enable','on', ...
                        'label',labelStr);
                end
                % Turn off all remaining menus
                set(h.Menus(Ncurr+1:end),'vis','off');
            end
        end
        
        % ----------------------------------------------------
        function localRecentFileMenuCb(h,idx)
            % Execute LoadCallback, if present
            %
            % NOTE: It is up to the callback to call
            %            h.setMostRecent(item)
            %       with item pulled from .SelectedItem
            
            % Get item from index
            items = h.getAllRecent;
            thisItem = items{idx};
            h.SelectedItem = thisItem;  % stash in RecentFilesList object
            
            % Execute callback, with no additional args supplied here, if present
            cbFcn = h.LoadCallback;
            if ~isempty(cbFcn)
                cbFcn();
            end            
        end                
    end
end

function s = emptyStringVec(n)
% Create column vector of empty strings
s = repmat({''},n,1);
end

function itemNames = getItemNames(items)
% Return cell-array of item names
%
% items is a cell-array
% entries are either strings, in which case we return
%   the item list it as-is
% entries can be cells, in which case we return the
%   first entry from each cell, presumably these are
%   string names (as long as the cell is not empty)
%
% Note: even if items contains inner cells, some may
%    be chars ... empty chars.  Empty chars are used
%    sometimes in place of empty cells.  So first,
%    to check it items contains cells itself, we must
%    check for "any" cells at all ... not just if the
%    1st entry is a cell.  Similarly, just because the
%    1st entry may be a char, doesn't mean everything
%    is a char.  Cells and empty chars may be mixed.

itemNames = items;
for i=1:numel(items)
    thisItem = items{i};
    if iscell(thisItem) && ~isempty(thisItem)
        itemNames{i} = thisItem{1};
    end
end
end

function str = strTruncate(str,Nmax,Npre) %strellip
%strTruncate Truncate string to maximum length using ellipsis ('...')
%   strTruncate(STR,NMAX,NPRE) truncates a string to a maximum specified
%   length NMAX, utilizing an ellipsis ('...') to indicate suppressed
%   characters.  NPRE number of characters are retained before the
%   ellipsis is inserted; if omitted, NPRE=5.
%
%   - If STR does not exceed NMAX characters, it is returned unchanged.
%   - Setting NMAX = inf effectively disables truncation and the
%     original string is always returned.
%   - NMAX will automatically be constrained to a minimum value of 3
%     so an ellipsis can be visible in the returned string.
%   - If NPRE = 0, characters from STR are removed from the start of the
%     string, and the new string will start with an ellipsis if truncated.
%   - NPRE will automatically be constrained to a maximum of NMAX-3 so an
%     ellipsis can be inserted into the truncated string.

Nstr = numel(str);
Nmax = max(Nmax,3);
if Nstr < Nmax
    % original string is shorter than limit; return original
    return
end
if nargin < 3
    Npre = 5;  % default value
end
% Create truncated string
Npre = min(Npre,Nmax-3);  % limit to Nmax-3
tpre = str(1:Npre);
Npre_actual = numel(tpre);
Ntail = Nmax-Npre_actual-3;
tpost = str(end-Ntail+1:end);
str = [tpre '...' tpost];
end
   
% [EOF]
