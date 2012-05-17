classdef UiFileOpenDialog < UiDialog.AbstractFileDialog
    % $Revision: 1.1.6.4 $  $Date: 2009/09/23 14:02:20 $
    % Copyright 2006-2008 The MathWorks, Inc.
    properties
        MultiSelection = false;
    end

    methods
        function obj = UiFileOpenDialog(varargin)
            % disp CFOO_FileOpenDialog;
            % Initialize properties
            initialize(obj);

            if rem(length(varargin), 2) ~= 0
                error('MATLAB:UiFileOpenDialog:UnpairedParamsValues', 'Param/value pairs must come in pairs.');
            end

            for i = 1:2:length(varargin)

                if ~ischar(varargin{i})
                    error ('MATLAB:UiFileOpenDialog:illegalParameter', ...
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

            createPeer(obj);
        end

%         function show(obj)
%             show@UiDialog.AbstractFileDialog(obj);
%         end

        %Error checking for MultiSelection property
        function obj = set.MultiSelection(obj,v)
            if ~islogical(v)
                error('MATLAB:UiFileOpenDialog:InvalidMultiSelection','MultiSelection must be a Logical value of true or false');
            end
            obj.MultiSelection = v;
        end
    end

    methods(Access = 'protected')
        function bool = isValidFieldName(obj,iFieldName)
            switch iFieldName
                case {'MultiSelection'}
                    bool = true;
                otherwise
                    bool = isValidFieldName@UiDialog.AbstractFileDialog(obj, iFieldName);
            end
        end

        function initialize(obj)
            % disp I_FileOpenDialog;
            initialize@UiDialog.AbstractFileDialog(obj);
            obj.MultiSelection = false;
            obj.Title = 'Select File To Open';
        end


        function dataobj = updateDataObject(obj)
            dataobj.isMultiSelect = false;
            try
                if isPeerMultiSelectionEnable(obj)
                    dataobj.SelectedFiles = obj.Peer.getSelectedFiles();
                    dataobj.isMultiSelect = true;
                else
                    dataobj.SelectedFiles = obj.Peer.getSelectedFile();
                end
            catch
                dataobj.SelectedFiles = [];
            end
            dataobj.State = ~logical(obj.Peer.getState());
        end
    end
    
    methods(Access='protected')
        function extraPrepareDialog(obj)
            setPeerMultiSelectionEnable(obj);
        end
        function doShowDialog(obj)
            javaMethodEDT('showOpenDialog',obj.Peer,getParentFrame(obj)); % synchronous
            %javaMethodEDT('showOpenDialog',obj.Peer,getParentFrame(obj),[]); % asynchronous
        end
    end

    methods(Access = 'private')
        % Multi Selection related
        function setPeerMultiSelectionEnable(obj)
            myobj = obj.Peer;
            myobj.setMultiSelectionEnabled(obj.MultiSelection);
        end

        function a = isPeerMultiSelectionEnable(obj)
            a = (obj.MultiSelection == 1);
        end
    end
end
