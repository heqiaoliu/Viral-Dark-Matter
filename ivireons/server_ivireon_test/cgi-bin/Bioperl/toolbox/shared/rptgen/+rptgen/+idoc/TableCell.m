% TABLECELL   Table cell
%    Table cell is a container for idoc object such as text, images and links.
%
%    See also rptgen.idoc.Table

%    Copyright 2009-2010 The Mathworks, Inc.

classdef TableCell < rptgen.idoc.Group
    properties (Dependent)
        Table
        TableIndex
    end
    
    % Accessor methods
    methods 
        function Table = get.Table(this)
            domsTable = this.Doms.getTable();
            Table = this.toIdoc(domsTable);
        end
        
        function TableIndex = get.TableIndex(this)
            seq = this.Doms.getTableIndex();
            TableIndex = this.convertSequenceOfIntegerToArray(seq) + 1;
        end
    end
    
    methods
        function this = TableCell(varargin)
            this = this@rptgen.idoc.Group(varargin{:});
        end
        
        function insertNewRow(this,direction)
            % INSERTNEWROW  Inserts a new table row 'above' or 'below'
            %
            % tableCellObject.insertNewRow('above')

            switch lower(direction)
                case 'above'
                    direction = rptgen.doms.VerticalDirection.ABOVE;
                case 'below'
                    direction = rptgen.doms.VerticalDirection.BELOW;
                otherwise
                    error('tbd');
            end
            
            transaction = this.Document.createTransaction();
            this.Doms.insertNewRow(direction);
            transaction.commit();
        end
        
        function insertNewColumn(this,direction)
            % INSERTNEWCOLUMN  Inserts a new table column to the 'left' or 'right'
            %
            % tableCellObject.insertNewColumn('left')

            switch lower(direction)
                case 'right'
                    direction = rptgen.doms.HorizontalDirection.RIGHT;
                case 'left'
                    direction = rptgen.doms.HorizontalDirection.LEFT;
                otherwise
                    error('tbd');
            end
            
            transaction = this.Document.createTransaction();
            this.Doms.insertNewColumn(direction);
            transaction.commit();
        end
        
        function removeRow(this)
            % REMOVEROW  Removes entire table row
            %
            % tableCellObject.removeRow()
            
            transaction = this.Document.createTransaction();
            this.Doms.removeRow();
            transaction.commit();
        end
        
        function removeColumn(this)
            % REMOVECOLUMN  Removes entire table column
            %
            % tableCellObject.removeColumn()
            
            transaction = this.Document.createTransaction();
            this.Doms.removeColumn();
            transaction.commit();
        end
        
        function splitTableCell(this,numberOfRows,numberOfColumns)
            % SPLITTABLECELL  Splits a table cell.
            %
            % tableObject.splitTableCell(numberOfRows,numberOfColumns)
            
            transaction = this.Document.createTransaction();
            this.Doms.splitTableCell(numberOfRows,numberOfColumns)
            transaction.commit();
        end
    end
    
    methods (Access = protected)
        function createDomsObject(this)
            this.Doms = this.Document.DomsFactory.createdomsTableCell();
        end        
        
        function index = getTableIndex(this)
            % Dom is zero based
            seqIndex = this.Doms.getTableIndex();
            row = seqIndex.at(1) + 1;
            col = seqIndex.at(2) + 1;
            index = [row col];
        end
    end
end
