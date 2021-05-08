function [pfinal,efinal] = apso(pn,herrfunc,varargin)

%
% Internal function based on 
% Yang XS
% Nature-Inspired Optimization Algorithms, Elsevier Insights, 2014

% Source Code for APSO obtained from
% https://www.mathworks.com/matlabcentral/fileexchange/74766-accelerated-particle-swarm-optimization-apso?s_tid=srchtitle

%switch length(varargin) %%set parameter
dim = size(pn,1);
N = size(pn,2);
Max_iter = 100;
ub = 10;
lb = -10;

% initiate parameters
beta=0.5;  alpha=1;
gamma=(10^(-20)/alpha)^(1/Max_iter);

% rand('twister',sum(pn(1)*clock))
% randn('state',sum(pn(2)*clock))

% initiate position
xn=rand(dim,N).*(ub-lb)+lb;
best=zeros(N+1,dim);   % location on best params + it's value

% Start iterations
for i=1:Max_iter,
    % Find the current best location (xo)
%     [fmin,xo]=findbest(xn);
    fmin=10^10;
    for j=1:size(xn,2),
       fnew=feval(herrfunc,xn(:,j),varargin{:});
       if fnew<fmin,
           fmin=fnew;
           xo=xn(:,j);
       end
    end
    % The accelerated PSO with alpha=alpha_0 gamma^t
    % or alpha = alpha *gamma
    alpha=alpha*gamma;
    % Move all the particles to new locations
%     [xn]=pso_move(xn,xo,alpha,beta,Lb,Ub);
    for j=1:size(xn,2),
        xn(:,j)=xn(:,j).*(1-beta)+xo.*beta+alpha.*randn(dim,1);
        % Check if the new solution is within simple limits
%         xn(j,:)=simplebounds(xn(j,:),Lb,Ub);
        ns_tmp=xn(:,j);
        % Apply the lower bound
        for k=1:dim
        if ns_tmp(k,1)<lb
            ns_tmp(k,1)=lb;
        end
        % Apply the upper bounds
        if ns_tmp(k,1)>ub
            ns_tmp(k,1)=ub;
        end
        end
        % Update this new move 
        xn(:,j)=ns_tmp;
    end
    % Record the search history 
    % for each row (1:nd), the best solution is stored, 
    % whereas the last value is the best fmin
    best(i,1:dim)=xo;  best(i,end)=fmin;
end   %%%%% end of iterations
pfinal = xo;
efinal = fmin;