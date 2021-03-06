function [bestx, bestf, exitflag, output] = sceua(fn, x0, bl,bu,maxn,kstop,pcento,peps,ngs,iseed,iniflg)
%% This is the subroutine implementing the SCE algorithm,
% written by Q.Duan, 9/2004
%
%% Update by Kong Dongdong, 20220607
% add argument default values
%
% Require MATLAB ≥ 2019b
% https://ww2.mathworks.cn/help/matlab/ref/arguments.html
%
%% Parameters:
%  x0       = the initial parameter array at the start;
%           = the optimized parameter array at the end;
%  fn       = the objective function value corresponding to the initial parameters
%           = the objective function value corresponding to the optimized parameters
%  bl       = the lower bound of the parameters
%  bu       = the upper bound of the parameters
%  iseed    = the random seed number (for repetetive testing purpose)
%  iniflg   = flag for initial parameter array (default 1, included it in initial
%             population; otherwise, not included)
%  ngs      = number of complexes (sub-populations)
%  npg      = number of members in a complex
%  nps      = number of members in a simplex
%  nspl     = number of evolution steps for each complex before shuffling
%  mings    = minimum number of complexes required during the optimization process
%  maxn     = maximum number of function evaluations allowed during optimization
%  kstop    = maximum number of evolution loops before convergency
%  percento = the percentage change allowed in kstop loops before convergency
%
%% RETURN
% `exitflag`:
%  - `1`: 函数收敛于解 x。
%  - `0`: 迭代次数超出 options.MaxIter 或函数计算次数超过 options.MaxFunEvals。
% `- -1`: 算法由输出函数终止。
%
%%seealso fminsearch
%
%% Examples
% ```MATLAB
% [x, feval, exitflag, output] = sceua(x0, fn, bl, bu, maxn);
% ```
%
%% References:
% 1. https://www.rdocumentation.org/packages/rtop/versions/0.5-14/topics/sceua
%
% ```R
% sceua(OFUN, pars, lower, upper, maxn = 10000, kstop = 5, pcento = 0.01,
%   ngs = 5, npg = 5, nps = 5, nspl = 5, mings = 5, iniflg = 1, iprint = 0, iround = 3,
%   peps = 0.0001, plog = rep(FALSE,length(pars)), implicit = NULL, timeout = NULL, ...)
% ```
% global BESTX BESTF ICALL PX PF
arguments
    fn
    x0
    bl
    bu
    % used the default parameter in rtop
    maxn     = 500
    kstop    = 5
    pcento   = 0.01
    peps     = 0.0001
    ngs      = 5
    % maxn   = 10000;
    % kstop  = 10;
    % pcento = 0.1;
    % peps   = 0.001;
    iseed    = -1
    iniflg   = 1
end

exitflag = -1;
output = [];

% LIST OF LOCAL VARIABLES
%    x(.,.)    = coordinates of points in the population
%    xf(.)     = function values of x(.,.)
%    xx(.)     = coordinates of a single point in x
%    cx(.,.)   = coordinates of points in a complex
%    cf(.)     = function values of cx(.,.)
%    s(.,.)    = coordinates of points in the current simplex
%    sf(.)     = function values of s(.,.)
%    bestx(.)  = best point at current shuffling loop
%    bestf     = function value of bestx(.)
%    worstx(.) = worst point at current shuffling loop
%    worstf    = function value of worstx(.)
%    xnstd(.)  = standard deviation of parameters in the population
%    gnrng     = normalized geometri%mean of parameter ranges
%    lcs(.)    = indices locating position of s(.,.) in x(.,.)
%    bound(.)  = bound on ith variable being optimized
%    ngs1      = number of complexes in current population
%    ngs2      = number of complexes in last population
%    iseed1    = current random seed
%    criter(.) = vector containing the best criterion values of the last
%                10 shuffling loops

% Initialize SCE parameters:
nopt=length(x0);
npg=2*nopt+1;
nps=nopt+1;
nspl=npg;
% mings=ngs;
npt=npg*ngs;

% make sure x is a row matrix
x0 = as_rowvec(x0);
bu = as_rowvec(bu);
bl = as_rowvec(bl);

bound = bu - bl;

% Create an initial population to fill array x(npt,nopt):
rand('seed', iseed);

x=zeros(npt,nopt);
for i=1:npt
    x(i,:) = bl + rand(1,nopt).*bound;
end

if iniflg==1; x(1,:)=x0; end

nloop=0;
icall=0;
for i=1:npt
    xf(i) = fn(x(i,:)); % nopt
    icall = icall + 1;
end
f0=xf(1);

% Sort the population in order of increasing function values;
[xf,idx]=sort(xf);
x=x(idx,:);

% Record the best and worst points;
bestx=x(1,:); bestf=xf(1);
worstx=x(npt,:); worstf=xf(npt);
BESTF=bestf; BESTX=bestx;ICALL=icall;

% Compute the standard deviation for each parameter
xnstd=std(x);

% Computes the normalized geometric range of the parameters
gnrng=exp(mean(log((max(x)-min(x))./bound)));

% disp('The Initial Loop: 0');
% disp(['BESTF  : ' num2str(bestf), '; ' 'BESTX  : [' num2str(bestx), ']']);
% disp(['WORSTF : ' num2str(worstf), '; ' 'WORSTX : [' num2str(worstx), ']']);
% disp(' ');
% nloop = 0;
fprintf('Iteration=%3d, nEvals=%3d, Best Cost = %.5f\n', nloop, icall, bestf)

% Check for convergency;
if icall >= maxn
    disp('*** OPTIMIZATION SEARCH TERMINATED BECAUSE THE LIMIT');
    disp('ON THE MAXIMUM NUMBER OF TRIALS ');
    disp(maxn);
    disp('HAS BEEN EXCEEDED.  SEARCH WAS STOPPED AT TRIAL NUMBER:');
    disp(icall);
    disp('OF THE INITIAL LOOP!');
end

if gnrng < peps
    exitflag = 1;
    disp('THE POPULATION HAS CONVERGED TO A PRESPECIFIED SMALL PARAMETER SPACE');
end

% Begin evolution loops:
criter=[];
criter_change=1e+5;

while icall < maxn && gnrng > peps && criter_change > pcento
    nloop=nloop+1;
    % Loop on complexes (sub-populations);
    for igs = 1: ngs
        % Partition the population into complexes (sub-populations);
        k1=1:npg;
        k2=(k1-1)*ngs+igs;
        cx(k1,:) = x(k2,:);
        cf(k1) = xf(k2);
        % Evolve sub-population igs for nspl steps:
        for loop=1:nspl
            % Select simplex by sampling the complex according to a linear
            % probability distribution
            lcs(1) = 1;
            for k3=2:nps
                for iter=1:1000
                    lpos = 1 + floor(npg+0.5-sqrt((npg+0.5)^2 - npg*(npg+1)*rand));
                    idx=find(lcs(1:k3-1)==lpos, 1);
                    if isempty(idx); break; end
                end
                lcs(k3) = lpos;
            end
            lcs=sort(lcs);

            % Construct the simplex:
            s = zeros(nps,nopt);
            s=cx(lcs,:); sf = cf(lcs);

            [snew,fnew,icall]=cceua(fn, s,sf,bl,bu,icall,maxn);

            % Replace the worst point in Simplex with the new point:
            s(nps,:) = snew; sf(nps) = fnew;

            % Replace the simplex into the complex;
            cx(lcs,:) = s;
            cf(lcs) = sf;

            % Sort the complex;
            [cf,idx] = sort(cf); cx=cx(idx,:);
            % End of Inner Loop for Competitive Evolution of Simplexes
        end
        % Replace the complex back into the population;
        x(k2,:) = cx(k1,:);
        xf(k2) = cf(k1);
        % End of Loop on Complex Evolution;
    end
    % Shuffled the complexes;
    [xf,idx] = sort(xf); x=x(idx,:);
    PX=x; PF=xf;

    % Record the best and worst points;
    bestx=x(1,:); bestf=xf(1);
    worstx=x(npt,:); worstf=xf(npt);
    BESTX=[BESTX;bestx]; BESTF=[BESTF;bestf];ICALL=[ICALL;icall];

    % Compute the standard deviation for each parameter
    xnstd=std(x);

    % Computes the normalized geometric range of the parameters
    gnrng=exp(mean(log((max(x)-min(x))./bound)));

    % disp(['Evolution Loop: ' num2str(nloop) ', Trial: ' num2str(icall)]);
    % disp(['BESTF  : ' num2str(bestf), '; ' 'BESTX  : [' num2str(bestx), ']']);
    % disp(['WORSTF : ' num2str(worstf), '; ' 'WORSTX : [' num2str(worstx), ']']);
    % disp(' ');
    fprintf('Iteration=%3d, nEvals=%3d, Best Cost = %.5f\n', nloop, icall, bestf)
    % disp(['Iteration ' num2str(nloop) ', #Fevals:'  ': Best Cost = ' num2str(BESTF)]);

    % Check for convergency;
    if icall >= maxn
        exitflag = 0;
        disp('*** OPTIMIZATION SEARCH TERMINATED BECAUSE THE LIMIT');
        disp(['ON THE MAXIMUM NUMBER OF TRIALS ' num2str(maxn) ' HAS BEEN EXCEEDED!']);
    end
    if gnrng < peps
        exitflag = 1;
        disp('THE POPULATION HAS CONVERGED TO A PRESPECIFIED SMALL PARAMETER SPACE');
    end
    criter=[criter;bestf];
    if (nloop >= kstop)
        criter_change=abs(criter(nloop)-criter(nloop-kstop+1))*100;
        criter_change=criter_change/mean(abs(criter(nloop-kstop+1:nloop)));
        if criter_change < pcento
            exitflag = 1;
            disp(['THE BEST POINT HAS IMPROVED IN LAST ' num2str(kstop) ' LOOPS BY ', ...
                'LESS THAN THE THRESHOLD ' num2str(pcento) '%']);
            disp('CONVERGENCY HAS ACHIEVED BASED ON OBJECTIVE FUNCTION CRITERIA!!!')
        end
    end
    % End of the Outer Loops
end

fprintf('SEARCH WAS STOPPED AT TRIAL NUMBER: %d \n', icall);
disp(['NORMALIZED GEOMETRIC RANGE = ' num2str(gnrng)]);
disp(['THE BEST POINT HAS IMPROVED IN LAST ' num2str(kstop) ' LOOPS BY ', ...
    num2str(criter_change) '%']);

% END of Subroutine sceua
end

function bool = is_rowvec(x)
    [nrow, ncol] = size(x);
    bool = nrow == 1 && ncol > 1;
end

function bool = is_colvec(x)
    [nrow, ncol] = size(x);
    bool = ncol == 1 && nrow > 1;
end

function x = as_rowvec(x)
    if is_rowvec(x)
       % nothing 
    elseif is_colvec(x)
        x = x';  
    end
end

function x = as_colvec(x)
    if is_colvec(x)
       % nothing 
    elseif is_rowvec(x)
        x = x';  
    end
end
