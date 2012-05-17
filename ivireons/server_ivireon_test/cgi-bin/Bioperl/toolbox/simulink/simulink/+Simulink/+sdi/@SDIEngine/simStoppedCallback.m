function simStoppedCallback(this, s ,e)
    
    % Copyright 2009-2010 The MathWorks, Inc.
    if (this.simStatus)
        try
            % Get target type for model reference - valid even for single models
            ModelReferenceTargetType = get(e.Source, 'ModelReferenceTargetType');

            % Only process top models
            if strcmpi(ModelReferenceTargetType, 'none')
                % Cache model name
                ModelName = get(e.Source, 'Name');
                % Create run
                [~, ~] = this.createRunFromModel(ModelName);                
            end % if
        catch ME %#ok

        end        
    else
        this.simStatus = true;
    end
end