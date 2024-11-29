--[[
    Project: SAMP-API.lua <https://github.com/imring/SAMP-API.lua>
    Developers: imring, LUCHARE, FYP

    Special thanks:
        SAMemory (https://www.blast.hk/threads/20472/) for implementing the basic functions.
        SAMP-API (https://github.com/BlastHackNet/SAMP-API) for the structures and addresses.
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'CRect'

shared.ffi.cdef[[
enum {
    MAX_DEATHMESSAGES = 5,
};

typedef struct SCDeathWindow SCDeathWindow;
#pragma pack(push, 1)
struct SCDeathWindow {
    BOOL m_bEnabled;
    struct {
        char m_szKiller[25];
        char m_szVictim[25];
        D3DCOLOR m_killerColor;
        D3DCOLOR m_victimColor;
        char m_nWeapon;
    } m_entry[5];
    int m_nLongestNickWidth;
    int m_position[2];
    struct ID3DXFont* m_pFont;
    struct ID3DXFont* m_pWeaponFont1;
    struct ID3DXFont* m_pWeaponFont2;
    struct ID3DXSprite* m_pSprite;
    struct IDirect3DDevice9* m_pDevice;
    BOOL m_bAuxFontInitialized;
    struct ID3DXFont* m_pAuxFont1;
    struct ID3DXFont* m_pAuxFont2;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCDeathWindow', 0x157)

local CDeathWindow_constructor = ffi.cast('void(__thiscall*)(SCDeathWindow*, IDirect3DDevice9*)', 0x69EE0)
local CDeathWindow_destructor = ffi.cast('void(__thiscall*)(SCDeathWindow*)', 0x693D0)
local function CDeathWindow_new(...)
    local obj = ffi.gc(ffi.new('struct SCDeathWindow[1]'), CDeathWindow_destructor)
    CDeathWindow_constructor(obj, ...)
    return obj
end

local SCDeathWindow_mt = {
    InitializeAuxFonts = ffi.cast('void(__thiscall*)(SCDeathWindow*)', sampapi.GetAddress(0x69440)),
    PushBack = ffi.cast('void(__thiscall*)(SCDeathWindow*)', sampapi.GetAddress(0x694B0)),
    DrawText = ffi.cast('void(__thiscall*)(SCDeathWindow*, const char*, SCRect, D3DCOLOR, int)', sampapi.GetAddress(0x694D0)),
    DrawWeaponSprite = ffi.cast('void(__thiscall*)(SCDeathWindow*, const char*, SCRect, D3DCOLOR)', sampapi.GetAddress(0x695D0)),
    GetWeaponSpriteRectSize = ffi.cast('void(__thiscall*)(SCDeathWindow*, void*)', sampapi.GetAddress(0x69660)),
    GetWeaponSpriteId = ffi.cast('const char*(__thiscall*)(SCDeathWindow*, char)', sampapi.GetAddress(0x696E0)),
    ResetFonts = ffi.cast('void(__thiscall*)(SCDeathWindow*)', sampapi.GetAddress(0x699E0)),
    Draw = ffi.cast('void(__thiscall*)(SCDeathWindow*)', sampapi.GetAddress(0x69B70)),
    AddEntry = ffi.cast('void(__thiscall*)(SCDeathWindow*, const char*, const char*, D3DCOLOR, D3DCOLOR, char)', sampapi.GetAddress(0x69E60)),
    AddMessage = ffi.cast('void(__thiscall*)(SCDeathWindow*, const char*, const char*, D3DCOLOR, D3DCOLOR, char)', sampapi.GetAddress(0x69F40)),
}
mt.set_handler('struct SCDeathWindow', '__index', SCDeathWindow_mt)

local function RefDeathWindow() return ffi.cast('SCDeathWindow**', sampapi.GetAddress(0x26E8D0))[0] end

return {
    new = CDeathWindow_new,
    RefDeathWindow = RefDeathWindow,
}