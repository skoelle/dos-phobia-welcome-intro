{ Copyright (c) 2026 Stefan Koelle (https://stefankoelle.de) }
{ Licensed under the MIT License. See LICENSE file in project root for details. }
unit pho_u;
INTERFACE
procedure phopic;
procedure phopal;
IMPLEMENTATION
procedure phopic;external
{$L phopic.obj};
procedure phopal;external
{$L phopal.obj};
begin
end.