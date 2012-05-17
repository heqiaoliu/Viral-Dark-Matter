classdef FileExtensionFilter < handle
% $Revision: 1.1.6.4 $  $Date: 2009/11/13 04:38:07 $
% Copyright 2006-2008 The MathWorks, Inc.
    properties (SetAccess='private', GetAccess='private')
        peer = {};
    end
    
    properties
        extension = '*.*';
        description = xlate('All Files');
    end
    
    properties (Constant = true)
        ACCEPT_ALL_DESCRIPTION = xlate('All Files');
        ACCEPT_ALL_EXTENSION = '*.*';
    end
    
    methods

        function obj = FileExtensionFilter(varargin)
            if (nargin > 1)
                %We have property value pairs that we need to use to
                %populate the fields of this class.
                if rem(length(varargin), 2) ~= 0
                    error('MATLAB:FileExtensionFilter:UnpairedParamsValues', 'Param/value pairs must come in pairs.');
                end
                for i = 1:2:length(varargin)
                    if ~ischar(varargin{i})
                        error ('MATLAB:FileExtensionFilter:illegalParameter', ...
                            'Parameter at input %d must be a string.', i);
                    end
                    fieldname = varargin{i};
                    switch fieldname
                        case {'extension','description'}
                            obj.(fieldname) = varargin{i+1};
                        otherwise
                            error('MATLAB:FileExtensionFilter:illegalParameter', 'Parameter "%s" is unrecognized.', ...
                                varargin{i});
                    end
                end
                %Peer has a description and an extension and so we
                %would like to suppress showing the extension with the
                %description. 
                obj.peer{1} = com.mathworks.mwswing.FileExtensionFilter(obj.description, obj.extension , false, true);
            elseif ((nargin == 1) & ~strcmp(varargin{1},''))
                %We are here because user did not specify property
                %value pairs. The user is trying to construct the
                %object using a filter(cell array of filters or a
                %string). uigetfile/uiputfile will get channelised
                %through this.
                filterlist = varargin{1};
                if ischar(varargin{1})
                    %A simple string filter extension like '*.abc' 
                    % '*.abc' --->convertTo---> cell array {'*.abc'}
                    filterlist = {varargin{1}};
                end
                if (size(filterlist,2)==2)
                    %We have a set of filters with descriptions and
                    %extensions. No 'All files' filter addition here
                    for i=1:size(filterlist,1)
                       filterext = returnFilterExtension(obj,filterlist{i,1});
                       filterdesc = filterlist{i,2};
                       obj.peer{i} = com.mathworks.mwswing.FileExtensionFilter(filterdesc,filterext,false,true);
                    end
                elseif (size(filterlist,2)==1)
                    %We have a set of filters with only extensions and
                    %no description. We add an 'All files' filter. We
                    %also check if the extension is one of our MATLAB
                    %related extensions and provide descriptions for
                    %those filters alone
                    for i=1:size(filterlist,1)
                        filterext = returnFilterExtension(obj,filterlist{i,1});
                        filterdesc = getDescIfMATLABFilters(obj,filterlist{i,1}) ;
                        obj.peer{i} = com.mathworks.mwswing.FileExtensionFilter(filterdesc,filterext,false,true);
                    end
                else
                    %We have an incorrect filter specification
                     error('MATLAB:FileExtensionFilter:illegalParameter','Incorrect Filter specification');
                end
                
            else
                x = {'getMatlabProductFilter';'getMFileFilter';'getFigFileFilter';'getMatFileFilter';'getModelFilter';'getRTWFilter';'getRptFileFilter'};
                %Peer is the set of all static default filters that we get
                %from the java class
                %com.mathworks.mwswing.FileExtensionFilter
                for i = 1:length(x)
                    obj.peer{i} =  com.mathworks.mwswing.FileExtensionFilter.(x{i});
                end
                %We have to explicitly add 'All Files' filter
                obj.peer{i+1} = com.mathworks.mwswing.FileExtensionFilter(obj.ACCEPT_ALL_DESCRIPTION,obj.ACCEPT_ALL_EXTENSION, false, true);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % The updated set of java peers is returned by 
        % the following method to add to a file dialog 
        % java peer(com.mathworks.mwswing.MJFCPP)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function fileextensionfilters = getPeer(obj)
            fileextensionfilters = obj.peer;
        end
        
    end
    
    
    methods(Access = 'private')
        %Given a matlab compound filter, '*.abc;*.exe' ---> convertTo----> {'*.abc';'*.exe'}
        %using semicolon as a delimiter.
        %Given a simple filter, '*.abc' --->convertTo--->{'*.abc'}
        function filterext = returnFilterExtension(obj,v)
            compoundCell = textscan(v,'%s', length(strfind(v,';'))+1, 'delimiter', ';');
            filterext = compoundCell{1};
        end
        
        %If filter description is not provided for the MATLAB
        %associated filters like '*.m','*.all','*.mat','*.fig' etc..
        %we give the description.
        function filterdesc = getDescIfMATLABFilters(obj,v)
            switch v
                case '*.all'
                    x = 'getMatlabProductFilter';
                    tempPeer = com.mathworks.mwswing.FileExtensionFilter.(x);
                case '*.m'
                    x = 'getMFileFilter';
                    tempPeer = com.mathworks.mwswing.FileExtensionFilter.(x);
                case '*.mat'
                    x = 'getMatFileFilter';
                    tempPeer = com.mathworks.mwswing.FileExtensionFilter.(x);
                case '*.mdl'
                    x =  'getModelFilter';
                    tempPeer = com.mathworks.mwswing.FileExtensionFilter.(x);
                case '*.fig'
                    x  = 'getFigFileFilter';
                    tempPeer = com.mathworks.mwswing.FileExtensionFilter.(x);
                case '*.rtw'
                    x = 'getRTWFilter';
                    tempPeer = com.mathworks.mwswing.FileExtensionFilter.(x);
                case '*.rpt'
                    x = 'getRptFileFilter';
                    tempPeer = com.mathworks.mwswing.FileExtensionFilter.(x);
                case '*.*'
                    tempPeer = com.mathworks.mwswing.FileExtensionFilter(obj.ACCEPT_ALL_DESCRIPTION,obj.ACCEPT_ALL_EXTENSION, false,true);
                otherwise
                    y = returnFilterExtension(obj,v);
                    tempPeer = com.mathworks.mwswing.FileExtensionFilter('',y,true,true);
            end
            filterdesc = char(tempPeer.getDescription);
        end
    end
end
            
            
            
            
            
            
            