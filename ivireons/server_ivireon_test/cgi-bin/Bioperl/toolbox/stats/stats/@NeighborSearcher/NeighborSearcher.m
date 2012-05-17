classdef NeighborSearcher
%NeighborSearcher Neighbor search object.
%   NeighborSearcher is an abstract class used for nearest neighbor search.
%   You cannot create instances of this class directly. You must create
%   an instance of ExhaustiveSearcher or KDTreeSearcher.
%
%   NeighborSearcher properties:
%       X               - Data used to create the object.
%       Distance        - The distance metric.
%       DistParameter   - Additional parameter for the distance metric.
%
%   NeighborSearcher methods:
%       NeighborSearcher/knnsearch       - An abstract method
%
%   See also ExhaustiveSearcher, KDTreeSearcher, CREATENS, KNNSEARCH.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:18:57 $
    
    properties(GetAccess='public', SetAccess='protected') % Public properties
        %X Data used to create the object.
        %  The X property is a matrix used to create the object.
        %
        %  See also NeighborSearcher. 
        X = [];
        
        %Distance The distance metric.
        %   The Distance property is a string specifying the built-in
        %   distance metric that you used (applies for both
        %   ExhaustiveSearcher and KDTreeSearcher), or a function handle
        %   that you provided (applies only for ExhaustiveSearcher) when
        %   you created the object. This property saves the default
        %   distance metric used when you call the KNNSEARCH method to find
        %   nearest neighbors for future query points.
        %
        %   See also NeighborSearcher. 
        Distance =  'euclidean';
        
        %DistParameter Additional parameter for the distance metric.
        %   The DistParameter property specifies the additional parameter
        %   for the chosen distance metric.
        %                                   Value:
        % 
        %   if 'Distance' is 'minkowski'    A positive scalar indicating
        %                                   the exponent of the minkowski     
        %                                   distance. (Applies for both
        %                                   ExhaustiveSearcher and
        %                                   KDTreeSearcher.)
        %   if 'Distance' is 'mahalanobis'  A positive definite matrix        
        %                                   representing the covariance
        %                                   matrix used for computing the
        %                                   mahalanobis distance. (Applies
        %                                   only for ExhaustiveSearcher.)
        %   if 'Distance' is 'seuclidean'   A vector representing the scale
        %                                   value to use in computing the
        %                                   'seuclidean' distance. (Applies
        %                                   only for ExhaustiveSearcher.)
        %   otherwise                       Empty. 
        %
        %  See also NeighborSearcher. 
        DistParameter = [];
    end
   
    methods(Abstract)
         [idx,dist]=knnsearch(obj,y,varargin)
         %KNNSEARCH  A abstract method to find K nearest neighbors. 
       
    end
    
    methods(Hidden, Static)
        function a = empty(varargin)
            error(['stats:' mfilename ':NoEmptyAllowed'], ...
                'Creation of empty %s objects is not allowed.',upper(mfilename));
        end
    end
  
    methods(Hidden)
        function a = cat(varargin),        throwNoCatError(); end
        function a = horzcat(varargin),    throwNoCatError(); end
        function a = vertcat(varargin),    throwNoCatError(); end
        
        function [varargout] = subsasgn(varargin)
            %SUBSASGN Subscripted reference for a NeighborSearcher object.
            %Subscript assignment is not allowed for a NeighborSearcher object         
            error('stats:NeighborSearcher:subsasgn:NotAllowed',...
                ' Subscripted assignments are not allowed.')
        end
        
        
        function [varargout] = subsref(obj,s)
            %SUBSREF Subscripted reference for a NeighborSearcher object.
            %   B = SUBSREF(OBJ,S) is called for the syntax OBJ(S) when OBJ
            %   is a NeighborSearcher object. S is a structure array with
            %   the fields:
            %       type -- string containing '()', '{}', or '.' specifying
            %       the subscript type.
            %       subs -- Cell array or string containing the actual
            %       subscripts.
            
            
            switch s(1).type
                case '()'
                    error('stats:NeighborSearcher:subsref:ArraySubscript', ...
                        'The %s class does not support () indexing.', class(obj));
                case '{}'
                     error('stats:NeighborSearcher:subsref:CellReferenceNotAllowed', ...
                        'Cell contents reference from a non-cell array object.')    
                case '.'
                    methodsProp = [methods(obj);properties(obj)];
                    %The following is to prevent accessing private methods or
                    %properties
                    if ~any(strcmp(s(1).subs, methodsProp))
                        error('stats:NeighborSearcher:subsref:InvalidAccess', ...
                            'No appropriate method or public field %s for class %s.',...
                            s(1).subs, class(obj));
                    end
                    [varargout{1:nargout}] = builtin('subsref',obj,s);
                  
                otherwise
                   [varargout{1:nargout}] = builtin('subsref',obj,s);
                 
            end
        end
    end
end   %classdef
%----------------------------------------------
function throwNoCatError()
error(['stats:' mfilename ':NoCatAllowed'], ...
    'Concatenation of %s objects is not allowed.  Use a cell array to contain multiple objects.',upper(mfilename));
end

