classdef MicrosoftSchedulerConnectionExceptionManager
    %MicrosoftSchedulerConnectionExceptionManager Class for converting errors for CCS/HPCServer2008
    %   Class for converting between errors thrown in distcomp.AbstractSchedulerConnection (and subclasses) 
    %   and those errors that ought to appear from distcomp.ccsscheduler.
    
    %  Copyright 2009 The MathWorks, Inc.
    
    %  $Revision: 1.1.6.1 $   $Date: 2009/04/15 22:59:07 $

    properties (Constant)
        % The ErrorID mnemonics that need converting ie. the 
        % distcomp.*ServerConnection.* errors need to be converted to 
        % distcomp.ccsscheduler.* errors
        InvalidJobDescriptionFileErrorID = 'InvalidJobDescriptionFile';
        UnableToContactServiceErrorID = 'UnableToContactService';
        InvalidJobTemplateErrorID = 'InvalidJobTemplate';
        FailedToCreateJobFromXMLErrorID = 'FailedToCreateJobFromXML';
        FailedToUseJobTemplateErrorID = 'FailedToUseJobTemplate';
        InvalidNumberOfWorkersErrorID = 'InvalidNumberOfWorkers';
        
        InvalidClusterSizeErrorID = 'InvalidClusterSize';
        
        % NB the error thrown in distcomp.AbstractMicrosoftSchedulerConnection 
        % set.MaximumNumberOfWorkersPerJob function must use this
        % InvalidNumberOfWorkersPhrase in the error message
        InvalidNumberOfWorkersPhrase = 'maximum number of workers per job';
        InvalidClusterSizePhrase = 'cluster size';
    end

    properties (Constant, GetAccess = private)
        % function handles to convert error messages
        ReturnEqualFunctionHandle = @(x) x;
        ReplaceClusterSizeStringFunctionHandle = @(x) strrep(x, ...
            distcomp.MicrosoftSchedulerConnectionExceptionManager.InvalidNumberOfWorkersPhrase, ...
            distcomp.MicrosoftSchedulerConnectionExceptionManager.InvalidClusterSizePhrase);
    end
    
    properties (Constant, GetAccess = private)
        % The error IDs for the distcomp package and ccsscheduler class
        DistcompPackageErrorPrefix = 'distcomp';
        CCSSchedulerErrorPrefix = 'ccsscheduler'
        
        % Error Conversion map - maps the AbstractMicrosoftServerConnection error ID mnemonic to the equivalent
        % ccsscheduler mnemonic and the function handle to use to convert the AbstractMicrosoftServerConnection
        % error message to the ccsscheduler one.
        % {original error ID, new error ID, function handle for converting orig error message to new error message}
        %
        % Most errors just need the errorID to be distcomp.ccsscheduler.* rather than distcomp.*SchedulerConnection.*.
        % The exception to this rule is the InvalidNumberOfWorkersError where the InvalidNumberOfWorkersPhrase
        % needs to be replaced with InvalidClusterSizePhrase and the error ID mnemonic also needs to be replaced.
        ErrorConversionMap = {
            distcomp.MicrosoftSchedulerConnectionExceptionManager.InvalidJobDescriptionFileErrorID, ...
            distcomp.MicrosoftSchedulerConnectionExceptionManager.InvalidJobDescriptionFileErrorID, ...
            distcomp.MicrosoftSchedulerConnectionExceptionManager.ReturnEqualFunctionHandle; ...
            
            distcomp.MicrosoftSchedulerConnectionExceptionManager.UnableToContactServiceErrorID, ...
            distcomp.MicrosoftSchedulerConnectionExceptionManager.UnableToContactServiceErrorID, ...
            distcomp.MicrosoftSchedulerConnectionExceptionManager.ReturnEqualFunctionHandle; ...
            
            distcomp.MicrosoftSchedulerConnectionExceptionManager.InvalidJobTemplateErrorID, ...
            distcomp.MicrosoftSchedulerConnectionExceptionManager.InvalidJobTemplateErrorID, ...
            distcomp.MicrosoftSchedulerConnectionExceptionManager.ReturnEqualFunctionHandle; ...
            
            distcomp.MicrosoftSchedulerConnectionExceptionManager.FailedToCreateJobFromXMLErrorID, ...
            distcomp.MicrosoftSchedulerConnectionExceptionManager.FailedToCreateJobFromXMLErrorID, ...
            distcomp.MicrosoftSchedulerConnectionExceptionManager.ReturnEqualFunctionHandle; ...
            
            distcomp.MicrosoftSchedulerConnectionExceptionManager.FailedToUseJobTemplateErrorID, ...
            distcomp.MicrosoftSchedulerConnectionExceptionManager.FailedToUseJobTemplateErrorID, ...
            distcomp.MicrosoftSchedulerConnectionExceptionManager.ReturnEqualFunctionHandle; ...
            
            distcomp.MicrosoftSchedulerConnectionExceptionManager.InvalidNumberOfWorkersErrorID, ...
            distcomp.MicrosoftSchedulerConnectionExceptionManager.InvalidClusterSizeErrorID, ...
            distcomp.MicrosoftSchedulerConnectionExceptionManager.ReplaceClusterSizeStringFunctionHandle;
        };
    end
    
    methods (Static)
        %---------------------------------------------------------------
        % convertToCCSSchedulerError
        %---------------------------------------------------------------
        % Returns the equivalent distcomp.ccsscheduler MException based on the original
        % distcomp.AbstractMicrosoftSchedulerConnection error.  If the origianal error 
        % requires no changes, the original error is returned.
        function ccsschedulerError = convertToCCSSchedulerError(originalError)
            try 
                % First we get the last part of the error ID
                [~, errorIDMnemonic] = distcomp.MicrosoftSchedulerConnectionExceptionManager.getErrorIDParts(...
                    originalError.identifier);
                % Work out the new short error ID and error message
                [newErrorIDMnemonic, newErrorMessage] = ...
                    distcomp.MicrosoftSchedulerConnectionExceptionManager.getEquivalentErrorIDAndMessage(...
                    errorIDMnemonic, originalError.message);
                % And build up the final error ID with the correct class name
                newErrorID = sprintf('%s:%s:%s', ...
                    distcomp.MicrosoftSchedulerConnectionExceptionManager.DistcompPackageErrorPrefix, ...
                    distcomp.MicrosoftSchedulerConnectionExceptionManager.CCSSchedulerErrorPrefix, newErrorIDMnemonic);
                
                % return the new error message
                ccsschedulerError = MException(newErrorID, '%s', newErrorMessage);
                ccsschedulerError = ccsschedulerError.addCause(originalError);
            catch err %#ok<NASGU>
                % If any error occurred, then the new ccsschedulerError = originalError
                ccsschedulerError = originalError;
            end
        end
    end
    
    methods (Static, Access = private)
        %---------------------------------------------------------------
        % getErrorIDParts
        %---------------------------------------------------------------
        % Strips the error ID down into its constituent parts and verifies that the
        % error actually originated from the distcomp package
        function [class, errorIDMnemonic] = getErrorIDParts(originalErrorID)
            errorParts = strread(originalErrorID, '%s', 'delimiter', ':');
            
            if length(errorParts) ~= 3
                error('distcomp:MicrosoftSchedulerConnectionExceptionManager:UnexpectedErrorID', ...
                    'Failed to parse error ID. Expected 3 error parts, Found %d', length(errorParts));
            end
            
            if ~strcmp(errorParts{1}, distcomp.MicrosoftSchedulerConnectionExceptionManager.DistcompPackageErrorPrefix)
                error('distcomp:MicrosoftSchedulerConnectionExceptionManager:UnexpectedErrorID', ...
                    'Error did not originate from the distcomp package');
            end
            
            class = errorParts{2};
            errorIDMnemonic = errorParts{3};
        end
        
        %---------------------------------------------------------------
        % getEquivalentErrorIDAndMessage
        %---------------------------------------------------------------
        % Retrieves the new short error ID and the new error message from the map.
        function [newErrorIDMnemonic, newErrorMessage] = getEquivalentErrorIDAndMessage(originalErrorIDMnemonic, originalErrorMessage)
            index = strcmp(distcomp.MicrosoftSchedulerConnectionExceptionManager.ErrorConversionMap(:,1), ...
                originalErrorIDMnemonic);
            if ~any(index)
                error('distcomp:MicrosoftSchedulerConnectionExceptionManager:UnexpectedErrorID', ...
                    'Failed to find error ID in error conversion map');
            end
            newErrorIDMnemonic = distcomp.MicrosoftSchedulerConnectionExceptionManager.ErrorConversionMap{index, 2};
            newErrorMessageFunctionHandle = distcomp.MicrosoftSchedulerConnectionExceptionManager.ErrorConversionMap{index, 3};
            
            newErrorMessage = newErrorMessageFunctionHandle(originalErrorMessage);
        end
    end
end