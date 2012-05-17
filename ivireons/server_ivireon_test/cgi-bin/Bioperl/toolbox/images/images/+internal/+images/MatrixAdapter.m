% This undocumented class may be removed in a future release.

% MATRIXADAPTER ImageAdapter class for MATLAB matrices.
%   ADPT = MatrixAdapter(I) creates a MatrixAdapter object, ADPT, that
%   wraps a copy of the MATLAB matrix I, a MATLAB M-by-N or M-by-N-by-P
%   matrix.  MatrixAdapter is an ImageAdapter interface class that can read
%   and write data to a matrix (image) stored completely in memory.
%
%     Supported Types
%     ---------------
%     * all numeric
%     * logical
%
%     Supported Sizes
%     ---------------
%     M x N
%     M x N x P
%
%   See also BLOCKPROC, IMAGEADAPTER.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/10/16 04:57:27 $

classdef MatrixAdapter < ImageAdapter
    
    properties (Access = private)
        Data
    end % private properties
    
    methods
        
        %------------------------------
        function obj = MatrixAdapter(I)
            
            % verify data types
            if ~(isnumeric(I) || islogical(I))
                eid = sprintf('Images:%s:invalidDataType',mfilename);
                error(eid,'%s%s','Invalid data type.  MatrixAdapter expects its first argument, I, ',...
                    'to be either numeric or logical matrix.');
            end
            
            % verify data size
            if numel(size(I)) > 3
                eid = sprintf('Images:%s:invalidDataSize',mfilename);
                error(eid,'%s%s','Invalid data size.  MatrixAdapter expects its first argument, ',...
                    'I, to be either M-by-N or M-by-N-by-P.');
            end
            obj.Data = I;
            obj.ImageSize = size(I);
            
        end
        
        %--------------------------------------------------
        function result = readRegion(obj, s_offset, s_size)
            
            [rows cols] = computeRowsCols(s_offset,s_size);
            result = obj.Data(rows,cols,:);
            
        end
        
        %---------------------------------------------------
        function writeRegion(obj, region_start, region_data)
            
            region_size = size(region_data);
            [rows cols] = computeRowsCols(region_start,region_size);
            obj.Data(rows,cols,:) = region_data;
            
        end
        
        %-------------------
        function close(obj)
            obj.Data = [];
        end
        
    end % public methods
    
end % MatrixAdapter

%---------------------------------------------------
function [rows cols] = computeRowsCols(start,offset)

rows = start(1):start(1)+offset(1)-1;
cols = start(2):start(2)+offset(2)-1;

end % computeRowsCols


