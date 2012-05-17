function mupadDemo
%mupadDemo MuPAD demo notebooks
%   mupadDemo provides a menu to access MuPAD demo notebooks along
%   with a short description of each demo.
%
%   The demos are divided into four categories: Basic Algebra, Calculus,
%   Abstract Algebra and Number Theory.
%   
%   The Basic Algebra demos are Matrix Algebra and Polynomial Algebra. 
%
%   The Calculus demos are Multivariable Differentiation, Multivariable
%   Integration and Stokes' Theorem. 
%
%   The Abstract Algebra demos are Field Extensions, Finite (non-Abelian)
%   Groups, Linear Ordinary Differential Operators, and the Quaternions.
%
%   The Number Theory demos are Integer Modulus Rings and Squares Modulo N.
%
%   See also: mupad

%   Copyright 2008-2010 The MathWorks, Inc.

    c = allchild(0);
    H = findall(c,'flat','Tag','mupadDemo');
    if ~isempty(H)
        warning('symbolic:mupadDemo:Started','Another mupadDemo is running.  Only 1 mupadDemo can be open at a time.');
        figure(H);
        return
    end
    figp = figure('Units','pixels','Position',[0 0 600 320],...
                  'Menu','none', 'Tag','mupadDemo',...
                  'HandleVisibility','callback','IntegerHandle','off',...
                  'Color',get(0,'DefaultUIControlBackgroundColor'), ...
                  'NumberTitle','off','Visible','off','Resize','off',...
                  'DefaultUIControlUnit','normalized',...
                  'Name','MuPAD Demo Notebooks','NumberTitle','off');

    root = fileparts(mfilename('fullpath')); % directory containing this file
    root = fullfile(root,'notebooks');
    
    % Control panel
    movegui(figp,'center');
    ax = axes('Position',[0.02 0.92 0.025 0.05],'Parent',figp);
    mup=imread(fullfile(root,'demoicon.png'));
    image(mup,'parent',ax);
    axis(ax,'off');
    uicontrol('Style','text','String','Select a demo:',...
              'Position',[0.05  0.93 0.27 0.04],...
              'Parent',figp,...
              'HorizontalAlignment','left');
    
    contents = {'Algebra',...
                '      Matrix Algebra',...
                '      Polynomial Algebra', ...
                'Calculus',...
                '      Multivariate Differentiation',...
                '      Multivariate Integration',...
                '      Stokes'' Theorem', ...
                'Abstract Algebra',...
                '      Field Extensions',...
                '      Finite Groups',...
                '      Linear Ordinary Differential Operators',...
                '      Quaternions', ...
                'Number Theory',...
                '      Integer Modulus Rings',...
                '      Squares Modulo N'};

    callbacks = {@noNotebook, ...   Algebra
                 @algebraNotebook,@polyNotebook,...
                 @noNotebook,...    Calculus
                 @diffNotebook, @intNotebook, @stokesNotebook, ...
                 @noNotebook,...    Abstract Algebra
                 @fieldNotebook, @groupNotebook, @ODENotebook, @quaternionNotebook,...
                 @noNotebook,...    Number Theory
                 @modNotebook, @squareNotebook};

    listbox = uicontrol('Style', 'listbox','Max',2,'Min',0, ...
                 'String',contents,...
                 'Value',[], 'Tag', 'ListBox', ...
                 'Position',[0.02 0.18 0.47 0.72], ...
                 'Parent',figp,...
                 'CallBack', @clickCallback,...
                 'BackgroundColor',[1 1 1]);
    Upa = uipanel('Position', [0.51 0.18 0.47 0.72],...
                  'Parent',figp,...
                  'BackgroundColor',[1 1 1]);
    preview = axes('Position',[0.18 0.61 0.64 0.37],'Parent',Upa);
    axis(preview,'off');
    desc = uicontrol(Upa, 'Style','text','String','  ',...
                     'Position',[0.01 0.32 0.99 0.28],...
                     'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
    feat = uicontrol(Upa, 'Style','text','String','   ',...
                     'Position',[0.01 0.01 0.70 0.32],...
                     'HorizontalAlign','left','BackgroundColor',[1 1 1]);
    openButton = uicontrol('Position',[0.15 0.03 0.2 0.10],...
                           'Parent',figp,...
                           'String','Start Demo', ...
                           'CallBack',@openCallback,'Enable','off',...
                           'Tag','OpenButton');
    uicontrol('Position',[1-0.18 .03 0.14 0.10],'String','Close', ...
              'Parent',figp,...
              'CallBack',@closeCallback);
    set(figp,'Visible','on')

    function clickCallback(src,ev) %#ok
        Value = get(listbox,'Value');
        if isscalar(Value)
            callback = callbacks{Value};
            [desc_str, feat_str, file, png] = callback();
        else
            [desc_str, feat_str, file, png] = multiClick;
        end
        setappdata(figp,'FileName',file);
        if isempty(file)
            state = 'off';
        else
            state = 'on';
        end
        set(openButton,'enable',state);
        set(desc,'string',desc_str);
        set(feat,'string',feat_str);
        if isempty(png)
            cla(preview);
        else
            mup=imread(fullfile(root,png));
            image(mup,'parent',preview);
            axis(preview,'equal')
        end
        axis(preview,'off');
    end

    function openCallback(src,ev) %#ok
        Pathname = getappdata(figp,'FileName');
        mupad(fullfile(root,Pathname));
    end

    function closeCallback(src,ev) %#ok
        close(figp);
    end

    function [desc_str, feat_str, file, png] = multiClick
        desc_str = 'Please choose one demo at a time.';
        feat_str = '';
        file = '';
        png = '';
    end

    function [desc_str, feat_str, file, png] = noNotebook
        desc_str = '';
        feat_str = '';
        file = '';
        png = '';
    end

    function [desc_str, feat_str, file, png] = algebraNotebook
        file = 'Matrix_Algebra.mn';
        desc_str = 'Matrices in terms of their algebraic structure, including a variety of normal forms and polynomials.';
        feat_str = sprintf('Features\n   Domains\n   Function Library');
        png = 'matprev.png';
    end
    
    function [desc_str, feat_str, file, png] = polyNotebook
        file = 'Polynomial_Algebra.mn';
        desc_str = 'Single-variable polynomials as functions and as algebraic objects over multiple coefficient rings.';
        feat_str = sprintf(['Features\n   Domains\n   Function Library\n' ...
                            '   Function Plotting']);
        png = 'polprev.png';
    end

    function [desc_str, feat_str, file, png] = diffNotebook
        file = 'Multivariate_Differentiation.mn';
        desc_str = 'Derivatives of multivariable functions, vector-valued functions, and solutions of vector fields. Briefly discusses Clairaut''s Theorem.';
        feat_str = sprintf('Features\n   Symbolic Differentiation\n   3D Function Plotting');
        png = 'difprev.png';
    end

    function [desc_str, feat_str, file, png] = intNotebook
        file = 'Multivariate_Integration.mn';
        desc_str = 'Integration of multivariable functions and the change of variables formula for multiple integrals.';
        feat_str = sprintf('Features\n   Symbolic Integration\n   3D Function Plotting');
        png = 'intprev.png';
    end

    function [desc_str, feat_str, file, png] = stokesNotebook
        file = 'Stokes_Theorem.mn';
        desc_str = 'Stokes'' Theorem for multivariate integration, a generalization of the fundamental theorem of calculus to multiple dimensions.';
        feat_str = sprintf('Features\n   Symbolic Integration\n   3D Function Plotting');
        png = 'stokeprev.png';
    end

    function [desc_str, feat_str, file, png] = fieldNotebook
        file = 'Field_Extensions.mn';
        desc_str = 'Elementary extensions over several types of fields. Focuses on polynomial representations of field elements and structures.';
        feat_str = sprintf('Features\n   Domains');
        png = 'fieldprev.png';
    end

    function [desc_str, feat_str, file, png] = groupNotebook
        file = 'Finite_Groups.mn';
        desc_str = 'Simple finite non-Abelian groups, specifically the symmetric and dihedral groups. Also looks at Cayley''s Embedding Theorem.';
        feat_str = sprintf('Features\n   Domains\n   2D Graphics\n   Animation');
        png = 'grouprev.png';
    end

    function [desc_str, feat_str, file, png] = ODENotebook
        file = 'Linear_Ordinary_Differential_Operators.mn';
        desc_str = 'Linear differential operators of one variable as algebraic objects and as operators on functions. Includes a discussion of the Shift Theorem.';
        feat_str = sprintf('Features\n   Domains\n   Symbolic Differentiation');
        png = 'lodprev.png';
    end

    function [desc_str, feat_str, file, png] = quaternionNotebook
        file = 'Quaternions.mn';
        desc_str = 'Quaternions as a generalization of the complex numbers. Focuses on a geometric description of the quaternion structure.';
        feat_str = sprintf(['Features\n   Domains\n   3D Graphics\n' ...
                            '   Animation\n   Programming Language']);
        png = 'quatprev.png';
    end

    function [desc_str, feat_str, file, png] = modNotebook
        file = 'Integer_Modulus_Rings.mn';
        desc_str = 'Elementary modular arithmetic and algebra. Focuses on units, unit groups, and powers of unit elements.';
        feat_str = sprintf('Features\n   Domains\n   Function Library');
        png = 'intmprev.png';
    end

    function [desc_str, feat_str, file, png] = squareNotebook
        file = 'Squares_Modulo_N.mn';
        desc_str = 'The set of perfect squares modulo various integers and the structure created by the moduli. Discusses quadratic reciprocity.';
        feat_str = sprintf('Features\n   Domains\n   Function Library');
        png = 'squaprev.png';
    end
end
