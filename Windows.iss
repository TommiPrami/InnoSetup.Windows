// Windows.iss

const
  KB = 1024; // kilobyte
  MB = 1048576; // megabyte
  GB = 1073741824; // gigabyte

type
  { the following mapping of the DWORDLONG data type is wrong; }
  { the correct type is a 64-bit unsigned integer which is not }
  { available in InnoSetup Pascal Script at this time, so max. }
  { values of the following fields will be limited to quite a }
  { big reserve of 8589,934.592 GB of RAM; I hope enough for }
  { the next versions of Windows :-) }
  DWORDLONG = Int64;

  TMemoryStatusEx = record
    dwLength: DWORD;
    dwMemoryLoad: DWORD;
    ullTotalPhys: DWORDLONG;
    ullAvailPhys: DWORDLONG;
    ullTotalPageFile: DWORDLONG;
    ullAvailPageFile: DWORDLONG;
    ullTotalVirtual: DWORDLONG;
    ullAvailVirtual: DWORDLONG;
    ullAvailExtendedVirtual: DWORDLONG;
  end;

// External API declarations

//  - https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-globalmemorystatusex
function GlobalMemoryStatusEx(var lpBuffer: TMemoryStatusEx): BOOL; external 'GlobalMemoryStatusEx@kernel32.dll stdcall';

//  - https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-getcurrentprocess
function GetCurrentProcess(): DWORD; external 'GetCurrentProcess@kernel32.dll stdcall';

//  - https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getprocessaffinitymask
function GetProcessAffinityMask(ACurrentProcess: DWORD; var AProcessAffinityMask, ASystemAffinityMask: DWORD): Boolean; external 'GetProcessAffinityMask@kernel32.dll stdcall';


// Wrapper around the GlobalMemoryStatusEx get available physical memory
function AvailablePhysicalMemory: Int64;
var
  LMemoryStatus: TMemoryStatusEx;
begin
  LMemoryStatus.dwLength := SizeOf(LMemoryStatus);

  if GlobalMemoryStatusEx(LMemoryStatus) then
    Result := LMemoryStatus.ullAvailPhys
  else
    Result := 0;
end;

function MinInt64(const AValue1, AValue2: Int64): Int64;
begin
  if AValue1 <= AValue2 then
    Result := AValue1
  else
     Result := AValue2;
end;

function FormatByteSize(const ABytes: Int64): string;
begin
  if ABytes > GB then
    Result := Format('%.2f', [ABytes / GB]) + ' GB'
  else if ABytes > MB then
    Result := Format('%.2f', [ABytes / MB]) + ' MB'
  else if ABytes > KB then
    Result := Format('%.2f', [ABytes / KB]) + ' KB'
  else
    Result := Format('%d', [ABytes]);
end;



// returns total number of processors available to system including
// logical hyperthreaded processors
function AvailableCoresCount: DWORD;
var
  LIndex: Integer;
  LProcess: THandle;
  LProcessAffinityMask: DWORD;
  LSystemAffinityMask: DWORD;
  LMask: DWORD;
begin
  LProcess := GetCurrentProcess;

  if GetProcessAffinityMask(LProcess, LProcessAffinityMask, LSystemAffinityMask)
  then
  begin
    Result := 0;

    for LIndex := 0 to 31 do
    begin
      LMask := 1 shl LIndex;

      if (LProcessAffinityMask and LMask) <> 0 then
        Result := Result + 1;
    end;
  end
  else
  begin
    // can't get the affinity mask so we just report the total number of
    // processors
    Result := 1;
  end;
end;
