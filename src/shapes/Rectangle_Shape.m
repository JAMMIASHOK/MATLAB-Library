classdef Rectangle_Shape < geometric_shape
        
    properties
        H
        B
        r = 0;
        
        plot_fill_color = [0.90 0.90 0.90];
    end
    
    methods
        function obj = Rectangle_Shape(H,B,r)
            obj.H = H;
            obj.B = B;
            if nargin > 2
                obj.r = r;
            end
        end 
        function tf = is_section_valid(obj)
            tf1 = obj.B > 0;    % B should be positive
            tf2 = obj.H > 0;    % H should be positive
            tf3 = obj.r >= 0;   % r should be positive or zero
            tf4 = obj.r < min([obj.B obj.H])/2;
            tf = all([tf1 tf2 tf3 tf4]);
        end
        function d = depth(obj,axis)
            switch lower(axis)
                case {'x','z'}
                    d = obj.H;
                case 'y'
                    d = obj.B;
                otherwise
                    error('Unknown axis: %s',axis);
            end            
        end
        function a = A(obj)
            a = obj.H*obj.B - (4-pi)*obj.r^2;
        end
        function j = J(obj)
            assert(obj.r==0,'Not yet implemented for rounded rectangles');
            % Equation for J from Theory of Elasticity by Timoshenko and Goodier 
            % (first two terms of the infinite series).
            % See also: Plaut, R. H., and Eatherton, M. R. (2017). 
            % "Lateral-torsional buckling of butterfly-shaped beams with 
            % rectangular cross section.� Engineering Structures, 136, 210�218.
            if obj.H >= obj.B 
                ar = obj.H/obj.B;
                beta = 1.0/3.0*(1-192.0/pi^5*1/ar*(tanh(pi*ar/(2.0))+tanh(3*pi*ar/2)/243));     
                j = beta*obj.H*obj.B^3;               
            else
               ar = obj.B/obj.H;
                beta = 1.0/3.0*(1-192.0/pi^5*1/ar*(tanh(pi*ar/(2.0))+tanh(3*pi*ar/2)/243));     
                j = beta*obj.B*obj.H^3;                
            end            
        end
        function i = I(obj,axis)
            switch lower(axis)
                case {'x','z','major','strong'}
                    if obj.r == 0
                        i = (1/12)*obj.B*obj.H^3;
                    else
                        i = (1/12)*obj.B*obj.H^3 ...
                            - 4 * ((1/12)*obj.r^4 + obj.r^2*(obj.H/2-obj.r/2)^2) ...
                            + 4 * ((pi/16-4/(9*pi))*obj.r^4 ...
                            + (pi/4)*obj.r^2*(obj.H/2-(obj.r-(4*obj.r)/(3*pi)))^2);
                    end
                case {'y','minor','weak'}
                    if obj.r == 0
                        i = (1/12)*obj.H*obj.B^3;
                    else
                        i = (1/12)*obj.H*obj.B^3 ...
                            - 4 * ((1/12)*obj.r^4 + obj.r^2*(obj.B/2-obj.r/2)^2) ...
                            + 4 * ((pi/16-4/(9*pi))*obj.r^4 ...
                            + (pi/4)*obj.r^2*(obj.B/2-(obj.r-(4*obj.r)/(3*pi)))^2);
                    end
                otherwise
                    error('Unknown axis: %s',axis);
            end
        end
        function s = S(obj,axis)
            I = obj.I(axis);
            switch lower(axis)
                case {'x','z','major','strong'}
                    s = I/(obj.H/2);
                case {'y','minor','weak'}
                    s = I/(obj.B/2);
                otherwise
                    error('Unknown axis: %s',axis);
            end 
        end
        function z = Z(obj,axis)
            switch lower(axis)
                case {'x','z','major','strong'}
                    if obj.r == 0
                        z = obj.B*obj.H^2/4;
                    else
                        z = obj.B*obj.H^2/4 ...
                            - 4*((1-pi/4)*obj.r^2)*(obj.H/2-((10-3*pi)/(12-3*pi))*obj.r);
                    end
                case {'y','minor','weak'}
                    if obj.r == 0
                        z = obj.H*obj.B^2/4;
                    else
                        z = obj.H*obj.B^2/4 ...
                            - 4*((1-pi/4)*obj.r^2)*(obj.B/2-((10-3*pi)/(12-3*pi))*obj.r);
                    end
                otherwise
                    error('Unknown axis: %s',axis);
            end
        end
        function [x,y,r] = boundary_points(obj)
            if obj.r == 0
                x = [ obj.B/2 -obj.B/2 -obj.B/2  obj.B/2 ];
                y = [ obj.H/2  obj.H/2 -obj.H/2 -obj.H/2 ];
                r = [0 0 0 0];
            else            
                error('Not yet impletmented')
            end
        end
        function plotSection(obj,lineWidth)
            if nargin < 2
                lineWidth = 2;
            end
            hold all
            if obj.r == 0
                x = [ obj.B/2 -obj.B/2 -obj.B/2  obj.B/2 obj.B/2 ];
                y = [ obj.H/2  obj.H/2 -obj.H/2 -obj.H/2 obj.H/2 ];
            else
                angles = linspace(0,pi/2,25);
                x = [ ( obj.B/2+obj.r*cos(angles)) ...
                      (-obj.B/2+obj.r*cos(angles+pi/2)) ...
                      (-obj.B/2+obj.r*cos(angles+pi)) ...
                      ( obj.B/2+obj.r*cos(angles+1.5*pi)) obj.B/2+obj.r ];
                y = [ ( obj.H/2+obj.r*sin(angles)) ...
                      ( obj.H/2+obj.r*sin(angles+pi/2)) ...
                      (-obj.H/2+obj.r*sin(angles+pi)) ...
                      (-obj.H/2+obj.r*sin(angles+1.5*pi)) obj.H/2 ]; 
                 
            end
            fill(x,y,obj.plot_fill_color,'LineStyle','none')
            plot(x,y,'k-','LineWidth',lineWidth);
            axis equal
        end
        function add_to_fiber_section(obj,fiber_section,matID)
            if obj.r == 0
                fiber_section.addPatch('quad',matID,...
                    -obj.B/2,-obj.H/2,...
                    -obj.B/2, obj.H/2,...
                     obj.B/2, obj.H/2,...
                     obj.B/2,-obj.H/2);
            else
                error('Not yet implemented');
            end
        end
    end
    
end

