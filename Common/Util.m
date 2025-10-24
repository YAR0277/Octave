classdef Util < handle
  % parent utilities class
  % https://www.mathworks.com/matlabcentral/answers/182131-percentile-of-a-value-based-on-array-of-data

  properties (Constant)

  endproperties

  methods (Static = true) % Public

    function [t_out,x_out] = Aggregate(t_in,x_in,dt)
      % [t_out,x_out] = Aggregate(t_in,x_in,dt) where t_in=input times, x_in=input values, dt=12, for example.
      a = int16(0:dt:length(x_in));
      n = int16(length(a)+1);
      t_out = NaN(n,1);
      x_out = NaN(n,1);
      t_out(1) = t_in(1);
      x_out(1) = x_in(1);
      for i=2:n-1
        t_out(i) = t_in(a(i));
        x_out(i) = mean( x_in(a(i-1)+1:a(i)) );
      endfor
      t_out(n) = t_in(end);
      x_out(n) = mean( x_in(a(end)+1:end) );
    endfunction

    function [r] = CalcPercentile(data,value)
      data = data(:)';
      value = value(:);

      nless = sum(data < value, 2);
      nequal = sum(data == value, 2);
      r = 100*( (nless + 0.5.*nequal) / length(data) );
    endfunction

    function [r] = CalcPercentileValue(data, percentile)
      dataSorted = sort(data,"ascend");
      idx = ( percentile * length(data) ) / 100;
      idx = ceil(idx); % round up
      r = dataSorted(idx);
    endfunction

    function [r] = IQM(data)
      % https://en.wikipedia.org/wiki/Interquartile_mean
      lowerBound = Util.CalcPercentileValue(data,25);
      upperBound = Util.CalcPercentileValue(data,75);
      dataSorted = sort(data,"ascend");
      ix = lowerBound <= dataSorted & dataSorted <= upperBound;
      r = mean(dataSorted(ix));
    endfunction

    function [p,e_var,r,p_var,fit_var] = DoLinearRegression(x,y)
      % https://octave.sourceforge.io/optim/function/LinearRegression.html
      pkg load optim;
    endfunction

    function [r] = GetAPR(t,y)
      timestep = Util.GetTimeStep(t);
      r = mean(y);
      switch timestep
        case 'day'
          r = r*(365);
        case 'week'
          r = r*(52);
        case 'month'
          r = r*(12);
        case 'quarter'
          r = r*(4);
        otherwise
      endswitch
    endfunction

    function [r] = GetDatestr(datenr)
      % [r] = GetDatestr(datenr) where datenr=739884
      r = datestr(datenr);
    endfunction

    function [r] = GetDatestrToday()
      r = datestr(now(),'yyyy-mm-dd');
    endfunction

    function [r] = GetDatenum(date)
      % [r] = GetDatenum(date) where date='2025-09-23'
      y = str2num(datestr(date,'yyyy'));
      m = str2num(datestr(date,'mm'));
      d = str2num(datestr(date,'dd'));
      r = datenum(y,m,d);
    endfunction

    function [r] = GetDatenumToday()
      s = Util.GetDatestrToday();
      r = datenum(s,'yyyy-mm-dd');
    endfunction

    function [r] = GetDatenumYear(y)
      % [r] = GetDatenumYear(y) where y=2025
      yearStr = num2str(y);
      dateStr = strcat(yearStr,'-01-01');
      r = datenum(dateStr,'yyyy-mm-dd');
    endfunction

    function [r,fmt] = GetDateTicks(t)
      % gets xticks and date format depending on timestep and timespan(numYears)
      timestep = Util.GetTimeStep(t);
      numYears = uint16((t(end)-t(1))/365);
      switch timestep
        case 'day'
          dt = 15;
          fmt = 'YY-mm-dd';
          szfmt = 8;
##          numYears = uint16((t(end)-t(1))/365);
          [r,dt,fmt,szfmt] = Util.GetDateTicksDay(t,length(t));
        case 'week'
          dt = 10;
          fmt = 'YY-mm-dd';
          szfmt = 8;
##          numYears = uint16((t(end)-t(1))/52);
        case 'month'
##          numYears = uint16((t(end)-t(1))/12);
          [r,dt,fmt,szfmt] = Util.GetDateTicksMonth(t,length(t));
        case 'quarter'
          dt = 10;
          fmt = 'YY-mm';
          szfmt = 6;
          numYears = uint16((t(end)-t(1))/4);
        case 'year'
##          numYears = uint16(length(t));
          [r,dt,fmt,szfmt] = Util.GetDateTicksYear(t,numYears);
        otherwise
          error('invalid number timestep: %s. \n',timestep);
      endswitch
      if length(t) > Constant.MaxNumXTicks
        r = t(1:dt:end);
      else
        r = t(1:1:end);
      endif
      % if there is enough room (szfmt), add the last return to the ticks,
      % otherwise replace the last tick with the last return.
##      if t(end) - r(end) > szfmt
##        r(end+1) = t(end);
##      else
##        r(end) = t(end);
##      endif
    endfunction

    function [r,dt,fmt,szfmt] = GetDateTicksDay(t,numTimestamp)
      fmt = 'YY-mm-dd';
      szfmt = 8;
      if numTimestamp > 12
        dt = int16(numTimestamp/12); % every 5 years * 12 months/yr
      elseif numTimestamp <=1
        dt = 1;
      else
        dt = 12;
      endif
      if length(t) > Constant.MaxNumXTicks
        r = t(1:dt:end);
      else
        r = t(1:1:end);
      endif
    endfunction

    function [r,dt,fmt,szfmt] = GetDateTicksMonth(t,numTimestamp)
      fmt = 'mmm yyyy';
      szfmt = 8;
      if numTimestamp > 12
        dt = int16(numTimestamp/12);
      elseif numTimestamp <=1
        dt = 1;
      else
        dt = 12;
      endif
      if length(t) > Constant.MaxNumXTicks
        r = t(1:dt:end);
      else
        r = t(1:1:end);
      endif
    endfunction

    function [r,dt,fmt,szfmt] = GetDateTicksYear(t,numTimestamp)
      fmt = 'yyyy';
      szfmt = 4;
      if numTimestamp > 12
        dt = int16(numTimestamp/12);
      elseif numTimestamp <=1
        dt = 1;
      else
        dt = 12;
      endif
      if length(t) > Constant.MaxNumXTicks
        r = t(1:dt:end);
      else
        r = t(1:1:end);
      endif
    endfunction

    function [r,p] = GetSignal(t,x)
      % p(x) coefficients of a polynomial of degree n that minimizes the least-squares-error of the fit to the points [x(:),y(:)]
      % s is a structure containing: 'yf' - the values of the polynomial for each value of x. etc.
      [p,s] = polyfit(t,x,1);
      r = s.yf;
    endfunction

    function [r] = GetTimeStep(timestamp)

        if length(timestamp) < 2
          error('invalid number of timestamps: %d. \n',length(timestamp));
        endif

        dt = diff(timestamp);
        dd = mode(dt); % delta (in) days
        if dd >= 1 && dd <2
          r = 'day';
        elseif dd >= 6 && dd <= 7
          r = 'week';
        elseif dd >= 27 && dd <= 32
          r = 'month';
        elseif dd >= 89 && dd <= 92
          r = 'quarter';
        elseif dd >= 364 && dd <= 366
          r = 'year';
        else
          error('invalid delta timestamp: %.2f. \n',dd);
        endif
    endfunction

    function [s] = PropToStruct(className)
      s = struct();
      fields = fieldnames(className);
      for i=1:length(fields)
        s.(fields{i}) = getfield(className,fields{i});
      endfor
    endfunction

    function [r] = Diff(x,p)
      % computes pth order difference of vector x
      % [r] = Diff([1 4 7 8],2).
      if nargin == 1
        p = 1;
      endif

      if p >= length(x)
        error('order of difference (%d) must be less than dimension of vector (%d). \n',p,length(x));
      endif

      if p == 1
        r = diff(x);
      else
        r = Util.Diff(diff(x),p-1);
      endif
    endfunction

    function [r] = RemoveFileExt(filename)
      [~,r,~] = fileparts(filename{:});
    endfunction

    function [r] = Round(r)
      r = round(r.*100)./100; % round to nearest 2 decimal places
    endfunction

    function [] = SaveStruct(className,folderName,fileName)
      filename = fullfile(folderName,strcat(fileName,".txt"));
      asStruct = Util.PropToStruct(className);
      fid = fopen(filename, 'w+');
      % https://www.mathworks.com/matlabcentral/answers/80200-access-elements-fields-from-a-struct
      names = fieldnames(asStruct);
      for i=1:length(names)
        value{i} = getfield(asStruct,names{i});
        fprintf(fid,'%s=%s\n',names{i},value{i});
      endfor
      fclose(fid);
    endfunction
  endmethods
endclassdef
