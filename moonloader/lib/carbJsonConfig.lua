--[[

	CarboneumJsonConfig Library v.241220
	by Corenale for kekwait.su
	
	used libs:
		• dkjson - http://dkolf.de/dkjson-lua/
		• base64 - https://github.com/iskolbin/lbase64
		• reflect - https://github.com/corsix/ffi-reflect
	
	functionality:
		• save(path, cfg) for rewrite config in folder
		• load(path, cfg) for read config from folder
		• call config() for save it
		• or call like config("reset") for reset to default settings
		• full path like "C:\luaFolder\config\cfg.json"
		• or short path like "config\cfg.json" -- same places
		• can save cdata (a little)
		• saves cdata as table if can (unsupported some unknown weird shit)
		• if cdata can't be saved as table, it saves as base64 string
	
	update log:
		v241227 • fixed creating cdata from json (i'm stupud x2) (thx https://www.blast.hk/members/481726/ for find this)
		v241220 • short path fix for Windows (if you run the script just with "luajit shit.lua", the root folder will be the folder with the executable file) -- bruh pasted from todo
		v241127 • fixed cdata types mismatch problem when loading config x2 (thx https://www.blast.hk/members/125042/)
		v241024 • fixed cdata types mismatch problem when loading config
		v240804 • moved from parseback to reflect
		v240716 • fixed creating new cdata (i'm stupud) (thx https://www.blast.hk/members/481726/ for find this)
		v240709 • fixed script path qualifier
		v240706 • fixed pathFixer for Windows
		v240627 • fixed bugs and added new ones
		v240620 • added universal cdata saving method (saving bytes + base64 bytes packing)
		v240618 • added pathFixer
		v240617 • added main functional
		
	P.S.:
		• i would do autosave, but it won't work for cdata, so...
		• this code looks like a trash, so it's okay, that's my style

	TODO:
		• create folders if they don't exist
		• short path fix for Windows (if you run the script just with "luajit shit.lua", the root folder will be the folder with the executable file) -- completed (maybe)
		• multiconfig (if possible and if needed)
		• save lua functions (if needed)
		• save cdata functions (if possible)

]]

--reflect pls (thx)

local carboneum = {}
local ffi = require("ffi")
ffi.cdef[[
	char *_getcwd(char *buffer, int maxlen);
	char *getcwd(char *buffer, int maxlen);
]]
local json = (function() local v0=false;local v1=false;local v2="json";local v3,v4,v5,v6,v7,v8,v9=pairs,type,tostring,tonumber,getmetatable,setmetatable,rawset;local v10,v11,v12,v13=error,require,pcall,select;local v14,v15=math.floor,math.huge;local v16,v17,v18,v19,v20,v21,v22,v23=string.rep,string.gsub,string.sub,string.byte,string.char,string.find,string.len,string.format;local v24=string.match;local v25=table.concat;local v26={version="dkjson 2.7"};local v27={};if v1 then if v0 then _G[v2]=v27;else _G[v2]=v26;end end local _ENV=nil;v12(function() local v60=v11("debug").getmetatable;if v60 then v7=v60;end end);v26.null=v8({},{__tojson=function() return "null";end});local function v29(v61) local v62,v63,v64=0,0,0;for v229,v230 in v3(v61) do if ((v229=="n") and (v4(v230)=="number")) then v64=v230;if (v230>v62) then v62=v230;end else if ((v4(v229)~="number") or (v229<1) or (v14(v229)~=v229)) then return false;end if (v229>v62) then v62=v229;end v63=v63 + 1 ;end end if ((v62>10) and (v62>v64) and (v62>(v63 * 2))) then return false;end return true,v62;end local v30={['\"']='\\\"',["\\"]="\\\\",["\b"]="\\b",["\f"]="\\f",["\n"]="\\n",["\r"]="\\r",["\t"]="\\t"};local function v31(v65) local v66=v30[v65];if v66 then return v66;end local v67,v68,v69,v70=v19(v65,1,4);v67,v68,v69,v70=v67 or 0 ,v68 or 0 ,v69 or 0 ,v70 or 0 ;if (v67<=127) then v66=v67;elseif ((192<=v67) and (v67<=223) and (v68>=128)) then v66=(((v67-192) * 64) + v68) -128 ;elseif ((224<=v67) and (v67<=239) and (v68>=128) and (v69>=128)) then v66=((((((v67-224) * 64) + v68) -128) * 64) + v69) -128 ;elseif ((240<=v67) and (v67<=247) and (v68>=128) and (v69>=128) and (v70>=128)) then v66=(((((((((v67-240) * 64) + v68) -128) * 64) + v69) -128) * 64) + v70) -128 ;else return "";end if (v66<=65535) then return v23("\\u%.4x",v66);elseif (v66<=1114111) then v66=v66-65536 ;local v298,v299=55296 + v14(v66/1024 ) ,56320 + (v66%1024) ;return v23("\\u%.4x\\u%.4x",v298,v299);else return "";end end local function v32(v71,v72,v73) if v21(v71,v72) then return v17(v71,v72,v73);else return v71;end end local function v33(v74) v74=v32(v74,'[%z\1-\31\"\\\127]',v31);if v21(v74,"[\194\216\220\225\226\239]") then v74=v32(v74,"\194[\128-\159\173]",v31);v74=v32(v74,"\216[\128-\132]",v31);v74=v32(v74,"\220\143",v31);v74=v32(v74,"\225\158[\180\181]",v31);v74=v32(v74,"\226\128[\140-\143\168-\175]",v31);v74=v32(v74,"\226\129[\160-\175]",v31);v74=v32(v74,"\239\187\191",v31);v74=v32(v74,"\239\191[\176-\191]",v31);end return '\"'   .. v74   .. '\"' ;end v26.quotestring=v33;local function v35(v75,v76,v77) local v78,v79=v21(v75,v76,1,true);if v78 then return v18(v75,1,v78-1 )   .. v77   .. v18(v75,v79 + 1 , -1) ;else return v75;end end local v36,v37;local function v38() v36=v24(v5(0.5),"([^05+])");v37="[^0-9%-%+eE"   .. v17(v36,"[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%0")   .. "]+" ;end v38();local function v39(v80) return v35(v32(v5(v80),v37,""),v36,".");end local function v40(v81) local v82=v6(v35(v81,".",v36));if  not v82 then v38();v82=v6(v35(v81,".",v36));end return v82;end local function v41(v83,v84,v85) v84[v85 + 1 ]="\n";v84[v85 + 2 ]=v16("  ",v83);v85=v85 + 2 ;return v85;end v26.addnewline=function(v88) if v88.indent then v88.bufferlen=v41(v88.level or 0 ,v88.buffer,v88.bufferlen or  #v88.buffer );end end;local v43;local function v44(v89,v90,v91,v92,v93,v94,v95,v96,v97,v98) local v99=v4(v89);if ((v99~="string") and (v99~="number")) then return nil,"type '"   .. v99   .. "' is not supported as a key by JSON." ;end if v91 then v95=v95 + 1 ;v94[v95]=",";end if v92 then v95=v41(v93,v94,v95);end v94[v95 + 1 ]=v33(v89);v94[v95 + 2 ]=":";return v43(v90,v92,v93,v94,v95 + 2 ,v96,v97,v98);end local function v45(v102,v103,v104) local v105=v104.bufferlen;if (v4(v102)=="string") then v105=v105 + 1 ;v103[v105]=v102;end return v105;end local function v46(v106,v107,v108,v109,v110,v111) v111=v111 or v106 ;local v112=v108.exception;if  not v112 then return nil,v111;else v108.bufferlen=v110;local v283,v284=v112(v106,v107,v108,v111);if  not v283 then return nil,v284 or v111 ;end return v45(v283,v109,v108);end end v26.encodeexception=function(v113,v114,v115,v116) return v33("<"   .. v116   .. ">" );end;function v43(v117,v118,v119,v120,v121,v122,v123,v124) local v125=v4(v117);local v126=v7(v117);v126=(v4(v126)=="table") and v126 ;local v127=v126 and v126.__tojson ;if v127 then if v122[v117] then return v46("reference cycle",v117,v124,v120,v121);end v122[v117]=true;v124.bufferlen=v121;local v287,v288=v127(v117,v124);if  not v287 then return v46("custom encoder failed",v117,v124,v120,v121,v288);end v122[v117]=nil;v121=v45(v287,v120,v124);elseif (v117==nil) then v121=v121 + 1 ;v120[v121]="null";elseif (v125=="number") then local v306;if ((v117~=v117) or (v117>=v15) or ( -v117>=v15)) then v306="null";else v306=v39(v117);end v121=v121 + 1 ;v120[v121]=v306;elseif (v125=="boolean") then v121=v121 + 1 ;v120[v121]=(v117 and "true") or "false" ;elseif (v125=="string") then v121=v121 + 1 ;v120[v121]=v33(v117);elseif (v125=="table") then if v122[v117] then return v46("reference cycle",v117,v124,v120,v121);end v122[v117]=true;v119=v119 + 1 ;local v316,v317=v29(v117);if ((v317==0) and v126 and (v126.__jsontype=="object")) then v316=false;end local v318;if v316 then v121=v121 + 1 ;v120[v121]="[";for v323=1,v317 do v121,v318=v43(v117[v323],v118,v119,v120,v121,v122,v123,v124);if  not v121 then return nil,v318;end if (v323<v317) then v121=v121 + 1 ;v120[v121]=",";end end v121=v121 + 1 ;v120[v121]="]";else local v320=false;v121=v121 + 1 ;v120[v121]="{";local v322=(v126 and v126.__jsonorder) or v123 ;if v322 then local v324={};v317= #v322;for v326=1,v317 do local v327=v322[v326];local v328=v117[v327];if (v328~=nil) then v324[v327]=true;v121,v318=v44(v327,v328,v320,v118,v119,v120,v121,v122,v123,v124);if  not v121 then return nil,v318;end v320=true;end end for v329,v330 in v3(v117) do if  not v324[v329] then v121,v318=v44(v329,v330,v320,v118,v119,v120,v121,v122,v123,v124);if  not v121 then return nil,v318;end v320=true;end end else for v331,v332 in v3(v117) do v121,v318=v44(v331,v332,v320,v118,v119,v120,v121,v122,v123,v124);if  not v121 then return nil,v318;end v320=true;end end if v118 then v121=v41(v119-1 ,v120,v121);end v121=v121 + 1 ;v120[v121]="}";end v122[v117]=nil;else return v46("unsupported type",v117,v124,v120,v121,"type '"   .. v125   .. "' is not supported by JSON." );end return v121;end v26.encode=function(v128,v129) v129=v129 or {} ;local v130=v129.buffer;local v131=v130 or {} ;v129.buffer=v131;v38();local v133,v134=v43(v128,v129.indent,v129.level or 0 ,v131,v129.bufferlen or 0 ,v129.tables or {} ,v129.keyorder,v129);if  not v133 then v10(v134,2);elseif (v130==v131) then v129.bufferlen=v133;return true;else v129.bufferlen=nil;v129.buffer=nil;return v25(v131);end end;local function v49(v135,v136) local v137,v138,v139=1,1,0;while true do v138=v21(v135,"\n",v138,true);if (v138 and (v138<v136)) then v137=v137 + 1 ;v139=v138;v138=v138 + 1 ;else break;end end return "line "   .. v137   .. ", column "   .. (v136-v139) ;end local function v50(v140,v141,v142) return nil,v22(v140) + 1 ,"unterminated "   .. v141   .. " at "   .. v49(v140,v142) ;end local function v51(v143,v144) while true do v144=v21(v143,"%S",v144);if  not v144 then return nil;end local v231=v18(v143,v144,v144 + 1 );if ((v231=="\239\187") and (v18(v143,v144 + 2 ,v144 + 2 )=="\191")) then v144=v144 + 3 ;elseif (v231=="//") then v144=v21(v143,"[\n\r]",v144 + 2 );if  not v144 then return nil;end elseif (v231=="/*") then v144=v21(v143,"*/",v144 + 2 );if  not v144 then return nil;end v144=v144 + 2 ;else return v144;end end end local v52={['\"']='\"',["\\"]="\\",["/"]="/",b="\b",f="\f",n="\n",r="\r",t="\t"};local function v53(v145) if (v145<0) then return nil;elseif (v145<=127) then return v20(v145);elseif (v145<=2047) then return v20(192 + v14(v145/64 ) ,128 + (v14(v145)%64) );elseif (v145<=65535) then return v20(224 + v14(v145/4096 ) ,128 + (v14(v145/64 )%64) ,128 + (v14(v145)%64) );elseif (v145<=1114111) then return v20(240 + v14(v145/262144 ) ,128 + (v14(v145/4096 )%64) ,128 + (v14(v145/64 )%64) ,128 + (v14(v145)%64) );else return nil;end end local function v54(v146,v147) local v148=v147 + 1 ;local v149,v150={},0;while true do local v232=v21(v146,'[\"\\]',v148);if  not v232 then return v50(v146,"string",v147);end if (v232>v148) then v150=v150 + 1 ;v149[v150]=v18(v146,v148,v232-1 );end if (v18(v146,v232,v232)=='\"') then v148=v232 + 1 ;break;else local v290=v18(v146,v232 + 1 ,v232 + 1 );local v291;if (v290=="u") then v291=v6(v18(v146,v232 + 2 ,v232 + 5 ),16);if v291 then local v310;if ((55296<=v291) and (v291<=56319)) then if (v18(v146,v232 + 6 ,v232 + 7 )=="\\u") then v310=v6(v18(v146,v232 + 8 ,v232 + 11 ),16);if (v310 and (56320<=v310) and (v310<=57343)) then v291=((v291-55296) * 1024) + (v310-56320) + 65536 ;else v310=nil;end end end v291=v291 and v53(v291) ;if v291 then if v310 then v148=v232 + 12 ;else v148=v232 + 6 ;end end end end if  not v291 then v291=v52[v290] or v290 ;v148=v232 + 2 ;end v150=v150 + 1 ;v149[v150]=v291;end end if (v150==1) then return v149[1],v148;elseif (v150>1) then return v25(v149),v148;else return "",v148;end end local v55;local function v56(v151,v152,v153,v154,v155,v156,v157) local v158=v22(v153);local v159,v160={},0;local v161=v154 + 1 ;if (v151=="object") then v8(v159,v156);else v8(v159,v157);end while true do v161=v51(v153,v161);if  not v161 then return v50(v153,v151,v154);end local v233=v18(v153,v161,v161);if (v233==v152) then return v159,v161 + 1 ;end local v234,v235;v234,v161,v235=v55(v153,v161,v155,v156,v157);if v235 then return nil,v161,v235;end v161=v51(v153,v161);if  not v161 then return v50(v153,v151,v154);end v233=v18(v153,v161,v161);if (v233==":") then if (v234==nil) then return nil,v161,"cannot use nil as table index (at "   .. v49(v153,v161)   .. ")" ;end v161=v51(v153,v161 + 1 );if  not v161 then return v50(v153,v151,v154);end local v293;v293,v161,v235=v55(v153,v161,v155,v156,v157);if v235 then return nil,v161,v235;end v159[v234]=v293;v161=v51(v153,v161);if  not v161 then return v50(v153,v151,v154);end v233=v18(v153,v161,v161);else v160=v160 + 1 ;v159[v160]=v234;end if (v233==",") then v161=v161 + 1 ;end end end function v55(v162,v163,v164,v165,v166) v163=v163 or 1 ;v163=v51(v162,v163);if  not v163 then return nil,v22(v162) + 1 ,"no valid JSON value (reached the end)";end local v167=v18(v162,v163,v163);if (v167=="{") then return v56("object","}",v162,v163,v164,v165,v166);elseif (v167=="[") then return v56("array","]",v162,v163,v164,v165,v166);elseif (v167=='\"') then return v54(v162,v163);else local v308,v309=v21(v162,"^%-?[%d%.]+[eE]?[%+%-]?%d*",v163);if v308 then local v312=v40(v18(v162,v308,v309));if v312 then return v312,v309 + 1 ;end end v308,v309=v21(v162,"^%a%w*",v163);if v308 then local v313=v18(v162,v308,v309);if (v313=="true") then return true,v309 + 1 ;elseif (v313=="false") then return false,v309 + 1 ;elseif (v313=="null") then return v164,v309 + 1 ;end end return nil,v163,"no valid JSON value at "   .. v49(v162,v163) ;end end local function v57(...) if (v13("#",...)>0) then return ...;else return {__jsontype="object"},{__jsontype="array"};end end v26.decode=function(v168,v169,v170,...) local v171,v172=v57(...);return v55(v168,v169,v170,v171,v172);end;v26.use_lpeg=function() local v173=v11("lpeg");if ((v4(v173.version)=="function") and (v173.version()=="0.11")) then v10("due to a bug in LPeg 0.11, it cannot be used for JSON matching");end local v174=v173.match;local v175,v176,v177=v173.P,v173.S,v173.R;local function v178(v236,v237,v238,v239) if  not v239.msg then v239.msg=v238   .. " at "   .. v49(v236,v237) ;v239.pos=v237;end return false;end local function v179(v240) return v173.Cmt(v173.Cc(v240) * v173.Carg(2) ,v178);end local function v180(v241,v242,v243,v244) return v178(v241,v242-1 ,"unterminated "   .. v243 ,v244);end local v181=v175("//") * ((1 -v176("\n\r"))^0) ;local v182=v175("/*") * ((1 -v175("*/"))^0) * v175("*/") ;local v183=(v176(" \n\r\t") + v175("\239\187\191") + v181 + v182)^0 ;local function v184(v245) return v173.Cmt(v173.Cc(v245) * v173.Carg(2) ,v180);end local v185=1 -v176('\"\\\n\r') ;local v186=(v175("\\") * v173.C(v176('\"\\/bfnrt') + v179("unsupported escape sequence") ))/v52 ;local v187=v177("09","af","AF");local function v188(v246,v247,v248,v249) v248,v249=v6(v248,16),v6(v249,16);if ((55296<=v248) and (v248<=56319) and (56320<=v249) and (v249<=57343)) then return true,v53(((v248-55296) * 1024) + (v249-56320) + 65536 );else return false;end end local function v189(v250) return v53(v6(v250,16));end local v190=v175("\\u") * v173.C(v187 * v187 * v187 * v187 ) ;local v191=v173.Cmt(v190 * v190 ,v188) + (v190/v189) ;local v192=v191 + v186 + v185 ;local v193=v175('\"') * ((v173.Cs(v192^0 ) * v175('\"')) + v184("string")) ;local v194=(v175("-")^ -1) * (v175("0") + (v177("19") * (v177("09")^0))) ;local v195=v175(".") * (v177("09")^0) ;local v196=(v176("eE")) * ((v176("+-"))^ -1) * (v177("09")^1) ;local v197=(v194 * (v195^ -1) * (v196^ -1))/v40 ;local v198=(v175("true") * v173.Cc(true)) + (v175("false") * v173.Cc(false)) + (v175("null") * v173.Carg(1)) ;local v199=v197 + v193 + v198 ;local v200,v201;local function v202(v251,v252,v253,v254) local v255,v256;local v257=v252;local v258;local v259,v260={},0;repeat v255,v256,v258=v174(v200,v251,v252,v253,v254);if (v256=="end") then return v180(v251,v257,"array",v254);end v252=v258;if ((v256=="cont") or (v256=="last")) then v260=v260 + 1 ;v259[v260]=v255;end until v256~="cont"  return v252,v8(v259,v254.arraymeta);end local function v203(v261,v262,v263,v264) local v265,v266,v267;local v268=v262;local v269;local v270={};repeat v266,v265,v267,v269=v174(v201,v261,v262,v263,v264);if (v267=="end") then return v180(v261,v268,"object",v264);end v262=v269;if ((v267=="cont") or (v267=="last")) then v270[v266]=v265;end until v267~="cont"  return v262,v8(v270,v264.objectmeta);end local v204=v175("[") * v173.Cmt(v173.Carg(1) * v173.Carg(2) ,v202) ;local v205=v175("{") * v173.Cmt(v173.Carg(1) * v173.Carg(2) ,v203) ;local v206=v183 * (v204 + v205 + v199) ;local v207=v206 + (v183 * v179("value expected")) ;local v208=v193 + v179("key expected") ;local v209=v175( -1) * v173.Cc("end") ;local v210=v179("invalid JSON");v200=((v206 * v183 * ((v175(",") * v173.Cc("cont")) + (v175("]") * v173.Cc("last")) + v209 + v210)) + (v173.Cc(nil) * ((v175("]") * v173.Cc("empty")) + v209 + v210))) * v173.Cp() ;local v211=v173.Cg(v183 * v208 * v183 * (v175(":") + v179("colon expected")) * v207 );v201=((v173.Cc(nil) * v173.Cc(nil) * v175("}") * v173.Cc("empty")) + v209 + (v211 * v183 * ((v175(",") * v173.Cc("cont")) + (v175("}") * v173.Cc("last")) + v209 + v210)) + v210) * v173.Cp() ;local v212=v207 * v173.Cp() ;v27.version=v26.version;v27.encode=v26.encode;v27.null=v26.null;v27.quotestring=v26.quotestring;v27.addnewline=v26.addnewline;v27.encodeexception=v26.encodeexception;v27.using_lpeg=true;v27.decode=function(v271,v272,v273,...) local v274={};v274.objectmeta,v274.arraymeta=v57(...);local v277,v278=v174(v212,v271,v272,v273,v274);if v274.msg then return nil,v274.pos,v274.msg;else return v277,v278;end end;v26.use_lpeg=function() return v27;end;v27.use_lpeg=v26.use_lpeg;return v27;end;if v0 then return v26.use_lpeg();end return v26; end)()
local base64 = (function() local v0={};local v1=_G.bit32 and _G.bit32.extract ;if  not v1 then if _G.bit then local v66,v67,v68=_G.bit.lshift,_G.bit.rshift,_G.bit.band;function v1(v75,v76,v77) return v68(v67(v75,v76),v66(1,v77) -1 );end elseif (_G._VERSION=="Lua 5.1") then function v1(v87,v88,v89) local v90=0;local v91=2^v88 ;for v92=0,v89-1  do local v93=v91 + v91 ;if ((v87%v93)>=v91) then v90=v90 + (2^v92) ;end v91=v93;end return v90;end else v1=load([[return function( v, from, width ) return ( v >> from ) & ((1 << width) - 1) end]])();end end v0.makeencoder=function(v10,v11,v12) local v13={};for v35,v36 in pairs({[0]="A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9",v10 or "+" ,v11 or "/" ,v12 or "=" }) do v13[v35]=v36:byte();end return v13;end;v0.makedecoder=function(v14,v15,v16) local v17={};for v38,v39 in pairs(v0.makeencoder(v14,v15,v16)) do v17[v39]=v38;end return v17;end;local v4=v0.makeencoder();local v5=v0.makedecoder();local v6,v7=string.char,table.concat;v0.encode=function(v18,v19,v20) v19=v19 or v4 ;local v21,v22,v23={},1, #v18;local v24=v23%3 ;local v25={};for v41=1,v23-v24 ,3 do local v42,v43,v44=v18:byte(v41,v41 + 2 );local v45=(v42 * 65536) + (v43 * 256) + v44 ;local v46;if v20 then v46=v25[v45];if  not v46 then v46=v6(v19[v1(v45,18,6)],v19[v1(v45,12,6)],v19[v1(v45,6,6)],v19[v1(v45,0,6)]);v25[v45]=v46;end else v46=v6(v19[v1(v45,18,6)],v19[v1(v45,12,6)],v19[v1(v45,6,6)],v19[v1(v45,0,6)]);end v21[v22]=v46;v22=v22 + 1 ;end if (v24==2) then local v55,v56=v18:byte(v23-1 ,v23);local v57=(v55 * 65536) + (v56 * 256) ;v21[v22]=v6(v19[v1(v57,18,6)],v19[v1(v57,12,6)],v19[v1(v57,6,6)],v19[64]);elseif (v24==1) then local v78=v18:byte(v23) * 65536 ;v21[v22]=v6(v19[v1(v78,18,6)],v19[v1(v78,12,6)],v19[64],v19[64]);end return v7(v21);end;v0.decode=function(v26,v27,v28) v27=v27 or v5 ;local v29="[^%w%+%/%=]";if v27 then local v59,v60;for v70,v71 in pairs(v27) do if (v71==62) then v59=v70;elseif (v71==63) then v60=v70;end end v29=("[^%%w%%%s%%%s%%=]"):format(v6(v59),v6(v60));end v26=v26:gsub(v29,"");local v30=v28 and {} ;local v31,v32={},1;local v33= #v26;local v34=((v26:sub( -2)=="==") and 2) or ((v26:sub( -1)=="=") and 1) or 0 ;for v48=1,((v34>0) and (v33-4)) or v33 ,4 do local v49,v50,v51,v52=v26:byte(v48,v48 + 3 );local v53;if v28 then local v72=(v49 * 16777216) + (v50 * 65536) + (v51 * 256) + v52 ;v53=v30[v72];if  not v53 then local v85=(v27[v49] * 262144) + (v27[v50] * 4096) + (v27[v51] * 64) + v27[v52] ;v53=v6(v1(v85,16,8),v1(v85,8,8),v1(v85,0,8));v30[v72]=v53;end else local v74=(v27[v49] * 262144) + (v27[v50] * 4096) + (v27[v51] * 64) + v27[v52] ;v53=v6(v1(v74,16,8),v1(v74,8,8),v1(v74,0,8));end v31[v32]=v53;v32=v32 + 1 ;end if (v34==1) then local v61,v62,v63=v26:byte(v33-3 ,v33-1 );local v64=(v27[v61] * 262144) + (v27[v62] * 4096) + (v27[v63] * 64) ;v31[v32]=v6(v1(v64,16,8),v1(v64,8,8));elseif (v34==2) then local v80,v81=v26:byte(v33-3 ,v33-2 );local v82=(v27[v80] * 262144) + (v27[v81] * 4096) ;v31[v32]=v6(v1(v82,16,8));end return v7(v31);end;return v0; end)()
local reflect = (function() local v0=require("ffi");local v1=require("bit");local v2={};local v3,v4;local v5,v6;local function v7(v27) if (v27~=0) then local v84=v0.cast("uint32_t*",v27);return v0.string(v84 + 4 ,v84[3]);end end local v8=rawget(v0,"typeinfo");v8=v8 or function(v28) local v29=(v3 or v4()).tab[v28];return {info=v29.info,size=(v1.bnot(v29.size)~=0) and v29.size ,sib=(v29.sib~=0) and v29.sib ,name=v7(v29.name)};end ;local function v9(v30) return tonumber(tostring(v30):match("%x*$"),16);end function v4() v0.cdef([[ typedef struct CType { uint32_t info; uint32_t size; uint16_t sib; uint16_t next; uint32_t name; } CType; typedef struct CTState { CType *tab; uint32_t top; uint32_t sizetab; void *L; void *g; void *finalizer; void *miscmap; } CTState; ]]);local v31=coroutine.create(function(v80,...) return v80(...);end);local v32=(v0.abi("gc64") and "uint64_t") or "uint32_t" ;local v33=v0.typeof(v32   .. "*" );local v34=v0.cast(v33,v0.cast(v33,v9(v31))[2]);local v35=v0.cast(v32,v0.cast("const char*","__index"));local v36=0;while math.abs(tonumber(v34[v36] -v35 ))>64  do v36=v36 + 1 ;end local v37,v38=coroutine.resume(v31,function(v81) for v85=v36-3 ,v36-20 , -1 do if (v34[v85]==v81) then return v85;end end end,v9(v31));if (v37 and v38) then for v97=v38 + 2 ,v36-1  do local v98=v34[v97];if ((v98~=0) and (v1.band(v98,3)==0)) then v3=v0.cast("CTState*",v98);if (v0.cast(v33,v3.g)==v34) then return v3;end end end else for v99=v36-1 ,0, -1 do local v100=v34[v99];if ((v100~=0) and (v1.band(v100,3)==0)) then v3=v0.cast("CTState*",v100);if (v0.cast(v33,v3.g)==v34) then return v3;end end end end end function v6() local v39={};v39[0]=v39;local v41=v0.cast("uintptr_t",(v3 or v4()).miscmap);if v0.abi("gc64") then local v86=v0.cast("uint64_t**",v9(v39))[2];v86[0]=v1.bor(v1.lshift(v1.rshift(v86[0],47),47),v41);else local v88=v0.cast("uint32_t*",v9(v39))[2];v0.cast("uint32_t*",v88)[(v0.abi("le") and 0) or 1 ]=v0.cast("uint32_t",v41);end v5=v39[0];return v5;end local v10={[0]={"int","","size",false,{134217728,"bool"},{67108864,"float","subwhat"},{33554432,"const"},{16777216,"volatile"},{8388608,"unsigned"},{4194304,"long"}},{"struct","","size",true,{33554432,"const"},{16777216,"volatile"},{8388608,"union","subwhat"},{1048576,"vla"}},{"ptr","element_type","size",false,{33554432,"const"},{16777216,"volatile"},{8388608,"ref","subwhat"}},{"array","element_type","size",false,{134217728,"vector"},{67108864,"complex"},{33554432,"const"},{16777216,"volatile"},{1048576,"vla"}},{"void","","size",false,{33554432,"const"},{16777216,"volatile"}},{"enum","type","size",true},{"func","return_type","nargs",true,{8388608,"vararg"},{4194304,"sse_reg_params"}},{"typedef","element_type","",false},{"attrib","type","value",true},{"field","type","offset",true},{"bitfield","","offset",true,{134217728,"bool"},{33554432,"const"},{16777216,"volatile"},{8388608,"unsigned"}},{"constant","type","value",true,{33554432,"const"}},{"extern","CID","",true},{"kw","TOK","size"}};local v11={element_type=true,return_type=true,value_type=true,type=true};local v12={};for v42,v43 in ipairs(v10) do local v44=v43[1];local v45={__index={}};v12[v44]=v45;end local v13={[0]=function(v47,v48) error("TODO: CTA_NONE");end,function(v49,v50) error("TODO: CTA_QUAL");end,function(v51,v52) v51=2^v51.value ;v52.alignment=v51;v52.attributes.align=v51;end,function(v55,v56) v56.transparent=true;v56.attributes.subtype=v56.typeid;end,function(v60,v61) v61.sym_name=v60.name;end,function(v64,v65) error("TODO: CTA_BAD");end};local v14={[0]="cdecl","thiscall","fastcall","stdcall"};local function v15(v66) local v67=v8(v66);local v68=v1.rshift(v67.info,28);local v69=v10[v68];local v70=v69[1];local v71=setmetatable({what=v70,typeid=v66,name=v67.name},v12[v70]);for v82=5, #v69 do if (v1.band(v67.info,v69[v82][1])~=0) then if (v69[v82][3]=="subwhat") then v71.what=v69[v82][2];else v71[v69[v82][2]]=true;end end end if (v68<=5) then v71.alignment=v1.lshift(1,v1.band(v1.rshift(v67.info,16),15));elseif (v70=="func") then v71.convention=v14[v1.band(v1.rshift(v67.info,16),3)];end if (v69[2]~="") then local v91=v69[2];local v92=v1.band(v67.info,65535);if v11[v91] then if (v92==0) then v92=nil;else v92=v15(v92);end end v71[v91]=v92;end if (v69[3]~="") then local v94=v69[3];v71[v94]=v67.size or ((v94=="size") and "none") ;end if (v70=="attrib") then local v96=v13[v1.band(v1.rshift(v67.info,16),255)];if v71.type then local v107=v71.type;v107.attributes={};v96(v71,v107);v107.typeid=v71.typeid;v71=v107;else v71.CTA=v96;end elseif (v70=="bitfield") then v71.offset=v71.offset + (v1.band(v67.info,127)/8) ;v71.size=v1.band(v1.rshift(v67.info,8),127)/8 ;v71.type={what="int",bool=v71.bool,const=v71.const,volatile=v71.volatile,unsigned=v71.unsigned,size=v1.band(v1.rshift(v67.info,16),127)};v71.bool,v71.const,v71.volatile,v71.unsigned=nil;end if v69[4] then while v67.sib do local v101=v8(v67.sib);if (v10[v1.rshift(v101.info,28)][1]~="attrib") then break;end if (v1.band(v101.info,65535)~=0) then break;end local v102=v15(v67.sib);v102:CTA(v71);v67=v101;end end return v71;end local function v16(v72,v73) repeat local v83=v8(v73.typeid);if  not v83.sib then return;end v73=v15(v83.sib);until v73.what~="attrib"  return v73;end local function v17(v74) while v74.attributes do v74=v15(v74.attributes.subtype or v8(v74.typeid).sib );end return v16,nil,v74;end v12.struct.__index.members=v17;v12.func.__index.arguments=v17;v12.enum.__index.values=v17;local function v21(v75,v76) local v77=tonumber(v76);if v77 then for v103 in v17(v75) do if (v77==1) then return v103;end v77=v77-1 ;end else for v104 in v17(v75) do if (v104.name==v76) then return v104;end end end end v12.struct.__index.member=v21;v12.func.__index.argument=v21;v12.enum.__index.value=v21;v2.typeof=function(v78) return v15(tonumber(v0.typeof(v78)));end;v2.getmetatable=function(v79) return (v5 or v6())[ -tonumber(v0.typeof(v79))];end;return v2; end)()

local shortPath = ""
do
	local function getCDPath()
		if jit.os == "Windows" then
			local testpath = ffi.new("char[256]")
			ffi.C._getcwd(testpath, 256)
			return ffi.string(testpath)
		else
			local testpath = ffi.new("char[4096]")
			ffi.C.getcwd(testpath, 4096)
			return ffi.string(testpath)
		end
	end
	
	local function getScriptPath()
		local i = 1
		while debug.getinfo(i, "S") do
			-- print(debug.getinfo(i, "S").source)
			i = i + 1
		end
		local ret = debug.getinfo(i-1, "S").source
		return ret ~= "=[C]" and ret or debug.getinfo(i-2, "S").source
	end
	
	local scriptPath = getScriptPath()
	if scriptPath:find("/") or scriptPath:find("\\") then
		shortPath = getScriptPath():sub(2):gsub("(\\)", "/"):match("(.*/)") -- if not full path
	else
		shortPath = getCDPath():gsub("(\\)", "/").."/" -- if not full path
	end
end

local function pathFixer(path)
	-- local debugLevel = 2
	-- local temp = debug.getinfo(1, "S").source
	-- while temp do
		-- if debug.getinfo(debugLevel, "S").source ~= temp then
			-- temp = nil
		-- else
			-- debugLevel = debugLevel + 1
		-- end
	-- end
	-- local debugLevel = debug.getinfo(3) and 3 or 2 -- 3 if required, 2 if minified
	

	
	local pth = path:gsub("(\\)", "/")
	if jit.os == "Windows" and not pth:find("^(%a:/)") then -- on linux everything is fine
		pth = shortPath..pth
	end

	return pth
end

local function cdataparser(cdata, name, parcedcdata, outputtable)
	local multstruct
	if type(cdata) == "cdata" then
		parcedcdata = cdata
		cdata = reflect.typeof(cdata)
		if cdata.element_type then
			multstruct = cdata.size/cdata.element_type.size
		end
	end
	
	local copy = outputtable or {}
	
	if multstruct then
		for i = 0, multstruct-1 do
			copy[i+1] = {}
			cdataparser(cdata.element_type, nil, parcedcdata[i], copy[i+1])
		end
	elseif cdata.attributes or cdata.members then
		for refct in cdata:members() do
			if refct.type then
				if refct.type.what == "array" then
					local count = refct.type.size/refct.type.element_type.size
					local name = refct.name and (name and name.."." or "")..refct.name or name
					if refct.what == "struct" then -- if struct shit[5]
						local refct = refct.type.element_type
						copy[refct.name] = {}
						for i = 0, count-1 do
							copy[refct.name][i+1] = {}
							local name = name.."["..i.."]"
							-- print(4, name)
							cdataparser(refct, name, parcedcdata[refct.name][i], copy[refct.name][i+1])
						end
					else -- if float[5]
						copy[refct.name] = {}
						for i = 0, count-1 do
							copy[refct.name][i+1] = parcedcdata[refct.name][i]
							local name = name.."["..i.."]"
							-- print(3, name)
						end
					end
				elseif refct.type.what == "struct" or refct.type.what == "union" then -- if struct or union
					local name = refct.name and (name and name.."." or "")..refct.name or name
					-- print(6, refct.what, refct.name, refct.type.what, name)
					copy[refct.name] = {}
					cdataparser(refct.type, name, parcedcdata[refct.name], copy[refct.name])
				else -- if just val lol
					copy[refct.name] = parcedcdata[refct.name]
					-- print(2, refct.what, refct.name, refct.type.what, refct.name and (name and name.."." or "")..refct.name or name)
				end
			elseif refct.transparent then -- if unnamed struct or union
				cdataparser(refct, name, parcedcdata, copy)
			end
		end
	end
	
	return copy
	
end

local function preptable2json(orig, copies, isKey)
	    copies = copies or {}
	    local orig_type = type(orig)
	    local copy
	    if orig_type == 'table' then
	        if copies[orig] then
	            copy = copies[orig]
	        else
	            copy = {}
	            copies[orig] = copy
	            for orig_key, orig_value in next, orig, nil do
	                copy[preptable2json(orig_key, copies, true)] = preptable2json(orig_value, copies)
	            end
	        end
	    elseif orig_type == 'cdata' then 

	    	local typeof = tostring(ffi.typeof(orig)):match("^ctype<(.+)>$")

			local function saveAsBytes()
		    	local typeof = tostring(ffi.typeof(orig)):match("^ctype<(.+)>$")
				if typeof:match("(struct %d%d%d%d)") then
					typeof = nil
				end
	
			    local isPointer = typeof:match("(%*)") and true or false
				local orig = isPointer and orig[0] or orig

	
		    	local size = ffi.sizeof(orig)
		    	local str = ffi.string(ffi.cast("void*", orig), size)
	
		    	copy = {orig_type, typeof, base64.encode(str)}
	    	end
	    
	    	if typeof:find("struct") then
				if typeof:match("(struct %d%d%d%d)") then
					print("CarboneumJsonConfig: Saved unnamed cdata struct as bytes: "..typeof)
					saveAsBytes()
				else
					local tbl = cdataparser(orig)
					if tbl then
						copy = {orig_type, typeof, tbl}
					else 
						saveAsBytes()
					end
				end
	    	else
	    		if typeof:match("%[(%d+)%]") then
	    			copy = {orig_type, typeof, {}}
					for i = 0, tonumber(typeof:match("%[(%d+)%]"))-1 do
						copy[3][i+1] = orig[i]
					end
	    		else
					print("CarboneumJsonConfig: Skipped weird cdata value: "..typeof)
	    		end
	    	end

	    
	    
	    	
	    elseif orig_type == 'userdata' or orig_type == "thread" or orig_type == "function" then
	    	-- skip that shit
			print("CarboneumJsonConfig(save): Skipped unsavable variable type: "..orig_type)
	    else
			copy = isKey and orig or {orig_type, orig}
	    end
	    return copy
	end


function carboneum.load(path, table, original)
	
	local original = original or preptable2json(table)
	local mt = {}
	mt.__call = function(self, str)
		if str == "reset" then
			configreset(path, table, original)
		else
			carboneum.save(path, table)
		end
	end
	setmetatable(table, mt)

	local file = io.open(pathFixer(path), "r") -- open json file in read mode
	
	if not file then -- if json doesn't exist
		carboneum.save(path, table)
		return
	end

	local filestr = file:read("*a") -- read json file

	if filestr == "" then -- if json is empty (for some reason)
		carboneum.save(path, table)
		return
	end
	
	local jsonTable = json.decode(filestr)
	file:close()
	
	function table_merge(target, source) 
		for k, v in pairs(source) do
			if type(v) == "table" then
				
				local orig_type
				if type(target) == "table" then
					orig_type = type(target[k])
				else
					print("CarboneumJsonConfig(load): table struct has been changed, ignoring...")
					return
				end
				if (v[1] == nil) or type(v[1]) == "table" then
					target[k] = target[k] or {}
					table_merge(target[k], v)
				elseif v[1] == "cdata" then
					if type(v[3]) == "string" then
						
						if not target[k] then
							if v[2] and not v[2]:match("(%*)") then
								target[k] = ffi.new(v[2])
							else
								if not v[2] then
									print("CarboneumJsonConfig(load): trying load var into unnamed unexisted cdata struct")
								else
									print("CarboneumJsonConfig(load): trying load var into unexisted pointer struct") -- ?
								end
							end
						end
						
						if target[k] then
							local isPointer = v[2]:match("(%*)") and true or false
							
							local bytes = base64.decode(v[3])
							if orig_type == "cdata" and not (ffi.sizeof(isPointer and target[k][0] or target[k]) ~= #bytes) then
								ffi.copy(ffi.cast("void*", isPointer and target[k][0] or target[k]), bytes, #bytes)
							else
								if orig_type == "cdata" then
									print(("CarboneumJsonConfig(load): cdata length size mismatch: j/t | %s/%s"):format(#bytes, ffi.sizeof(target[k])))
								else
									print(("CarboneumJsonConfig(load): data types mismatch: j/t | cdata/%s"):format(orig_type))
								end
								-- need to be config resaved, but fuck it
							end
						end
						
					else
						if orig_type == "cdata" or orig_type == "nil" then
							if target[k] and tostring(ffi.typeof(target[k])):match("^ctype<(.+)>$") == v[2] then
								local temp = ffi.new(v[2]:gsub("(%*)", ""), v[3])
								local str = ffi.string(temp, ffi.sizeof(temp))
								ffi.copy(ffi.cast("void*", target[k]), str, #str)
							else
								if not v[2]:match("(%*)") then
									if not target[k] or tostring(ffi.typeof(target[k])):match("^ctype<(.+)>$") == v[2] then
										target[k] = ffi.new(v[2], v[3])
									else
										print(("CarboneumJsonConfig(load): data types mismatch: j/t | %s/%s"):format(v[2], tostring(ffi.typeof(target[k])):match("^ctype<(.+)>$")))
										-- why we need to do something? (fix for devs bruh)
									end
								else
									print("CarboneumJsonConfig(load): trying load var into unexisted pointer struct")
								end
							end
						else
							print(("CarboneumJsonConfig(load): data types mismatch: j/t | %s/%s"):format(type(v[2]), orig_type))
							-- print(v[2])
						end
						
					end
				else
					if target[k] ~= nil and orig_type ~= type(v[2]) then -- for what
						print(("CarboneumJsonConfig(load): data types mismatch: j/t | %s/%s"):format(type(v[2]), orig_type))
					else
						target[k] = v[2]
					end
				end
			else
				print("CarboneumJsonConfig(load): weird shit happens..")
				--target[k] = v -- if happens then user is stupid as piece of shit, or me (not me)
			end
		end
	end

	table_merge(table, jsonTable)
	
end

function carboneum.save(path, table)
	-- print(pathFixer(path))
	local file = io.open(pathFixer(path), "w")
	
	local good = preptable2json(table)
	file:write(json.encode(good, {indent = true}))
	file:flush()
	file:close()
end

function configreset(path, table, original)
	local file = io.open(pathFixer(path), "w")
	
	file:write(json.encode(original, {indent = true}))
	file:flush()
	file:close()
	
	carboneum.load(path, table, original)
end

return carboneum
