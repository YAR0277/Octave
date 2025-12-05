function [] = Write2Csv(this)
  c = table2cell(this.DistrictTable); % convert to cell
  cell2csv(fullfile(this.DataFolder,this.CsvDistrictTable),c); % write to CSV
endfunction
