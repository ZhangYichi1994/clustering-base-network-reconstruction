function [z, history] = basis_pursuit_box(A, b, rho, alpha)
% basis_pursuit_box  Solve basis pursuit via ADMM
%
% [x, history] = basis_pursuit_box(A, b, rho, alpha)
% 
% Solves the following problem via ADMM:
% 
%   minimize     ||x||_1
%   subject to   Ax = b
%				 x belong to [0,1]
%
% The solution is returned in the vector x.
%
% history is a structure that contains the objective value, the primal and 
% dual residual norms, and the tolerances for the primal and dual residual 
% norms at each iteration.
% 
% rho is the augmented Lagrangian parameter. 
%
% alpha is the over-relaxation parameter (typical values for alpha are 
% between 1.0 and 1.8).
%
%

t_start = tic;

%% Global constants and defaults

QUIET    = 0;
MAX_ITER = 1000;
ABSTOL   = 1e-12;
RELTOL   = 1e-12;

%% Data preprocessing

[m n] = size(A);

%% ADMM solver

x = zeros(n,1);
z = zeros(n,1);
u = zeros(n,1);
z1 = zeros(n,1);
u1 = zeros(n,1);

if ~QUIET
    fprintf('%3s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n', 'iter', ...
      'r norm', 'eps pri', 's norm', 'eps dual', 'r1 norm', 'eps pri1', 's1 norm', 'eps dual1','objective');
end

% precompute static variables for x-update (projection on to Ax=b)
AAt = A*A';
[size_m,siz_n] = size(AAt);
if(rank(AAt)<size_m)
    AAt_1 = pinv(AAt);
else
    AAt_1 = inv(AAt);
end
% P = eye(n) - A' * (AAt \ A);
P = eye(n) - A' * (AAt_1 * A);
q = A' * (AAt_1 * b);
% q = A' * (AAt \ b);

for k = 1:MAX_ITER
    % x-update
%     x = P*(z - u) + q;
    x = P*( 0.5*(z-u) + 0.5*(z1-u1) ) + q;

    % z-update with relaxation
    zold = z;
    x_hat = alpha*x + (1 - alpha)*zold;
    z = shrinkage(x_hat + u, 1/rho);
    
    % z1-update with proximal algrithm
    zold1 = z1;
    z1 = box0_1(x_hat+u1);

    u = u + (x_hat - z);
    u1= u1 + (x_hat - z1);

    % diagnostics, reporting, termination checks
    history.objval(k)  = objective(A, b, x);

    history.r_norm(k)  = norm(x - z);
    history.s_norm(k)  = norm(-rho*(z - zold));
    history.r1_norm(k) = norm(x - z1);
    history.s1_norm(k) = norm(-rho*(z1 - zold1));
    
    history.eps_pri(k) = sqrt(n)*ABSTOL + RELTOL*max(norm(x), norm(-z));
    history.eps_dual(k)= sqrt(n)*ABSTOL + RELTOL*norm(rho*u);
    history.eps_pri1(k)= sqrt(n)*ABSTOL + RELTOL*max(norm(x), norm(-z1));
    history.eps_dual1(k)=sqrt(n)*ABSTOL + RELTOL*norm(rho*u1);

    if ~QUIET
        fprintf('%3d\t%10.5f\t%10.5f\t%10.5f\t%10.5f\t%10.5f\t%10.5f\t%10.5f\t%10.5f\t%10.2f\n', k, ...
            history.r_norm(k), history.eps_pri(k), ...
            history.s_norm(k), history.eps_dual(k), ...
            history.r1_norm(k),history.eps_pri1(k), ...
            history.s1_norm(k),history.eps_dual1(k), ...
            history.objval(k));
    end

    if (history.r_norm(k) < history.eps_pri(k) && ...
       history.s_norm(k) < history.eps_dual(k) && ...
       history.r1_norm(k) < history.eps_pri1(k)&& ...
       history.s1_norm(k) < history.eps_dual1(k)   )
         break;
    end
end

if ~QUIET
    toc(t_start);
end

end

function obj = objective(A, b, x)
    obj = norm(x,1);
end

function y = shrinkage(a, kappa)
    y = max(0, a-kappa) - max(0, -a-kappa);
end

function z_hat = box0_1(v)
    z_hat = max(0,v);
    z_hat = min(z_hat,1);
end
