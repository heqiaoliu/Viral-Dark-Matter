% DOCUMENT
%

%    Copyright 2009 The Mathworks, Inc.

classdef Document < rptgen.idoc.Node
    properties (Constant, Hidden)
        INVALID_DOCUMENT_FORMAT_ID = 'rptgen:idoc:Document:InvalidDocumentFormat';
        INVALID_DOCUMENT_FORMAT_MSG = 'Invalid document format.  Reason: %s';
    end
    
    properties (Dependent)
        Filename = 'untitled';
        PreviewFilename;
        OutputFormat;
        
        
        
%         Stylesheet;
    end
    
    properties
        
        % NOTE: TODO.  Move to DOMS
        
        Num2StrFormat = '';  
        
        ViewAfterGeneration = true;
        AutoGeneratePreview = false;
    end
    
    properties (Hidden = true)
        DomsModel = [];
        DomsFactory = [];       
        DbFormat = '';
        
    end
    
    % Accessor methods
    methods
        function set.AutoGeneratePreview(this,previewMode)
            if previewMode
                M3I.registerObservingListener(this.DomsModel,'rptgen.idoc.update');
            else
                M3I.unregisterObservingListener(this.DomsModel,'rptgen.idoc.update');
            end
        end
        
        
        function Filename = get.Filename(this)
            Filename = this.DomsModel.filename;
        end
        
        function set.Filename(this, newFilename)
            transaction = this.Document.createTransaction();
            this.DomsModel.filename = rptgen.findFile(newFilename,true);
            this.setFileExtension();
            transaction.commit();
        end
        
        function PreviewFilename = get.PreviewFilename(this)
            [previewPath previewName] = fileparts(this.Filename);
            PreviewFilename = fullfile(previewPath,[previewName '_preview.html']);
        end
        
        
        function format = get.OutputFormat(this)
            domsEnumFormat = this.DomsModel.outputFormat;
            if (domsEnumFormat == rptgen.render.DocumentFormat.DOC)
                format = 'DOC';
            elseif (domsEnumFormat == rptgen.render.DocumentFormat.PREVIEW)
                format = 'PREVIEW';
            elseif (domsEnumFormat == rptgen.render.DocumentFormat.PDF)
                format = 'PDF';
            elseif (domsEnumFormat == rptgen.render.DocumentFormat.HTML)
                format = 'HTML';
            elseif (domsEnumFormat == rptgen.render.DocumentFormat.DB)
                if (isempty(this.DbFormat))
                    format = 'DB';
                else
                    format = 'PDF';
                end
            elseif (domsEnumFormat == rptgen.render.DocumentFormat.RTF)
                format = 'RTF';
            elseif (domsEnumFormat == rptgen.render.DocumentFormat.TXT)
                format = 'TXT';
            else
                format = 'unknown';
            end
        end
        
        function set.OutputFormat(this, newFormat)
            transaction = this.Document.createTransaction();
            switch lower(newFormat)
                case 'doc'
                    this.DomsModel.outputFormat = rptgen.render.DocumentFormat.DOC;
                case 'preview'
                    this.DomsModel.outputFormat = rptgen.render.DocumentFormat.PREVIEW;
                case 'pdf'
                    this.DomsModel.outputFormat = rptgen.render.DocumentFormat.PDF;
%%%GRA%%%                    this.DomsModel.outputFormat = rptgen.render.DocumentFormat.DB;
                    this.DbFormat = 'pdf';
                case 'html'
                    this.DomsModel.outputFormat = rptgen.render.DocumentFormat.HTML;
                case 'db'
                    this.DomsModel.outputFormat = rptgen.render.DocumentFormat.DB;
                    this.DbFormat = '';
                case 'rtf'
                    this.DomsModel.outputFormat = rptgen.render.DocumentFormat.RTF;
                case 'txt'
                    this.DomsModel.outputFormat = rptgen.render.DocumentFormat.TXT;
                otherwise
                    warning(this.INVALID_DOCUMENT_FORMAT_ID, ...
                        this.INVALID_DOCUMENT_FORMAT_MSG, newFormat);
        end   

            this.setFileExtension();
            transaction.commit();

        end
        
        function styleClass = getStyleClass(this, styleClassName)
            styleClass = this.Doms.getStyleClass(styleClassName);
            if (~styleClass.isvalid)
                styleClass = [];
            else
                styleClass = this.toIdoc(styleClass);
            end
        end
        
        function setStyleClass(this, styleClassName, styleObject)
            transaction = this.Document.createTransaction();
            this.Doms.setStyleClass(styleClassName, styleObject.Doms.asImmutable);
            transaction.commit();
        end
        
        function propValue = getRendererProperty(this, propName)
            propValue = this.DomsModel.getRendererProperty(this.DomsModel.outputFormat, propName);
        end
        
        function setRendererProperty(this, propName, propValue)
            transaction = this.Document.createTransaction();
            this.DomsModel.setRendererProperty(this.DomsModel.outputFormat, propName, propValue);
            transaction.commit();
        end
        
    end
    
    methods
        function this = Document(filename)
            this.Document = this;
            rptgen.idoc.current(this);

            rptgenDomsModel = rptgen.Factory.createNewModel();
            this.DomsModel = rptgenDomsModel;
            this.OutputFormat = 'html';
            
            rptgenDomsFactory = rptgenDomsModel.factory;
            this.DomsFactory = rptgenDomsFactory;
            
            transaction = this.createTransaction();

            rptgenDomsRoot = rptgenDomsFactory.createdomsRoot();
            this.Doms = rptgenDomsRoot;
            this.DomsModel.root = rptgenDomsRoot;
            this.Doms.initializeDefaultStyles();
            %% Initialize the ID for the root object immediately
            this.Doms.identifier;
            
            this.Filename = filename;
            
            transaction.commit();
            rptgenDomsModel.clearUndoStack();
            rptgenDomsModel.clearRedoStack();
        end
        
        function undo(this)
            this.DomsModel.undo();
        end
        
        function redo(this)
            this.DomsModel.redo();
        end
        
        function transaction = createTransaction(this)
            transaction = rptgen.idoc.Transaction(this);
        end
        
        function generateReport(this)
            
            if ( (this.DomsModel.outputFormat == rptgen.render.DocumentFormat.DB  && ...
                    ~isempty(this.DbFormat)) || ...
                    this.DomsModel.outputFormat == rptgen.render.DocumentFormat.PDF)
transaction = this.createTransaction();                
                origFilename = this.DomsModel.filename;
                this.DomsModel.filename = strrep(this.DomsModel.filename, '.pdf', '.xml');
                this.DomsModel.generateReport();
%% TODO:: Take this next line out.  It is only helpful for debugging stylesheets                
com.mathworks.toolbox.rptgencore.output.StylesheetCache.clearCachedStylesheet;
%% TODO:: The next line should be added to a .phl file somewhere once idoc
%% ships
                addpath(fullfile(matlabroot, 'toolbox','shared','rptgen','resources'));
                rptconvert(this.DomsModel.filename, 'pdf', 'idoc-fo');
                this.DomsModel.filename = origFilename;
transaction.cancel();
            else
                this.DomsModel.generateReport();
            end
            
            if this.ViewAfterGeneration
                rptgen.viewfile(this.Filename);
            end
        end
        
        
        function generatePreview(this)
            previewFile = this.PreviewFilename;
            
            % TEMP HACK
            this.DomsModel.generateReport(rptgen.render.DocumentFormat.PREVIEW, previewFile);
            
            activeBrowser = com.mathworks.mde.webbrowser.WebBrowser.getActiveBrowser();
            if isempty(activeBrowser)
                web(previewFile);         
            else
                p = activeBrowser.getBrowserPanel();
                p.setCurrentLocation(previewFile);
            end
        end
        
        function outString = generateHtmlString(this, node)
            transaction = this.createTransaction();
            outString = this.DomsModel.generateStringFor(node.Doms.asImmutable(), rptgen.render.DocumentFormat.HTML);
            transaction.commit();
        end
        
    end
    
    methods (Access = private)
        
        function setFileExtension(this)
            extension = '';
            if (this.DomsModel.outputFormat == rptgen.render.DocumentFormat.DOC)
                extension = '.doc';
            elseif (this.DomsModel.outputFormat == rptgen.render.DocumentFormat.PDF)
                extension = '.pdf';
            elseif (this.DomsModel.outputFormat == rptgen.render.DocumentFormat.DB)
                if (isempty(this.DbFormat))
                    extension = '.xml';
                else
                    extension = '.pdf';
                end
            elseif (this.DomsModel.outputFormat == rptgen.render.DocumentFormat.HTML || ...
                    this.DomsModel.outputFormat == rptgen.render.DocumentFormat.PREVIEW)
                extension = '.html';                
            end
            
            [path, name] = fileparts(this.DomsModel.filename);
            this.DomsModel.filename = fullfile(path, [name extension]);
        end
    end
end
