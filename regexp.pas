program regexp;
uses regexpr;
var
  Regex: TRegExpr;
  i : integer;
  texte : string;
begin
  Regex := TRegExpr.Create;
  Regex.Expression := '.*login.*';
  if Regex.Exec('Please try to login here') then WriteLn('The login was found!');

  writeln('Args:'+ParamStr(1));
//  regex.Expression:='^.*<(.*)\(((.*)(.)(.))\).*';
  regex.Expression:=ParamStr(1);
  texte := 'occ001.Split.010414.E07ALDI.DepotAgenceANGERS_BFCM_010414-1319.split.xml.formate.01042014132726';
  texte := 'g:\dev\railsprj\prj\carto\';
  writeln('On cherche '+regex.Expression+' dans '+texte);
  if regex.Exec(texte) then
    writeln('Retourne TRUE');
  for i:=1 to regex.SubExprMatchCount do
    writeln(regex.Match[i]);

  Regex.Free;
end.
