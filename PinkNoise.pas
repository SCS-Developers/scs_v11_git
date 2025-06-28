{
   Generation of pink noise

     For basic knwoledge and derivation take a look at:
     http://www.firstpr.com.au/dsp/pink-noise/
     by Phil Burk, http://www.softsynth.com
     Copyleft 1999 Phil Burk - No rights reserved.
     File/s:
     Original: http://www.firstpr.com.au/dsp/pink-noise/phil_burk_19990905_patest_pink.c
     ... else: patest_pink.c (https://www.assembla.com/code/portaudio/subversion/nodes/1368/portaudio/branches/v19-devel/test/patest_pink.c)

   Extended to use with BASS.DLL >= 2.4.10 by TERWI
   V 1.0 - 2014-05-16
 }

unit pink2;

 interface

 uses
   SysUtils, Types;

 const
   PINK_MAX_RANDOM_ROWS  = 30;
   PINK_RANDOM_BITS      = 24;
   PINK_RANDOM_SHIFT     = 8; // ((sizeof(long)*8)-PINK_RANDOM_BITS)
   PINK_OUTVALMAX        = 32767;
   PINK_OUTVALMIN        = -32767;

 type
   TPinkNoiseStat = record
     Rows      : array[0..PINK_MAX_RANDOM_ROWS - 1] of longword;
     RunningSum : longint; // Used to optimize summing of generators
     Index     : integer; // Incremented each sample
     IndexMask : integer; // Index wrapped by ANDing with this mask
     rndMax    : DWORD;   // max. value for Random
     IncVal    : boolean; // switch to align the master value to max
     Min       : longint; // min val dependend on rand-generation
     Max       : longint; // max val dependend on rand-generation
     Avg       : longint; // calc average val
     SumMin    : longint; // min val output integer (before level)
     SumMax    : longint; // max val output integer (before level)
     Level     : integer; // 0 to 100 (%) Default: 70
   end;

 type
   TPinkNoise2 = Class
   private
     PNS : TPinkNoiseStat;
     function   GenerateRandomNumber : longint;
   public
     Constructor Create(numRows : integer; level : integer);
     function   GetPinkNoiseVal : longint;
     procedure  SetPinkNoiseLevel(level : integer);
     procedure  GetPinkNoiseStat(var _PNS : TPinkNoiseStat);
   end;

 implementation

 // -----------------------------------------------------------------------------
// Setup PinkNoise structure for N rows of generators.
 // Level is between 0 and 100
 constructor TPinkNoise2.Create(numRows : integer; level : integer);
 var
   i : integer;
 begin
   // Initialize var's
   // Define parameter:
   for i := 0 to numRows - 1 do PNS.Rows[i] := 0; // filled by procedure
   PNS.RunningSum := 0;          // Used to optimize summing of generators
   PNS.Index     := 0;          // Incremented each sample
   PNS.IndexMask := 0;          // Index wrapped by ANDing with this mask
   PNS.rndMax    := 65536 * 16; // max. value for Random (default)
   PNS.IncVal    := true;       // enable auto-increasing out-val (by WarmUp)
   PNS.Min       := 2147483647; // min val dependend on rand-generation
   PNS.Max       := -2147483647; // max val dependend on rand-generation
   PNS.Avg       := -1;         // substract for average zero
   PNS.SumMin    := PNS.Min;    // min val output integer (before level)
   PNS.SumMax    := PNS.Max;    // max val output integer (before level)
   // Initialize:
   if (numrows > PINK_MAX_RANDOM_ROWS) then numrows := PINK_MAX_RANDOM_ROWS; // for safety
   PNS.Index := 0;
   PNS.IndexMask := (1 shl numRows) - 1;
   // Initialize rows.
   for i := 0 to numRows - 1 do PNS.Rows[i] := 0;
   PNS.RunningSum := 0;
   // initialize Random
   Randomize;
   // "WarmUp" to align level: call 1 million values
   // (takes less than a blink of an eye...)
   for i := 1 to 1000000 do GetPinkNoiseVal;
   // Set Outputlevel (either int or float)
   SetPinkNoiseLevel(level);
 end;

 // -----------------------------------------------------------------------------
// Calculate pseudo-random 32 bit number based on linear congruential method.
 function TPinkNoise2.GenerateRandomNumber : longint;
 begin
   result := Random(PNS.rndMax); // randomMax can change during runtime
 end;

 // -----------------------------------------------------------------------------
// Generate Pink noise values between -1.0 and +1.0
 function TPinkNoise2.GetPinkNoiseVal : longint;
 var
   newRandom  : longint;
   sum        : longint;
   OutFloat   : extended;
   OutInt     : longint;
   n, numZeros : integer;
 begin
   // Increment and mask index.
   PNS.Index := (PNS.Index + 1) and PNS.IndexMask;
   // If index is zero, don't update any random values.
   if (PNS.Index <> 0) then
   begin
     // Determine how many trailing zeros in PinkIndex.
     // This algorithm will hang if n==0 so test first.
     numZeros := 0;
     n := PNS.Index;
     while ((n and 1) = 0) do
     begin
       n := n shr 1;
       inc(numZeros);
     end;
     // Replace the indexed ROWS random value.
     // Subtract and add back to RunningSum instead of adding all the random
     // values together. Only one changes each time.
     PNS.RunningSum := PNS.RunningSum - PNS.Rows[numZeros];
     newRandom := GenerateRandomNumber shr PINK_RANDOM_SHIFT;
     PNS.RunningSum := PNS.RunningSum + newRandom;
     PNS.Rows[numZeros] := newRandom;
   end;
   // Add extra white noise value.
   newRandom := GenerateRandomNumber shr PINK_RANDOM_SHIFT;
   sum := PNS.RunningSum + newRandom;

   // Normalize the signal (by TERWI)
   if (sum < PNS.Min) then PNS.Min := sum;
   if (sum > PNS.Max) then PNS.Max := sum;
   PNS.Avg := (PNS.Max - PNS.Min) div 2;
   sum := (sum - PNS.Min) - PNS.Avg;

   // Check maximum Generator-value for 0dB-output and to provide overload
   if (sum < PNS.SumMin) then
   begin
     PNS.SumMin := sum;
     if PNS.SumMin < PINK_OUTVALMIN then // Overload negativ ?
     begin                               // YES !
       Sum := PINK_OUTVALMIN;            // Limit value now
       dec(PNS.rndMax, 300);             // reduce max. value at generation
       PNS.IncVal := false;              // stop increasing val to max
     end;
   end;
   if (sum > PNS.SumMax) then
   begin
     PNS.SumMax := sum;
     if PNS.SumMax > PINK_OUTVALMAX then // Overload positiv ?
     begin                               // YES !
       Sum := PINK_OUTVALMAX;            // Limit value now
       dec(PNS.rndMax, 300);             // reduce max. value at generation
       PNS.IncVal := false;              // stop increasing val to max
     end;
   end;
   if PNS.IncVal then inc(PNS.rndMax, 10); // stepwise increasing max. value by generation

   // Set level after normalization
   OutInt := sum * PNS.Level div 100;
   // Scale to range of -1.0 to 1.
   //OutFloat := 1 / OutInt;                // not in use yet

   result := OutInt;
 end;

 // -----------------------------------------------------------------------------
// Set PinkNoise level: 0 - 100 %
 procedure TPinkNoise2.SetPinkNoiseLevel(level : integer);
 begin
   if (level > 100) then level := 100;
   if (level < 0)  then level := 0;
   PNS.Level := level;
 end;

 // -----------------------------------------------------------------------------
// Get PinkNoise Statistics
 // ! Copy/Move seems not working. So do it in old fashion way ... var2var
 procedure TPinkNoise2.GetPinkNoiseStat(var _PNS : TPinkNoiseStat);
 var
   i : integer;
 begin
   for I := 0 to PINK_MAX_RANDOM_ROWS - 1 do
     _PNS.Rows[i] := PNS.Rows[i];      // depended row values
   _PNS.RunningSum  := PNS.RunningSum; // Used to optimize summing of generators.
   _PNS.Index       := PNS.Index;     // Incremented each sample.
   _PNS.IndexMask   := PNS.IndexMask; // Index wrapped by ANDing with this mask.
   _PNS.rndMax      := PNS.rndMax;    // max. value for Random
   _PNS.IncVal      := PNS.IncVal;    // enable auto-increasing out-val (by WarmUp)
   _PNS.Min         := PNS.Min;       // min val dependend on rand-generation
   _PNS.Max         := PNS.Max;       // max val dependend on rand-generation
   _PNS.Avg         := PNS.Avg;       // substract for average zero
   _PNS.SumMin      := PNS.SumMin;    // min val output integer (before level)
   _PNS.SumMax      := PNS.SumMax;    // max val output integer (before level)
   _PNS.Level       := PNS.Level;     // 0 to 100 (%) Default: 70
 end;

 end.
