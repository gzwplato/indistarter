unit UniqueInstanceRaw;

{
  UniqueInstance is a component to allow only a instance by program

  Copyright (C) 2006 Luiz Americo Pereira Camara
  pascalive@bol.com.br

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version with the following modification:

  As a special exception, the copyright holders of this library give you
  permission to link this library with independent modules to produce an
  executable, regardless of the license terms of these independent modules,and
  to copy and distribute the resulting executable under terms of your choice,
  provided that you also meet, for each linked independent module, the terms
  and conditions of the license of that module. An independent module is a
  module which is not derived from or based on this library. If you modify
  this library, you may extend this exception to your version of the library,
  but you are not obligated to do so. If you do not wish to do so, delete this
  exception statement from your version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, simpleipc;
  
  function InstanceRunning(const Identifier: String; SendParameters: Boolean = False): Boolean;

  function InstanceRunning: Boolean;

implementation

const
  BaseServerId = 'tuniqueinstance_';
  Separator = '|';

var
  FIPCServer: TSimpleIPCServer;
  
function InstanceRunning(const Identifier: String; SendParameters: Boolean = False): Boolean;

  function GetServerId: String;
  begin
    if Identifier <> '' then
      Result := BaseServerId + Identifier
    else
      Result := BaseServerId + ExtractFileName(ParamStr(0));
  end;
  
var
  TempStr: String;
  i: Integer;
  
begin
  with TSimpleIPCClient.Create(nil) do
  try
    ServerId := GetServerId;
    Result := ServerRunning;
    if not Result then
    begin
      //It's the first instance. Init the server
      if FIPCServer = nil then
        FIPCServer := TSimpleIPCServer.Create(nil);
      FIPCServer.ServerID := ServerId;
      FIPCServer.Global := True;
      FIPCServer.StartServer;
    end
    else
      // an instance already exists
      if SendParameters then
      begin
        TempStr := '';
        for i := 1 to ParamCount do
          TempStr := TempStr + ParamStr(i) + Separator;
        Active := True;
        SendStringMessage(ParamCount, TempStr);
      end;
  finally
    Free;
  end;
end;

function InstanceRunning: Boolean;
begin
  Result := InstanceRunning('');
end;

finalization  
  FIPCServer.Free;
end.

