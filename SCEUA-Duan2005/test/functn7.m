function f=functn(x)
%
%   This is the Hartman Function
%   Bound: X(j)=[0,1], j=1,2,...,6
%   Global Optimum:-3.322368011415515,
%   (0.201,0.150,0.477,0.275,0.311,0.657)
%
%   Data for Hartman function coefficients (6-D)
nopt = length(x);

a2=[10.,0.05,3.,17.;
    3.,10.,3.5,8.;
    17.,17.,1.7,.05;
    3.5,0.1,10.,10.;
    1.7,8.,17.,.1;
    8.,14.,8.,14.];
c2=[1.,1.2,3.,3.2];
p2=[.1312,.2329,.2348,.4047;
    .1696,.4135,.1451,.8828;
    .5569,.8307,.3522,.8732;
    .0124,.3736,.2883,.5743;
    .8283,.1004,.3047,.1091;
    .5886,.9991,.6650,.0381];

%  Data for Hartman function coefficient (3-D)
a3=[3.,.1,3.,.1;
    10.,10.,10.,10.;
    30.,35.,30.,35.];
c3=[1.,1.2,3.,3.2];
p3=[.3689,.4699,.1091,.03815;
    .1170,.4387,.8732,.5743;
    .2673,.7470,.5547,.8828];
%       
f = 0.0;
for i = 1:4
    u = 0.0;
    for j = 1:nopt
        if nopt==3;
            a2(j,i) = a3(j,i);
            p2(j,i) = p3(j,i);
        end;
        u = u + a2(j,i) * (x(j) - p2(j,i))^2;
    end;
    if nopt == 3; c2(i) = c3(i); end;
    f = f - c2(i) * exp(-u);
end;

return
