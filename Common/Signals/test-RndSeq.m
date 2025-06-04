clear all;
s=Sinput;
s.SetType('Bernoulli');
rs=RndSeq(s);
rs.PlotSeq;
s.SetType('GaussMarkov');
rs=RndSeq(s);
rs.PlotSeq;
s.SetType('RandomWalk');
rs=RndSeq(s);
rs.PlotSeq;
s.SetType('White');
rs=RndSeq(s);
rs.PlotSeq;
s.SetType('Wiener');
rs=RndSeq(s);
rs.PlotSeq;

