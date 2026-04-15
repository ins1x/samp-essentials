local module = require("arizona-events.core")

local IO          = module.INTERFACE.BitStream.IO
local INCOMING    = module.INTERFACE.INCOMING
local OUTGOING    = module.INTERFACE.OUTGOING
local INCOMING_EX = module.INTERFACE.INCOMING_EX
local OUTGOING_EX = module.INTERFACE.OUTGOING_EX

INCOMING[0] = {
	"onArizonaSetLocalDriver",
	{ IO.uint8, "seat_code" }, -- код всегда 0x02
	{ IO.bool,  "state" }
}

INCOMING[2] = {
	"onArizonaTurnLightUpdate",
	{ IO.uint16, "vehicle_id" },
	{ IO.uint8, "state" }
}

INCOMING[3] = {
	"onArizonaSetSatiety",
	{ IO.uint8, "satiety" }
}

INCOMING[8] = {
	"onArizonaSetHudMode",
	{ IO.uint8, "mode" }
}

INCOMING[9] = {
	"onArizonaSetRadarMode",
	{ IO.uint8, "mode" }
}

INCOMING[10] = {
	"onArizonaLoadJs", 
	{ IO.byteArray[16], "_unknown" }, 
	{ IO.maybeEncoded,  "js" }, 
	{ IO.maybeEncoded,  "any" },
	{ IO.uint32,        "server_id" }
}

INCOMING[12] = {
	"onArizonaPlayMediaOnBillboard",
	{ IO.int32,         "billboard_id" },
	{ IO.byteArray[12], "_unknown1" },
	{ IO.maybeEncoded,  "link" },
	{ IO.maybeEncoded,  "user_agent" },
	{ IO.byteArray[12], "_unknown2" }
}

INCOMING[16] = {
	"onArizonaLoadHtml",
	{ IO.uint32, "server_id" },
	{ IO.string32,"url" }
}

INCOMING[17] = {
	"onArizonaDisplay",
	{ IO.uint32,       "server_id" },
	{ IO.maybeEncoded, "text"}
}

INCOMING[25] = {
	"onArizonaToggleCursor",
	{ IO.uint32, "_unknown1" },
	{ IO.bool8,  "status" },
	{ IO.uint16, "_unknown2" }
}

INCOMING[27] = {
	"onArizonaSetPlayerUnknownState", 
	{ IO.uint16, "player_id" },
	{ IO.bool,   "_unknown1" },
	{ IO.uint8,  "state" }
}

INCOMING[34] = {
	"onArizonaUiColorScale",
	{ IO.uint16, "server_id" },
	{ IO.uint32, "argb" },
	{ IO.float,  "scale" },
	{ IO.uint16, "_u16a" },
	{ IO.uint16, "_u16b" },
	{ IO.uint8,  "_flags" }
}

INCOMING[36] = {
	"onArizonaSetChatGroup",
	{ IO.uint8,   "chat_id" },
	{ IO.string8, "command" },
	{ IO.int32,   "color" },
	{ IO.string8, "chat_name" }
}

INCOMING[40] = {
    "onArizonaSetLocalInVehicle",
    { IO.uint8, "state" }
}

INCOMING[42] = {
	"onArizonaSetNicknameMode",
	{ IO.uint8, "mode" }
}

-- INCOMING[47] = {
-- 	"onArizona47",
-- 	{ IO.string8, "fx_name" },
-- 	{ IO.byteUnread, "unread" }
-- }

-- INCOMING[48] = {
-- 	"onArizona48",
-- 	{ IO.string8, "fx_name" },
-- 	{ IO.byteUnread, "unread" }
-- }

INCOMING[52] = {
	"onArizonaSwitchChatMode",
	{ IO.uint8, "mode" }
}

INCOMING[64] = {
	"onArizonaSetVisableDistance3DMarker",
	{ IO.bool, "status" },
	{ IO.float, "distance" },
	{ IO.uint8, "_0" }
}

INCOMING[91] = {
    "onArizonaAutoDrinkBeer",
    { IO.bool, "state" }
}

INCOMING[71] = {
	"onArizonaShowPositionInDiscord",
	{ IO.bool8, "status" }
}

INCOMING[108] = {
	"onArizonaSwitchChatState",
	{ IO.uint32, "player_id" },
	{ IO.bool,   "is_open" }
}

INCOMING[110] = {
	"onArizonaUiConfig",
	{ IO.uint8,  "type" },
	{ IO.uint16, "len" }
}

INCOMING[120] = {
	"onArizonaSetPlayerNametagFlags",
	{ IO.uint16,  "player_id" },
	{ IO.bool,    "_unknown1" },
	{
		{
			{ IO.string8, 1 },
			{ IO.string8, 2 },
			{ IO.string8, 3 },
			{ IO.string8, 4 }
		}, "flags"
	}
}

INCOMING[127] = {
	"onArizonaSetMapIcon",
	{ IO.uint8,         "icon_id" },
	{ IO.byteArray[14], "_unknown1" },
	{ IO.uint16,        "icon_model" },
	{ IO.vector3d,      "position" },
	{ IO.string8,       "icon_name" },
	{ IO.uint8,         "_unknown2" }
}

INCOMING[135] = {
    "onArizonaUiScalar",
    { IO.uint16, "server_id" },
    { IO.uint8,  "index" },
    { IO.float,  "value" }
}

INCOMING[139] = {
    "onArizonaSetVehicleColorSmoke",
    { IO.uint16, "vehicle_id" },
    { IO.float,  "intensity" },   -- 0.4 стандарт
    { IO.uint8,  "r" },     
    { IO.uint8,  "g" },       
    { IO.uint8,  "b" }       
}

INCOMING[142] = {
    "onArizonaVehicleColor",
    { IO.uint16, "vehicle_id" },
    { IO.uint8,  "r" },
    { IO.uint8,  "g" },
    { IO.uint8,  "b" },
    { IO.uint8,  "a" }
}

INCOMING[144] = {
    "onArizonaSetSkyboxImages",
    { IO.uint8,  "tag0" }, -- всегда 0x21
    { IO.uint8,  "tag1" }, -- всегда 0x00
    { IO.uint8,  "tag2" }, -- всегда 0x00
    { IO.string, "names" },     -- Подгрузка имен файлов картинок для скайбокса Пример: skyimage_8;skyimage_9;skyimage_12d
    { IO.uint32, "offset1" }, -- адреса в дллке которые юзается для самой установки картинок на скайбокс
    { IO.uint32, "offset2" },
    { IO.uint32, "offset3" },
    { IO.uint32, "offset4" },
    { IO.uint32, "offset5" },
    { IO.uint16, "end" }      -- всегда 0x8020
}

INCOMING[153] = {
	"onArizonaSetVehicleNumberPlate",
	{ IO.uint16, "vehicle_id" },
	{
		{
			{ IO.uint8,        "type" },
			{ IO.string8,      "text" },
			{ IO.stringUnread, "region" }
		},
		"plate"
	}
}

INCOMING[155] = {
	"onArizonaSetPlayerAttachedObject",
	{ IO.uint16, "player_id" },
	{ IO.int32,  "index" },
	{ IO.bool,   "create" },
	{
		{
			{ IO.int32,    "bone" },
			{ IO.int32,    "model_id" },
			{ IO.vector3d, "offset" },
			{ IO.vector3d, "rotation" },
			{ IO.vector3d, "scale" },
			{ IO.int32,    "color1" },
			{ IO.int32,    "color2" }
		}, "object"
	}
}

INCOMING[165] = {
	"onArizonaLoadBinary",
	{ IO.string8, "text" }
}

INCOMING[172] = {
	"onArizonaSetCurrentTask",
	{ IO.uint8,        "_unused" },
	{ IO.string8,      "text" },
	{ IO.stringUnread, "emoji" }
}

INCOMING[174] = {
	"onArizonaToggleDrawInterface",
	{ IO.bool8, "status" }
}

INCOMING[175] = {
	"onArizonaSetInterior",
	{ IO.vector3d, "position" },
	{ IO.uint16, "_500" },
	{ IO.uint8, "interior" },
	{ IO.byteUnread, "_unknown1" }
}

INCOMING[176] = {
	"onArizonaUiToggle",
	{ IO.uint16, "server_id" },
	{ IO.bool,   "state" }
}

INCOMING[180] = {
    "onArizonaVehicleHeadlightsState",
    { IO.uint16, "vehicle_id" },
    { IO.bool,   "state" }
}

INCOMING[183] = {
	"onArizonaSetVirtualWorld",
	{ IO.uint32, "world" }
}

INCOMING[187] = {
	"onArizonaSetVehicleDriftMode",
	{ IO.uint16, "vehicle_id" },
	{ IO.bool8, "state" }
}

-- INCOMING[191] = {
-- 	"onArizona191",
-- 	{ IO.byteUnread, "_data" }
-- }

INCOMING[193] = {
	"onArizonaSetVehicleLights",
	{ IO.uint16, "vehicle_id" },
	{ IO.string8, "light_name" }
}

INCOMING[209] = {
	"onArizonaSetVehicleStrobeligths",
	{ IO.uint16,       "vehicle_id" },
	{ IO.byteArray[6], "_unknown1" }
}

OUTGOING[0] = {
	"onArizonaSendKey",
	{ IO.uint8, "key" },
	{ IO.uint8, "_unknown" }
}

OUTGOING[1] = {
	"onArizonaSendSwitchChatState",
	{ IO.bool, "is_open" }
}

OUTGOING[2] = {
	"onArizonaSendTurnLights",
	{ IO.uint8, "state" } -- 1 = левый поворотник, 2 = правый, 3 = аварийка, 0 = выключены
}

OUTGOING[17] = {
	"onArizonaSendOpenInterface",
	{ IO.uint32, "server_id" },
	{ IO.uint32, "menu_id" }
}

OUTGOING[18] = {
	"onArizonaSend",
	{ IO.string16, "text" },
	{ IO.uint32,   "server_id" }
}

OUTGOING[20] = {
	"onArizonaSendResolution",
	{ IO.uint32, "width" },
	{ IO.uint32, "height" }
}

OUTGOING[24] = {
	"onArizonaSendToggleDrawInterface",
	{ IO.uint32, "server_id" },
	{ IO.bool,   "status" }
}

OUTGOING[38] = {
	"onArizonaSendHash",
	{ IO.string[64], "hash" }
}

OUTGOING[51] = {
	"onArizonaSendSwitchChatMode",
	{ IO.uint8, "mode" }
}

OUTGOING[140] = {
	"onArizonaSendClientJoin",
	{ IO.string16, "text" }
}

OUTGOING[184] = {
	"onArizonaSendWeaponScroll", -- колесико мыши
	{ IO.uint8, "direction" } -- 0 = вверх 1 = вниз
}

INCOMING_EX[50] = {
	"onArizonaBotStreamIn",
	{ IO.uint16,       "bot_id" },
	{ IO.int16,        "model_id" },
	{ IO.vector3d,     "position" },
	{ IO.float,        "rotation" },
	{ IO.bool,         "_padding" },
	{ IO.float,        "health" },
	{ IO.float,        "armour" },
	{ IO.byteArray[3], "_unknown1" },
	{
		{
			{ IO.int32, "color" },
			{ IO.string32, "text" }
		},
		"nametag_1"
	},
	{ IO.byteArray[1],  "_unknown2" },
	{
		{
			{ IO.int32, "color" },
			{ IO.string32, "text" }
		},
		"nametag_2"
	},
	{ IO.byteArray[7],  "_unknown3" }
}

INCOMING_EX[51] = {
	"onArizonaBotStreamOut",
	{ IO.uint16, "bot_id" }
}

INCOMING_EX[52] = {
	"onArizonaBotOnfootSync",
	{ IO.uint16,       "bot_id" },
	{ IO.byteArray[4], "_unknown1" },
	{ IO.bool,         "_padding" },
	{ IO.float,        "health" },
	{ IO.float,        "max_health" },
	{ IO.float,        "armour" },
	{ IO.float,        "max_armour" },
	{ IO.byteArray[1], "_unknown2" }
}

-- 54 onSetBotColor
-- 55 onSetBotFightStyle

INCOMING_EX[56] = {
	"onArizonaSetBotInvulnerable",
	{ IO.uint16, "bot_id" },
	{ IO.bool,   "invulnerable" }
}

INCOMING_EX[57] = {
	"onArizonaSetBotName",
	{ IO.uint16,   "bot_id" },
	{ IO.string32, "name" },
	{ IO.uint8,    "_unused" }
}

-- 64 onSetBotSkin

INCOMING_EX[65] = {
	"onArizonaSetBotWeapon",
	{ IO.uint16, "bot_id" },
	{ IO.uint16, "weapon_id" },
	{ IO.uint8,  "_unknown1" }
}

INCOMING_EX[66] = {
	"onArizonaSetBotPos",
	{ IO.uint16, "bot_id" },
	{ IO.vector3d, "position" }
}

INCOMING_EX[67] = {
	"onArizonaMoveBotToPos",
	{ IO.uint16,       "bot_id" },
	{ IO.vector3d,     "position" },
	{ IO.uint16,       "_unknown1" },
	{ IO.uint32,       "_unknown2" }
}

-- 68 onShootBotAtPos

INCOMING_EX[69] = {
	"onArizonaApplyBotAnimation",
	{ IO.uint16,       "bot_id" },
	{ IO.string32,     "anim_lib" },
	{ IO.string32,     "anim_name" },
	{ IO.byteArray[9], "_unknown" }
}

-- 70 onClearBotAction
-- 72 onShootBotAtPlayer

INCOMING_EX[80] = {
	"onArizonaBotAttackPlayer",
	{ IO.uint16, "bot_id" },
	{ IO.uint16, "player_id" },
	{ IO.uint32, "_unknown" }
}

INCOMING_EX[81] = {
	"onArizonaBotEnterVehicle",
	{ IO.uint16, "bot_id" },
	{ IO.uint16, "vehicle_id" },
	{ IO.int16,  "_unknown1" },
	{ IO.uint32, "_unknown2" },
}

INCOMING_EX[82] = {
	"onArizonaBotPassengerSync",
	{ IO.uint16, "bot_id" },
	{ IO.uint16, "vehicle_id" },
	{ IO.int16,  "seat_id" },
	{ IO.float,  "health" },
	{ IO.float,  "armour" }
}

-- 83 onBotDriveSync

INCOMING_EX[84] = {
	"onArizonaBotExitVehicle",
	{ IO.uint16, "bot_id" }
}

INCOMING_EX[85] = {
	"onArizonaBotChatBubble",
	{ IO.uint16,   "bot_id" },
	{ IO.string32, "text" },
	{ IO.int32,    "color" },
	{ IO.float,    "distance" },
	{ IO.int32,    "duration" }
}

INCOMING_EX[86] = {
	"onArizonaSetBotAttachedObject",
	{ IO.uint16,   "bot_id" },
	{ IO.uint16,   "slot" },
	{ IO.int32,    "model_id" },
	{ IO.int16,    "bone_id" },
	{ IO.vector3d, "offset" },
	{ IO.vector3d, "rotation" },
	{ IO.vector3d, "scale" },
	{ IO.int32,    "color1" },
	{ IO.int32,    "color2" }
}

INCOMING_EX[87] = {
	"onArizonaRemoveAttachedObjectFromBot",
	{ IO.uint16, "bot_id" },
	{ IO.uint16, "slot" }
}

INCOMING_EX[97] = {
    "onArizonaShootBotAtBot",
    { IO.uint16, "shooter_bot_id" },
    { IO.uint16, "target_bot_id" }
}

-- 89 onSetBotAngle
-- 96 onBotStopAllAction
-- 98 onBotSetAnimationGroup
-- 101 onBotAttackPed

INCOMING_EX[102] = {
	"onArizonaDestroyBot",
	{ IO.uint16, "bot_id" },
	{ IO.bool8,  "_unknown1" }
}

INCOMING_EX[103] = {
	"onArizonaSetBotAttachedSimpleObject",
	{ IO.uint16,   "bot_id" },
	{ IO.uint16,   "slot" },
	{ IO.int32,    "model_id" },
	{ IO.int16,    "bone_id" },
	{ IO.vector3d, "offset" },
	{ IO.vector3d, "rotation" },
	{ IO.vector3d, "scale" },
	{ IO.int32,    "color1" },
	{ IO.int32,    "color2" }
}

OUTGOING_EX[53] = {
	"onArizonaSendBotOnfootSync",
	{ IO.uint16,       "bot_id" },
	{ IO.vector3d,     "position" },
	{ IO.byteArray[4], "_unknown1" },
	{ IO.bool,         "_padding" },
	{ IO.float,        "heading" }, -- radian [-math.pi; math.pi]
	{ IO.byteArray[3], "_unknown2" }
}

OUTGOING_EX[73] = {
	"onArizonaSendBotDamage",
	{ IO.bool,   "give_or_take" },
	{ IO.uint16, "bot_id" },
	{ IO.float,  "damage" },
	{ IO.int32,  "weapon" },
	{ IO.int32,  "bodypart" },
	{ IO.uint16, "_unknown" },
	{ IO.uint16, "player_id" }
}

return module