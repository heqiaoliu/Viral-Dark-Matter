% Image  Image
%

%    Copyright 2009 The Mathworks, Inc.

classdef Image < rptgen.idoc.Node
    
    properties (Dependent)
        Title;
        DisplayWidth;
        DisplayHeight;
        Size;
        Units;
        Caption;
        Filename;
    end
    
    % Accessor methods
    methods
        function Title = get.Title(this)
            Title = this.toIdoc(this.Doms.title);
        end
        
        function set.Title(this, newTitle)
            transaction = this.Document.createTransaction();
            newTitle = this.toDoms(newTitle);
            this.Doms.title = newTitle{1};
            transaction.commit();
        end
        
        function Width = get.DisplayWidth(this)
            Width = this.Doms.displayWidth;
        end
        
        function set.DisplayWidth(this, newWidth)
            transaction = this.Document.createTransaction();
            this.Doms.displayWidth = newWidth;
            transaction.commit();
        end
        
        function Height = get.DisplayHeight(this)
            Height = this.Doms.displayHeight;
        end
        
        function set.DisplayHeight(this, newHeight)
            transaction = this.Document.createTransaction();
            this.Doms.displayHeight = newHeight;
            transaction.commit();
        end
        
        function Units = get.Units(this)
            switch(this.Doms.units)
                case rptgen.doms.ImageSizeTypes.PIXELS
                    Units = 'pixels';
                case rptgen.doms.ImageSizeTypes.CENTIMETERS
                    Units = 'centimeters';
                case rptgen.doms.ImageSizeTypes.POINTS
                    Units = 'points';
                case rptgen.doms.ImageSizeTypes.INCHES
                    Units = 'inches';
                case rptgen.doms.ImageSizeTypes.PERCENTAGES
                    Units = 'percentage';
            end
        end
        
        function set.Units(this, newUnits)
            transaction = this.Document.createTransaction();
            switch(lower(newUnits))
                case {'px','pixels'}
                    this.Doms.units = rptgen.doms.ImageSizeTypes.PIXELS;
                case {'cm','centimeters'}
                    this.Doms.units = rptgen.doms.ImageSizeTypes.CENTIMETERS;
                case {'pt','points'}
                    this.Doms.units = rptgen.doms.ImageSizeTypes.POINTS;
                case {'in','inches'}
                    this.Doms.units = rptgen.doms.ImageSizeTypes.INCHES;
                case {'%','percentage'}
                    this.Doms.units = rptgen.doms.ImageSizeTypes.PERCENTAGES;
            end
            transaction.commit();
        end
        
        function size = get.Size(this)
            size = [this.DisplayHeight, this.DisplayWidth];
        end
        
        function set.Size(this, newSize)
            transaction = this.Document.createTransaction();
            this.DisplayHeight = newSize(1);
            this.DisplayWidth = newSize(2);
            transaction.commit();
        end
        
        function caption = get.Caption(this)
            caption = this.toIdoc(this.Doms.caption);
        end
        
        function set.Caption(this, newCaption)
            transaction = this.Document.createTransaction();
            newCaption = this.toDoms(newCaption);
            this.Doms.caption = newCaption{1};
            transaction.commit();
        end
        
        function filename = get.Filename(this)
            filename = this.Doms.filename;
        end
        
        function set.Filename(this, newFilename)
            transaction = this.Document.createTransaction();
            this.Doms.filename = newFilename;
            transaction.commit();
        end
    end
    
    methods
        function this = Image(varargin)
            this = this@rptgen.idoc.Node(varargin{:});
        end
    end
    
    methods (Access = protected)
        function createDomsObject(this)
            this.Doms = this.Document.DomsFactory.createdomsImage();
        end
        
        function initialize(this,varargin)
            if ~isempty(varargin)
                this.Filename = varargin{1};
            end
        end
    end
end
