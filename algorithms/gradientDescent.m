% -------------------------------------------------------------------
% METODO: gradient-based nonlinear optimization
% Newton, Quasi-Newton, Steepest Descent
% Author: Thiago Lima Silva (thiagolims@gmail.com)
% -------------------------------------------------------------------
function [ xs, fs, gs] = gradientDescent(f, g, h, x0, optType, lsType, varargin)
%gradientDescent steepest gradient descent algorithm
% input:
%   - f: pointer to the function to be minimized
%   - g: pointer to the function gradient
%   - h: point to the function hessian
%   - x0: initial point
%   - ls: line search type (1 - Armijo, 2 - Polynomial)
% output:
%   - xs: local optimal solution
%   - fs: optimal function value f(xs)
%   - gs: gradient of fs at the optimal value df(xs)/dx

%% Initialization
xs = x0;
dim = size(xs,1);
H = eye(dim,dim);
f0 = f(x0);
g0 = g(x0);
h0 = h(x0);

fs = f(xs);
gs = g(xs)';
hs = h(xs);

% Parameter for Marquardt's Modification to the Newton Method
lambda = 1000;

%% convergence parameters
eps = 1.e-4; 
tol = 1.e-6;
maxIter = 500;

if (norm(g0) < eps) return; end

for i=1:maxIter
    switch(optType)
        case 1, % Newton
            % Parameters for Marquardt's Modification to the Newton Method
            beta = 5.0e-1*norm(hs)^-1;
            teta = 1e-6;
            
            if rcond(H)
                d = -(hs\gs);  % Newton's method direction
            else
                d = -(hs + lambda.*eye(dim,dim))\gs;   % Marquardt Modification to Newton's Method
            end
            
            while (gs'*d >= 0) ||  (gs'*d > -teta*norm(gs)*norm(d)) || (norm(d) < beta*norm(gs))
                lambda = 2*lambda;
                if rcond(hs + lambda.*eye(dim,dim)) > 1.0e-6
                    d = -(hs + lambda.*eye(dim,dim))\gs;
                else
                    d = -gs;
                end
            end
            
            lambda = 0.5*lambda;
            
        case 2, % Steepest Descent
            d = -gs;
    end

    switch(lsType)
        case 1,
            [s, x1, f1] = lsArmijo(f, double(xs), double(d), double(gs));            
            g1 = g(x1)';
            h1 = h(x1);
            %%TODO: compute gradient with ADI
         
        case 2,
            s = 1; %% full step  %%TODO: implement polynomial
            x1 = xs + s*d;
            f1 = f(x1);
            g1 = g(x1);
           
    end
    
    
     % Convergence test
     gradientNorm = (norm(double(g1))/norm(double(g0)));
     
     if (gradientNorm < eps)
         disp(sprintf('\n Iteration number %d', i));
         disp(sprintf('  f = %g  Step = %d', fs, s));
         disp(sprintf('  X = ')); disp(sprintf(' %d ',xs));
         disp(sprintf('  g/g0 = ')); disp(sprintf(' %d ',gradientNorm));   

     	disp('Convergence OK!');
        return 
     end
     
    % Plotting and printing
    xsD = double(xs);
    x1D = double(x1);
    
    dx = [xsD(1) x1D(1)];
    dy = [xsD(2) x1D(2)];
    plot(dx,dy,'-ro');
    
    disp(sprintf('\n Iteration number %d', i));
 	disp(sprintf('  f = %g  Step = %d', f1, s));
 	disp(sprintf('  X = ')); disp(sprintf(' %d ',x1));
 	disp(sprintf('  g/g0 = ')); disp(sprintf(' %d ',gradientNorm));   
    
    xs = x1;
    gs = g1;
    fs = f1;
    hs = h1;    
    
end

end

