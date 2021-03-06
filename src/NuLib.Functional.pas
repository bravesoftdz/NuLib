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

unit NuLib.Functional;

interface

uses
  NuLib.Common,
  NuLib.Functional.Common,
  NuLib.Functional.Detail;

type
  Enumerator<T> = record
  strict private
    FImpl: NuLib.Functional.Detail.IEnumeratorImpl<T>;
    function GetCurrent: T; inline;
  private
    class function Create(const Impl: NuLib.Functional.Detail.IEnumeratorImpl<T>): Enumerator<T>; static;
  public
    function MoveNext: Boolean; inline;
    property Current: T read GetCurrent;
  end;

  Enumerable<T> = record
  strict private
    FImpl: NuLib.Functional.Detail.IEnumerableImpl<T>;
  private
    property Impl: NuLib.Functional.Detail.IEnumerableImpl<T> read FImpl;
  public
    // nested type since records cannot be forward declared
    type OrderedEnumerable = record
      strict private
        FImpl: NuLib.Functional.Detail.IOrderedEnumerableImpl<T>;
      private
        property Impl: NuLib.Functional.Detail.IOrderedEnumerableImpl<T> read FImpl;
      public
        function ThenBy<K>(const KeySelector: Func<T, K>): OrderedEnumerable; inline;

        //function Where(const Predicate: Predicate<T>): Enumerable<T>; inline;

        ///	<summary>
        ///	  <para>
        ///	    Used to assign nil to the enumerable instance, freeing internal
        ///	    references such as to wrapped objects.
        ///	  </para>
        ///	  <para>
        ///	    Other uses are internal only.
        ///	  </para>
        ///	</summary>
        ///	<param name="EnumerableImpl">
        ///	  Pass nil.
        ///	</param>
        ///	<returns>
        ///	  An enumerable instance with no associated implementation. Do not use
        ///	  the returned instance.
        ///	</returns>
        class operator Implicit(const OrderedEnumerableImpl: NuLib.Functional.Detail.IOrderedEnumerableImpl<T>): OrderedEnumerable; inline;

        function GetEnumerator: Enumerator<T>; inline;
      end;
  public
    function Aggregate(const AccumulateFunc: Func<T, T, T>): T; overload;
    function Aggregate<TAccumulate>(const InitialValue: TAccumulate; const AccumulateFunc: Func<TAccumulate, T, TAccumulate>): TAccumulate; overload;

    function OrderBy<K>(const KeySelector: Func<T, K>): OrderedEnumerable; inline;

    function Where(const Predicate: Predicate<T>): Enumerable<T>; inline;

    function Select<R>(const Selector: Func<T, R>): Enumerable<R>; inline;

    function Take(const Count: NativeInt): Enumerable<T>; inline;

    function ToArray(): TArray<T>;

    ///	<summary>
    ///	  Wraps an enumerable object, that is an object which can be used in
    ///	  for..in.
    ///	</summary>
    ///	<typeparam name="E">
    ///	  <para>
    ///	    Type of the enumerable object.
    ///	  </para>
    ///	  <para>
    ///	    If E is an interface type then E be compiled with RTTI, for example
    ///	    by descending from IInvokable.
    ///	  </para>
    ///	</typeparam>
    ///	<param name="EnumerableObj">
    ///	  Instance of the enumerable object.
    ///	</param>
    ///	<remarks>
    ///	  <para>
    ///	    The wrapper keeps a reference to the supplied enumerable object.
    ///	    Thus the returned Enumerable&lt;T&gt; instance should not be used
    ///	    after the wrapped object is destroyed.
    ///	  </para>
    ///	  <para>
    ///	    Nil the Enumerable&lt;T&gt; instance to release this reference.
    ///	  </para>
    ///	</remarks>
    class function Wrap<E>(const EnumerableObj: E): Enumerable<T>; static;

    ///	<summary>
    ///	  <para>
    ///	    Used to assign nil to the enumerable instance, freeing internal
    ///	    references such as to wrapped objects.
    ///	  </para>
    ///	  <para>
    ///	    Other uses are internal only.
    ///	  </para>
    ///	</summary>
    ///	<param name="EnumerableImpl">
    ///	  Pass nil.
    ///	</param>
    ///	<returns>
    ///	  An enumerable instance with no associated implementation. Do not use
    ///	  the returned instance.
    ///	</returns>
    class operator Implicit(const EnumerableImpl: NuLib.Functional.Detail.IEnumerableImpl<T>): Enumerable<T>; inline;

    class operator Implicit(const OrderedEnum: OrderedEnumerable): Enumerable<T>; inline;

    function GetEnumerator: Enumerator<T>; inline;
  end;

  Functional = record
  public
    ///	<summary>
    ///	  Filters a sequence based on the supplied predicate.
    ///	</summary>
    ///	<param name="Predicate">
    ///	  Predicate to test each element in the sequence.
    ///	</param>
    ///	<returns>
    ///	  Returns a sequence containing the elements of the source sequence for
    ///	  which the predicate returned true.
    ///	</returns>
    class function Filter<T>(const Predicate: Predicate<T>; const Source: Enumerable<T>): Enumerable<T>; static;

    class function Map<T, R>(const F: Func<T, R>; const Source: Enumerable<T>): Enumerable<R>; overload; static;
    class function Map<T1, T2, R>(const F: Func<T1, T2, R>; const Source1: Enumerable<T1>; const Source2: Enumerable<T2>): Enumerable<R>; overload; static;

    class function Slice<T>(const Source: Enumerable<T>; const Stop: NativeInt): Enumerable<T>; overload; static;
    class function Slice<T>(const Source: Enumerable<T>; const Start, Stop: NativeInt; const Step: NativeInt = 1): Enumerable<T>; overload; static;

    class function Zip<T1, T2>(const Source1: Enumerable<T1>; const Source2: Enumerable<T2>): Enumerable<Tuple<T1, T2>>; overload; static;
  end;

implementation

uses
  System.SysUtils,
  NuLib.Functional.Detail.EnumerableWrapper,
  NuLib.Functional.Detail.OrderedEnumerable,
  NuLib.Functional.Detail.Filter,
  NuLib.Functional.Detail.Map,
  NuLib.Functional.Detail.Aggregate,
  NuLib.Functional.Detail.Slice,
  NuLib.Functional.Detail.Zip;

{ Enumerator<T> }

class function Enumerator<T>.Create(const Impl: NuLib.Functional.Detail.IEnumeratorImpl<T>): Enumerator<T>;
begin
  result.FImpl := Impl;
end;

function Enumerator<T>.GetCurrent: T;
begin
  result := FImpl.Current;
end;

function Enumerator<T>.MoveNext: Boolean;
begin
  result := FImpl.MoveNext;
end;

{ Enumerable<T> }

function Enumerable<T>.Aggregate(const AccumulateFunc: Func<T, T, T>): T;
begin
  result := AggregateImpl.Compute<T>(Impl, AccumulateFunc);
end;

function Enumerable<T>.Aggregate<TAccumulate>(const InitialValue: TAccumulate;
  const AccumulateFunc: Func<TAccumulate, T, TAccumulate>): TAccumulate;
begin
  result := AggregateImpl.Compute<T, TAccumulate>(Impl, InitialValue, AccumulateFunc);
end;

function Enumerable<T>.GetEnumerator: Enumerator<T>;
begin
  result := Enumerator<T>.Create(Impl.GetEnumerator());
end;

class operator Enumerable<T>.Implicit(const OrderedEnum: OrderedEnumerable): Enumerable<T>;
begin
  result.FImpl := OrderedEnum.Impl;
end;

class operator Enumerable<T>.Implicit(const EnumerableImpl: NuLib.Functional.Detail.IEnumerableImpl<T>): Enumerable<T>;
begin
  result.FImpl := EnumerableImpl;
end;

function Enumerable<T>.OrderBy<K>(const KeySelector: Func<T, K>): OrderedEnumerable;
begin
  result := TOrderedEnumerable<T>.Create(Impl);
  result.ThenBy<K>(KeySelector); // workaround
end;

function Enumerable<T>.Select<R>(const Selector: Func<T, R>): Enumerable<R>;
begin
  result := TMapEnumerable<T,R>.Create(Impl, Selector);
end;

function Enumerable<T>.Take(const Count: NativeInt): Enumerable<T>;
begin
  result := TSliceEnumerable<T>.Create(Impl, 0, Count, 1);
end;

function Enumerable<T>.ToArray: TArray<T>;
var
  i: integer;
  v: T;
begin
  if (Impl.HasCount) then
  begin
    i := 0;

    SetLength(result, Impl.Count);
    for v in Impl do
    begin
      result[i] := v;
      i := i + 1;
    end;
  end
  else
  begin
    i := 0;

    SetLength(result, 4);
    for v in Impl do
    begin
      if Length(result) <= i then
        SetLength(result, (Length(result) * 3) div 2);

      result[i] := v;
      i := i + 1;
    end;
    SetLength(result, i);
  end;
end;

function Enumerable<T>.Where(const Predicate: Predicate<T>): Enumerable<T>;
begin
  result := TFilterEnumerable<T>.Create(Impl, Predicate);
end;

class function Enumerable<T>.Wrap<E>(const EnumerableObj: E): Enumerable<T>;
begin
  result := TEnumerableWrapper<E, T>.Create(EnumerableObj);
end;

{ Enumerable<T>.OrderedEnumerable }

function Enumerable<T>.OrderedEnumerable.GetEnumerator: Enumerator<T>;
begin
  result := Enumerator<T>.Create(Impl.GetEnumerator());
end;

class operator Enumerable<T>.OrderedEnumerable.Implicit(
  const OrderedEnumerableImpl: NuLib.Functional.Detail.IOrderedEnumerableImpl<T>): OrderedEnumerable;
begin
  result.FImpl := OrderedEnumerableImpl;
end;

function Enumerable<T>.OrderedEnumerable.ThenBy<K>(const KeySelector: Func<T, K>): OrderedEnumerable;
var
  orderedImpl: TOrderedEnumerable<T>;
begin
  orderedImpl := Impl.Instance as TOrderedEnumerable<T>;
  orderedImpl.AddOrdering<K>(KeySelector, Comparer<K>.Default, false);
  result := Self;
end;

// cannot be implemented due to compiler bug
//
//function Enumerable<T>.OrderedEnumerable.Where(const Predicate: Predicate<T>): Enumerable<T>;
//var
//  e: Enumerable<T>;
//begin
//  e := Impl;
//  result := e.Where(Predicate);
//end;

{ Functional }

class function Functional.Filter<T>(const Predicate: Predicate<T>; const Source: Enumerable<T>): Enumerable<T>;
begin
  result := TFilterEnumerable<T>.Create(Source.Impl, Predicate);
end;

class function Functional.Map<T, R>(const F: Func<T, R>; const Source: Enumerable<T>): Enumerable<R>;
begin
  result := TMapEnumerable<T, R>.Create(Source.Impl, F);
end;

class function Functional.Map<T1, T2, R>(const F: Func<T1, T2, R>; const Source1: Enumerable<T1>;
  const Source2: Enumerable<T2>): Enumerable<R>;
begin

end;

class function Functional.Slice<T>(const Source: Enumerable<T>; const Start, Stop, Step: NativeInt): Enumerable<T>;
begin
  result := TSliceEnumerable<T>.Create(Source.Impl, Start, Stop, Step);
end;

class function Functional.Zip<T1, T2>(const Source1: Enumerable<T1>;
  const Source2: Enumerable<T2>): Enumerable<Tuple<T1, T2>>;
begin
  result := TZipEnumerable<T1, T2>.Create(Source1.Impl, Source2.Impl, False);
end;

class function Functional.Slice<T>(const Source: Enumerable<T>; const Stop: NativeInt): Enumerable<T>;
begin
  result := TSliceEnumerable<T>.Create(Source.Impl, 0, Stop, 1);
end;

end.
