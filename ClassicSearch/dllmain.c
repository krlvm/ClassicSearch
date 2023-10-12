#include "pch.h"
#include <DbgHelp.h>

#pragma comment(lib, "Dbghelp.lib")

/////////////////////////////////////////////////////
#pragma region IAT Hook Injector
// https://github.com/valinet/libvalinet/blob/f0b704fb585aff54692fda6a7d1edcef3fa3e27b/valinet/hooking/iatpatch.h
// https://blog.neteril.org/blog/2016/12/23/diverting-functions-windows-iat-patching/
inline BOOL PatchIAT(HMODULE hMod, PSTR libName, PSTR funcName, uintptr_t hookAddr)
{
    // Increment module reference count to prevent other threads from unloading it while we're working with it
    HMODULE module;
    if (!GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS, hMod, &module)) return FALSE;

    // Get a reference to the import table to locate the kernel32 entry
    ULONG size;
    PIMAGE_IMPORT_DESCRIPTOR importDescriptor = (PIMAGE_IMPORT_DESCRIPTOR)ImageDirectoryEntryToDataEx(module, TRUE, IMAGE_DIRECTORY_ENTRY_IMPORT, &size, NULL);

    // In the import table find the entry that corresponds to kernel32
    BOOL found = FALSE;
    while (importDescriptor->Characteristics && importDescriptor->Name) {
        PSTR importName = (PSTR)((PBYTE)module + importDescriptor->Name);
        if (_stricmp(importName, libName) == 0) {
            found = TRUE;
            break;
        }
        importDescriptor++;
    }
    if (!found) {
        FreeLibrary(module);
        return FALSE;
    }

    // From the kernel32 import descriptor, go over its IAT thunks to
    // find the one used by the rest of the code to call GetProcAddress
    PIMAGE_THUNK_DATA oldthunk = (PIMAGE_THUNK_DATA)((PBYTE)module + importDescriptor->OriginalFirstThunk);
    PIMAGE_THUNK_DATA thunk = (PIMAGE_THUNK_DATA)((PBYTE)module + importDescriptor->FirstThunk);
    while (thunk->u1.Function) {
        PROC* funcStorage = (PROC*)&thunk->u1.Function;

        BOOL bFound = FALSE;
        if (oldthunk->u1.Ordinal & IMAGE_ORDINAL_FLAG)
        {
            bFound = (!(*((WORD*)&(funcName)+1)) && IMAGE_ORDINAL32(oldthunk->u1.Ordinal) == (DWORD)funcName);
        }
        else
        {
            PIMAGE_IMPORT_BY_NAME byName = (PIMAGE_IMPORT_BY_NAME)((uintptr_t)module + oldthunk->u1.AddressOfData);
            bFound = ((*((WORD*)&(funcName)+1)) && !_stricmp((char*)byName->Name, funcName));
        }

        // Found it, now let's patch it
        if (bFound) {
            // Get the memory page where the info is stored
            MEMORY_BASIC_INFORMATION mbi;
            VirtualQuery(funcStorage, &mbi, sizeof(MEMORY_BASIC_INFORMATION));

            // Try to change the page to be writable if it's not already
            if (!VirtualProtect(mbi.BaseAddress, mbi.RegionSize, PAGE_READWRITE, &mbi.Protect)) {
                FreeLibrary(module);
                return FALSE;
            }

            // Store our hook
            *funcStorage = (PROC)hookAddr;

            // Restore the old flag on the page
            DWORD dwOldProtect;
            VirtualProtect(mbi.BaseAddress, mbi.RegionSize, mbi.Protect, &dwOldProtect);

            // Profit
            FreeLibrary(module);
            return TRUE;
        }

        thunk++;
        oldthunk++;
    }

    FreeLibrary(module);
    return FALSE;
}

#pragma endregion
/////////////////////////////////////////////////////

int WINAPI Patch_GetSystemMetricsForDpi(
    int  nIndex,
    UINT dpi
)
{
    if (nIndex == SM_CYFIXEDFRAME) return 0;
    return GetSystemMetricsForDpi(nIndex, dpi);
}

#ifdef _WIN64
#pragma comment(linker, "/export:DllGetClassObject")
#else
#pragma comment(linker, "/export:DllGetClassObject=_DllGetClassObject@12")
#endif
HRESULT WINAPI DllGetClassObject(
    REFCLSID rclsid,
    REFIID   riid,
    LPVOID* ppv
)
{
    HMODULE hExplorerFrame = LoadLibraryEx(L"ExplorerFrame.dll", NULL, LOAD_LIBRARY_SEARCH_SYSTEM32);
    if (!hExplorerFrame)
    {
        return E_HANDLE;
    }
    if (!PatchIAT(hExplorerFrame, "user32.dll", "GetSystemMetricsForDpi", Patch_GetSystemMetricsForDpi))
    {
        return E_FAIL;
    }
    FreeLibrary(hExplorerFrame);
    return S_OK;
}

BOOL APIENTRY DllMain(
    HMODULE hModule,
    DWORD  ul_reason_for_call,
    LPVOID lpReserved
)
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
        DisableThreadLibraryCalls(hModule);
        break;
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}