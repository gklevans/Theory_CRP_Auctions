(* Written by Gregory Klevans, December 11, 2020 *)

\[Mu] = 5;
Clear[InvBid2]
F2[b_] := (InvBid2[b]-b+\[Mu]+5)^2/1800+(b-\[Mu]-10)/90
P2[b_,c_] := (b-c)BetaRegularized[1-F2[b],8,8];
foc2 = D[P2[b,c],b]/.c-> InvBid2[b];
Needs["DifferentialEquations`InterpolatingFunctionAnatomy`"];
s2=First[InvBid2/.NDSolve[{foc2==0, InvBid2[99.99995]==99.9999}, InvBid2, {b,10,100},
  AccuracyGoal-> 10, PrecisionGoal-> 10, WorkingPrecision-> 15, MaxSteps-> \[Infinity]]]
domain2 = InterpolatingFunctionDomain[s2];
{begin2, end2} = domain2[[1]];
b2[c_] : =FindRoot[s2[a]==c, {a,80}, AccuracyGoal-> 15, PrecisionGoal-> 15, WorkingPrecision-> 20, MaxIterations-> 10000][[1,2]];
b2capped[c_] := Min[c+\[Mu]+5, b2[c]];
F3[b_] := (b-\[Mu]-5)/90;
P3[b_,c_] := (b-c)BetaRegularized[1-F3[b],8,8];
b3[c_] := b/.Last[NMaximize[{P3[b,c],c+\[Mu]+5<=b<=begin2}, b]]; bidf5[c_] := Piecewise[{{b3[c],c>=10&&c<s2[begin2]}, {b2[c], c>= s2[begin2]&&c<=100}}];
p5 = Plot[{c, bidf5[c]}, {c,10,100}, PlotRange-> 0,110}, 
  AxesLabel-> {"Bid","Cost"}, PlotStyle-> {{Gray,Thin}, {Red,{Dotted,Thick}}}, PlotLegends-> {None,"\[Mu]=5"}]

\[Mu]=15;
b1[c_]=(55 (13726000000000+1098080000000 c+49444800000 c^2+1633600000 c^3+48200000 c^4+720000 c^5+52000 c^6-832 c^7+39 c^8))/
  (16 (857631250000+68825000000 c+3022050000 c^2+115750000 c^3+1306250 c^4+181500 c^5-3575 c^6+143 c^7));
c1 = FindRoot[b1[c]==c+\[Mu]-5, {c,80}][[1,2]]
Clear[InvBid2];
F2[b_] := (InvBid2[b]-b+\[Mu]+5)^2/1800+(b-\[Mu]-10)/90
P2[b_,c_] := (b-c)BetaRegularized[1-F2[b],8,8];
foc2 = D[P2[b,c],b]/.c-> InvBid2[b];
Needs["DifferentialEquations`InterpolatingFunctionAnatomy`"];
s2 = First[InvBid2/.NDSolve[{foc2==0, InvBid2[b1[c1]]==c1}, InvBid2, {b,10,100}, 
  AccuracyGoal-> 0, PrecisionGoal-> 10, WorkingPrecision-> 5, MaxSteps-> \[Infinity]]]
domain2 = InterpolatingFunctionDomain[s2];
{begin2, end2} = domain2[[1]];
b2[c_] := FindRoot[s2[a]==c, {a,80}, AccuracyGoal-> 20, PrecisionGoal-> 20, WorkingPrecision-> 25, MaxIterations-> 10000][[1,2]]
F3[b_] := (b-\[Mu]-5)/90;
P3[b_,c_] := (b-c)BetaRegularized[1-F3[b],8,8];
b3[c_] := b/.Last[NMaximize[{P3[b,c], c+\[Mu]+5<=b<=begin2}, b]];
bidf15[c_] := Piecewise[{{b3[c], c>=10&&c<s2[begin2]}, {b2[c], c>=s2[begin2]&&c<c1}, {b1[c], c>=c1&&c<100}}];
p15 = Plot[{bidf15[c],c}, {c,10,100}, PlotRange-> {0,110}, 
  AxesLabel-> {"Bid","Cost"}, PlotStyle-> {{Blue,{Dashed,Thin}}, {LightGray,Thin}}, PlotLegends-> {"\[Mu]=15",None}]

\[Mu] = 3;
b1[c_] := 105+\[Mu];
w2 = 1/2-\[Mu]/10; (*Probability that a given opponent doesn't participate*)
w11[b_] = (105+\[Mu]-b)^2/1800; (*Probability that a participating opponent submits a higher bid*)
P1[b_,c_] = (b-c)BetaRegularized[w11[b]+w2,8,8]; (*Expected payoff, up to a constant*)
Simplify[D[P1[b,c], b]]
Manipulate[Plot[P1[b,c], {b,c,c+5+\[Mu]}], {c,10,100}]
b/.Last[NMaximize[{P1[b,96], 96<= b<= 96+5+\[Mu]}, b]]
b0[c_] := b/.Last[NMaximize[{P1[b,c],c<=b<=c+5+\[Mu]}, b]]
Plot[b0[c], {c,95,100}]
p1=Plot[b1[c], {c,96.6,100}, AxesLabel-> {"Cost","Bid"}]
Clear[InvBid2];
w12[b_] = ((105+\[Mu]-b)^2-(100-InvBid2[b])^2)/1800;
P2[b_,c_] = (b-c)BetaRegularized[w12[b]+w2,8,8];
foc2 = D[P2[b,c],b]/.c-> InvBid2[b];
c2 = 96.6;
s2 = First[InvBid2/.NDSolve[{foc2==0, InvBid2[c2+\[Mu]+4.999]==c2}, InvBid2, {b,100,c2+\[Mu]+4.999}]]
Needs["DifferentialEquations`InterpolatingFunctionAnatomy`"];
domain2 = InterpolatingFunctionDomain[s2];
{begin2, end2} = domain2[[1]];
Plot[s2[b], {b,begin2,end2}, AxesLabel-> {"Bid","Cost"}]
b2[c_] := FindRoot[s2[a]==c, {a,102}][[1,2]] 
p2 = Plot[b2[c], {c,s2[begin2],s2[end2]}, AxesLabel-> {"Cost","Bid"}]
F3[b_] := ((\[Mu]+5)(InvBid3[b]-10)+(b-InvBid3[b])^2/2)/900;
P3[b_,c_] := (b-c)BetaRegularized[1-F3[b],8,8]
foc3 = D[P3[b,c],b]/.c-> InvBid3[b];
s3 = First[InvBid3/.NDSolve[{foc3==0, InvBid3[begin2]==s2[begin2]}, InvBid3, {b,10,100}, WorkingPrecision-> 60, MaxSteps-> \[Infinity]]]
domain3 = InterpolatingFunctionDomain[s3];
{begin3, end3} = domain3[[1]];
Plot[s3[b], {b,begin3,end3}, AxesLabel-> {"Bid","Cost"}]
b3[c_] : =FindRoot[s3[a]==c, {a,90}][[1,2]];
p3 = Plot[b3[c], {c,s3[begin3],s3[end3]}, AxesLabel-> {"Cost","Bid"}]
F4[b_] := ((5+\[Mu])(b-\[Mu]-15)+(\[Mu]+5)^2/2)/900;
P4[b_,c_] := (b-c)BetaRegularized[1-F4[b],8,8];
Manipulate[Plot[P4[b,c], {b,c,begin3}], {c,10,s3[begin3]}]
b4[c_] := b/.Last[NMaximize[{P4[b,c],c<=b<=begin3}, b]];
p4 = Plot[b4[c], {c,10,s3[begin3]}, AxesLabel-> {"Cost","Bid"}]
bidf3[c_] := Piecewise[{{b1[c],c>=s2[end2]}, {b2[c],c>=s3[end3]&&c<s2[end2]}, {b3[c],c>=s3[begin3]&&c<s3[end3]}, {b4[c],c>= 10&&c<s3[begin3]}}]; 
p3 = Plot[{bidf3[c],c}, {c,10,100}, PlotRange-> {0,110}, 
  AxesLabel-> {"Cost","Bid"}, PlotStyle-> {{DarkGreen,DotDashed},{Gray,Thin}}, PlotLegends-> {"\[Mu]=3",None}]

Show[p3,p5,p15]
