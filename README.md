# InnoSetup.Windows

Couple Windows API utilities for InnoSetup.

```Delphi
  // Helper Wrapper around GlobalMemoryStatusEx API
  function AvailablePhysicalMemory: Int64;

  // Simple "user friendly" memory/File Size formatting function
  function FormatByteSize(const ABytes: Int64): string;

  // Get CPU Core count, on machine that is not NUMA-monster
  function AvailableCoresCount: DWORD;

  // Helper to get computer name, wrapper around GetComputerNameEx API
  function TryGetComputerName(const AFormat: TComputerNameFormat; var AOutput: string): Boolean;

  // Simple string check unit, I needed for domain check
  function EndsWith(const ASubText, AText: string; const ACaseSensitive: Boolean): Boolean;

  // To check´does current computer domain end with certain text (Casse insensitive)
  function ComputerDomainContains(const ADomainSuffix: string): Boolean;

```
