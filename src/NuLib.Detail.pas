unit NuLib.Detail;

interface

// currently hardcoded to max size 1024
procedure SwapData(var v1, v2; Size: UInt32); inline;

procedure IntRefToMethPtr(const IntRef; var MethPtr; MethNo: Integer);

// returns 0 if v is 0 or result > 2^31
function NextPow2(v: UInt32): UInt64; inline;

// works for v <= 2^32
function LargestPrimeLessThan(v: UInt64): UInt32; overload;
function LargestPrimeLessThan(v: UInt64; out PrimitiveRoot: UInt32): UInt32; overload;

implementation

procedure SwapData(var v1, v2; Size: UInt32); inline;
type
  PData = ^UInt8;
var
  p1, p2, pt: PData;
  tv: array[0..1023] of UInt8; // yeah ok...
begin
  Assert(Size <= SizeOf(tv), 'Size too large in SwapData');

  p1 := PData(@v1);
  p2 := PData(@v2);
  pt := PData(@tv);

  Move(p1^, pt^, Size);
  Move(p2^, p1^, Size);
  Move(pt^, p2^, Size);
end;

procedure IntRefToMethPtr(const IntRef; var MethPtr; MethNo: Integer);
type
  TVtable = array[0..999] of Pointer;
  PVtable = ^TVtable;
  PPVtable = ^PVtable;
begin
  // QI=0, AddRef=1, Release=2, 3 = first user method
  TMethod(MethPtr).Code := PPVtable(IntRef)^^[MethNo];
  TMethod(MethPtr).Data := Pointer(IntRef);
end;

function NextPow2(v: UInt32): UInt64;
begin
  v := v or (v shr 1);
  v := v or (v shr 2);
  v := v or (v shr 4);
  v := v or (v shr 8);
  v := v or (v shr 16);
  result := v;
  result := result + 1;
end;

const
  PrimeList: array[0..30] of UInt32 = (
  3, 7, 13, 31, 61, 127, 251, 509, 1021, 2039, 4093, 8191, 16381, 32749, 65521,
  131071, 262139, 524287, 1048573, 2097143, 4194301, 8388593, 16777213,
  33554393, 67108859, 134217689, 268435399, 536870909, 1073741789,
  2147483647, 4294967291);
  PrimitiveRootList: array[0..30] of UInt32 = (
  // list containing a primitive root for each prime number in PrimeList
  // these are randomly picked for now, any primitive root should do in theory...
  2, // 3
  3, // 7
  6, // 13
  12, // 31
  17, // 61
  23, // 127
  24, // 251
  27, // 509
  30, // 1021
  33, // 2039
  34, // 4093
  35, // 8191
  40, // 16381
  44, // 32749
  46, // 65521
  52, // 131071
  54, // 262139
  56, // 524287
  60, // 1048573
  65, // 2097143
  73, // 4194301
  75, // 8388593
  80, // 16777213
  82, // 33554393
  87, // 67108859
  89, // 134217689
  93, // 268435399
  95, // 536870909
  90, // 1073741789
  99, // 2147483647
  101 // 4294967291
  );

function LargestPrimeLessThan(v: UInt64): UInt32; overload;
var
  pr: UInt32;
begin
  result := LargestPrimeLessThan(v, pr);
end;

function LargestPrimeLessThan(v: UInt64; out PrimitiveRoot: UInt32): UInt32;
var
  i: UInt32;
begin
  result := 0;
  PrimitiveRoot := 0;
  for i := 0 to High(PrimeList) do
  begin
    if PrimeList[i] > v  then
      exit;
    result := PrimeList[i];
    PrimitiveRoot := PrimitiveRootList[i];
  end;
end;

end.
