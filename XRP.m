(*Written by Gregory Klevans, December 11, 2020*)

G1[s_] := (1/360)*((10/3)*Sqrt[5]*((5*(s-2)*s+7)^(3/2)-(5*s^2-2*Sqrt[5]*Sqrt[5*s^2-4]+1)^(3/2))-50*Sqrt[5]*Sqrt[5*s^2-4]+400*s-295)
G2[s_] := (1/216)*(2*Sqrt[5]*(5*s^2-2*Sqrt[5]*Sqrt[5*s^2-4]+1)^(3/2)-30*Sqrt[5]*Sqrt[5*s^2-4]+240*s+2*Sqrt[5]*(5*(s-2)*s+7)^(3/2)-177)
G3[s_] := (1/216)*(2*Sqrt[5]*(5*s^2-2*Sqrt[5]*Sqrt[5*s^2-4]+1)^(3/2)-30*Sqrt[5]*Sqrt[5*s^2-4]-4*Sqrt[5]*(5*(s-2)*s+3)^(3/2)+240*s+2*Sqrt[5]*(5*(s-2)*s+7)^(3/2)-177)
G4[s_] := (1/108)*(30*s+Sqrt[5]*((5*(s-2)*s+7)^(3/2)-(5*(s-2)*s+3)^(3/2))-42)
G5[s_] := (1/216)*(-(50*(s^2+2*Sqrt[s^2-8]-7)^(3/2))+150*Sqrt[s^2-8]+780*s+2*Sqrt[5]*(5*(s-2)*s+7)^(3/2)-2337)
G[s_] := Which[s > 561/190, G5[s], s > 21/10, G4[s], s > Sqrt[10]/5 + 1, G3[s], s > (3*Sqrt[5])/5, G2[s], s >= 29/30, G1[s]]
InvG[(g_)?NumericQ] := FindRoot[Evaluate[G[x]] == g, {x, 2}, WorkingPrecision -> 40, MaxIterations -> Infinity][[1,2]]
n = 8; 
Clear[F2]
sol2 = NDSolve[{Derivative[1][F2][s] == (Beta[n, n]*BetaRegularized[1 - F2[s], n, n])/(((1 - F2[s])^(n - 1)*F2[s]^(n - 1))*(s - Evaluate[InvG[F2[s]]])), 
  F2[641/210] == 0.999999999}, F2, {s, 29/30, 641/210}, WorkingPrecision -> 40, Method-> "StiffnessSwitching", AccuracyGoal->20, MaxSteps->\[Infinity]]
Plot[{G[s], F2[s] /. sol2}, {s, 29/30,641/210}]
scr[s_] := FindRoot[G[s]==F2[x]/.sol2,{x,2.105}][[1,2]]
Plot[scr[s], {s,29/30,641/210}]
s[c_,e_] : c/(c+e)+(c+e)/50
b[c_,e_] : (c+e)(scr[s[c,e]]-(c+e)/50)*)
Plot3D[{s[c,e],scr[s[c,e]]}, {c,10,100}, {e,-5,5}, AxesLabel->{"Cost","Noise","Score"}, Exclusions->None,
  PlotRange -> {{0, 100}, {-5, 5}, {0, 3.25}}, Ticks -> {{10, 55, 100}, {-5, 0, 5}, {1, 2, 3}}, 
  BoxRatios -> {10, 1, 10}, PlotStyle -> Opacity[0.75], ViewPoint -> {-3, -2, 1}]
Plot3D[{c,b[c,e]}, {c,10,100}, {e,-5,5}, AxesLabel->{"Cost","Noise","Bid"}, Exclusions->None,
  PlotRange -> {{0, 100}, {-5, 5}, {0, 110}}, Ticks -> {{10, 55, 100}, {-5, 0, 5}, {10, 55, 100}}, 
  BoxRatios -> {10, 1, 10}, PlotStyle -> Opacity[0.75], ViewPoint -> {-3, -2, 1}]
Table[{c,e,scr[s[c,e]],b[c,e]}, {c,10,100}, {e,-5,5}];
Export["XRP Table.csv", Flatten[%], "Table"]
