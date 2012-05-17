classdef UiDirDialog < UiDialog.AbstractBaseFileDialog
% $Revision: 1.1.6.6 $  $Date: 2009/07/06 20:39:13 $
% Copyright 2006-2009 The MathWorks, Inc.

    properties (SetAccess = 'private')
       SelectedFolder = [];
    end
    
    %%%%%%%%%%%%%%%%%%%
    % ALL PUBLIC METHODS
    %%%%%%%%%%%%%%%%%%%
    methods
        function obj = UiDirDialog(varargin)
            % Initialize properties
            initialize(obj);
            
            if rem(length(varargin), 2) ~= 0
                error('MATLAB:UiDirDialog:UnpairedParamsValues', 'Param/value pairs must come in pairs.');
            end

            for i = 1:2:length(varargin)
                if ~ischar(varargin{i})
                    error ('MATLAB:UiDirDialog:illegalParameter', ...
                        'Parameter at input %d must be a string.', i);
                end

                fieldname = varargin{i};
                if isValidFieldName(obj,fieldname)
                    obj.(fieldname) = varargin{i+1};
                else
                    error('MATLAB:UiFileDialog:illegalParameter', 'Parameter "%s" is unrecognized.', ...
                        varargin{i});
                end
            end
            
            createMJFolderChooser(obj);
        end
        
        
        function show(obj)
            % Setting Title causes the peer to be recreated because of a
            % lack of ability to set Title on MJFolderChooser. So,
            % setPeerTitle must be the first call in show().
            setPeerTitle(obj);
            setPeerInitialPathName(obj);
            myobj = obj.Peer;
            set(myobj,'ActionPerformedCallback',{@localUpdateIfSelected}); 
            set(myobj,'DialogCancelledCallback',{@localUpdateIfCancelled}); 
            myobj.browseAsynchronously();
            
            blockMATLAB(obj)

            function localUpdateIfSelected(src,evt)
                obj.SelectedFolder = char(evt.getActionCommand);
                dispose(obj);
            end
            function localUpdateIfCancelled(src,evt)
                obj.SelectedFolder = [];
                dispose(obj);
            end
        end
       
    end
        
    methods (Access='protected')
        function setPeerInitialPathName(obj)
            myobj = obj.Peer;
            aPathName = obj.InitialPathName;
            myobj.setInitialDirectory(java.io.File(aPathName));
        end
        
        function setPeerTitle(obj)
            createMJFolderChooser(obj);
        end
             
        function initialize(obj)
            initialize@UiDialog.AbstractBaseFileDialog(obj);
            obj.SelectedFolder = [];
            obj.Title = 'Select a Directory To Open';
        end
        
        % create thread safe java object
        function createMJFolderChooser(obj)
            if ~isempty(obj.Peer)
                delete(obj.Peer);
            end

            parent = getParentFrame(obj);
            aTitle = obj.Title;
            %f = handle(javaObjectEDT('javax.swing.JFrame', 'New Title'))
            obj.Peer = handle(javaObjectEDT('com.mathworks.mwswing.dialog.MJFolderChooser', parent, aTitle),'callbackproperties');
            javaObj = obj.Peer;
        end
        
        
        function dispose(obj)
            dispose@UiDialog.AbstractBaseFileDialog(obj);
            set(obj.Peer,'ActionPerformedCallback','');
            set(obj.Peer,'DialogCancelledCallback','');
        end

    end
end
