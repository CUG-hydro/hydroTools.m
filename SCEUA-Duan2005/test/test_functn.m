clear;
% global BESTX BESTF ICALL PX PF

ifunc = 6;

if ifunc==1
    % Goldstein-Price Function
    % Bound X1=[-2,2], X2=[-2,2]; Global Optimum: 3.0,(0.0,-1.0)
    fn = @functn1;
    bl=[-2 -2]; bu=[2 2]; x0=[1 1];
end

if ifunc==2
    %  Rosenbrock Function
    %  Bound: X1=[-5,5], X2=[-2,8]; Global Optimum: 0,(1,1)
    fn = @functn2;
    bl=[-5 -5]; bu=[5 5]; x0=[1 1];
end

if ifunc==3
    %  Six-hump Camelback Function.
    %  Bound: X1=[-5,5], X2=[-5,5]
    %  True Optima: -1.03628453489877, (-0.08983,0.7126), (0.08983,-0.7126)
    fn = @functn3;
    bl=[-5 -2]; bu=[5 8]; x0=[-0.08983 0.7126];
end

if ifunc==4
    %  Rastrigin Function
    %  Bound: X1=[-1,1], X2=[-1,1]; Global Optimum: -2, (0,0)
    fn = @functn4;
    bl=[-1 -1]; bu=[1 1]; x0=[0 0];
end

if ifunc==5
    %  Griewank Function (2-D or 10-D)
    %  Bound: X(i)=[-600,600], for i=1,2,...,10
    %  Global Optimum: 0, at origin
    fn = @functn5;
    bl=-600*ones(1,10); bu=600*ones(1,10); x0=zeros(1,10);
end

if ifunc==6
    %  Shekel Function; Bound: X(i)=[0,10], j=1,2,3,4
    %  Global Optimum:-10.5364098252,(4,4,4,4)
    fn = @functn6;
    bl=zeros(1,4); bu=10*ones(1,4); x0=[4 4 4 4];
end

if ifunc==7
    %   Hartman Function
    %   Bound: X(j)=[0,1], j=1,2,...,6;
    %   Global Optimum:-3.322368011415515, (0.201,0.150,0.477,0.275,0.311,0.657)
    fn = @functn7;
    bl=zeros(1,6); bu=ones(1,6); x0=[0.201,0.150,0.477,0.275,0.311,0.657];
end

maxn   = 10000;
% default parameters are OK
kstop  = 10;
pcento = 0.1;
peps   = 0.001;
iseed  = -1;
iniflg = 0;
ngs    = 2; % the number of complexes

% [bestx, bestf] = sceua(fn, x0, bl,bu,maxn,kstop,pcento,peps,ngs,iseed,iniflg);
[bestx, bestf] = sceua(fn, x0, bl, bu, maxn);
