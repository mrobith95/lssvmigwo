function [pfinal,efinal] = igwo(pn,herrfunc,varargin)

%
% Internal function based on 
% Nadimi-Shahraki M H, Taghian S, Mirjalili S
% An Improved Grey Wolf Optimizer for Solving Engineering Problems
% Expert System and Applications; 2021; Vol. 166; Article 113917
% 
% Source Code for GWO obtained from
% https://www.mathworks.com/matlabcentral/fileexchange/81253-improved-grey-wolf-optimizer-i-gwo?s_tid=srchtitle


%switch length(varargin) %%set parameter
dim = size(pn,1);
SearchAgents_no = size(pn,2);
Max_iter = 100;
ub = 10;
lb = -10;
Positions=rand(dim,SearchAgents_no).*(ub-lb)+lb;
l=0;% Loop counter

% initialize alpha, beta, and delta_pos
Alpha_pos=zeros(dim,1);
Alpha_score=inf; %change this to -inf for maximization problems

Beta_pos=zeros(dim,1);
Beta_score=inf; %change this to -inf for maximization problems

Delta_pos=zeros(dim,1);
Delta_score=inf; %change this to -inf for maximization problems

%% compute fitness, best positions
Fit = zeros(1,SearchAgents_no);
for i=1:SearchAgents_no
    Fit(1,i)=feval(herrfunc,Positions(:,i),varargin{:});
    
end
pBestScore = Fit;
pBest = Positions;

%% set tetangga and stuff
neighbor = zeros(SearchAgents_no,SearchAgents_no);
X_GWO = zeros(dim,SearchAgents_no);
Fit_GWO = zeros(1,SearchAgents_no);

% rand('twister',sum(pn(1)*clock))
% randn('state',sum(pn(2)*clock))

%%e0 = feval(herrfunc,pn,varargin{:});
%if any(e0<0), etol = -etol*etol^-2;end

% Main loop
while l<Max_iter
    for i=1:SearchAgents_no
        fitness = Fit(1,i); %%IGWO-GWO part
        
        % Update Alpha, Beta, and Delta
        
        if fitness<Alpha_score 
            Alpha_score=fitness; % Update alpha
            Alpha_pos=Positions(:,i);
        end
        
        if fitness>Alpha_score && fitness<Beta_score 
            Beta_score=fitness; % Update beta
            Beta_pos=Positions(:,i);
        end
        
        if fitness>Alpha_score && fitness>Beta_score && fitness<Delta_score 
            Delta_score=fitness; % Update delta
            Delta_pos=Positions(:,i);
        end
    end
    
    
    a=2-l*((2)/Max_iter); % a decreases linearly fron 2 to 0
    
    % Update the Position of search agents including omegas
    for i=1:SearchAgents_no 
        for j=1:dim    
                       
            r1=rand(); % r1 is a random number in [0,1]
            r2=rand(); % r2 is a random number in [0,1]
            
            A1=2*a*r1-a; % Equation (3.3)
            C1=2*r2; % Equation (3.4)
            
            D_alpha=abs(C1*Alpha_pos(j)-Positions(j,i)); % Equation (3.5)-part 1
            X1=Alpha_pos(j)-A1*D_alpha; % Equation (3.6)-part 1
                       
            r1=rand();
            r2=rand();
            
            A2=2*a*r1-a; % Equation (3.3)
            C2=2*r2; % Equation (3.4)
            
            D_beta=abs(C2*Beta_pos(j)-Positions(j,i)); % Equation (3.5)-part 2
            X2=Beta_pos(j)-A2*D_beta; % Equation (3.6)-part 2       
            
            r1=rand();
            r2=rand(); 
            
            A3=2*a*r1-a; % Equation (3.3)
            C3=2*r2; % Equation (3.4)
            
            D_delta=abs(C3*Delta_pos(j)-Positions(j,i)); % Equation (3.5)-part 3
            X3=Delta_pos(j)-A3*D_delta; % Equation (3.5)-part 3             
            
            X_GWO(j,i)=(X1+X2+X3)/3;% Equation (3.7)
            
        end
       % Return back the search agents that go beyond the boundaries of the search space
        Flag4ub=X_GWO(:,i)>ub;
        Flag4lb=X_GWO(:,i)<lb;
        X_GWO(:,i)=(X_GWO(:,i).*(~(Flag4ub+Flag4lb)))+0.5.*(ub+lb).*Flag4ub+0.5.*(ub+lb).*Flag4lb;  
        Fit_GWO(1,i) = feval(herrfunc,X_GWO(:,i),varargin{:});
        
    end
    
    %% Calculate the candiadate position Xi-DLH
    radius = pdist2(Positions', X_GWO', 'euclidean');         % Equation (10)
    dist_Position = squareform(pdist(Positions'));
    r1 = randperm(SearchAgents_no,SearchAgents_no);
    
    for t=1:SearchAgents_no
        neighbor(t,:) = (dist_Position(t,:)<=radius(t,t));
        [~,Idx] = find(neighbor(t,:)==1);                   % Equation (11)             
        random_Idx_neighbor = randi(size(Idx,2),1,dim);
        
        for d=1:dim
            X_DLH(d,t) = Positions(d,t) + rand .*(Positions(d,Idx(random_Idx_neighbor(d)))...
                - Positions(d,r1(t)));                      % Equation (12)
        end
        Flag4ub=X_DLH(:,t)>ub;
        Flag4lb=X_DLH(:,t)<lb;
        X_DLH(:,t)=(X_DLH(:,t).*(~(Flag4ub+Flag4lb)))+0.5.*(ub+lb).*Flag4ub+0.5.*(ub+lb).*Flag4lb;  
        Fit_DLH(1,t) = feval(herrfunc,X_DLH(:,t),varargin{:});
        
    end
    
    %% Selection  
    tmp = Fit_GWO < Fit_DLH;                                % Equation (13)
    tmp_rep = repmat(tmp',1,dim);
    tmp_rep = tmp_rep'; %% entahlah
    
    tmpFit = tmp .* Fit_GWO + (1-tmp) .* Fit_DLH;
    tmpPositions = tmp_rep .* X_GWO + (1-tmp_rep) .* X_DLH;
    
    %% Updating
    tmp = pBestScore <= tmpFit;                             % Equation (13)
    tmp_rep = repmat(tmp',1,dim);
    tmp_rep = tmp_rep'; %% entahlah
    
    pBestScore = tmp .* pBestScore + (1-tmp) .* tmpFit;
    pBest = tmp_rep .* pBest + (1-tmp_rep) .* tmpPositions;
    
    Fit = pBestScore;
    Positions = pBest;
    
    l=l+1;
    neighbor = zeros(SearchAgents_no,SearchAgents_no);
end
pfinal = Alpha_pos;
efinal = Alpha_score;