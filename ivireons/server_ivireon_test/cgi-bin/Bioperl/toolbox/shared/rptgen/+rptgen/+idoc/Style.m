% STYLE  Style
%

%    Copyright 2009 The Mathworks, Inc.

classdef Style < rptgen.idoc.Node
    methods
        function this = Style(varargin)
            this = this@rptgen.idoc.Node(varargin{:});
        end
        
        function value = getAttribute(this, name)
            name = this.stringToStyleAttribute(name);
            value = this.Doms.getAttribute(name);
        end

        function setAttribute(this, name, value)
            transaction = this.Document.createTransaction();
            name = this.stringToStyleAttribute(name);
            this.Doms.setAttribute(name, value);
            transaction.commit();
        end
    end
    
    methods (Access = protected)
        function createDomsObject(this)
            this.Doms = this.Document.DomsFactory.createdomsStyle();
        end
    end
    
    methods (Static)
    
        function styleAttribute = stringToStyleAttribute(attributeName)
            
            if (isa(attributeName, 'char'))
                if (strcmpi(attributeName, 'align'))
                    styleAttribute = rptgen.doms.StyleAttribute.ALIGN;
                elseif (strcmpi(attributeName, 'backgroundimage'))
                    styleAttribute = rptgen.doms.StyleAttribute.BACKGROUND_IMAGE;
                elseif (strcmpi(attributeName, 'backgroundcolor'))
                    styleAttribute = rptgen.doms.StyleAttribute.BACKGROUND_COLOR;
                elseif (strcmpi(attributeName, 'border'))
                    styleAttribute = rptgen.doms.StyleAttribute.BORDER;
                elseif (strcmpi(attributeName, 'bordercolor'))
                    styleAttribute = rptgen.doms.StyleAttribute.BORDER_COLOR;
                elseif (strcmpi(attributeName, 'borderwidth'))
                    styleAttribute = rptgen.doms.StyleAttribute.BORDER_WIDTH;
                elseif (strcmpi(attributeName, 'bold'))
                    styleAttribute = rptgen.doms.StyleAttribute.BOLD;
                elseif (strcmpi(attributeName, 'color'))
                    styleAttribute = rptgen.doms.StyleAttribute.COLOR;
                elseif (strcmpi(attributeName, 'font'))
                    styleAttribute = rptgen.doms.StyleAttribute.FONT;
                elseif (strcmpi(attributeName, 'fontsize'))
                    styleAttribute = rptgen.doms.StyleAttribute.FONT_SIZE;
                elseif (strcmpi(attributeName, 'italic'))
                    styleAttribute = rptgen.doms.StyleAttribute.ITALIC;
                elseif (strcmpi(attributeName, 'strikethrough'))
                    styleAttribute = rptgen.doms.StyleAttribute.STRIKE_THROUGH;
                elseif (strcmpi(attributeName, 'margin'))
                    styleAttribute = rptgen.doms.StyleAttribute.MARGIN;
                elseif (strcmpi(attributeName, 'numeration'))
                    styleAttribute = rptgen.doms.StyleAttribute.NUMERATION;
                elseif (strcmpi(attributeName, 'underline'))
                    styleAttribute = rptgen.doms.StyleAttribute.UNDERLINE;
                else
                    styleAttribute = rptgen.doms.StyleAttribute.UNSUPPORTED_STYLE;
                end
            else
                styleAttribute = attributeName;
            end
        end
    end
end
