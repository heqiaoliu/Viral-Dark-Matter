%WEBFIGURECACHE the WebFigure LRU implementation for storing uuid's and fig
%handles.
%
%   We have found that having more then 32 figures open at once can cause
%   massive slow down in the HG infrastructure.  Although we do not have
%   control over other people adding figures to the mcr we can control the
%   WebFigure infrastructure.  Whenever a render is initialized it first
%   checks this cache to see if the figure is open, if it is we use that.
%
%   If the figure is not in the cache, we add it to the cache for future
%   rendering, if the cache is above the max size, we toss out the figure
%   that was accessed the longest ago.
function [hnd] = webfigurecache(uid, figStruct)
% The caching mechanism used in this code is important. It makes the
% webfigures work almost 3 times faster. The containers used for
% caching are declared to be persistent to make sure that no one clears
% them accidentally. To make sure that this M file does not get cleared
% from MATLAB's memory, we are using mlock.

mlock;
%Ensure that the uid being passed in is a string, if not
%convert it
if(isa(uid, 'numeric'))
    uid = num2str(uid);
end

%The ordered list of uuids we know about.
%A vector always performs add's to the end of the
%vector so we know that things in the beginning are the oldest.
persistent wfcLruList;
if(isempty(wfcLruList))
    wfcLruList = java.util.Vector(0,5);
end

%The HashMap containing the UUID to Handle mapping.  This is
%unordered and has no concept of least recently used.
persistent wfcHndByUid;
if(isempty(wfcHndByUid))
    wfcHndByUid = java.util.HashMap();
end

%The maximum size that either of the lists can grow to.
MAX_SIZE = 32;

hnd = getWebFigure(uid, figStruct);

%Private method to check if a key exists, this does not change
% ordering or invoke any cleanup tasks.
    function doesExist = exists(uid)
        strId = java.lang.String(uid);
        doesExist = wfcHndByUid.containsKey(strId);
    end

%Private helper function to move things to the end of the vector.
%Since a vector always adds to the end we do a remove then an add.
%We only do this if the element exists in the hashmap since hashmap
% lookup is very fast.
    function moveToEnd(uid)
        strId = java.lang.String(uid);
        %Check the hashmap since hashmap lookups
        %  are faster then vector removes
        if(wfcHndByUid.containsKey(strId))
            %If this is the first occurrence of this item,
            %  the remove does nothing
            %Removes value so it can be added to the end
            wfcLruList.remove(strId);
            %Adds to end of list
            wfcLruList.add(strId);
        end
    end

%Private helper function to make sure we keep our lists below the max
% size.
%If we reach the max size we remove the oldest from the lists, and
% remove the figure from the HG infrastructure.
    function maintainList()
        %TODO: we should add some logic to look at how many total figures exist in
        % this mcr and if we are near the limit we should have less of our
        % webfigures in the our cache so we do what we can to not bog
        % the mcr.
        if(double(wfcLruList.size()) >= MAX_SIZE)
            %Since we have ordered the list by usage with
            %  the most recently used at the end,
            %  the first element is the least
            %  frequently used element.
            oldestUID = wfcLruList.firstElement();
            remove(oldestUID);
        end
    end

%Private function to remove a uid and its associated
%  handle from the cache, and to close the figure
%  related to the handle.
    function remove(uid)
        strId = java.lang.String(uid);
        
        %Remove element from list
        wfcLruList.remove(strId);
        
        %Remove element from hashmap.
        hnd = double(wfcHndByUid.remove(strId));
        
        % verify that this figure has the proper id and close it
        if ~isempty(hnd) && ishghandle(hnd,'figure')
            % get the user data associated with this figure and make sure it
            %  matches the uuid for the webfigure
            actualId = getappdata(hnd, 'WebFigure_id');
            if ~isempty(actualId) && isequal(actualId,uid)
                close(hnd);
            end
        end
    end

%Private function to add things to the list and map.
%We first determine if the list needs any cleanup,
% then we add to the list, and then the hashmap.
    function put(uid, hnd)
        strId = java.lang.String(uid);
        dblHnd = java.lang.Double(hnd);
        
        %Determines if the list needs cleanup (has grown to large)
        maintainList();
        
        %Adds to end of vector
        wfcLruList.add(strId);
        %Adds to the hashmap
        wfcHndByUid.put(strId, dblHnd);
    end

%Private function to get a value from the map,
% this also moves the key to the front of the
% vector since it is being accessed right now.
    function hnd = getHnd(uid)
        strId = java.lang.String(uid);
        
        if(wfcHndByUid.containsKey(strId))
            %Since we are accessing the value, move
            %  it to the most frequently used position.
            moveToEnd(uid);
            
            hnd = double(wfcHndByUid.get(strId));
        end
    end

%Function responsible for deserializing
%  figData into a handle and cacheing that handle.
    function hnd = openWebFigure(uid, figData)
        % We must set the 'BusyDeserializing' appdata flag or legends will
        %  fail to deserialize
        setappdata(0,'BusyDeserializing',1);
        hnd = struct2handle(figData, 0, 'convert');
        rmappdata(0,'BusyDeserializing');        
        % A WebFigure's MATLAB figure should never be visible
        set(hnd,'Visible','off');
        % In HG2 there's a bug that's not setting the currentAxes of a
        % deserialized figure
        if feature('hgusingmatlabclasses')
            hnd.CurrentAxes = hnd.Children(1); 
            % Need to caste it to double so that we can use the List and
            % HashMap java containers later for HG2 also
            hnd = double(hnd);
        end                
        
        % id is a cookie we put in the figure to tell if this figure is in fact
        %  the one we expect it to be, in case someone has called close(all)
        %  and then reopened another figure which has recycled our old handle.
        setappdata(hnd, 'WebFigure_id', uid);
        
        % Save all the figure information in another appdata. By doing this
        % here, it will be done just once.
        setFigInfoAppData(hnd);      
           
        %Save the hnd in the local cache table so we can check for it later
        %Check cache table for any handle associated with this id
        put(uid,hnd);
    end

%Function to get and validate a webfigure, it first checks
%  and validates the cache, and if all else fails it will
%  deserialize the figStruct and save the handle in the cache.
    function hnd = getWebFigure(uid, figData)
        if(exists(uid))
            hnd = getHnd(uid);
            % re-open if the figure was closed or if this is
            %  the first time we have rendered this figure in
            %  this instance of the mcr
            if isempty(hnd) || ~ishghandle(hnd,'figure')
                %logger.warning('Unknown or invalid handle passed to webfigurecache.getWebFigure; calling openwebfigure');
                hnd = openWebFigure(uid, figStruct);
            else
                % get the user data associated with this figure and
                %  make sure it matches the uuid for the webfigure
                actualId = getappdata(hnd, 'WebFigure_id');
                if isempty(actualId) || ~isequal(actualId,uid)
                    % somehow this is not the right figure!  reopen
                    %logger.warning('webfigurecache.getWebFigure: appdata for handle is not correct; calling openwebfigure');
                    hnd = openWebFigure(uid, figStruct);
                end
            end
        else
            %logger.warning('webfigurecache.getWebFigure: Do not have figure cached; calling openwebfigure');
            %If we dont have this id cached Open it
            %  which will add it to the cache.
            hnd = openWebFigure(uid, figStruct);
        end
    end

% Store the original information about the figure and it's children as
% appdata
    function setFigInfoAppData(hnd)
        
        figInfo.figHnd       = hnd;
        figInfo.figOrigUnits = get(hnd,'units');               
        figInfo.figOrigPos   = get(hnd,'pos');        
        traversalDepth = 1;
        if feature('hgusingmatlabclasses')
            traversalDepth = 2;            
        end
            
        figChildren                  = findall(hnd, '-depth',traversalDepth,'-not', 'type', 'figure',...
                                                          '-property','units','-property','position');                
        figInfo.figChildren          = figChildren;
        figInfo.figChildrenOrigUnits = get(figChildren,'units');                
        figInfo.figChildrenOrigPos   = get(figChildren,'position');         
        
        set(figChildren,'Units','normalized');
        % Following arrayfun call should not be replaced by just get,
        % though it will work. arrayfun will save the childlayout info in
        % cell array format. Cell array format is required in
        % renderwebfig.m where we do the cropping using cellfun which
        % expects the inputs to be in the form of cell array
        figInfo.childlayout = arrayfun(@(ch) get(ch,'Position'), figChildren, 'UniformOutput', false);        
                
        set(hnd,'Units','pixels');
        set(figChildren,'Units','pixels');
        
        grandChildren                  = findall(hnd, '-property', 'units', '-not', 'units', 'pixels');        
        figInfo.grandChildren          = grandChildren;
        figInfo.grandChildrenOrigUnits = get(grandChildren,'units');
        figInfo.grandChildrenOrigPos   = get(grandChildren,'position');        
        
        figInfo.origFigPositionInPixel = get(hnd,'Position');        
        
        currentAxes = get(hnd, 'CurrentAxes');
        if isempty(currentAxes)
            error('MATLAB:openWebFigure:FigureWithoutAxes',...
                'RENDERWEBFIGURE must be called on a figure with at least one axes');
        end
        figInfo.currentAxes = currentAxes;        
        figInfo.origView = get(currentAxes, 'View');        
        setappdata(hnd,'figInfo',figInfo);
    end
end
