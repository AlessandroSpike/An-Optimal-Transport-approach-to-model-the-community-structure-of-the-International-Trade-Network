function [T,a,b,Err,disto] = Sinkhorn_OT(C,epsilon,p,q, tol,niter)
%% gibbs kernel
K = exp(-C/epsilon);
K(K<1e-200)=1e-200; % Safe
q(q==0)=1e-200; % Safe
p(p==0)=1e-200; % Safe
a = ones(size(p));

%% Main
for i=1:niter
    b = q ./ (K'*a);
    if nargout>3 || tol>0
        Err(1,1) = norm(a.*(K*b)-p, 1);
    end
    a = p ./ (K*b);
    if nargout>3 || tol>0
        Err(1,2) = norm(b.*(K'*a)-q, 1);
    end
    if min(Err(1,:))<tol
        break;
    end
end
T = diag(a)*K*diag(b);
disto = sum(sum(C.*T));
end