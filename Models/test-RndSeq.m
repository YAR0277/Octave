%pkg load statistics
clear all;
s=Sinput;

s.SetType('Bernoulli');
rs=RndSeq(s);
rs.PlotSample;

s.SetType('GaussMarkov');
rs=RndSeq(s);
rs.PlotSample;

s.SetType('RandomWalk');
rs=RndSeq(s);
rs.PlotSample;

s.SetType('White');
rs=RndSeq(s);
rs.PlotSample;

s.SetType('Wiener');
rs=RndSeq(s);
rs.PlotSample;

