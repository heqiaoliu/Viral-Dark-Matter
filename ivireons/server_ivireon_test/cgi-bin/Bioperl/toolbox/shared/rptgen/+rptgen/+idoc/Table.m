% TABLE   Table
%    Table

% TODO.  
% 1. Title cell support
% 2. Support dataset

%    Copyright 2009-2010 The Mathworks, Inc.

classdef Table < rptgen.idoc.Group
    methods
        function this = Table(varargin)
            this = this@rptgen.idoc.Group(varargin{:});
        end
        
        function import(this,content)
            % IMPORT  Imports a two dimension cell array or matix into a table.
            %
            % cellContent = {'a','b','c'; 'd','e','f'; 'g','h','i'}
            % tableObject.import(content)
            
            % Get dimension
            dimensions = size(content);
            rows = dimensions(1);
            cols = dimensions(2);
            
            % If content has more than two dimension, fail
            if (length(dimensions) > 2)
                error(['Cannot convert a ' length(dimensions) ...
                    '-dimensional object into a table']);
            end
            
            % Create empty table
            transaction = this.Document.createTransaction();
            this.createEmptyTable(rows,cols);
            
            % Create table
            for i = 1:rows
                for j = 1:cols
                    domsTableCell = this.getDomsTableCell(i,j);
                    
                    % Convert current item to doms object
                    currentItem = content(i,j);
                    if iscell(currentItem)
                        currentItem = currentItem{1};
                    end
                    currentDoms = this.toDoms(currentItem);
                    
                    % Append doms to tablecell object
                    for k = 1:length(currentDoms)
                        domsTableCell.appendChild(currentDoms{k});
                    end
                end
            end
            
            transaction.commit();
        end
        
        function createEmptyTable(this,numberOfRows,numberOfColumns)
            % CREATEEMPTYTABLE  Creates empty table.
            %
            % tableOject.createEmptyTable(numberOfRows,numberOfColumns)

            transaction = this.Document.createTransaction();
            this.Doms.createEmptyTable(numberOfRows,numberOfColumns);
            transaction.commit();
        end
        
        function tableCell = getTableCell(this,varargin)
            % GETTABLECELL  Returns table cell for a given row and column index.
            % 
            % TABLECELL = tableObject.getTableCell(row,col)
            % TABLECELL = tableObject.getTableCell([row col])
            
            index = this.extractIndex(varargin{:});
            domsTableCell = this.getDomsTableCell(index(1),index(2));
            tableCell = this.toIdoc(domsTableCell);
        end
        
        function tableIndex = getTableIndex(this,tableCell)
            % GETTABLECELLINDEX  Returns table cell index for a given table cell.
            % 
            % TABLEINDEX = tableObject.getTableIndex(tableCellObject)
            % 
            % TABLEINDEX is an array of [rowIndex columnIndex]
            
            index = this.getDomsTableIndex(tableCell.Doms);
            tableIndex = [index(1) index(2)];
        end
        
        function mergeTableCells(this,varargin)
            % MERGECELLS  Merges table cells.
            %
            % tableObject.mergeTableCells(topLeftTableCell,numberOfRows,numberOfColumns)
            % tableObject.mergeTableCells([row col],numberOfRows,numberOfColumns)
            % tableObject.mergeTableCells(row,col,numberOfRows,numberOfColumns)
            
            [topLeft, remainder] = this.extractDomsTableCell(varargin{:});
            numberOfRows = remainder{1};
            numberOfColumns = remainder{2};

            transaction = this.Document.createTransaction();
            this.Doms.mergeTableCells(...
                topLeft.asImmutable(),...
                numberOfRows,...
                numberOfColumns);
            transaction.commit();
        end
        
        function splitTableCell(this,varargin)
            % SPLITTABLECELL  Splits a table cell.
            %
            % tableObject.splitTableCell(topLeftTableCell,numberOfRows,numberOfColumns)
            % tableObject.splitTableCell([row col],numberOfRows,numberOfColumns)
            % tableObject.splitTableCell(row,col,numberOfRows,numberOfColumns)
            
            [domsTableCell remainder] = this.extractDomsTableCell(varargin{:});
            numberOfRows = remainder{1};
            numberOfColumns = remainder{2};

            transaction = this.Document.createTransaction();
            this.Doms.splitTableCell(...
                domsTableCell.asImmutable(),...
                numberOfRows,...
                numberOfColumns);
            transaction.commit();
        end
        
        function insertNewRow(this,varargin)
            % INSERTNEWROW  Inserts a new table row 'above' or 'below' a given table cell.
            %
            % tableObject.insertNewRow(tableCellObject,'above')
            % tableObject.insertNewRow([row col],'below')
            % tableObject.insertNewRow(row,col,'below')
            
            [domsTableCell remainder] = this.extractDomsTableCell(varargin{:});
            switch lower(remainder{1})
                case 'above'
                    direction = rptgen.doms.VerticalDirection.ABOVE;
                case 'below'
                    direction = rptgen.doms.VerticalDirection.BELOW;
                otherwise
                    error('tbd');
            end
            
            transaction = this.Document.createTransaction();
            this.Doms.insertNewRow(domsTableCell.asImmutable(),direction);
            transaction.commit();
        end
        
        function insertNewColumn(this,varargin)
            % INSERTNEWCOLUMN  Inserts a new table column to the 'left' or 'right' a given table cell.
            %
            % tableObject.insertNewColumn(tableCellObject,'left')
            % tableObject.insertNewColumn([row col],'right')
            % tableObject.insertNewColumn(row,col,'right')

            [domsTableCell remainder] = this.extractDomsTableCell(varargin{:});
            switch lower(remainder{1})
                case 'right'
                    direction = rptgen.doms.HorizontalDirection.RIGHT;
                case 'left'
                    direction = rptgen.doms.HorizontalDirection.LEFT;
                otherwise
                    error('tbd');
            end
            
            transaction = this.Document.createTransaction();
            this.Doms.insertNewColumn(domsTableCell.asImmutable(),direction);
            transaction.commit();
        end
        
        function removeRow(this,varargin)
            % REMOVEROW  Removes entire table row for a table cell location.
            %
            % tableObject.removeRow(tableCellObject)
            % tableObject.removeRow([row col])
            % tableObject.removeRow(row,col)
            
            domsTableCell = this.extractDomsTableCell(varargin{:});
            transaction = this.Document.createTransaction();
            this.Doms.removeRow(domsTableCell.asImmutable());
            transaction.commit();
        end
        
        function removeColumn(this,varargin)
            % REMOVECOLUMN Removes a table column for a table cell location.
            
            domsTableCell = this.extractDomsTableCell(varargin{:});
            transaction = this.Document.createTransaction();
            this.Doms.removeColumn(domsTableCell.asImmutable());
            transaction.commit();
        end
                
        function this = subsasgn(this,subscript,varargin)
            % SUBSASGN  Subscripted assignment to a table cell object
            %
            % +-----+-----+-----------+      +-----+-----+-----------+
            % | 1,1 | 1,2 |    1,3    |      | 1,1 | 1,2 |    1,3    |
            % +-----+-----+-----+-----+      +-----+-----+-----+-----+
            % |     | 2,2 |     |     |      |     | 2,2 |     |     |
            % | 2,1 +-----+ 2,3 | 2,4 |  =>  | 2,1 +-----+ 2,3 | 2,4 |
            % |     | 3,1 |     |     |      |     | 3,1 |     |     |
            % +-----+-----+-----+-----+      +-----+-----+-----+-----+
            % | 4,1 |    4,2    | 4,3 |      | AAA |    4,2    | 4,3 |
            % +-----+-----------+-----+      +-----+-----------+-----+
            %
            % t(4,1) = 'AAA'  
            %
            % Note: This is equilvent to calling the import method of a table cell.
            % t(4,1).import('AAA')
            
            transaction = this.Document.createTransaction();
            if strcmp(subscript(1).type,'()')
                % Assignment on table cell
                tablecell = this.getTableCell(subscript(1).subs{:});
                tablecell.import(varargin{1});
            else
                % Default property assignment or method invocation
                this = builtin('subsasgn',this,varargin{:});
            end
            transaction.commit();
        end
        
        function out = subsref(this,subscript)
            % SUBSREF  Subscripted reference to a table cell object
            %
            % +-----+-----+-----------+
            % | 1,1 | 1,2 |    1,3    |
            % +-----+-----+-----+-----+
            % |     | 2,2 |     |     |
            % | 2,1 +-----+ 2,3 | 2,4 |
            % |     | 3,1 |     |     |
            % +-----+-----+-----+-----+
            % | 4,1 |    4,2    | 4,3 |
            % +-----+-----------+-----+
            %
            % t(4,1)
            % ans = '4,1'

            if strcmp(subscript(1).type,'()')
                % Get tablecell
                tablecell = this.getTableCell(subscript(1).subs{:});
                if (length(subscript) == 1)
                    % Return tablecell
                    out = tablecell;
                else
                    % Safely call builtin SUBSREF on remaining subscript
                    out = tablecell.builtinSubsref(tablecell,subscript(2:end));
                end
            else
                % Safely call builtin SUBSREF
                out = this.builtinSubsref(this, subscript);
            end
        end
    end
    
    methods (Access = protected)
        function createDomsObject(this)
            this.Doms = this.Document.DomsFactory.createdomsTable();
        end        
    end

    methods (Access = private)
        function domsTableCell = getDomsTableCell(this,row,col)
            % Doms is zero based
            domsRowIndex = row - 1;
            domsColIndex = col - 1;
            domsTableCell = this.Doms.getTableCell(domsRowIndex,domsColIndex);
 
            domsModel = this.Document.DomsModel;
            domsTableCell = domsModel.toMutable(domsTableCell);
        end
        
        function tableIndex = getDomsTableIndex(this,domsTableCell)
            % Dom is zero based
            seqIndex = this.Doms.getTableIndex(domsTableCell.asImmutable());
            row = seqIndex.at(1) + 1;
            col = seqIndex.at(2) + 1;
            tableIndex = double([row col]);
        end
 
        function [tableCell remainder] = extractDomsTableCell(this,varargin)
            if isa(varargin{1},'rptgen.idoc.TableCell')
                tableCell = varargin{1}.Doms;
                remainder = varargin(2:end);
            else
                [index remainder] = this.extractIndex(varargin{:});
                tableCell = this.getDomsTableCell(index(1),index(2));
            end
        end
    end
    
    methods (Access = private, Static)
        function [index remainder] = extractIndex(varargin)
            in1 = varargin{1};
            in2 = varargin{2};
            
            if (isnumeric(in1) && (length(in1) == 2))
                index = [in1(1) in1(2)];
                remainder = varargin(2:end);
            
            elseif ((isnumeric(in1) && (length(in1) == 1)) ...
                    && (isnumeric(in2) && (length(in2) == 1)))
                index = [in1 in2];
                remainder = varargin(3:end);
                
            else
                error('tbd');
            end
        end
    end
end
