function match_type = comparevars(x1,x2)
% Compares two variables and returns a string indicating whether they are equal
%
% match_type = comparevars(x1,x2)
%
% match_type can be 'yes','no' or 'classesdiffer'.  The last of these
% indicates that the numerical values of the variables are equal but the
% data types are different.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

    match_type = 'no';
    try
        if strcmp(class(x1),class(x2))
            if ismethod(x1,'isContentEqual')
                % Several MathWorks object types have a method
                % called isContentEqual.  Use this (because for reference types
                % isequal will tell us only whether these are the same object,
                % rather than whether they have the same content.
                if isContentEqual(x1,x2)
                    match_type = 'yes';
                end
            elseif isequalwithequalnans(x1,x2)
                % For these purposes we treat NaN values as being equal to
                % each other.
                match_type = 'yes';
            elseif iscell(x1)
                % isequal would work on cell arrays as long as the cells
                % don't contain UDD objects or function handles etc.
                match_type = i_compare_cell(x1,x2);
            elseif isstruct(x1)
                % isequal would work on structs as long as the fields
                % don't contain UDD objects or function handles etc.  Once
                % we've checked that the fields are the same, we can
                % handle these in exactly the same way as we handle UDD objects.
                if isequal(fieldnames(x1),fieldnames(x2))
                    match_type = i_compare_udd(x1,x2);
                end
            elseif isa(x1,'handle.handle')
                % UDD objects without an isContentEqual method are more difficult,
                % because "isequal" tells us only whether these are the same object,
                % and not whether these are different-but-identical objects.
                match_type = i_compare_udd(x1,x2);
            elseif strcmp(class(x1),'function_handle')
                % Two identical function handles will be reported as different
                % unless they are copies of the same variable.  Better,
                % though still not perfect, to compare the strings.
                if strcmp(func2str(x1),func2str(x2))
                    match_type = 'yes';
                end
            end
        else
            % Different classes.  For numeric types, we can still
            % check whether the values are the same.
            if isnumeric(x1)
                if isequalwithequalnans(x1,x2)
                    match_type = 'classesdiffer';
                end
            end
        end
    catch E %#ok<NASGU>
        % We'll return "no".  Which in this case actually means
        % "we can't tell".
        return;
    end
end


%------------------------------------------------------------
function match_type = i_compare_udd(x1,x2)
    match_type = 'no';
    if isequal(size(x1),size(x2))
        if numel(x1)==1
            % Avoid invoking a "subsref" operation if we're dealing with
            % scalars.  Some classes (e.g. Simulink.TsArray) don't handle
            % subsref very well.
            match_type = i_compare_udd_scalar(x1,x2);
        else
            for i=1:numel(x1)
                if ~strcmp(i_compare_udd_scalar(x1(i),x2(i)),'yes')
                    % Field values differ.  Return "no".
                    return;
                end
            end
            match_type = 'yes';
        end
    end
end

%------------------------------------------------------------
function match_type = i_compare_cell(x1,x2)
    match_type = 'no';
    if isequal(size(x1),size(x2))
        for i=1:numel(x1)
            if ~strcmp(comparevars(x1{i},x2{i}),'yes');
                % Cell values differ.  Return "no".
                return;
            end
        end
        match_type = 'yes';
    end
end

%------------------------------------------------------------
function match_type = i_compare_udd_scalar(x1,x2)
    match_type = 'no';
    s1 = struct(x1);
    s2 = struct(x2);
    f = fieldnames(s1);
    % These objects are of the same class, so it's safe to assume
    % that they have the same fields.  The only real danger here
    % is a recursionLimit error due to a reference loop.  MATLAB handles
    % that reasonably tidily, we don't need special handling here.
    for k=1:numel(f)
        if ~strcmp(comparevars(s1.(f{k}),s2.(f{k})),'yes')
            % Field values differ.  Return "no".
            return;
        end
    end
    match_type = 'yes';
end

