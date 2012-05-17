classdef UiFileSaveDialog < UiDialog.AbstractFileDialog
    % $Revision: 1.1.6.3 $  $Date: 2009/09/23 14:02:21 $
    % Copyright 2006-2008 The MathWorks, Inc.
    methods
        function obj = UiFileSaveDialog(varargin)
            % disp C_FileSaveDialog;
            % Initialize properties
            initialize(obj);
            if rem(length(varargin), 2) ~= 0
                error('MATLAB:UiFileSaveDialog:UnpairedParamsValues', 'Param/value pairs must come in pairs.');
            end
            for i = 1:2:length(varargin)
                if ~ischar(varargin{i})
                    error ('MATLAB:UiFileSaveDialog:illegalParameter', ...
                        'Parameter at input %d must be a string.', i);
                end

                fieldname = varargin{i};
                if isValidFieldName(obj,fieldname)
                    obj.(fieldname) = varargin{i+1};
                else
                    error('MATLAB:UiFileSaveDialog:illegalParameter', 'Parameter "%s" is unrecognized.', ...
                        varargin{i});
                end
            end
            createPeer(obj);

        end

        function setIncludeFilterExtension(obj,validate)
            obj.Peer.setIncludeFilterExtension(validate);
        end


%         function show(obj)
%             show@UiDialog.AbstractFileDialog(obj);
%         end

    end

    methods(Access = 'protected')
        function initialize(obj)
            % disp I_FileSaveDialog;
            initialize@UiDialog.AbstractFileDialog(obj);
            obj.Title = 'Select File to Write';
        end

        function dataobj = updateDataObject(obj)
            dataobj.isMultiSelect = false;
            try
                dataobj.SelectedFiles = obj.Peer.getSelectedFile();
            catch
                dataobj.SelectedFiles = [];
            end
            dataobj.State = ~logical(obj.Peer.getState());
        end
     end
    
     methods(Access='protected')
        function extraPrepareDialog(obj)
            setIncludeFilterExtension(obj,true);
        end
        function doShowDialog(obj)
            javaMethodEDT('showSaveDialog',obj.Peer,getParentFrame(obj));
        end
    end
    
end
