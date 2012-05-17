classdef Callbacks < handle
    methods
        function self = Callbacks()
        end
    end
    
    methods(Static)
        function CloseTab( cbinfo )
            tab = cbinfo.studio.getCurrentTab();
            if tab ~= -1
                cbinfo.studio.destroyTab( tab );
            end
        end
        
        function CloseOtherTabs( cbinfo )
            current = cbinfo.studio.getCurrentTab;
            while current > 0
                cbinfo.studio.destroyTab(0);
                current = cbinfo.studio.getCurrentTab;
            end
            count = cbinfo.studio.getTabCount;
            while count > 1
                cbinfo.studio.destroyTab(1);
                count = cbinfo.studio.getTabCount;
            end
        end
        
        function CloseAllTabs( cbinfo )
            count = cbinfo.studio.getTabCount();
            if count > 0
                for current = 0:count-1
                    cbinfo.studio.destroyTab( current );
                end
            end
        end
        
        function CloseWindow( ~ )
            disp('CloseWindow Not yet Implemented!');
            
        end
        
        function CloseAllWindows( ~ )
            disp('CloseAllWindows Not yet Implemented!');
            
        end
        
        function Save( ~ )
            %cbinfo.domain.Save();
            disp('Save Not yet Implemented!');
        end
        
        function ExitMatlab( cbinfo )
            cbinfo.domain.exitMATLAB;
        end

		function Undo( cbinfo )
			cbinfo.domain.undo;
		end
		
		function Redo( cbinfo )
			cbinfo.domain.redo;
		end

		function Cut( cbinfo )
			cbinfo.domain.doCut;
		end
		
		function Copy( cbinfo )
			cbinfo.domain.doCopy;
		end
		
		function Paste( cbinfo )
			cbinfo.domain.doPaste;
		end
		
		function Clear( ~ )
			%cbinfo.domain.Clear;
		end
    end
end