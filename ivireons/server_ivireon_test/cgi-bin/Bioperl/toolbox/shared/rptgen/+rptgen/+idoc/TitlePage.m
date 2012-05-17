% TITLEPAGE  Titlepage
%

%    Copyright 2009 The Mathworks, Inc.

classdef TitlePage < rptgen.idoc.Node
    
    properties (Dependent)
        Abstract;
        Author;
        CopyrightHolder;
        CopyrightDate;
        Image;
        LegalNotice;
        Subtitle;
        Title;
    end
    
    % Accessor methods
    methods
        function this = TitlePage(varargin)
            this = this@rptgen.idoc.Node(varargin{:});
        end
        
        function abstract = get.Abstract(this)
            abstract = this.toIdoc(this.obj.abstract);
        end
        
        function set.Abstract(this, newAbstract)
            transaction = this.Document.createTransaction();
            newAbstract = this.toDoms(newAbstract);
            this.Doms.abstract = newAbstract{1};
            transaction.commit();
        end
        
        function author = get.Author(this)
            author = this.toIdoc(this.Doms.author);
        end
        
        function set.Author(this, newAuthor)
            transaction = this.Document.createTransaction();
            newAuthor = this.toDoms(newAuthor);
            this.Doms.author = newAuthor{1};
            transaction.commit();
        end
        
        function copyrightHolder = get.CopyrightHolder(this)
            copyrightHolder = this.toIdoc(this.Doms.copyrightHolder);
        end
        
        function set.CopyrightHolder(this, newCopyrightHolder)
            transaction = this.Document.createTransaction();
            newCopyrightHolder = this.toDoms(newCopyrightHolder);
            this.Doms.copyrightHolder = newCopyrightHolder{1};
            transaction.commit();
        end
        
        function copyrightDate = get.CopyrightDate(this)
            copyrightDate = this.toIdoc(this.Doms.copyrightDate);
        end
        
        function set.CopyrightDate(this, newCopyrightDate)
            transaction = this.Document.createTransaction();
            newCopyrightDate = this.toDoms(newCopyrightDate);
            this.Doms.copyrightDate= newCopyrightDate{1};
            transaction.commit();
        end
        
        function image = get.Image(this)
            image = this.toIdoc(this.Doms.image);
        end
        
        function set.Image(this, newImage)
            transaction = this.Document.createTransaction();
            newImage = this.toDoms(newImage);
            this.Doms.image = newImage{1};
            transaction.commit();
        end
        
        function legalNotice = get.LegalNotice(this)
            legalNotice = this.toIdoc(this.Doms.legalNotice);
        end
        
        function set.LegalNotice(this, newLegalNotice)
            transaction = this.Document.createTransaction();
            newLegalNotice = this.toDoms(newLegalNotice);
            this.Doms.legalNotice = newLegalNotice{1};
            transaction.commit();
        end
        
        function subtitle = get.Subtitle(this)
            subtitle = this.toIdoc(this.Doms.subtitle);
        end
        
        function set.Subtitle(this, newSubtitle)
            transaction = this.Document.createTransaction();
            newSubtitle = this.toDoms(newSubtitle);
            this.Doms.subtitle = newSubtitle{1};
            transaction.commit();
        end
        
        function title = get.Title(this)
            title = this.toIdoc(this.Doms.title);
        end
        
        function set.Title(this, newTitle)
            transaction = this.Document.createTransaction();
            newTitle = this.toDoms(newTitle);
            this.Doms.title = newTitle{1};
            transaction.commit();
        end
    end
    
    methods (Access = protected)
        function createDomsObject(this)
            this.Doms = this.Document.DomsFactory.createdomsTitlePage();
        end
        
        function initialize(this,varargin)
            if ~isempty(varargin)
                this.Title = title;
            end
        end
    end
end
