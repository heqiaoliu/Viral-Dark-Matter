% This undocumented class may be removed in a future release.

% ADAPTERDISPATCHER Dispatches ImageAdapter method invocations.
%   DISPATCHER = AdapterDispatcher(ADAPTER,MODE) creates an
%   AdapterDispatcher object, DISPATCHER, for ADAPTER, an image format
%   adapter.  ADAPTER is an instance of a class which inherits from the
%   ImageAdapter class, implementing each method for a specific image file
%   format.  MODE can either be 'r' or 'r+', creating a read-only or
%   read-and-write dispatcher respectively.
%
%   The AdapterDispatcher class wraps the methods of the ADAPTER object to
%   provide more informative error messages.
%
%   See also BLOCKPROC, IMAGEADAPTER.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/04 16:21:02 $

classdef AdapterDispatcher < handle
    
    properties (Access = public)
        ImageSize
    end % public properties
    
    properties (Access = private)
        Adapter
        ReadOnly
        NumBands
    end % private properties
    
    
    methods
        
        %-------------------------------------------
        function obj = AdapterDispatcher(adpt, mode)
            
            % set the adapter
            if isa(adpt,'ImageAdapter')
                obj.Adapter = adpt;
            else
                eid = sprintf('Images:%s:invalidImageAdapter',mfilename);
                error(eid,'%s%s','Invalid ImageAdapter.  AdapterDispatcher expects its first argument ',...
                    'to be an ImageAdapter object.  See the help for AdapterDispatcher.');
            end
            
            % validate mode
            if strcmpi(mode,'r')
                obj.ReadOnly = true;
            elseif strcmpi(mode,'r+')
                obj.ReadOnly = false;
            else
                eid = sprintf('Images:%s:invalidMode',mfilename);
                error(eid,'Invalid mode specified.  AdapterDispatcher expects the mode argument to be either ''r'' or ''r+''');
            end
            
            % validate image size
            sz = obj.Adapter.ImageSize;
            if ~isnumeric(sz) || (numel(sz) < 2) || (numel(sz) > 3)
                eid = sprintf('Images:%s:invalidImageSize',mfilename);
                error(eid,'%s%s','Invalid image size.  The AdapterDispatcher expects the ImageAdapter Size property to be ',...
                    'M-by-N or M-by-N-by-P.');
            end
            
            % get the number of bands
            if numel(obj.Adapter.ImageSize) > 2
                obj.NumBands = size(3);
            else
                obj.NumBands = 1;
            end
            
        end % AdapterDispatcher
        
        
        %---------------------------------------------------------
        function data = readRegion(obj, region_start, region_size)
            % readRegion Read region from ImageAdapter object.
            %   See the help for ImageAdapter.readRegion method.
            
            try
                data = obj.Adapter.readRegion(region_start, region_size);
            catch adpt_ex
                
                % create formatted argument strings
                start_str = sprintf('[%s]',num2str(region_start));
                size_str  = sprintf('[%s]',num2str(region_size));
                % create diagnostic string
                diag_str = sprintf('%s\n%s\n%s','The input arguments were:',...
                    sprintf('  region_start: %s',start_str),...
                    sprintf('  region_size : %s',size_str));
                % create/throw new exception
                new_ex = internal.images.ImageAdapterException('readRegion',...
                    class(obj.Adapter),diag_str);
                new_ex = new_ex.addCause(adpt_ex);
                throw(new_ex);
                
            end
            
            % validate returned data size
            act_size = [size(data,1) size(data,2)];
            if ~isequal(act_size,region_size)
                
                % create formatted argument strings
                exp_size_str = sprintf('[%s]',num2str(region_size));
                act_size_str = sprintf('[%s]',num2str(act_size));
                
                % display the error message with some diagnostics
                eid = sprintf('Images:%s:readRegionSizeError',mfilename);
                error(eid,'%s%s%s\n%s%s','Incorrect data size returned from ',...
                    class(obj.Adapter),'.readRegion method:',...
                    sprintf('  returned data size : %s\n',act_size_str),...
                    sprintf('  expected data size : %s\n',exp_size_str));
                
            end
            
        end % readRegion
        
        
        %--------------------------------------------------------
        function [] = writeRegion(obj, region_start, region_data)
            % writeRegion Write region to ImageAdapter object.
            %   See the help for ImageAdapter.writeRegion method.
            
            if obj.ReadOnly
                eid = sprintf('Images:%s:readOnly',mfilename);
                error(eid,'Attempted to write to a read-only AdapterDispatcher.');
            end
            
            try
                obj.Adapter.writeRegion(region_start, region_data);
                
            catch adpt_ex
                
                % create formatted argument strings
                start_str = sprintf('[%s]',num2str(region_start));
                size_str  = sprintf('[%s]',num2str(size(region_data)));
                % create diagnostic string
                diag_str = sprintf('%s\n%s\n%s','The input arguments were:',...
                    sprintf('  region_start: %s',start_str),...
                    sprintf('  region_data : Matrix of size %s',size_str));
                % create/throw new exception
                new_ex = internal.images.ImageAdapterException('writeRegion',...
                    class(obj.Adapter),diag_str);
                new_ex = new_ex.addCause(adpt_ex);
                throw(new_ex);
                
            end
            
        end % writeRegion
        
        
        %------------------
        function close(obj)
            % close Close ImageAdapter object.
            %   See the help for ImageAdapter.close method.
            
            % call the adapter function
            try
                obj.Adapter.close();
                
            catch adpt_ex
                
                new_ex = internal.images.ImageAdapterException('close',...
                    class(obj.Adapter));
                new_ex = new_ex.addCause(adpt_ex);
                throw(new_ex);
                
            end
            
        end % close
        
    end % methods
    
end % AdapterDispatcher
