% Function to set the value of all instances of a variant data class consistently to
% a variant
function rtwdemo_param_variants_set_value(class, variant)
    
    % Loop over all vars
    allVars = evalin('base','whos');
    for i = 1:length(allVars)
        
        % If the variable is of the class of interest ...
        if strcmp(allVars(i).class, class)

            % Copy the specified variant to its Value
            cmd = [allVars(i).name '.Value = ' allVars(i).name '.Variants.' variant ';'];
            evalin('base',cmd);
        end
    end
