function [value1, value2] = dicomlookup_actions(varargin)
%DICOMLOOKUP_ACTIONS  Call dictionary lookup functions without checking.
%
%   This function requires correct inputs.  Use the public function
%   DICOMLOOKUP for error checking.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:31:50 $

if (nargin == 1)

    % Look up the tag for a given attribute name.
    tag = dicom_tag_lookup(varargin{1});
    
    if (~isempty(tag))
        value1 = tag(1);
        value2 = tag(2);
    else
        value1 = [];
        value2 = [];
    end

else
  
    % Look up the name when given a group and an attribute.
    group   = varargin{1};
    element = varargin{2};
    
    % Look up the attribute.
    attr = dicomlookup_helper(group, element, dicomdict('get_current'));

    if (~isempty(attr))
       
        % The attribute was in the dictionary; use its name.
        name = attr.Name;
        
    else

        % Construct Private names if the group is odd.
        if (rem(group, 2) == 1)
          
            if (element == 0)
                % (gggg,0000) is Private Group Length.
                name = sprintf('Private_%04x_GroupLength', group);
                
            elseif (element < 16)
                % (gggg,0001-000f) are not allowed.
                name = '';
                
            elseif ((element >= 16) && (element <= 255))
                % (gggg,0010-00ff) are Private Creator Data Elements.
                
                % Private attributes are assigned in blocks of 256.  The
                % Private Creator Data Elements (gggg,0010-00ff) reserve a
                % block.  For example, (gggg,0030) reserves elements
                % (gggg,3000-30ff).
                name = sprintf('Private_%04x_%02xxx_Creator', group, element);
        
            else
                % The rest are normal private metadata.
                name = sprintf('Private_%04x_%04x', group, element);
                
            end
            
        else
          
            % The public attribute was not found.
            name = '';
            
        end
    end
    
    % Assign the output.
    value1 = name;
    value2 = [];
    
end
