classdef LBCustomizer < handle
    
    properties
        lb
    end
    
    methods
        %------------------------------------------------------------------
        function obj = LBCustomizer()
            obj.lb = 0; 
        end
        
        function lb=getLB(obj)
            if( eq(obj.lb,0) || ~ishandle(obj.lb) )
                obj.lb = LibraryBrowser.StandaloneBrowser;
            end
            lb = obj.lb;
        end
                
        function applyOrder( obj, order )
            if( ~iscell(order) || ~eq( mod(length(order),2) , 0 ) )
                warning('Simulink:LibraryBrowserCustomization',...
                        'applyOrder expects a cell array of tuples (productName, priority)');
                return;
            end
            
            i=1;
            while i < length(order)
                if( ~ischar(order{i}) || ~isnumeric(order{i+1}) )
                    warning('Simulink:LibraryBrowserCustomization',...
                            'applyOrder expects a cell array of tuples (productName, priority)');                    
                    return;
                end  
                                
                i = i+2;
            end 
            
            
            i=1;
            lb = obj.getLB();
            if( ~lb.isInitialized() ), return; end
            
            while i < length(order)
                
                productName = order{i};
                productPriority = order{i+1};                                
                
                lb.setSortPriority(productName, productPriority);
                i = i + 2;
            end   
                                  
        end
                
        function applyFilter( obj, filters )
            if( ~iscell(filters) || ~eq( mod(length(filters),2) , 0 ) )
                warning('Simulink:LibraryBrowserCustomization',...
                        'applyFilter expects a cell array of tuples (blockPath, filterType)');
                return;
            end
            
            for i=1:length(filters)
                if( ~ischar(filters{i}) )
                    warning('Simulink:LibraryBrowserCustomization',...
                            'applyFilter expects a cell array of strings');                    
                    return;
                end                
            end
            
            i=1;
            lb = obj.getLB();
            if( ~lb.isInitialized() ), return; end
            
            while i < length(filters)
                blockPath = filters{i};
                filterType = filters{i+1};
                                                
                if( ~strcmp(filterType, 'Enabled') && ...
                    ~strcmp(filterType, 'Disabled') && ...
                    ~strcmp(filterType, 'Hidden') )
                    warning('Simulink:LibraryBrowserCustomization',...
                            'Unknown filter type %s for block %s. applyFilter expected ''Enabled'', ''Disabled'' or ''Hidden''', filterType, blockPath);
                    i = i + 2;
                    continue;
                end
                                      
                lb.setAtomicFilterState(blockPath, filterType);
                i = i + 2;
            end
                                    
        end
        
        function hideAllBlocks(obj)
            lb = obj.getLB();
            if( ~lb.isInitialized() ), return; end
            lb.hideAllBlocks();        
        end
                         
        function clear(obj)
            if( ~eq(obj.lb, 0 ) )
                lb = obj.getLB();
                if( ~lb.isInitialized() ), return; end
                lb.resetAllFilterStatesAndSortPriorities();
            end
        end
                                 
    end
    
    methods(Static=true)
        function obj = getInstance() 
            mlock;
            persistent objStorage;
            
            if( isempty(objStorage) )
                objStorage = LBCustomizer;
            end
            
            obj = objStorage;            
        end    
    end
end
