classdef (Hidden = true) AutosarCodeInfoUtils < rtw.connectivity.CodeInfoUtils
%AUTOSARCODEINFOUTILS provides AUTOSAR CodeInfo extensions and utilities
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.
  
%   Copyright 2009-2010 The MathWorks, Inc.
        
    methods (Access = 'public')
        % constructor
        function this = AutosarCodeInfoUtils(codeInfo)
            error(nargchk(1, 1, nargin, 'struct'));
            % call super class constructor
            this@rtw.connectivity.CodeInfoUtils(codeInfo);
        end                  
        
        % return the storage specifier string for an implementation
        function storageSpecifier = getStorageSpecifier(this, implementation)                        
            switch class(implementation)                
                case {'RTW.AutosarSenderReceiver' ...
                      'RTW.AutosarErrorStatus' ...
                      'RTW.AutosarClientServer' ...
                      'RTW.AutosarCalibration' ...
                      'RTW.AutosarInterRunnable'}
                    % no storage specifier
                    storageSpecifier = '';
                otherwise
                    % call superclass
                    storageSpecifier = getStorageSpecifier@rtw.connectivity.CodeInfoUtils(this, implementation);
            end
        end       
        
        % return the ErrorStatus implementation for a Receiver
        % implementation if one exists, otherwise return empty
        function errorStatusImpl = getErrorStatusFromReceiver(this, receiverImpl)
            assert(isa(receiverImpl, 'RTW.AutosarSenderReceiver'), ...
                'Argument must be a RTW.AutosarSenderReceiver');
            % find all error status & check for receiver match
            errorStatusDi = this.getErrorStatusPorts;
            numErrorStatusDi = length(errorStatusDi);
            errorPortIdx = zeros(1, numErrorStatusDi);
            for i=1:numErrorStatusDi
               currReceiverImpl = this.getReceiverFromErrorStatus(errorStatusDi(i).Implementation);
               if receiverImpl == currReceiverImpl
                  errorPortIdx(i) = true;
               end
            end      
            errorPortIdx = find(errorPortIdx);
            assert(isempty(errorPortIdx) || isscalar(errorPortIdx), 'Found multiple error ports for receiverImpl');
            if isempty(errorPortIdx)
                errorStatusImpl = [];
            else
                errorStatusImpl = errorStatusDi(errorPortIdx).Implementation;    
            end            
        end
        
        % return all ErrorStatus data interfaces
        function errorStatusDi = getErrorStatusPorts(this)
            numInports = length(this.codeInfo.Inports);
            indices = zeros(1, numInports);
            for i=1:numInports
               di = this.codeInfo.Inports(i);
               if strcmp(di.Implementation.DataAccessMode, 'ErrorStatus')
                  indices(i) = true;
               end
            end                        
            errorStatusDi = this.codeInfo.Inports(logical(indices));            
        end
        
        % return the Receiver implementation for an ErrorStatus
        % implementation
        function receiverImpl = getReceiverFromErrorStatus(this, errorStatusImpl)
           assert(isa(errorStatusImpl, 'RTW.AutosarErrorStatus'), ...
                  'Argument must be a RTW.AutosarErrorStatus');
           receiverDi = this.codeInfo.Inports(str2double(errorStatusImpl.ReceiverPortNumber));
           receiverImpl = receiverDi.Implementation;           
        end
    end                
end