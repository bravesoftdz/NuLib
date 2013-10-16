//  Copyright 2013 Asbj�rn Heid
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

unit NuLib.Containers;

interface

uses
  NuLib.Containers.Common,
  NuLib.Containers.Detail,
  NuLib.Containers.Detail.OpenAddressingInline,
  NuLib.Containers.Detail.OpenAddressingSeparate;

type
  Pair<T1, T2> = record
    Value1: T1;
    Value2: T2;

    constructor Create(const V1: T1; const V2: T2);

    property Key: T1 read value1 write value1;
    property Value: T2 read value2 write value2;

    property First: T1 read value1 write value1;
    property Second: T2 read value2 write value2;
  end;


  Dictionary<K, V> = record
  private
    type
//      TDictImpl = NuLib.Containers.Detail.OpenAddressingSeparate.Dictionary<K, V>;
      TDictImpl = NuLib.Containers.Detail.OpenAddressingInline.Dictionary<K, V>;
  strict private
    FDict: NuLib.Containers.Detail.IDictionaryImplementation<K,V>;
  private
    function GetCount: UInt32; inline;
    function GetItem(const Key: K): V; inline;
    procedure SetItem(const Key: K; const Value: V); inline;
    function GetEmpty: Boolean;
    function GetContains(const Key: K): Boolean;
  public
    procedure Clear;
    function Remove(const Key: K): Boolean;

    procedure Reserve(const MinNewCapacity: UInt32);

    property Empty: Boolean read GetEmpty;
    property Count: UInt32 read GetCount;
    property Item[const Key: K]: V read GetItem write SetItem; default;
    property Contains[const Key: K]: Boolean read GetContains;

    class function Create: Dictionary<K, V>; overload; static;
    class function Create(const Comparer: NuLib.IEqualityComparer<K>): Dictionary<K, V>; overload; static;
    class function Create(const Comparison: NuLib.EqualityComparisonFunction<K>; const Hasher: NuLib.HashFunction<K>): Dictionary<K, V>; overload; static;
  end;

implementation

{ Pair<T1, T2> }

constructor Pair<T1, T2>.Create(const V1: T1; const V2: T2);
begin
  Value1 := V1;
  Value2 := V2;
end;

{ Dictionary<K, V> }

class function Dictionary<K, V>.Create: Dictionary<K, V>;
begin
  result.FDict := TDictImpl.Create(NuLib.Containers.Detail.EqualityComparerInstance<K>.Get());
end;

procedure Dictionary<K, V>.Clear;
begin
  FDict.Clear;
end;

class function Dictionary<K, V>.Create(const Comparer: NuLib.IEqualityComparer<K>): Dictionary<K, V>;
begin
  result.FDict := TDictImpl.Create(Comparer);
end;

class function Dictionary<K, V>.Create(const Comparison: NuLib.EqualityComparisonFunction<K>;
  const Hasher: NuLib.HashFunction<K>): Dictionary<K, V>;
begin
  result.FDict := TDictImpl.Create(NuLib.Containers.Common.DelegatedEqualityComparer<K>.Create(Comparison, Hasher));
end;

function Dictionary<K, V>.GetContains(const Key: K): Boolean;
begin
  result := FDict.Contains[Key];
end;

function Dictionary<K, V>.GetCount: UInt32;
begin
  result := FDict.Count;
end;

function Dictionary<K, V>.GetEmpty: Boolean;
begin
  result := FDict.Empty;
end;

function Dictionary<K, V>.GetItem(const Key: K): V;
begin
  result := FDict.Item[Key];
end;

function Dictionary<K, V>.Remove(const Key: K): Boolean;
begin
  result := FDict.Remove(Key);
end;

procedure Dictionary<K, V>.Reserve(const MinNewCapacity: UInt32);
begin
  FDict.Reserve(MinNewCapacity);
end;

procedure Dictionary<K, V>.SetItem(const Key: K; const Value: V);
begin
  FDict.Item[Key] := Value;
end;

end.