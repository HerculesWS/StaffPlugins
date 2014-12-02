" Vim syntax file
" Language:    Hercules/*Athena Script
" Maintainer:  Haru <haru@dotalux.com>
" Last Change: 2013-12-11


" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif


" Allowed characters in a keyword
setlocal iskeyword=@,',_,a-z,A-Z,48-57

syn match	hVariable	display "\<\%(\|\.\|\.@\|@\|\$\|'\|##\?\)\I\i*$\?\>"

syn keyword	hKeyword	break continue
" FIXME hKeyword function
syn keyword	hConditional	if else switch
syn keyword	hRepeat		do for while

syn keyword	hTodo		contained TODO FIXME XXX

" hCommentGroup allows adding matches for special things in comments
syn cluster	hCommentGroup	contains=hTodo

" String constants
" Escaped double quotes
syn match	hStringSpecial	display contained "\\\"\|\\\\"
" Color constants
syn match	hColor		display contained "\^[0-9a-fA-F]\{6\}"
" Event names
syn match	hNpcEvent	display contained "[a-zA-Z][a-zA-Z0-9 _#-]\+::On[A-Z][A-Za-z0-9_-]\+"
syn region	hString		start=+"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=hColor,hNpcEvent,hStringSpecial,@Spell

"when wanted, highlight trailing white space -- FIXME
"if exists("c_space_errors")
"  if !exists("c_no_trail_space_error")
    syn match	hSpaceError	display excludenl "\s\+$"
"  endif
"  if !exists("c_no_tab_space_error")
    syn match	hSpaceError	display " \+\t"me=e-1
"  endif
"endif

" This should be before cErrInParen to avoid problems with #define ({ xxx })
if exists("c_curly_error")
  syntax match hCurlyError	"}"
  syntax region hBlock		start="{" end="}" contains=ALLBUT,hCurlyError,@hParenGroup,hErrInParen,hErrInBracket,hString,@hTopLevel,@Spell fold
else
  syntax region	hBlock		start="{" end="}" contains=TOP,@hTopLevel transparent fold
endif

"catch errors caused by wrong parenthesis and brackets
syn cluster	hParenGroup	contains=hParenError,hNpcEvent,hCommentSkip,hCommentString,hComment2String,@hCommentGroup,hCommentStartError,hUserCont,hUserLabel,hNumber,hNumbersCom
if exists("c_no_curly_error")
"  syn region	hParen		transparent start='(' end=')' contains=ALLBUT,@hParenGroup,hString,@Spell
  syn region	hParen		transparent start='(' end=')' contains=ALLBUT,@hParenGroup,@Spell,@hTopLevel
  syn match	hParenError	display ")"
  syn match	hErrInParen	display contained "^[{}]"
elseif exists("c_no_bracket_error")
"  syn region	hParen		transparent start='(' end=')' contains=ALLBUT,@hParenGroup,hString,@Spell
  syn region	hParen		transparent start='(' end=')' contains=ALLBUT,@hParenGroup,@Spell,@hTopLevel
  syn match	hParenError	display ")"
  syn match	hErrInParen	display contained "[{}]"
else
"  syn region	hParen		transparent start='(' end=')' contains=ALLBUT,@hParenGroup,hErrInBracket,hString,@Spell
  syn region	hParen		transparent start='(' end=')' contains=ALLBUT,@hParenGroup,hErrInBracket,@Spell,@hTopLevel
  syn match	hParenError	display "[\])]"
  syn match	hErrInParen	display contained "[\]{}]"
"  syn region	hBracket	transparent start='\[' end=']' contains=ALLBUT,@hParenGroup,hErrInParen,hString,@Spell
  syn region	hBracket	transparent start='\[' end=']' contains=ALLBUT,@hParenGroup,hErrInParen,@Spell,@hTopLevel
  syn match	hErrInBracket	display contained "[);{}]"
endif

"integer number.
syn case ignore
syn match	hNumbers	display transparent "\<\d" contains=hNumber
syn match	hNumbersCom	display contained transparent "\<\d" contains=hNumber
syn match	hNumber		display contained "\d\+\>"
"hex number
syn match	hNumber		display contained "0x\x\+\>"

syn case match

syntax match	hTopError	excludenl ".\+" contained
syntax match	hTopName	excludenl "[^\t#:]*\%(#[^\t:]*\)\?\%(::[^\t]*\)\?\t"me=e-1 contained

syntax match	hTopShopData	excludenl "\%(,[0-9]\+:\%(-1\|[0-9]\+\)\)*" contains=hNumber
syntax match	hTopMobData	excludenl "[0-9]\+,[0-9]\+\%(,[0-9]\+\%(,[0-9]\+\%(,[^,]\+\%(,[0-9]\+\)\{,2}\)\)\)\?" contains=hNpcEvent,hNumber
syntax match	hTopWDest	excludenl "[0-9]\+,[0-9]\+,[a-zA-Z0-9@_-]\+,[0-9]\+,[0-9]\+" contains=hMapName,hNumber
syntax match	hTopFSprite	excludenl "-1," contained contains=hNumber nextgroup=hBlock
syntax match	hTopSprite	excludenl "[^,]\+\%(,[0-9]\+,[0-9]\+\)\?," contained contains=hNumber,hConstant nextgroup=hBlock
syntax match	hTopSSprite	excludenl "[^,]\+\%(,[0-9]\+,[0-9]\+\)\?" contained contains=hNumber,hConstant nextgroup=hTopShopData,hTopError
syntax match	hTopDSprite	excludenl "[^,]\+\%(,[0-9]\+,[0-9]\+\)\?$" contained contains=hNumber,hConstant

syntax match	hTopNameFunc	excludenl "[^\t]*\t" transparent contained contains=hTopName nextgroup=hBlock
syntax match	hTopNameShop	excludenl "[^\t]*\t" transparent contained contains=hTopName nextgroup=hTopSSprite,hTopError
syntax match	hTopNameScript	excludenl "[^\t]*\t" transparent contained contains=hTopName nextgroup=hTopSprite,hTopFSprite,hTopError
syntax match	hTopNameDup	excludenl "[^\t]*\t" transparent contained contains=hTopName nextgroup=hTopDSprite,hTopError
syntax match	hTopNameWarp	excludenl "[^\t]*\t" transparent contained contains=hTopName nextgroup=hTopWDest,hTopError
syntax match	hTopNameMob	excludenl "[^,\t]*\%(,[0-9]\+\)\?\t" transparent contained contains=hTopName nextgroup=hTopMobData,hTopError
syntax match	hDupName	excludenl "duplicate([^)]*)"me=e-1,ms=s+10 contained

syntax match	hTopMapflag	excludenl "nosave\t\%(off\|SavePoint\|[a-zA-Z0-9@_-]\+,[0-9]\+,[0-9]\+\)" contained contains=hMapName,hNumber
syntax match	hTopMapflag	excludenl "pvp_nightmaredrop\t\%(off\|\%(random\|inventory\|equip\|all\),[^,]\+,[0-9]\+\)" contained contains=hMapName,hNumber
syntax match	hTopMapflag	excludenl "\%(nocommand\|battleground\|invincible_time_inc\|\%(weapon\|magic\|misc\|short\|long\)_damage_rate\)\%(\|\toff\|\t[0-9]\+\)" contained contains=hNumber
syntax match	hTopMapflag	excludenl "\%(autotrade\|allowks\|town\|monster_noteleport\|no\%(memo\|teleport\|warp\%(to\)\?\|return\|branch\|\%(\|zeny\|exp\)penalty\|trade\|vending\|drop\|skill\|icewall\|\%(\|base\|job\)exp\|\%(\|mob\|mvp\)loot\|command\|chat\|tomb\|mapchannelautojoin\|knockback\|cashshop\)\|pvp\%(\|_noparty\|_noguild\|_nocalcrank\)\|gvg\%(\|_noparty\|_dungeon\|_castle\)\|snow\|clouds2\?\|fog\|fireworks\|sakura\|leaves\|nightenabled\|[bj]exp\|loadevent\|\%(party\|guild\)lock\|reset\|src4instance\)\%(\toff\)\?" contained
syntax match	hTopMapflag	excludenl "adjust_\%(unit_duration\|skill_damage\)\t.*" contained
syntax match	hTopMapflag	excludenl "zone\t.*" contained
" TODO: adjust_unit_duration, adjust_skill_damage

syntax match	hTopTypeM	excludenl "\%(\|boss_\)monster\t" contained nextgroup=hTopNameMob,hTopError
syntax match	hTopTypeW	excludenl "warp\t" contained nextgroup=hTopNameWarp,hTopError
syntax match	hTopTypeS	excludenl "script\t" contained nextgroup=hTopNameScript,hTopError
syntax match	hTopTypeS	excludenl "\%(\|cash\)shop\t" contained nextgroup=hTopNameShop,hTopError
syntax match	hTopTypeMF	excludenl "mapflag\t" contained nextgroup=hTopMapflag,hTopError
syntax match	hTopType	excludenl "duplicate([^)\t]*)\t"he=e-1 contains=hDupName contained nextgroup=hTopNameDup,hTopError

syntax match	hTopLocation	excludenl "^[a-zA-Z0-9@_-]\+,[0-9]\+,[0-9]\+\%(,[0-9]\+\)\{,2}\t" contains=hMapName,hNumber nextgroup=hTopTypeM,hTopError
syntax match	hTopLocation	excludenl "^[a-zA-Z0-9@_-]\+,[0-9]\+,[0-9]\+\t" contains=hMapName,hNumber nextgroup=hTopTypeW,hTopError
syntax match	hTopLocation	excludenl "^[a-zA-Z0-9@_-]\+,[0-9]\+,[0-9]\+,[0-9]\+\t" contains=hMapName,hNumber nextgroup=hTopType,hTopTypeS,hTopTypeW,hTopError
syntax match	hTopLocation	excludenl "^[a-zA-Z0-9@_-]\+\t" contains=hMapName nextgroup=hTopTypeMF,hTopError
syntax match	hTopLocation	excludenl "^-\t" contains=hKeyword nextgroup=hTopTypeS,hTopError
syntax match	hTopLocation	excludenl "^function\tscript\t" contains=hKeyword nextgroup=hTopNameFunc,hTopError
syn cluster hTopLevel contains=hTopLocation,@hTopKeywordG,hDupName,hTopNameShop,hTopNameDup,hTopNameScript,hTopNameFunc,hTopNameMob,hTopNameWarp,hTopFSprite,hTopName,hTopSprite,hTopDSprite,hTopSSprite,hTopWDest,hTopError,hTopMobData,hTopShopData,hTopMapflag
syn cluster hTopKeywordG contains=hTopType,hTopTypeW,hTopTypeS,hTopTypeM,hTopTypeMF

syn case match
syn keyword	hConstant	null


" Constants (imported from db/const.txt)
syn keyword hConstant Job_Novice Job_Swordman Job_Mage Job_Archer Job_Acolyte Job_Merchant Job_Thief Job_Knight
syn keyword hConstant Job_Priest Job_Wizard Job_Blacksmith Job_Hunter Job_Assassin Job_Knight2 Job_Crusader Job_Monk
syn keyword hConstant Job_Sage Job_Rogue Job_Alchem Job_Alchemist Job_Bard Job_Dancer Job_Crusader2 Job_Wedding
syn keyword hConstant Job_SuperNovice Job_Gunslinger Job_Ninja Job_Xmas Job_Summer Job_Novice_High Job_Swordman_High
syn keyword hConstant Job_Mage_High Job_Archer_High Job_Acolyte_High Job_Merchant_High Job_Thief_High Job_Lord_Knight
syn keyword hConstant Job_High_Priest Job_High_Wizard Job_Whitesmith Job_Sniper Job_Assassin_Cross Job_Lord_Knight2
syn keyword hConstant Job_Paladin Job_Champion Job_Professor Job_Stalker Job_Creator Job_Clown Job_Gypsy Job_Paladin2
syn keyword hConstant Job_Baby Job_Baby_Swordman Job_Baby_Mage Job_Baby_Archer Job_Baby_Acolyte Job_Baby_Merchant
syn keyword hConstant Job_Baby_Thief Job_Baby_Knight Job_Baby_Priest Job_Baby_Wizard Job_Baby_Blacksmith
syn keyword hConstant Job_Baby_Hunter Job_Baby_Assassin Job_Baby_Knight2 Job_Baby_Crusader Job_Baby_Monk Job_Baby_Sage
syn keyword hConstant Job_Baby_Rogue Job_Baby_Alchem Job_Baby_Alchemist Job_Baby_Bard Job_Baby_Dancer
syn keyword hConstant Job_Baby_Crusader2 Job_Super_Baby Job_Taekwon Job_Star_Gladiator Job_Star_Gladiator2
syn keyword hConstant Job_Soul_Linker Job_Gangsi Job_Death_Knight Job_Dark_Collector Job_Rune_Knight Job_Warlock
syn keyword hConstant Job_Ranger Job_Arch_Bishop Job_Mechanic Job_Guillotine_Cross Job_Rune_Knight_T Job_Warlock_T
syn keyword hConstant Job_Ranger_T Job_Arch_Bishop_T Job_Mechanic_T Job_Guillotine_Cross_T Job_Royal_Guard Job_Sorcerer
syn keyword hConstant Job_Minstrel Job_Wanderer Job_Sura Job_Genetic Job_Shadow_Chaser Job_Royal_Guard_T Job_Sorcerer_T
syn keyword hConstant Job_Minstrel_T Job_Wanderer_T Job_Sura_T Job_Genetic_T Job_Shadow_Chaser_T Job_Rune_Knight2
syn keyword hConstant Job_Rune_Knight_T2 Job_Royal_Guard2 Job_Royal_Guard_T2 Job_Ranger2 Job_Ranger_T2 Job_Mechanic2
syn keyword hConstant Job_Mechanic_T2 Job_Baby_Rune Job_Baby_Warlock Job_Baby_Ranger Job_Baby_Bishop Job_Baby_Mechanic
syn keyword hConstant Job_Baby_Cross Job_Baby_Guard Job_Baby_Sorcerer Job_Baby_Minstrel Job_Baby_Wanderer Job_Baby_Sura
syn keyword hConstant Job_Baby_Genetic Job_Baby_Chaser Job_Baby_Rune2 Job_Baby_Guard2 Job_Baby_Ranger2
syn keyword hConstant Job_Baby_Mechanic2 Job_Super_Novice_E Job_Super_Baby_E Job_Kagerou Job_Oboro Job_Rebellion
syn keyword hConstant EAJL_2_1 EAJL_2_2 EAJL_2 EAJL_UPPER EAJL_BABY EAJL_THIRD
syn keyword hConstant EAJ_BASEMASK EAJ_UPPERMASK EAJ_THIRDMASK EAJ_NOVICE EAJ_SWORDMAN EAJ_MAGE EAJ_ARCHER EAJ_ACOLYTE
syn keyword hConstant EAJ_MERCHANT EAJ_THIEF EAJ_TAEKWON EAJ_GUNSLINGER EAJ_NINJA EAJ_GANGSI EAJ_SUPER_NOVICE
syn keyword hConstant EAJ_KNIGHT EAJ_WIZARD EAJ_HUNTER EAJ_PRIEST EAJ_BLACKSMITH EAJ_ASSASSIN EAJ_STAR_GLADIATOR
syn keyword hConstant EAJ_REBELLION EAJ_KAGEROUOBORO EAJ_DEATH_KNIGHT EAJ_CRUSADER EAJ_SAGE EAJ_BARDDANCER EAJ_MONK
syn keyword hConstant EAJ_ALCHEMIST EAJ_ROGUE EAJ_SOUL_LINKER EAJ_DARK_COLLECTOR EAJ_NOVICE_HIGH EAJ_SWORDMAN_HIGH
syn keyword hConstant EAJ_MAGE_HIGH EAJ_ARCHER_HIGH EAJ_ACOLYTE_HIGH EAJ_MERCHANT_HIGH EAJ_THIEF_HIGH EAJ_LORD_KNIGHT
syn keyword hConstant EAJ_HIGH_WIZARD EAJ_SNIPER EAJ_HIGH_PRIEST EAJ_WHITESMITH EAJ_ASSASSIN_CROSS EAJ_PALADIN
syn keyword hConstant EAJ_PROFESSOR EAJ_CLOWNGYPSY EAJ_CHAMPION EAJ_CREATOR EAJ_STALKER EAJ_BABY EAJ_BABY_SWORDMAN
syn keyword hConstant EAJ_BABY_MAGE EAJ_BABY_ARCHER EAJ_BABY_ACOLYTE EAJ_BABY_MERCHANT EAJ_BABY_THIEF EAJ_SUPER_BABY
syn keyword hConstant EAJ_BABY_KNIGHT EAJ_BABY_WIZARD EAJ_BABY_HUNTER EAJ_BABY_PRIEST EAJ_BABY_BLACKSMITH
syn keyword hConstant EAJ_BABY_ASSASSIN EAJ_BABY_CRUSADER EAJ_BABY_SAGE EAJ_BABY_BARDDANCER EAJ_BABY_MONK
syn keyword hConstant EAJ_BABY_ALCHEMIST EAJ_BABY_ROGUE EAJ_SUPER_NOVICE_E EAJ_RUNE_KNIGHT EAJ_WARLOCK EAJ_RANGER
syn keyword hConstant EAJ_ARCH_BISHOP EAJ_MECHANIC EAJ_GUILLOTINE_CROSS EAJ_ROYAL_GUARD EAJ_SORCERER
syn keyword hConstant EAJ_MINSTRELWANDERER EAJ_SURA EAJ_GENETIC EAJ_SHADOW_CHASER EAJ_RUNE_KNIGHT_T EAJ_WARLOCK_T
syn keyword hConstant EAJ_RANGER_T EAJ_ARCH_BISHOP_T EAJ_MECHANIC_T EAJ_GUILLOTINE_CROSS_T EAJ_ROYAL_GUARD_T
syn keyword hConstant EAJ_SORCERER_T EAJ_MINSTRELWANDERER_T EAJ_SURA_T EAJ_GENETIC_T EAJ_SHADOW_CHASER_T
syn keyword hConstant EAJ_SUPER_BABY_E EAJ_BABY_RUNE EAJ_BABY_WARLOCK EAJ_BABY_RANGER EAJ_BABY_BISHOP EAJ_BABY_MECHANIC
syn keyword hConstant EAJ_BABY_CROSS EAJ_BABY_GUARD EAJ_BABY_SORCERER EAJ_BABY_MINSTRELWANDERER EAJ_BABY_SURA
syn keyword hConstant EAJ_BABY_GENETIC EAJ_BABY_CHASER
syn keyword hConstant Option_Wedding Option_Xmas Option_Summer Option_Wug Option_Wugrider
syn keyword hConstant bc_all bc_map bc_area bc_self bc_pc bc_npc bc_yellow bc_blue bc_woe
syn keyword hConstant mf_nomemo mf_noteleport mf_nosave mf_nobranch mf_nopenalty mf_nozenypenalty mf_pvp mf_pvp_noparty
syn keyword hConstant mf_pvp_noguild mf_gvg mf_gvg_noparty mf_notrade mf_noskill mf_nowarp mf_partylock mf_noicewall
syn keyword hConstant mf_snow mf_fog mf_sakura mf_leaves mf_clouds mf_clouds2 mf_fireworks mf_gvg_castle mf_gvg_dungeon
syn keyword hConstant mf_nightenabled mf_nobaseexp mf_nojobexp mf_nomobloot mf_nomvploot mf_noreturn mf_nowarpto
syn keyword hConstant mf_nightmaredrop mf_zone mf_nocommand mf_nodrop mf_jexp mf_bexp mf_novending mf_loadevent
syn keyword hConstant mf_nochat mf_noexppenalty mf_guildlock mf_town mf_autotrade mf_allowks mf_monster_noteleport
syn keyword hConstant mf_pvp_nocalcrank mf_battleground mf_reset mf_notomb mf_nocashshop
syn keyword hConstant cell_walkable cell_shootable cell_water cell_npc cell_basilica cell_landprotector cell_novending
syn keyword hConstant cell_nochat cell_chkwall cell_chkwater cell_chkcliff cell_chkpass cell_chkreach cell_chknopass
syn keyword hConstant cell_chknoreach cell_chknpc cell_chkbasilica cell_chklandprotector cell_chknovending
syn keyword hConstant cell_chknochat
syn keyword hParam StatusPoint BaseLevel SkillPoint Class Upper Zeny Sex Weight MaxWeight JobLevel BaseExp JobExp Karma
syn keyword hParam Manner NextBaseExp NextJobExp Hp MaxHp Sp MaxSp BaseJob BaseClass killerrid killedrid SlotChange
syn keyword hParam CharRename ModExp ModDrop ModDeath
syn keyword hConstant bMaxHP bMaxSP bStr bAgi bVit bInt bDex bLuk bAtk bAtk2 bDef bDef2 bMdef bMdef2 bHit bFlee bFlee2
syn keyword hConstant bCritical bAspd bFame bUnbreakable bAtkRange bAtkEle bDefEle bCastrate bMaxHPrate bMaxSPrate
syn keyword hConstant bUseSPrate bAddEle bAddRace bAddSize bSubEle bSubRace bAddEff bResEff bBaseAtk bAspdRate
syn keyword hConstant bHPrecovRate bSPrecovRate bSpeedRate bCriticalDef bNearAtkDef bLongAtkDef bDoubleRate
syn keyword hConstant bDoubleAddRate bSkillHeal bMatkRate bIgnoreDefEle bIgnoreDefRace bAtkRate bSpeedAddRate
syn keyword hConstant bSPRegenRate bMagicAtkDef bMiscAtkDef bIgnoreMdefEle bIgnoreMdefRace bMagicAddEle bMagicAddRace
syn keyword hConstant bMagicAddSize bPerfectHitRate bPerfectHitAddRate bCriticalRate bGetZenyNum bAddGetZenyNum
syn keyword hConstant bAddDamageClass bAddMagicDamageClass bAddDefClass bAddMdefClass bAddMonsterDropItem
syn keyword hConstant bDefRatioAtkEle bDefRatioAtkRace bUnbreakableGarment bHitRate bFleeRate bFlee2Rate bDefRate
syn keyword hConstant bDef2Rate bMdefRate bMdef2Rate bSplashRange bSplashAddRange bAutoSpell bHPDrainRate bSPDrainRate
syn keyword hConstant bShortWeaponDamageReturn bLongWeaponDamageReturn bWeaponComaEle bWeaponComaRace bAddEff2
syn keyword hConstant bBreakWeaponRate bBreakArmorRate bAddStealRate bMagicDamageReturn bAllStats bAgiVit bAgiDexStr
syn keyword hConstant bPerfectHide bNoKnockback bClassChange bHPDrainValue bSPDrainValue bWeaponAtk bWeaponAtkRate
syn keyword hConstant bDelayrate bHPDrainRateRace bSPDrainRateRace bIgnoreMdefRate bIgnoreDefRate bSkillHeal2
syn keyword hConstant bAddEffOnSkill bHealPower bHealPower2 bRestartFullRecover bNoCastCancel bNoSizeFix bNoMagicDamage
syn keyword hConstant bNoWeaponDamage bNoGemStone bNoCastCancel2 bNoMiscDamage bUnbreakableWeapon bUnbreakableArmor
syn keyword hConstant bUnbreakableHelm bUnbreakableShield bLongAtkRate bCritAtkRate bCriticalAddRace bNoRegen
syn keyword hConstant bAddEffWhenHit bAutoSpellWhenHit bSkillAtk bUnstripable bAutoSpellOnSkill bSPGainValue
syn keyword hConstant bHPRegenRate bHPLossRate bAddRace2 bHPGainValue bSubSize bHPDrainValueRace bAddItemHealRate
syn keyword hConstant bSPDrainValueRace bExpAddRace bSPGainRace bSubRace2 bUnbreakableShoes bUnstripableWeapon
syn keyword hConstant bUnstripableArmor bUnstripableHelm bUnstripableShield bIntravision bAddMonsterDropChainItem
syn keyword hConstant bSPLossRate bAddSkillBlow bSPVanishRate bMagicSPGainValue bMagicHPGainValue bAddClassDropItem
syn keyword hConstant bMatk bSPGainRaceAttack bHPGainRaceAttack bSkillUseSPrate bSkillCooldown bSkillFixedCast
syn keyword hConstant bSkillVariableCast bFixedCastrate bVariableCastrate bSkillUseSP bMagicAtkEle bFixedCast
syn keyword hConstant bVariableCast
syn keyword hConstant EQI_HEAD_TOP EQI_ARMOR EQI_HAND_L EQI_HAND_R EQI_GARMENT EQI_SHOES EQI_ACC_L EQI_ACC_R
syn keyword hConstant EQI_HEAD_MID EQI_HEAD_LOW EQI_COSTUME_HEAD_LOW EQI_COSTUME_HEAD_MID EQI_COSTUME_HEAD_TOP
syn keyword hConstant EQI_COSTUME_GARMENT EQI_SHADOW_ARMOR EQI_SHADOW_WEAPON EQI_SHADOW_SHIELD EQI_SHADOW_SHOES
syn keyword hConstant EQI_SHADOW_ACC_R EQI_SHADOW_ACC_L
syn keyword hConstant LOOK_BASE LOOK_HAIR LOOK_WEAPON LOOK_HEAD_BOTTOM LOOK_HEAD_TOP LOOK_HEAD_MID LOOK_HAIR_COLOR
syn keyword hConstant LOOK_CLOTHES_COLOR LOOK_SHIELD LOOK_SHOES LOOK_BODY LOOK_FLOOR LOOK_ROBE
syn keyword hConstant Eff_Stone Eff_Freeze Eff_Stun Eff_Sleep Eff_Poison Eff_Curse Eff_Silence Eff_Confusion Eff_Blind
syn keyword hConstant Eff_Bleeding Eff_DPoison Eff_Burning
syn keyword hConstant Ele_Neutral Ele_Water Ele_Earth Ele_Fire Ele_Wind Ele_Poison Ele_Holy Ele_Dark Ele_Ghost
syn keyword hConstant Ele_Undead
syn keyword hConstant RC_Formless RC_Undead RC_Brute RC_Plant RC_Insect RC_Fish RC_Demon RC_DemiHuman RC_Angel
syn keyword hConstant RC_Dragon RC_Boss RC_NonBoss RC_NonDemiHuman
syn keyword hConstant RC2_None RC2_Goblin RC2_Kobold RC2_Orc RC2_Golem RC2_Guardian RC2_Ninja
syn keyword hConstant Size_Small Size_Medium Size_Large
syn keyword hConstant BF_WEAPON BF_MAGIC BF_MISC BF_SHORT BF_LONG BF_SKILL BF_NORMAL
syn keyword hConstant ATF_SELF ATF_TARGET ATF_SHORT ATF_LONG ATF_WEAPON ATF_MAGIC ATF_MISC ATF_SKILL
syn keyword hConstant SC_ALL SC_STONE SC_FREEZE SC_STUN SC_SLEEP SC_POISON SC_CURSE SC_SILENCE SC_CONFUSION SC_BLIND
syn keyword hConstant SC_BLOODING SC_DPOISON SC_BURNING SC_PROVOKE SC_ENDURE SC_TWOHANDQUICKEN SC_CONCENTRATION
syn keyword hConstant SC_HIDING SC_CLOAKING SC_ENCHANTPOISON SC_POISONREACT SC_QUAGMIRE SC_ANGELUS SC_BLESSING
syn keyword hConstant SC_CRUCIS SC_INC_AGI SC_DEC_AGI SC_SLOWPOISON SC_IMPOSITIO SC_SUFFRAGIUM SC_ASPERSIO
syn keyword hConstant SC_BENEDICTIO SC_KYRIE SC_MAGNIFICAT SC_GLORIA SC_LEXAETERNA SC_ADRENALINE SC_WEAPONPERFECT
syn keyword hConstant SC_OVERTHRUST SC_MAXIMIZEPOWER SC_TRICKDEAD SC_SHOUT SC_ENERGYCOAT SC_BROKENARMOR SC_BROKENWEAPON
syn keyword hConstant SC_ILLUSION SC_WEIGHTOVER50 SC_WEIGHTOVER90 SC_ATTHASTE_POTION1 SC_ATTHASTE_POTION2
syn keyword hConstant SC_ATTHASTE_POTION3 SC_ATTHASTE_INFINITY SC_MOVHASTE_HORSE SC_MOVHASTE_INFINITY
syn keyword hConstant SC_PLUSATTACKPOWER SC_PLUSMAGICPOWER SC_WEDDING SC_SLOWDOWN SC_ANKLESNARE SC_KEEPING SC_BARRIER
syn keyword hConstant SC_NOEQUIPWEAPON SC_NOEQUIPSHIELD SC_NOEQUIPARMOR SC_NOEQUIPHELM SC_PROTECTWEAPON
syn keyword hConstant SC_PROTECTSHIELD SC_PROTECTARMOR SC_PROTECTHELM SC_AUTOGUARD SC_REFLECTSHIELD SC_SPLASHER
syn keyword hConstant SC_PROVIDENCE SC_DEFENDER SC_MAGICROD SC_SPELLBREAKER SC_AUTOSPELL SC_SIGHTTRASHER SC_AUTOBERSERK
syn keyword hConstant SC_SPEARQUICKEN SC_AUTOCOUNTER SC_SIGHT SC_SAFETYWALL SC_RUWACH SC_EXTREMITYFIST
syn keyword hConstant SC_EXPLOSIONSPIRITS SC_COMBOATTACK SC_BLADESTOP_WAIT SC_BLADESTOP SC_PROPERTYFIRE
syn keyword hConstant SC_PROPERTYWATER SC_PROPERTYWIND SC_PROPERTYGROUND SC_VOLCANO SC_DELUGE SC_VIOLENTGALE
syn keyword hConstant SC_SUB_WEAPONPROPERTY SC_ARMOR SC_ARMORPROPERTY SC_NOCHAT SC_BABY SC_AURABLADE SC_PARRYING
syn keyword hConstant SC_LKCONCENTRATION SC_TENSIONRELAX SC_BERSERK SC_FURY SC_GOSPEL SC_ASSUMPTIO SC_BASILICA
syn keyword hConstant SC_GUILDAURA SC_MAGICPOWER SC_EDP SC_TRUESIGHT SC_WINDWALK SC_MELTDOWN SC_CARTBOOST SC_CHASEWALK
syn keyword hConstant SC_SWORDREJECT SC_MARIONETTE_MASTER SC_MARIONETTE SC_PROPERTYUNDEAD SC_JOINTBEAT SC_MINDBREAKER
syn keyword hConstant SC_MEMORIZE SC_FOGWALL SC_SPIDERWEB SC_DEVOTION SC_SACRIFICE SC_STEELBODY SC_ORCISH
syn keyword hConstant SC_STORMKICK_READY SC_DOWNKICK_READY SC_TURNKICK_READY SC_COUNTERKICK_READY SC_DODGE_READY SC_RUN
syn keyword hConstant SC_PROPERTYDARK SC_ADRENALINE2 SC_PROPERTYTELEKINESIS SC_KAIZEL SC_KAAHI SC_KAUPE
syn keyword hConstant SC_ONEHANDQUICKEN SC_PRESERVE SC_GDSKILL_BATTLEORDER SC_GDSKILL_REGENERATION SC_DOUBLECASTING
syn keyword hConstant SC_GRAVITATION SC_OVERTHRUSTMAX SC_LONGING SC_HERMODE SC_TAROTCARD SC_CR_SHRINK
syn keyword hConstant SC_WZ_SIGHTBLASTER SC_DC_WINKCHARM SC_RG_CCONFINE_M SC_RG_CCONFINE_S SC_DANCING SC_ARMOR_PROPERTY
syn keyword hConstant SC_RICHMANKIM SC_ETERNALCHAOS SC_DRUMBATTLE SC_NIBELUNGEN SC_ROKISWEIL SC_INTOABYSS SC_SIEGFRIED
syn keyword hConstant SC_WHISTLE SC_ASSNCROS SC_POEMBRAGI SC_APPLEIDUN SC_MODECHANGE SC_HUMMING SC_DONTFORGETME
syn keyword hConstant SC_FORTUNE SC_SERVICEFORYOU SC_STOP SC_STRUP SC_SOULLINK SC_COMA SC_CLAIRVOYANCE SC_INCALLSTATUS
syn keyword hConstant SC_CHASEWALK2 SC_INCAGI SC_INCVIT SC_INCINT SC_INCDEX SC_INCLUK SC_INCHIT SC_INCHITRATE
syn keyword hConstant SC_INCFLEE SC_INCFLEERATE SC_INCMHPRATE SC_INCMSPRATE SC_INCATKRATE SC_INCMATKRATE SC_INCDEFRATE
syn keyword hConstant SC_FOOD_STR SC_FOOD_AGI SC_FOOD_VIT SC_FOOD_INT SC_FOOD_DEX SC_FOOD_LUK SC_FOOD_BASICHIT
syn keyword hConstant SC_FOOD_BASICAVOIDANCE SC_BATKFOOD SC_WATKFOOD SC_MATKFOOD SC_SCRESIST SC_XMAS SC_WARM
syn keyword hConstant SC_SUN_COMFORT SC_MOON_COMFORT SC_STAR_COMFORT SC_FUSION SC_SKILLRATE_UP SC_SKE SC_KAITE SC_SWOO
syn keyword hConstant SC_SKA SC_EARTHSCROLL SC_MIRACLE SC_GS_MADNESSCANCEL SC_GS_ADJUSTMENT SC_GS_ACCURACY
syn keyword hConstant SC_GS_GATLINGFEVER SC_NJ_TATAMIGAESHI SC_NJ_UTSUSEMI SC_NJ_BUNSINJYUTSU SC_NJ_KAENSIN
syn keyword hConstant SC_NJ_SUITON SC_NJ_NEN SC_KNOWLEDGE SC_SMA_READY SC_FLING SC_HLIF_AVOID SC_HLIF_CHANGE
syn keyword hConstant SC_HAMI_BLOODLUST SC_HLIF_FLEET SC_HLIF_SPEED SC_HAMI_DEFENCE SC_INCASPDRATE SC_PLUSAVOIDVALUE
syn keyword hConstant SC_JAILED SC_ENCHANTARMS SC_MAGICALATTACK SC_STONESKIN SC_CRITICALWOUND SC_MAGICMIRROR
syn keyword hConstant SC_SLOWCAST SC_SUMMER SC_CASH_PLUSEXP SC_CASH_RECEIVEITEM SC_CASH_BOSS_ALARM SC_CASH_DEATHPENALTY
syn keyword hConstant SC_CRITICALPERCENT SC_PROTECT_MDEF SC_HEALPLUS SC_PNEUMA SC_AUTOTRADE SC_KSPROTECTED
syn keyword hConstant SC_ARMOR_RESIST SC_ATKER_BLOOD SC_TARGET_BLOOD SC_TK_SEVENWIND SC_PROTECT_DEF SC_WALKSPEED
syn keyword hConstant SC_MER_FLEE SC_MER_ATK SC_MER_HP SC_MER_SP SC_MER_HIT SC_MER_QUICKEN SC_REBIRTH SC_ITEMSCRIPT
syn keyword hConstant SC_S_LIFEPOTION SC_L_LIFEPOTION SC_CASH_PLUSONLYJOBEXP SC_HELLPOWER SC_INVINCIBLE
syn keyword hConstant SC_INVINCIBLEOFF SC_MANU_ATK SC_MANU_DEF SC_SPL_ATK SC_SPL_DEF SC_MANU_MATK SC_SPL_MATK
syn keyword hConstant SC_FOOD_STR_CASH SC_FOOD_AGI_CASH SC_FOOD_VIT_CASH SC_FOOD_DEX_CASH SC_FOOD_INT_CASH
syn keyword hConstant SC_FOOD_LUK_CASH SC_FEAR SC_FROSTMISTY SC_ENCHANTBLADE SC_DEATHBOUND SC_MILLENNIUMSHIELD
syn keyword hConstant SC_CRUSHSTRIKE SC_REFRESH SC_REUSE_REFRESH SC_GIANTGROWTH SC_STONEHARDSKIN SC_VITALITYACTIVATION
syn keyword hConstant SC_STORMBLAST SC_FIGHTINGSPIRIT SC_ABUNDANCE SC_ADORAMUS SC_EPICLESIS SC_ORATIO SC_LAUDAAGNUS
syn keyword hConstant SC_LAUDARAMUS SC_RENOVATIO SC_EXPIATIO SC_DUPLELIGHT SC_SECRAMENT SC_WHITEIMPRISON
syn keyword hConstant SC_MARSHOFABYSS SC_RECOGNIZEDSPELL SC_STASIS SC_SUMMON1 SC_SUMMON2 SC_SUMMON3 SC_SUMMON4
syn keyword hConstant SC_SUMMON5 SC_READING_SB SC_FREEZINGSP SC_FEARBREEZE SC_ELECTRICSHOCKER SC_WUGDASH SC_WUGBITE
syn keyword hConstant SC_CAMOUFLAGE SC_ACCELERATION SC_HOVERING SC_SHAPESHIFT SC_INFRAREDSCAN SC_ANALYZE
syn keyword hConstant SC_MAGNETICFIELD SC_NEUTRALBARRIER SC_NEUTRALBARRIER_MASTER SC_STEALTHFIELD
syn keyword hConstant SC_STEALTHFIELD_MASTER SC_OVERHEAT SC_OVERHEAT_LIMITPOINT SC_VENOMIMPRESS SC_POISONINGWEAPON
syn keyword hConstant SC_WEAPONBLOCKING SC_CLOAKINGEXCEED SC_HALLUCINATIONWALK SC_HALLUCINATIONWALK_POSTDELAY
syn keyword hConstant SC_ROLLINGCUTTER SC_TOXIN SC_PARALYSE SC_VENOMBLEED SC_MAGICMUSHROOM SC_DEATHHURT SC_PYREXIA
syn keyword hConstant SC_OBLIVIONCURSE SC_LEECHESEND SC_LG_REFLECTDAMAGE SC_FORCEOFVANGUARD SC_SHIELDSPELL_DEF
syn keyword hConstant SC_SHIELDSPELL_MDEF SC_SHIELDSPELL_REF SC_EXEEDBREAK SC_PRESTIGE SC_BANDING SC_BANDING_DEFENCE
syn keyword hConstant SC_EARTHDRIVE SC_INSPIRATION SC_SPELLFIST SC_COLD SC_STRIKING SC_WARMER SC_VACUUM_EXTREME
syn keyword hConstant SC_PROPERTYWALK SC_SWING SC_SYMPHONY_LOVE SC_MOONLIT_SERENADE SC_RUSH_WINDMILL SC_ECHOSONG
syn keyword hConstant SC_HARMONIZE SC_SIREN SC_DEEP_SLEEP SC_SIRCLEOFNATURE SC_GLOOMYDAY SC_GLOOMYDAY_SK
syn keyword hConstant SC_SONG_OF_MANA SC_DANCE_WITH_WUG SC_SATURDAY_NIGHT_FEVER SC_LERADS_DEW SC_MELODYOFSINK
syn keyword hConstant SC_BEYOND_OF_WARCRY SC_UNLIMITED_HUMMING_VOICE SC_SITDOWN_FORCE SC_NETHERWORLD SC_CRESCENTELBOW
syn keyword hConstant SC_CURSEDCIRCLE_ATKER SC_CURSEDCIRCLE_TARGET SC_LIGHTNINGWALK SC_RAISINGDRAGON
syn keyword hConstant SC_GENTLETOUCH_ENERGYGAIN SC_GENTLETOUCH_CHANGE SC_GENTLETOUCH_REVITALIZE SC_GN_CARTBOOST
syn keyword hConstant SC_THORNS_TRAP SC_BLOOD_SUCKER SC_FIRE_EXPANSION_SMOKE_POWDER SC_FIRE_EXPANSION_TEAR_GAS
syn keyword hConstant SC_MANDRAGORA SC_STOMACHACHE SC_MYSTERIOUS_POWDER SC_MELON_BOMB SC_BANANA_BOMB
syn keyword hConstant SC_BANANA_BOMB_SITDOWN_POSTDELAY SC_SAVAGE_STEAK SC_COCKTAIL_WARG_BLOOD SC_MINOR_BBQ
syn keyword hConstant SC_SIROMA_ICE_TEA SC_DROCERA_HERB_STEAMED SC_PUTTI_TAILS_NOODLES SC_BOOST500 SC_FULL_SWING_K
syn keyword hConstant SC_MANA_PLUS SC_MUSTLE_M SC_LIFE_FORCE_F SC_EXTRACT_WHITE_POTION_Z SC_VITATA_500
syn keyword hConstant SC_EXTRACT_SALAMINE_JUICE SC__REPRODUCE SC__AUTOSHADOWSPELL SC__SHADOWFORM SC__BODYPAINT
syn keyword hConstant SC__INVISIBILITY SC__DEADLYINFECT SC__ENERVATION SC__GROOMY SC__IGNORANCE SC__LAZINESS
syn keyword hConstant SC__UNLUCKY SC__WEAKNESS SC__STRIPACCESSARY SC__MANHOLE SC__BLOODYLUST SC_CIRCLE_OF_FIRE
syn keyword hConstant SC_CIRCLE_OF_FIRE_OPTION SC_FIRE_CLOAK SC_FIRE_CLOAK_OPTION SC_WATER_SCREEN
syn keyword hConstant SC_WATER_SCREEN_OPTION SC_WATER_DROP SC_WATER_DROP_OPTION SC_WATER_BARRIER SC_WIND_STEP
syn keyword hConstant SC_WIND_STEP_OPTION SC_WIND_CURTAIN SC_WIND_CURTAIN_OPTION SC_ZEPHYR SC_SOLID_SKIN
syn keyword hConstant SC_SOLID_SKIN_OPTION SC_STONE_SHIELD SC_STONE_SHIELD_OPTION SC_POWER_OF_GAIA SC_PYROTECHNIC
syn keyword hConstant SC_PYROTECHNIC_OPTION SC_HEATER SC_HEATER_OPTION SC_TROPIC SC_TROPIC_OPTION SC_AQUAPLAY
syn keyword hConstant SC_AQUAPLAY_OPTION SC_COOLER SC_COOLER_OPTION SC_CHILLY_AIR SC_CHILLY_AIR_OPTION SC_GUST
syn keyword hConstant SC_GUST_OPTION SC_BLAST SC_BLAST_OPTION SC_WILD_STORM SC_WILD_STORM_OPTION SC_PETROLOGY
syn keyword hConstant SC_PETROLOGY_OPTION SC_CURSED_SOIL SC_CURSED_SOIL_OPTION SC_UPHEAVAL SC_UPHEAVAL_OPTION
syn keyword hConstant SC_TIDAL_WEAPON SC_TIDAL_WEAPON_OPTION SC_ROCK_CRUSHER SC_ROCK_CRUSHER_ATK SC_LEADERSHIP
syn keyword hConstant SC_GLORYWOUNDS SC_SOULCOLD SC_HAWKEYES SC_ODINS_POWER SC_FIRE_INSIGNIA SC_WATER_INSIGNIA
syn keyword hConstant SC_WIND_INSIGNIA SC_EARTH_INSIGNIA SC_PUSH_CART SC_SPELLBOOK1 SC_SPELLBOOK2 SC_SPELLBOOK3
syn keyword hConstant SC_SPELLBOOK4 SC_SPELLBOOK5 SC_SPELLBOOK6 SC_SPELLBOOK7 SC_INCMHP SC_INCMSP SC_PARTYFLEE
syn keyword hConstant SC_MEIKYOUSISUI SC_KO_JYUMONJIKIRI SC_KYOUGAKU SC_IZAYOI SC_ZENKAI SC_KG_KAGEHUMI SC_KYOMU
syn keyword hConstant SC_KAGEMUSYA SC_ZANGETSU SC_GENSOU SC_AKAITSUKI SC_STYLE_CHANGE SC_GOLDENE_FERSE
syn keyword hConstant SC_ANGRIFFS_MODUS SC_ERASER_CUTTER SC_OVERED_BOOST SC_LIGHT_OF_REGENE SC_VOLCANIC_ASH
syn keyword hConstant SC_GRANITIC_ARMOR SC_MAGMA_FLOW SC_PYROCLASTIC SC_NEEDLE_OF_PARALYZE SC_PAIN_KILLER
syn keyword hConstant SC_EXTREMITYFIST2 SC_RAID SC_DARKCROW SC_FULL_THROTTLE SC_REBOUND SC_UNLIMIT SC_KINGS_GRACE
syn keyword hConstant SC_TELEKINESIS_INTENSE SC_OFFERTORIUM SC_FRIGG_SONG SC_ALL_RIDING SC_HANBOK SC_MONSTER_TRANSFORM
syn keyword hConstant SC_ANGEL_PROTECT SC_ILLUSIONDOPING SC_MTF_ASPD SC_MTF_RANGEATK SC_MTF_MATK SC_MTF_MLEATKED
syn keyword hConstant SC_MTF_CRIDAMAGE SC_MOONSTAR SC_SUPER_STAR
syn keyword hConstant e_gasp e_what e_ho e_lv e_swt e_ic e_an e_ag e_cash e_dots e_scissors e_rock e_paper e_korea
syn keyword hConstant e_lv2 e_thx e_wah e_sry e_heh e_swt2 e_hmm e_no1 e_no e_omg e_oh e_X e_hlp e_go e_sob e_gg e_kis
syn keyword hConstant e_kis2 e_pif e_ok e_mute e_indonesia e_bzz e_rice e_awsm e_meh e_shy e_pat e_mp e_slur e_com
syn keyword hConstant e_yawn e_grat e_hp e_philippines e_malaysia e_singapore e_brazil e_flash e_spin e_sigh e_dum
syn keyword hConstant e_loud e_otl e_dice1 e_dice2 e_dice3 e_dice4 e_dice5 e_dice6 e_india e_luv e_russia e_virgin
syn keyword hConstant e_mobile e_mail e_chinese e_antenna1 e_antenna2 e_antenna3 e_hum e_abs e_oops e_spit e_ene
syn keyword hConstant e_panic e_whisp
syn keyword hConstant PET_CLASS PET_NAME PET_LEVEL PET_HUNGRY PET_INTIMATE
syn keyword hConstant MOB_NAME MOB_LV MOB_MAXHP MOB_BASEEXP MOB_JOBEXP MOB_ATK1 MOB_ATK2 MOB_DEF MOB_MDEF MOB_STR
syn keyword hConstant MOB_AGI MOB_VIT MOB_INT MOB_DEX MOB_LUK MOB_RANGE MOB_RANGE2 MOB_RANGE3 MOB_SIZE MOB_RACE
syn keyword hConstant MOB_ELEMENT MOB_MODE MOB_MVPEXP
syn keyword hConstant AI_ACTION_TYPE AI_ACTION_TAR_TYPE AI_ACTION_TAR AI_ACTION_SRC AI_ACTION_TAR_TYPE_PC
syn keyword hConstant AI_ACTION_TAR_TYPE_MOB AI_ACTION_TAR_TYPE_PET AI_ACTION_TAR_TYPE_HOMUN AI_ACTION_TAR_TYPE_ITEM
syn keyword hConstant AI_ACTION_TYPE_NPCCLICK AI_ACTION_TYPE_ATTACK AI_ACTION_TYPE_DETECT AI_ACTION_TYPE_DEAD
syn keyword hConstant AI_ACTION_TYPE_ASSIST AI_ACTION_TYPE_KILL AI_ACTION_TYPE_UNLOCK AI_ACTION_TYPE_WALKACK
syn keyword hConstant AI_ACTION_TYPE_WARPACK
syn keyword hConstant ALL_CLIENT ALL_SAMEMAP AREA
syn keyword hConstant AREA_WOS AREA_WOC AREA_WOSC AREA_CHAT_WOC CHAT
syn keyword hConstant CHAT_WOS PARTY
syn keyword hConstant PARTY_WOS PARTY_SAMEMAP PARTY_SAMEMAP_WOS PARTY_AREA PARTY_AREA_WOS GUILD
syn keyword hConstant GUILD_WOS GUILD_SAMEMAP GUILD_SAMEMAP_WOS GUILD_AREA GUILD_AREA_WOS GUILD_NOBG DUEL
syn keyword hConstant DUEL_WOS
syn keyword hConstant CHAT_MAINCHAT SELF BG
syn keyword hConstant BG_WOS BG_SAMEMAP BG_SAMEMAP_WOS BG_AREA BG_AREA_WOS
syn keyword hConstant ARCH_MERC_GUILD
syn keyword hConstant SPEAR_MERC_GUILD
syn keyword hConstant SWORD_MERC_GUILD
syn keyword hConstant EF_NONE EF_HIT1 EF_HIT2 EF_HIT3 EF_HIT4 EF_HIT5 EF_HIT6 EF_ENTRY EF_EXIT EF_WARP EF_ENHANCE
syn keyword hConstant EF_COIN EF_ENDURE EF_BEGINSPELL EF_GLASSWALL EF_HEALSP EF_SOULSTRIKE EF_BASH EF_MAGNUMBREAK
syn keyword hConstant EF_STEAL EF_HIDING EF_PATTACK EF_DETOXICATION EF_SIGHT EF_STONECURSE EF_FIREBALL EF_FIREWALL
syn keyword hConstant EF_ICEARROW EF_FROSTDIVER EF_FROSTDIVER2 EF_LIGHTBOLT EF_THUNDERSTORM EF_FIREARROW EF_NAPALMBEAT
syn keyword hConstant EF_RUWACH EF_TELEPORTATION EF_READYPORTAL EF_PORTAL EF_INCAGILITY EF_DECAGILITY EF_AQUA EF_SIGNUM
syn keyword hConstant EF_ANGELUS EF_BLESSING EF_INCAGIDEX EF_SMOKE EF_FIREFLY EF_SANDWIND EF_TORCH EF_SPRAYPOND
syn keyword hConstant EF_FIREHIT EF_FIRESPLASHHIT EF_COLDHIT EF_WINDHIT EF_POISONHIT EF_BEGINSPELL2 EF_BEGINSPELL3
syn keyword hConstant EF_BEGINSPELL4 EF_BEGINSPELL5 EF_BEGINSPELL6 EF_BEGINSPELL7 EF_LOCKON EF_WARPZONE EF_SIGHTRASHER
syn keyword hConstant EF_BARRIER EF_ARROWSHOT EF_INVENOM EF_CURE EF_PROVOKE EF_MVP EF_SKIDTRAP EF_BRANDISHSPEAR EF_CONE
syn keyword hConstant EF_SPHERE EF_BOWLINGBASH EF_ICEWALL EF_GLORIA EF_MAGNIFICAT EF_RESURRECTION EF_RECOVERY
syn keyword hConstant EF_EARTHSPIKE EF_SPEARBMR EF_PIERCE EF_TURNUNDEAD EF_SANCTUARY EF_IMPOSITIO EF_LEXAETERNA
syn keyword hConstant EF_ASPERSIO EF_LEXDIVINA EF_SUFFRAGIUM EF_STORMGUST EF_LORD EF_BENEDICTIO EF_METEORSTORM
syn keyword hConstant EF_YUFITEL EF_YUFITELHIT EF_QUAGMIRE EF_FIREPILLAR EF_FIREPILLARBOMB EF_HASTEUP EF_FLASHER
syn keyword hConstant EF_REMOVETRAP EF_REPAIRWEAPON EF_CRASHEARTH EF_PERFECTION EF_MAXPOWER EF_BLASTMINE
syn keyword hConstant EF_BLASTMINEBOMB EF_CLAYMORE EF_FREEZING EF_BUBBLE EF_GASPUSH EF_SPRINGTRAP EF_KYRIE EF_MAGNUS
syn keyword hConstant EF_BOTTOM EF_BLITZBEAT EF_WATERBALL EF_WATERBALL2 EF_FIREIVY EF_DETECTING EF_CLOAKING
syn keyword hConstant EF_SONICBLOW EF_SONICBLOWHIT EF_GRIMTOOTH EF_VENOMDUST EF_ENCHANTPOISON EF_POISONREACT
syn keyword hConstant EF_POISONREACT2 EF_OVERTHRUST EF_SPLASHER EF_TWOHANDQUICKEN EF_AUTOCOUNTER EF_GRIMTOOTHATK
syn keyword hConstant EF_FREEZE EF_FREEZED EF_ICECRASH EF_SLOWPOISON EF_BOTTOM2 EF_FIREPILLARON EF_SANDMAN EF_REVIVE
syn keyword hConstant EF_PNEUMA EF_HEAVENSDRIVE EF_SONICBLOW2 EF_BRANDISH2 EF_SHOCKWAVE EF_SHOCKWAVEHIT EF_EARTHHIT
syn keyword hConstant EF_PIERCESELF EF_BOWLINGSELF EF_SPEARSTABSELF EF_SPEARBMRSELF EF_HOLYHIT EF_CONCENTRATION
syn keyword hConstant EF_REFINEOK EF_REFINEFAIL EF_JOBCHANGE EF_LVUP EF_JOBLVUP EF_TOPRANK EF_PARTY EF_RAIN EF_SNOW
syn keyword hConstant EF_SAKURA EF_STATUS_STATE EF_BANJJAKII EF_MAKEBLUR EF_TAMINGSUCCESS EF_TAMINGFAILED EF_ENERGYCOAT
syn keyword hConstant EF_CARTREVOLUTION EF_VENOMDUST2 EF_CHANGEDARK EF_CHANGEFIRE EF_CHANGECOLD EF_CHANGEWIND
syn keyword hConstant EF_CHANGEFLAME EF_CHANGEEARTH EF_CHAINGEHOLY EF_CHANGEPOISON EF_HITDARK EF_MENTALBREAK
syn keyword hConstant EF_MAGICALATTHIT EF_SUI_EXPLOSION EF_DARKATTACK EF_SUICIDE EF_COMBOATTACK1 EF_COMBOATTACK2
syn keyword hConstant EF_COMBOATTACK3 EF_COMBOATTACK4 EF_COMBOATTACK5 EF_GUIDEDATTACK EF_POISONATTACK EF_SILENCEATTACK
syn keyword hConstant EF_STUNATTACK EF_PETRIFYATTACK EF_CURSEATTACK EF_SLEEPATTACK EF_TELEKHIT EF_PONG EF_LEVEL99
syn keyword hConstant EF_LEVEL99_2 EF_LEVEL99_3 EF_GUMGANG EF_POTION1 EF_POTION2 EF_POTION3 EF_POTION4 EF_POTION5
syn keyword hConstant EF_POTION6 EF_POTION7 EF_POTION8 EF_DARKBREATH EF_DEFFENDER EF_KEEPING EF_SUMMONSLAVE
syn keyword hConstant EF_BLOODDRAIN EF_ENERGYDRAIN EF_POTION_CON EF_POTION_ EF_POTION_BERSERK EF_POTIONPILLAR
syn keyword hConstant EF_DEFENDER EF_GANBANTEIN EF_WIND EF_VOLCANO EF_GRANDCROSS EF_INTIMIDATE EF_CHOOKGI EF_CLOUD
syn keyword hConstant EF_CLOUD2 EF_MAPPILLAR EF_LINELINK EF_CLOUD3 EF_SPELLBREAKER EF_DISPELL EF_DELUGE EF_VIOLENTGALE
syn keyword hConstant EF_LANDPROTECTOR EF_BOTTOM_VO EF_BOTTOM_DE EF_BOTTOM_VI EF_BOTTOM_LA EF_FASTMOVE EF_MAGICROD
syn keyword hConstant EF_HOLYCROSS EF_SHIELDCHARGE EF_MAPPILLAR2 EF_PROVIDENCE EF_SHIELDBOOMERANG EF_SPEARQUICKEN
syn keyword hConstant EF_DEVOTION EF_REFLECTSHIELD EF_ABSORBSPIRITS EF_STEELBODY EF_FLAMELAUNCHER EF_FROSTWEAPON
syn keyword hConstant EF_LIGHTNINGLOADER EF_SEISMICWEAPON EF_MAPPILLAR3 EF_MAPPILLAR4 EF_GUMGANG2 EF_TEIHIT1
syn keyword hConstant EF_GUMGANG3 EF_TEIHIT2 EF_TANJI EF_TEIHIT1X EF_CHIMTO EF_STEALCOIN EF_STRIPWEAPON EF_STRIPSHIELD
syn keyword hConstant EF_STRIPARMOR EF_STRIPHELM EF_CHAINCOMBO EF_RG_COIN EF_BACKSTAP EF_TEIHIT3 EF_BOTTOM_DISSONANCE
syn keyword hConstant EF_BOTTOM_LULLABY EF_BOTTOM_RICHMANKIM EF_BOTTOM_ETERNALCHAOS EF_BOTTOM_DRUMBATTLEFIELD
syn keyword hConstant EF_BOTTOM_RINGNIBELUNGEN EF_BOTTOM_ROKISWEIL EF_BOTTOM_INTOABYSS EF_BOTTOM_SIEGFRIED
syn keyword hConstant EF_BOTTOM_WHISTLE EF_BOTTOM_ASSASSINCROSS EF_BOTTOM_POEMBRAGI EF_BOTTOM_APPLEIDUN
syn keyword hConstant EF_BOTTOM_UGLYDANCE EF_BOTTOM_HUMMING EF_BOTTOM_DONTFORGETME EF_BOTTOM_FORTUNEKISS
syn keyword hConstant EF_BOTTOM_SERVICEFORYOU EF_TALK_FROSTJOKE EF_TALK_SCREAM EF_POKJUK EF_THROWITEM EF_THROWITEM2
syn keyword hConstant EF_CHEMICALPROTECTION EF_POKJUK_SOUND EF_DEMONSTRATION EF_CHEMICAL2 EF_TELEPORTATION2
syn keyword hConstant EF_PHARMACY_OK EF_PHARMACY_FAIL EF_FORESTLIGHT EF_THROWITEM3 EF_FIRSTAID EF_SPRINKLESAND EF_LOUD
syn keyword hConstant EF_HEAL EF_HEAL2 EF_EXIT2 EF_GLASSWALL2 EF_READYPORTAL2 EF_PORTAL2 EF_BOTTOM_MAG EF_BOTTOM_SANC
syn keyword hConstant EF_HEAL3 EF_WARPZONE2 EF_FORESTLIGHT2 EF_FORESTLIGHT3 EF_FORESTLIGHT4 EF_HEAL4 EF_FOOT EF_FOOT2
syn keyword hConstant EF_BEGINASURA EF_TRIPLEATTACK EF_HITLINE EF_HPTIME EF_SPTIME EF_MAPLE EF_BLIND EF_POISON EF_GUARD
syn keyword hConstant EF_JOBLVUP50 EF_ANGEL2 EF_MAGNUM2 EF_CALLZONE EF_PORTAL3 EF_COUPLECASTING EF_HEARTCASTING
syn keyword hConstant EF_ENTRY2 EF_SAINTWING EF_SPHEREWIND EF_COLORPAPER EF_LIGHTSPHERE EF_WATERFALL EF_WATERFALL_90
syn keyword hConstant EF_WATERFALL_SMALL EF_WATERFALL_SMALL_90 EF_WATERFALL_T2 EF_WATERFALL_T2_90 EF_WATERFALL_SMALL_T2
syn keyword hConstant EF_WATERFALL_SMALL_T2_90 EF_MINI_TETRIS EF_GHOST EF_BAT EF_BAT2 EF_SOULBREAKER EF_LEVEL99_4
syn keyword hConstant EF_VALLENTINE EF_VALLENTINE2 EF_PRESSURE EF_BASH3D EF_AURABLADE EF_REDBODY EF_LKCONCENTRATION
syn keyword hConstant EF_BOTTOM_GOSPEL EF_ANGEL EF_DEVIL EF_DRAGONSMOKE EF_BOTTOM_BASILICA EF_ASSUMPTIO EF_HITLINE2
syn keyword hConstant EF_BASH3D2 EF_ENERGYDRAIN2 EF_TRANSBLUEBODY EF_MAGICCRASHER EF_LIGHTSPHERE2 EF_LIGHTBLADE
syn keyword hConstant EF_ENERGYDRAIN3 EF_LINELINK2 EF_LINKLIGHT EF_TRUESIGHT EF_FALCONASSAULT EF_TRIPLEATTACK2
syn keyword hConstant EF_PORTAL4 EF_MELTDOWN EF_CARTBOOST EF_REJECTSWORD EF_TRIPLEATTACK3 EF_SPHEREWIND2 EF_LINELINK3
syn keyword hConstant EF_PINKBODY EF_LEVEL99_5 EF_LEVEL99_6 EF_BASH3D3 EF_BASH3D4 EF_NAPALMVALCAN EF_PORTAL5
syn keyword hConstant EF_MAGICCRASHER2 EF_BOTTOM_SPIDER EF_BOTTOM_FOGWALL EF_SOULBURN EF_SOULCHANGE EF_BABY
syn keyword hConstant EF_SOULBREAKER2 EF_RAINBOW EF_PEONG EF_TANJI2 EF_PRESSEDBODY EF_SPINEDBODY EF_KICKEDBODY
syn keyword hConstant EF_AIRTEXTURE EF_HITBODY EF_DOUBLEGUMGANG EF_REFLECTBODY EF_BABYBODY EF_BABYBODY2 EF_GIANTBODY
syn keyword hConstant EF_GIANTBODY2 EF_ASURABODY EF_4WAYBODY EF_QUAKEBODY EF_ASURABODY_MONSTER EF_HITLINE3 EF_HITLINE4
syn keyword hConstant EF_HITLINE5 EF_HITLINE6 EF_ELECTRIC EF_ELECTRIC2 EF_HITLINE7 EF_STORMKICK EF_HALFSPHERE
syn keyword hConstant EF_ATTACKENERGY EF_ATTACKENERGY2 EF_CHEMICAL3 EF_ASSUMPTIO2 EF_BLUECASTING EF_RUN EF_STOPRUN
syn keyword hConstant EF_STOPEFFECT EF_JUMPBODY EF_LANDBODY EF_FOOT3 EF_FOOT4 EF_TAE_READY EF_GRANDCROSS2
syn keyword hConstant EF_SOULSTRIKE2 EF_YUFITEL2 EF_NPC_STOP EF_DARKCASTING EF_GUMGANGNPC EF_AGIUP EF_JUMPKICK
syn keyword hConstant EF_QUAKEBODY2 EF_STORMKICK1 EF_STORMKICK2 EF_STORMKICK3 EF_STORMKICK4 EF_STORMKICK5 EF_STORMKICK6
syn keyword hConstant EF_STORMKICK7 EF_SPINEDBODY2 EF_BEGINASURA1 EF_BEGINASURA2 EF_BEGINASURA3 EF_BEGINASURA4
syn keyword hConstant EF_BEGINASURA5 EF_BEGINASURA6 EF_BEGINASURA7 EF_AURABLADE2 EF_DEVIL1 EF_DEVIL2 EF_DEVIL3
syn keyword hConstant EF_DEVIL4 EF_DEVIL5 EF_DEVIL6 EF_DEVIL7 EF_DEVIL8 EF_DEVIL9 EF_DEVIL10 EF_DOUBLEGUMGANG2
syn keyword hConstant EF_DOUBLEGUMGANG3 EF_BLACKDEVIL EF_FLOWERCAST EF_FLOWERCAST2 EF_FLOWERCAST3 EF_MOCHI EF_LAMADAN
syn keyword hConstant EF_EDP EF_SHIELDBOOMERANG2 EF_RG_COIN2 EF_GUARD2 EF_SLIM EF_SLIM2 EF_SLIM3 EF_CHEMICALBODY
syn keyword hConstant EF_CASTSPIN EF_PIERCEBODY EF_SOULLINK EF_CHOOKGI2 EF_MEMORIZE EF_SOULLIGHT EF_MAPAE EF_ITEMPOKJUK
syn keyword hConstant EF_05VAL EF_BEGINASURA11 EF_NIGHT EF_CHEMICAL2DASH EF_GROUNDSAMPLE EF_GI_EXPLOSION EF_CLOUD4
syn keyword hConstant EF_CLOUD5 EF_BOTTOM_HERMODE EF_CARTTER EF_ITEMFAST EF_SHIELDBOOMERANG3 EF_DOUBLECASTBODY
syn keyword hConstant EF_GRAVITATION EF_TAROTCARD1 EF_TAROTCARD2 EF_TAROTCARD3 EF_TAROTCARD4 EF_TAROTCARD5
syn keyword hConstant EF_TAROTCARD6 EF_TAROTCARD7 EF_TAROTCARD8 EF_TAROTCARD9 EF_TAROTCARD10 EF_TAROTCARD11
syn keyword hConstant EF_TAROTCARD12 EF_TAROTCARD13 EF_TAROTCARD14 EF_ACIDDEMON EF_GREENBODY EF_THROWITEM4
syn keyword hConstant EF_BABYBODY_BACK EF_THROWITEM5 EF_BLUEBODY EF_HATED EF_REDLIGHTBODY EF_RO2YEAR EF_SMA_READY
syn keyword hConstant EF_STIN EF_RED_HIT EF_BLUE_HIT EF_QUAKEBODY3 EF_SMA EF_SMA2 EF_STIN2 EF_HITTEXTURE EF_STIN3
syn keyword hConstant EF_SMA3 EF_BLUEFALL EF_BLUEFALL_90 EF_FASTBLUEFALL EF_FASTBLUEFALL_90 EF_BIG_PORTAL
syn keyword hConstant EF_BIG_PORTAL2 EF_SCREEN_QUAKE EF_HOMUNCASTING EF_HFLIMOON1 EF_HFLIMOON2 EF_HFLIMOON3 EF_HO_UP
syn keyword hConstant EF_HAMIDEFENCE EF_HAMICASTLE EF_HAMIBLOOD EF_HATED2 EF_TWILIGHT1 EF_TWILIGHT2 EF_TWILIGHT3
syn keyword hConstant EF_ITEM_THUNDER EF_ITEM_CLOUD EF_ITEM_CURSE EF_ITEM_ZZZ EF_ITEM_RAIN EF_ITEM_LIGHT EF_ANGEL3
syn keyword hConstant EF_M01 EF_M02 EF_M03 EF_M04 EF_M05 EF_M06 EF_M07 EF_KAIZEL EF_KAAHI EF_CLOUD6 EF_FOOD01 EF_FOOD02
syn keyword hConstant EF_FOOD03 EF_FOOD04 EF_FOOD05 EF_FOOD06 EF_SHRINK EF_THROWITEM6 EF_SIGHT2 EF_QUAKEBODY4
syn keyword hConstant EF_FIREHIT2 EF_NPC_STOP2 EF_NPC_STOP2_DEL EF_FVOICE EF_WINK EF_COOKING_OK EF_COOKING_FAIL
syn keyword hConstant EF_TEMP_OK EF_TEMP_FAIL EF_HAPGYEOK EF_THROWITEM7 EF_THROWITEM8 EF_THROWITEM9 EF_THROWITEM10
syn keyword hConstant EF_BUNSINJYUTSU EF_KOUENKA EF_HYOUSENSOU EF_BOTTOM_SUITON EF_STIN4 EF_THUNDERSTORM2 EF_CHEMICAL4
syn keyword hConstant EF_STIN5 EF_MADNESS_BLUE EF_MADNESS_RED EF_RG_COIN3 EF_BASH3D5 EF_CHOOKGI3 EF_KIRIKAGE EF_TATAMI
syn keyword hConstant EF_KASUMIKIRI EF_ISSEN EF_KAEN EF_BAKU EF_HYOUSYOURAKU EF_DESPERADO EF_LIGHTNING_S EF_BLIND_S
syn keyword hConstant EF_POISON_S EF_FREEZING_S EF_FLARE_S EF_RAPIDSHOWER EF_MAGICALBULLET EF_SPREADATTACK
syn keyword hConstant EF_TRACKCASTING EF_TRACKING EF_TRIPLEACTION EF_BULLSEYE EF_MAP_MAGICZONE EF_MAP_MAGICZONE2
syn keyword hConstant EF_DAMAGE1 EF_DAMAGE1_2 EF_DAMAGE1_3 EF_UNDEADBODY EF_UNDEADBODY_DEL EF_GREEN_NUMBER
syn keyword hConstant EF_BLUE_NUMBER EF_RED_NUMBER EF_PURPLE_NUMBER EF_BLACK_NUMBER EF_WHITE_NUMBER EF_YELLOW_NUMBER
syn keyword hConstant EF_PINK_NUMBER EF_BUBBLE_DROP EF_NPC_EARTHQUAKE EF_DA_SPACE EF_DRAGONFEAR EF_BLEEDING
syn keyword hConstant EF_WIDECONFUSE EF_BOTTOM_RUNNER EF_BOTTOM_TRANSFER EF_CRYSTAL_BLUE EF_BOTTOM_EVILLAND EF_GUARD3
syn keyword hConstant EF_NPC_SLOWCAST EF_CRITICALWOUND EF_GREEN99_3 EF_GREEN99_5 EF_GREEN99_6 EF_MAPSPHERE EF_POK_LOVE
syn keyword hConstant EF_POK_WHITE EF_POK_VALEN EF_POK_BIRTH EF_POK_CHRISTMAS EF_MAP_MAGICZONE3 EF_MAP_MAGICZONE4
syn keyword hConstant EF_DUST EF_TORCH_RED EF_TORCH_GREEN EF_MAP_GHOST EF_GLOW1 EF_GLOW2 EF_GLOW4 EF_TORCH_PURPLE
syn keyword hConstant EF_CLOUD7 EF_CLOUD8 EF_FLOWERLEAF EF_MAPSPHERE2 EF_GLOW11 EF_GLOW12 EF_CIRCLELIGHT EF_ITEM315
syn keyword hConstant EF_ITEM316 EF_ITEM317 EF_ITEM318 EF_STORM_MIN EF_POK_JAP EF_MAP_GREENLIGHT EF_MAP_MAGICWALL
syn keyword hConstant EF_MAP_GREENLIGHT2 EF_YELLOWFLY1 EF_YELLOWFLY2 EF_BOTTOM_BLUE EF_BOTTOM_BLUE2 EF_WEWISH
syn keyword hConstant EF_FIREPILLARON2 EF_FORESTLIGHT5 EF_SOULBREAKER3 EF_ADO_STR EF_IGN_STR EF_CHIMTO2 EF_WINDCUTTER
syn keyword hConstant EF_DETECT2 EF_FROSTMYSTY EF_CRIMSON_STR EF_HELL_STR EF_SPR_MASH EF_SPR_SOULE EF_DHOWL_STR
syn keyword hConstant EF_EARTHWALL EF_SOULBREAKER4 EF_CHAINL_STR EF_CHOOKGI_FIRE EF_CHOOKGI_WIND EF_CHOOKGI_WATER
syn keyword hConstant EF_CHOOKGI_GROUND EF_MAGENTA_TRAP EF_COBALT_TRAP EF_MAIZE_TRAP EF_VERDURE_TRAP EF_NORMAL_TRAP
syn keyword hConstant EF_CLOAKING2 EF_AIMED_STR EF_ARROWSTORM_STR EF_LAULAMUS_STR EF_LAUAGNUS_STR EF_MILSHIELD_STR
syn keyword hConstant EF_CONCENTRATION2 EF_FIREBALL2 EF_BUNSINJYUTSU2 EF_CLEARTIME EF_GLASSWALL3 EF_ORATIO
syn keyword hConstant EF_POTION_BERSERK2 EF_CIRCLEPOWER EF_ROLLING1 EF_ROLLING2 EF_ROLLING3 EF_ROLLING4 EF_ROLLING5
syn keyword hConstant EF_ROLLING6 EF_ROLLING7 EF_ROLLING8 EF_ROLLING9 EF_ROLLING10 EF_PURPLEBODY EF_STIN6 EF_RG_COIN4
syn keyword hConstant EF_POISONWAV EF_POISONSMOKE EF_GUMGANG4 EF_SHIELDBOOMERANG4 EF_CASTSPIN2 EF_VULCANWAV EF_AGIUP2
syn keyword hConstant EF_DETECT3 EF_AGIUP3 EF_DETECT4 EF_ELECTRIC3 EF_GUARD4 EF_BOTTOM_BARRIER EF_BOTTOM_STEALTH
syn keyword hConstant EF_REPAIRTIME EF_NC_ANAL EF_FIRETHROW EF_VENOMIMPRESS EF_FROSTMISTY EF_BURNING EF_COLDTHROW
syn keyword hConstant EF_MAKEHALLU EF_HALLUTIME EF_INFRAREDSCAN EF_CRASHAXE EF_GTHUNDER EF_STONERING EF_INTIMIDATE2
syn keyword hConstant EF_STASIS EF_REDLINE EF_FROSTDIVER3 EF_BOTTOM_BASILICA2 EF_RECOGNIZED EF_TETRA EF_TETRACASTING
syn keyword hConstant EF_FIREBALL3 EF_INTIMIDATE3 EF_RECOGNIZED2 EF_CLOAKING3 EF_INTIMIDATE4 EF_STRETCH EF_BLACKBODY
syn keyword hConstant EF_ENERVATION EF_ENERVATION2 EF_ENERVATION3 EF_ENERVATION4 EF_ENERVATION5 EF_ENERVATION6
syn keyword hConstant EF_LINELINK4 EF_RG_COIN5 EF_WATERFALL_ANI EF_BOTTOM_MANHOLE EF_MANHOLE EF_MAKEFEINT
syn keyword hConstant EF_FORESTLIGHT6 EF_DARKCASTING2 EF_BOTTOM_ANI EF_BOTTOM_MAELSTROM EF_BOTTOM_BLOODYLUST
syn keyword hConstant EF_BEGINSPELL_N1 EF_BEGINSPELL_N2 EF_HEAL_N EF_CHOOKGI_N EF_JOBLVUP50_2 EF_CHEMICAL2DASH2
syn keyword hConstant EF_CHEMICAL2DASH3 EF_ROLLINGCAST EF_WATER_BELOW EF_WATER_FADE EF_BEGINSPELL_N3 EF_BEGINSPELL_N4
syn keyword hConstant EF_BEGINSPELL_N5 EF_BEGINSPELL_N6 EF_BEGINSPELL_N7 EF_BEGINSPELL_N8 EF_WATER_SMOKE EF_DANCE1
syn keyword hConstant EF_DANCE2 EF_LINKPARTICLE EF_SOULLIGHT2 EF_SPR_PARTICLE EF_SPR_PARTICLE2 EF_SPR_PLANT
syn keyword hConstant EF_CHEMICAL_V EF_SHOOTPARTICLE EF_BOT_REVERB EF_RAIN_PARTICLE EF_CHEMICAL_V2 EF_SECRA
syn keyword hConstant EF_BOT_REVERB2 EF_CIRCLEPOWER2 EF_SECRA2 EF_CHEMICAL_V3 EF_ENERVATION7 EF_CIRCLEPOWER3
syn keyword hConstant EF_SPR_PLANT2 EF_CIRCLEPOWER4 EF_SPR_PLANT3 EF_RG_COIN6 EF_SPR_PLANT4 EF_CIRCLEPOWER5
syn keyword hConstant EF_SPR_PLANT5 EF_CIRCLEPOWER6 EF_SPR_PLANT6 EF_CIRCLEPOWER7 EF_SPR_PLANT7 EF_CIRCLEPOWER8
syn keyword hConstant EF_SPR_PLANT8 EF_HEARTASURA EF_BEGINSPELL_150 EF_LEVEL99_150 EF_PRIMECHARGE EF_GLASSWALL4
syn keyword hConstant EF_GRADIUS_LASER EF_BASH3D6 EF_GUMGANG5 EF_HITLINE8 EF_ELECTRIC4 EF_TEIHIT1T EF_SPINMOVE
syn keyword hConstant EF_FIREBALL4 EF_TRIPLEATTACK4 EF_CHEMICAL3S EF_GROUNDSHAKE EF_DQ9_CHARGE EF_DQ9_CHARGE2
syn keyword hConstant EF_DQ9_CHARGE3 EF_DQ9_CHARGE4 EF_BLUELINE EF_SELFSCROLL EF_SPR_LIGHTPRINT EF_PNG_TEST
syn keyword hConstant EF_BEGINSPELL_YB EF_CHEMICAL2DASH4 EF_GROUNDSHAKE2 EF_PRESSURE2 EF_RG_COIN7 EF_PRIMECHARGE2
syn keyword hConstant EF_PRIMECHARGE3 EF_PRIMECHARGE4 EF_GREENCASTING EF_WALLOFTHORN EF_FIREBALL5 EF_THROWITEM11
syn keyword hConstant EF_SPR_PLANT9 EF_DEMONICFIRE EF_DEMONICFIRE2 EF_DEMONICFIRE3 EF_HELLSPLANT EF_FIREWALL2 EF_VACUUM
syn keyword hConstant EF_SPR_PLANT10 EF_SPR_LIGHTPRINT2 EF_POISONSMOKE2 EF_MAKEHALLU2 EF_SHOCKWAVE2 EF_SPR_PLANT11
syn keyword hConstant EF_COLDTHROW2 EF_DEMONICFIRE4 EF_PRESSURE3 EF_LINKPARTICLE2 EF_SOULLIGHT3 EF_CHAREFFECT
syn keyword hConstant EF_GUMGANG6 EF_FIREBALL6 EF_GUMGANG7 EF_GUMGANG8 EF_GUMGANG9 EF_BOTTOM_DE2 EF_COLDSTATUS
syn keyword hConstant EF_SPR_LIGHTPRINT3 EF_WATERBALL3 EF_HEAL_N2 EF_RAIN_PARTICLE2 EF_CLOUD9 EF_YELLOWFLY3 EF_EL_GUST
syn keyword hConstant EF_EL_BLAST EF_EL_AQUAPLAY EF_EL_UPHEAVAL EF_EL_WILD_STORM EF_EL_CHILLY_AIR EF_EL_CURSED_SOIL
syn keyword hConstant EF_EL_COOLER EF_EL_TROPIC EF_EL_PYROTECHNIC EF_EL_PETROLOGY EF_EL_HEATER EF_POISON_MIST
syn keyword hConstant EF_ERASER_CUTTER EF_SILENT_BREEZE EF_MAGMA_FLOW EF_GRAYBODY EF_LAVA_SLIDE EF_SONIC_CLAW
syn keyword hConstant EF_TINDER_BREAKER EF_MIDNIGHT_FRENZY EF_MACRO EF_CHEMICAL_ALLRANGE EF_TETRA_FIRE EF_TETRA_WATER
syn keyword hConstant EF_TETRA_WIND EF_TETRA_GROUND EF_EMITTER EF_VOLCANIC_ASH EF_LEVEL99_ORB1 EF_LEVEL99_ORB2
syn keyword hConstant EF_LEVEL150 EF_LEVEL150_SUB EF_THROWITEM4_1 EF_THROW_HAPPOKUNAI EF_THROW_MULTIPLE_COIN
syn keyword hConstant EF_THROW_BAKURETSU EF_ROTATE_HUUMARANKA EF_ROTATE_BG EF_ROTATE_LINE_GRAY EF_2011RWC EF_2011RWC2
syn keyword hConstant EF_KAIHOU EF_GROUND_EXPLOSION EF_KG_KAGEHUMI EF_KO_ZENKAI_WATER EF_KO_ZENKAI_LAND
syn keyword hConstant EF_KO_ZENKAI_FIRE EF_KO_ZENKAI_WIND EF_KO_JYUMONJIKIRI EF_KO_SETSUDAN EF_RED_CROSS EF_KO_IZAYOI
syn keyword hConstant EF_ROTATE_LINE_BLUE EF_KG_KYOMU EF_KO_HUUMARANKA EF_BLUELIGHTBODY EF_KAGEMUSYA EF_OB_GENSOU
syn keyword hConstant EF_NO100_FIRECRACKER EF_KO_MAKIBISHI EF_KAIHOU1 EF_AKAITSUKI EF_ZANGETSU EF_GENSOU EF_HAT_EFFECT
syn keyword hConstant EF_CHERRYBLOSSOM EF_EVENT_CLOUD EF_RUN_MAKE_OK EF_RUN_MAKE_FAILURE EF_MIRESULT_MAKE_OK
syn keyword hConstant EF_MIRESULT_MAKE_FAIL EF_ALL_RAY_OF_PROTECTION EF_VENOMFOG EF_DUSTSTORM EF_GC_DARKCROW
syn keyword hConstant EF_RK_DRAGONBREATH_WATER EF_ALL_FULL_THROTTLE EF_SR_FLASHCOMBO EF_RK_LUXANIMA
syn keyword hConstant EF_SO_ELEMENTAL_SHIELD EF_AB_OFFERTORIUM EF_WL_TELEKINESIS_INTENSE EF_GN_ILLUSIONDOPING
syn keyword hConstant EF_NC_MAGMA_ERUPTION EF_LG_KINGS_GRACE EF_BLOODDRAIN2 EF_NPC_WIDEWEB EF_NPC_BURNT EF_NPC_CHILL
syn keyword hConstant EF_RA_UNLIMIT EF_AB_OFFERTORIUM_RING EF_SC_ESCAPE EF_WM_FRIGG_SONG EF_C_MAKER EF_HAMMER_OF_GOD
syn keyword hConstant EF_BANISHING_BUSTER EF_SLUGSHOT EF_D_TAIL EF_S_STORM WARPNPC
syn keyword hConstant 1_ETC_01 1_M_01 1_M_02 1_M_03 1_M_04 1_M_BARD 1_M_HOF 1_M_INNKEEPER 1_M_JOBGUIDER 1_M_JOBTESTER
syn keyword hConstant 1_M_KNIGHTMASTER 1_M_LIBRARYMASTER 1_M_MERCHANT 1_M_ORIENT01 1_M_PASTOR 1_M_PUBMASTER 1_M_SIZ
syn keyword hConstant 1_M_SMITH 1_M_WIZARD 1_M_YOUNGKNIGHT 1_F_01 1_F_02 1_F_03 1_F_04 1_F_GYPSY 1_F_LIBRARYGIRL
syn keyword hConstant 1_F_MARIA 1_F_MERCHANT_01 1_F_MERCHANT_02 1_F_ORIENT_01 1_F_ORIENT_02 1_F_ORIENT_03 1_F_ORIENT_04
syn keyword hConstant 1_F_PRIEST 1_F_PUBGIRL 4_DOG01 4_KID01 4_M_01 4_M_02 4_M_03 4_M_04 4_M_BARBER 4_M_ORIENT01
syn keyword hConstant 4_M_ORIENT02 4_F_01 4_F_02 4_F_03 4_F_04 4_F_MAID 4_F_SISTER 4W_KID 4W_M_01 4W_M_02 4W_M_03
syn keyword hConstant 4W_SAILOR 4W_F_01 8_F 8_F_GRANDMOTHER EFFECTLAUNCHER 8W_SOLDIER 1_M_MOC_LORD 1_M_PAY_ELDER
syn keyword hConstant 1_M_PRON_KING 4_M_MANAGER 4_M_MINISTER
syn keyword hConstant HIDDEN_NPC
syn keyword hConstant 4_F_KAFRA6 4_F_KAFRA5 4_F_KAFRA4 4_F_KAFRA3 4_F_KAFRA2 4_F_KAFRA1 2_M_THIEFMASTER 2_M_SWORDMASTER
syn keyword hConstant 2_M_PHARMACIST 2_M_MOLGENSTEIN 2_M_DYEINGER 2_F_MAGICMASTER 4_F_TELEPORTER 4_M_TELEPORTER
syn keyword hConstant HIDDEN_WARP_NPC
syn keyword hConstant 4_M_MUT2 4_M_SCIENCE 4_F_VALKYRIE2 4_M_UNCLEKNIGHT 4_M_YOUNGKNIGHT 2_MONEMUS 4_M_ATEIL
syn keyword hConstant 4_F_ANNIVERSARY 4_M_GREATPO 4_M_NOVELIST 4_M_CHAMPSOUL 4_M_OLDFRIAR 4_M_CRU_SOLD 4_M_CRU_KNT
syn keyword hConstant 4_M_CRU_HEAD 4_M_CRU_CRUA 4_M_KY_SOLD 4_M_KY_KNT 4_M_KY_HEAD 4_M_KY_KIYOM 4_M_BOSSCAT 4_M_BABYCAT
syn keyword hConstant 4W_F_KAFRA2 4_F_MUNAK 4_M_BONGUN 4_BEAR 4_BLUEWOLF 4_PECOPECO 4_M_JP_MID 4_M_JP_RUN 4_ORCLADY
syn keyword hConstant 4_ORCLADY2 4_ORCWARRIOR 4_ORCWARRIOR2 4_F_FAIRY 4_F_FAIRYKID 4_F_FAIRYKID2 4_F_FAIRYKID3
syn keyword hConstant 4_F_FAIRYKID4 4_F_FAIRYKID5 4_F_FAIRYKID6 4_M_FAIRYKID 4_M_FAIRYKID2 4_M_FAIRYKID3 4_M_FAIRYKID4
syn keyword hConstant 4_M_FAIRYKID5 4_M_FAIRYSOLDIER 4_M_TUFFOLD 4_MAN_BENKUNI 4_MAN_GALTUN 4_MAN_JERUTOO 4_MAN_LAVAIL
syn keyword hConstant 4_MAN_NITT 4_MAN_PIOM 4_MAN_PIOM2 4_M_DSTMAN 4_M_DSTMANDEAD 4_BABYLEOPARD 4_M_REDSWORD
syn keyword hConstant 4_MAN_PIOM3 4_M_FAIRYSOLDIER2 4_F_FAIRYSOLDIER 4_DRAGON_EGG 4_MIMIC 4_F_FAIRY1 4_F_GUILLOTINE
syn keyword hConstant 4_M_GUILLOTINE 4_M_KNIGHT_BLACK 4_M_KNIGHT_GOLD 4_M_KNIGHT_SILVER 4_SKULL_MUD 4_M_BRZ_INDIAN
syn keyword hConstant 4_F_BRZ_INDIAN 4_F_BRZ_INDOLD 4_M_BRZ_JACI 4_M_BRZ_MAN1 4_M_BRZ_MAN2 4_F_BRZ_WOMAN 4_M_MINSTREL
syn keyword hConstant 4_M_MINSTREL1 4_M_SHADOWCHASER 4_F_SHADOWCHASER 4_M_SURA 4_F_SURA 4_F_WANDERER 4_M_BARD
syn keyword hConstant 1_FLAG_NOFEAR 4_M_NOFEARGUY 4_MAN_PIOM6 4_MAN_PIOM4 4_MAN_PIOM5 4_MAN_GALTUN1 4_HUMAN_GERUTOO
syn keyword hConstant 4_M_ROKI 4_M_MERCAT1 4_M_MERCAT2 4_M_CATMAN1 4_M_CATMAN2 4_F_BRZ_WOMAN2 4_M_JP_DISH 4_F_JP_NOAH
syn keyword hConstant 4_F_JP_OZ 4_F_JP_CHROME 4_F_JP_RINNE 4_WHITETIGER 4_VENDING_MACHINE 4_MISTY 4_NECORING 4_ELEPHANT
syn keyword hConstant 4_F_NYDHOG 4_F_NYDHOG2 4_M_ROKI2 4_M_DOGTRAVELER 4_M_DOGTRAVELER2 4_F_DOGTRAVELER 4_M_RAFLE_GR
syn keyword hConstant 4_M_RAFLE_OLD 4_F_RAFLE_PK 4_M_LYINGDOG 4_F_MORAFINE1 4_F_MORAFINE2 4_M_RAFLE_OR 4_F_RAFLE_YE
syn keyword hConstant 4_M_RAFLE_VI 4_F_RAFLE_VI 4_M_ARDHA 4_CREEPER
syn keyword hConstant JP_RUFAKU JP_SUPIKA JP_SABIKU JP_ARUGORU JP_ARUNA JP_AIRI
syn keyword hConstant 4_M_DEWOLDMAN 4_M_DEWOLDWOMAN 4_M_DEWMAN 4_M_DEWWOMAN 4_M_DEWBOY 4_M_DEWGIRL 4_M_DEWZATICHIEF
syn keyword hConstant 4_M_DEWZATIMAN 4_M_ALCHE_E 4_MASK_SMOKEY 4_CAT_SAILOR1 4_CAT_SAILOR2 4_CAT_SAILOR3 4_CAT_SAILOR4
syn keyword hConstant 4_CAT_CHEF 4_CAT_MERMASTER 4_CRACK 4_ASTER 4_F_STARFISHGIRL 4_CAT_DOWN 4_CAT_REST 4_CAT_3COLOR
syn keyword hConstant 4_CAT_ADMIRAL 4_SOIL 4_F_ALCHE_A 4_CAT_ADV1 4_CAT_ADV2 4_CAT_SAILOR5 2_DROP_MACHINE
syn keyword hConstant 2_SLOT_MACHINE 2_VENDING_MACHINE1
syn keyword hConstant MOB_TOMB
syn keyword hConstant 4_MYSTCASE 4_M_SIT_NOVICE 4_OCTOPUS_LEG 4_F_NURSE 4_MAL_SOLDIER 4_MAL_CAPTAIN 4_MAL_BUDIDAI
syn keyword hConstant 4_M_MAYOR 4_M_BARYO_OLD 4_F_BARYO_OLD 4_F_BARYO_GIRL 4_M_BARYO_BOY 4_M_BARYO_MAN 4_F_BARYO_WOMAN
syn keyword hConstant 4_BARYO_CHIEF 4_MAL_KAFRA 4_M_MALAYA 4_F_MALAYA 4_F_PATIENT 4_M_PATIENT 4_F_KR_TIGER 4_M_KR_BOY
syn keyword hConstant 4_M_KAGE_OLD 4_WHIKEBAIN 4_EREND 4_RAWREL 4_ARMAIA 4_KAVAC 4_YGNIZEM 4_EREMES 4_MAGALETA
syn keyword hConstant 4_KATRINN 4_SHECIL 4_SEYREN 4_HARWORD 4_F_JP_CYNTHIA 4_M_JP_GUSTON 4_M_JP_BERKUT
syn keyword hConstant 4_F_JP_DARK_ADELAIDE 4_M_JP_DARK_DARIUS 4_M_JP_JESTER
syn keyword hConstant XMAS_SMOKEY_B XMAS_SMOKEY_R XMAS_SMOKEY_Y
syn keyword hConstant 4_F_CLOCKDOLL 4_F_FAIRY2 4_F_PINKWOMAN 4_FAIRYDEADLEAF 4_FROG 4_M_BLACKMAN 4_M_BLUEMAN
syn keyword hConstant 4_M_FAIRYANG 4_M_FAIRYAVANT 4_M_FAIRYFREAK 4_M_FAIRYKID6 4_M_FAIRYSCHOLAR 4_M_FAIRYSCHOLAR_DIRTY
syn keyword hConstant 4_M_FARIY_HISIE 4_M_FARIYKING 4_M_NEWOZ 4_M_OLIVER 4_M_PROFESSORWORM 4_M_REDMAN 4_F_GELKA
syn keyword hConstant 4_M_ROTERT 4_BLACKDRAGON 4_M_GUNSLINGER 4_F_GUNSLINGER 4_M_ARCHER 4_M_SWORDMAN 4_M_NINJA_RED
syn keyword hConstant 4_M_NINJA_BLUE 4_M_THIEF_RUMIN 4_M_NOV_RUMIN 4_F_MAYSEL 4_F_ACOLYTE 4_M_NOV_HUNT 4_F_GENETIC
syn keyword hConstant 4_F_TAEKWON 4_F_SWORDMAN 4_F_IU 4_M_RAGI 4_M_MELODY 4_TRACE 4_F_HIMEL 4_LEVITATEMAN 4_M_HEINRICH
syn keyword hConstant 4_M_ROYALGUARD 4_M_BARMUND 4_F_KHALITZBURG 4_F_HIMEL2 4_WHITEKNIGHT 4_COCO 4_M_ALADDIN 4_M_GENIE
syn keyword hConstant 4_F_GENIE 4_JP_MID_SWIM 4_JP_RUNE_SWIM 4_F_FENRIR 4_F_GEFFEN_FAY 4_F_IRIS 4_F_LUCILE
syn keyword hConstant 4_F_SARAH_BABY 4_GEFFEN_01 4_GEFFEN_02 4_GEFFEN_03 4_GEFFEN_04 4_GEFFEN_05 4_GEFFEN_06
syn keyword hConstant 4_GEFFEN_07 4_GEFFEN_08 4_GEFFEN_09 4_GEFFEN_10 4_GEFFEN_11 4_GEFFEN_12 4_GEFFEN_13 4_GEFFEN_14
syn keyword hConstant 4_M_CHAOS 4_M_CHIEF_IRIN 4_M_SAKRAY 4_M_SAKRAYROYAL 4_TOWER_01 4_TOWER_02 4_TOWER_03 4_TOWER_04
syn keyword hConstant 4_TOWER_05 4_TOWER_06 4_TOWER_07 4_TOWER_08 4_TOWER_09 4_TOWER_10 4_TOWER_11 4_TOWER_12
syn keyword hConstant 4_TOWER_13 8_F_GIRL 4_F_GODEMOM 4_F_GON 4_F_KID2 4_M_BIBI 4_M_GEF_SOLDIER 4_M_KID1
syn keyword hConstant 4_M_MOC_SOLDIER 4_M_PAY_SOLDIER 4_M_SEAMAN 4_M_SNOWMAN 4_F_05 4_M_05 4_M_06 4_F_06 4_M_PIERROT
syn keyword hConstant 4_M_KID2 4_F_KID3 4_M_SANTA 4_F_NACORURI 4_F_SHAMAN 4_F_KAFRA7
syn keyword hConstant GUILD_FLAG
syn keyword hConstant 1_SHADOW_NPC 4_F_07 4_F_JOB_ASSASSIN 4_F_JOB_BLACKSMITH 4_F_JOB_HUNTER 4_F_JOB_KNIGHT 4_F_NOVICE
syn keyword hConstant 4_M_JOB_ASSASSIN 4_M_JOB_BLACKSMITH 4_M_JOB_HUNTER 4_M_JOB_KNIGHT1 4_M_JOB_KNIGHT2 4_M_JOB_WIZARD
syn keyword hConstant 4_BAPHOMET 4_DARKLORD 4_DEVIRUCHI 8_DOPPEL 2_M_ALCHE 2_M_BARD_ORIENT 2_M_SAGE_B 2_M_SAGE_OLD
syn keyword hConstant 4_F_ALCHE 4_F_CRU 4_F_MONK 4_F_ROGUE 4_M_ALCHE_A 4_M_ALCHE_B 4_M_ALCHE_C 4_M_CRU 4_M_CRU_OLD
syn keyword hConstant 4_M_MONK 4_M_SAGE_A 4_M_SAGE_C 4_F_SON 4_F_JPN2 4_F_JPN 4_F_JPNCHIBI 4_F_JPNOBA2 4_F_JPNOBA
syn keyword hConstant 4_M_JPN2 4_M_JPN 4_M_JPNCHIBI 4_M_JPNOJI2 4_M_JPNOJI 8_M_JPNSOLDIER 8_M_JPNMASTER 4_F_JPNMU
syn keyword hConstant 4_F_TWGIRL 4_F_TWGRANDMOM 4_F_TWMASKGIRL 4_F_TWMIDWOMAN 4_M_TWBOY 4_M_TWMASKMAN 4_M_TWMIDMAN
syn keyword hConstant 4_M_TWOLDMAN 4_M_TWTEAMAN 4_M_YOYOROGUE 8_M_TWSOLDIER 4_F_UMGIRL 4_F_UMOLDWOMAN 4_F_UMWOMAN
syn keyword hConstant 4_M_UMCHIEF 4_M_UMDANCEKID2 4_M_UMDANCEKID 4_M_UMKID 4_M_UMOLDMAN 4_M_UMSOLDIER 4_M_SALVATION
syn keyword hConstant 4_F_NFDEADKAFRA 4_F_NFDEADMGCIAN 4_F_NFLOSTGIRL 4_M_NFDEADMAN2 4_M_NFDEADMAN 4_M_NFDEADSWDMAN
syn keyword hConstant 4_M_NFLOSTMAN 4_M_NFMAN 4_NFBAT 4_NFCOCK 4_NFCOFFIN 4_NFWISP 1_F_SIGNZISK 1_M_SIGN1 1_M_SIGNALCHE
syn keyword hConstant 1_M_SIGNART 1_M_SIGNMCNT 1_M_SIGNMONK2 1_M_SIGNMONK 1_M_SIGNROGUE 4_F_VALKYRIE
syn keyword hConstant TW_TOWER
syn keyword hConstant 2_M_OLDBLSMITH 4_F_CHNDOCTOR 4_F_CHNDRESS1 4_F_CHNDRESS2 4_F_CHNDRESS3 4_F_CHNWOMAN 4_M_CHN8GUEK
syn keyword hConstant 4_M_CHNCOOK 4_M_CHNGENERL 4_M_CHNMAN 4_M_CHNMONK 4_M_CHNOLD 4_M_CHNSOLDIER 4_M_DWARF
syn keyword hConstant 4_M_GRANDMONK 4_M_ROGUE 4_M_DOMINO 4_F_DOMINO 4_F_ZONDAGIRL 4_M_REIDIN_KURS 4_M_ZONDAOYAJI
syn keyword hConstant 4_M_BUDDHIST 2_BOARD1 2_BOARD2 2_BULLETIN_BOARD 4_F_THAIAYO 4_F_THAIGIRL 4_F_THAISHAMAN
syn keyword hConstant 4_M_THAIAYO 4_M_THAIOLD 4_M_THAIONGBAK
syn keyword hConstant CLEAR_NPC
syn keyword hConstant 4_F_RACING 4_F_EINOLD 4_M_EINOLD 4_M_EINMINER 4_M_DIEMAN 4_F_EINWOMAN 4_M_REPAIR 4_M_EIN_SOLDIER
syn keyword hConstant 4_M_YURI 4_M_EINMAN2 4_M_EINMAN 2_F_SIGN1 4_BOARD3 4_BULLETIN_BOARD2 4_F_AGENTKAFRA 4_F_KAFRA8
syn keyword hConstant 4_F_KAFRA9 4_F_LGTGIRL 4_F_LGTGRAND 4_F_OPERATION 4_LGTSCIENCE 4_M_LGTGRAND 4_M_LGTGUARD2
syn keyword hConstant 4_M_LGTGUARD 4_M_LGTMAN 4_M_LGTPOOR 4_M_OPERATION 4_M_PRESIDENT 4_M_REINDEER 4_M_ZONDAMAN
syn keyword hConstant 4_M_PECOKNIGHT 4_CAT 4_F_YUNYANG 4_M_OILMAN 4_F_CAPEGIRL 4_M_MASKMAN 4_M_SITDOWN 4_F_SITDOWN
syn keyword hConstant 4_M_ALCHE_D 4_M_ACROSS 4_F_ACROSS 4_COOK 4_M_LIEMAN 2_POSTBOX 4_BULL 4_LAM 4_F_HUGIRL
syn keyword hConstant 4_F_HUGRANMA 4_F_HUWOMAN 4_F_KHELLISIA 4_F_KHELLY 4_M_HUBOY 4_M_HUGRANFA 4_M_HUMAN_01
syn keyword hConstant 4_M_HUMAN_02 4_M_HUMERCHANT 4_M_HUOLDARMY 4_M_KHKIEL 4_M_KHKYEL 4_M_KHMAN 4_F_KHWOMAN 4_F_KHGIRL
syn keyword hConstant 4_M_KHBOY 4_M_PHILMAN 4_PORING 2_COLAVEND 4_F_SOCCER 4_M_SOCCER7 4_M_SOCCER9 4_F_CHILD 4_F_MADAME
syn keyword hConstant 4_F_MASK1 4_F_MASK 4_F_RACHOLD 4_F_SHABBY 4_F_TRAINEE 4_M_CHILD1 4_M_CHILD 4_M_DOCTOR 4_M_FROZEN1
syn keyword hConstant 4_M_FROZEN 4_M_MASK1 4_M_MASK 4_M_MIDDLE1 4_M_MIDDLE 4_M_RACHMAN2 4_M_RACHMAN1 4_M_RACHOLD1
syn keyword hConstant 4_M_RACHOLD 4_M_RASWORD 4_M_TRAINEE 4_F_ARUNA_POP 4_M_ARUNA_NFM1 4_DST_CAMEL 4_DST_SOLDIER
syn keyword hConstant 4_F_DESERT 4_F_DST_CHILD 4_F_DST_GRAND 4_M_DESERT 4_M_DST_CHILD 4_M_DST_GRAND 4_M_DST_MASTER
syn keyword hConstant 4_M_DST_TOUGH 4_ANGELING 4_ARCHANGELING 4_GHOSTRING 4_F_EDEN_MASTER 4_F_EDEN_OFFICER
syn keyword hConstant 4_M_EDEN_GUARDER 4_M_PATRICK 4_DONKEY 4_M_TRISTAN 4_WHITE_COW 4_F_RUSCHILD 4_F_RUSWOMAN1
syn keyword hConstant 4_F_RUSWOMAN2 4_F_RUSWOMAN3 4_M_RUSCHILD 4_M_GUSLIMAN 4_M_RUSBALD 4_M_RUSKING 4_M_RUSKNIGHT
syn keyword hConstant 4_M_RUSMAN1 4_M_RUSMAN2 4_M_DRAKE 4_F_BABAYAGA 4_F_RUSGREEN 4_RUS_DWOLF 1_FLAG_LION 1_FLAG_EAGLE
syn keyword hConstant 4_M_MIKID 4_BLUE_FLOWER 4_RED_FLOWER 4_YELL_FLOWER 4_F_CAVE1 4_F_MUT1 4_F_MUT2 4_F_SCIENCE
syn keyword hConstant 4_M_1STPRIN1 4_M_1STPRIN2 4_M_2NDPRIN1 4_M_2NDPRIN2 4_M_3RDPRIN1 4_M_3RDPRIN2 4_M_4THPRIN1
syn keyword hConstant 4_M_4THPRIN2 4_M_5THPRIN1 4_M_5THPRIN2 4_M_6THPRIN1 4_M_6THPRIN2 4_M_CASMAN1 4_M_CAVE1
syn keyword hConstant 4_M_MOCASS1 4_M_MOCASS2 4_M_MUT1 4_TOWER_14 4_TOWER_15 4_TOWER_16 4_TOWER_17 4_TREASURE_BOX
syn keyword hConstant ACADEMY_MASTER PORTAL THANATOS_BATTLE THANATOS_KEEP 4_F_LYDIA 4_LUDE 4_ALIZA 4_ALICE
syn keyword hConstant 4_ARCHER_SKEL 4_JACK 4_SOLDIER_SKEL 4_LOLI_RURI 4_M_SAKRAY_TIED 4_M_ANTONIO 4_M_COOKIE
syn keyword hConstant 4_M_BELIEVER01 4_F_BELIEVER01 4_M_BELIEVER02 4_ROPEPILE 4_BRICKPILE 4_WOODPILE 4_M_TAMARIN
syn keyword hConstant 4_M_DEATH 4_GHOST_STAND 4_GHOST_COLLAPSE 4_COOKIEHOUSE 4_F_SKULL06GIRL 4_NONMYSTCASE 4_F_KIMI
syn keyword hConstant 4_M_FROZEN_GC 4_M_FROZEN_KN 4_SNAKE_LORD 4_F_MOCBOY 4_F_RUNAIN 4_M_ROEL 4_F_SHALOSH 4_ENERGY_RED
syn keyword hConstant 4_ENERGY_BLUE 4_ENERGY_YELLOW 4_ENERGY_BLACK 4_ENERGY_WHITE 4_F_PERE01 4_JITTERBUG 4_SEA_OTTER
syn keyword hConstant 4_GALAPAGO 4_DESERTWOLF_B 4_BB_PORING 4_F_CHARLESTON01 4_F_CHARLESTON02 4_F_CHARLESTON03 4_M_IAN
syn keyword hConstant 4_M_OLDSCHOLAR 4_F_LAPERM 4_M_DEBON 4_M_BIRMAN 4_F_SHAM 4_M_REBELLION 4_F_REBELLION 4_CHN_SHAOTH
syn keyword hConstant 4_SHOAL 4_F_SARAH 4_GIGANTES_BIG 4_GIGANTES 4_GIGANTES_SMALL 4_GARGOYLE_STATUE
syn keyword hConstant MER_LIF MER_AMISTR MER_FILIR MER_VANILMIRTH MER_LIF2 MER_AMISTR2 MER_FILIR2 MER_VANILMIRTH2
syn keyword hConstant MER_LIF_H MER_AMISTR_H MER_FILIR_H MER_VANILMIRTH_H MER_LIF_H2 MER_AMISTR_H2 MER_FILIR_H2
syn keyword hConstant MER_VANILMIRTH_H2 MER_ARCHER01 MER_ARCHER02 MER_ARCHER03 MER_ARCHER04 MER_ARCHER05 MER_ARCHER06
syn keyword hConstant MER_ARCHER07 MER_ARCHER08 MER_ARCHER09 MER_ARCHER10 MER_LANCER01 MER_LANCER02 MER_LANCER03
syn keyword hConstant MER_LANCER04 MER_LANCER05 MER_LANCER06 MER_LANCER07 MER_LANCER08 MER_LANCER09 MER_LANCER10
syn keyword hConstant MER_SWORDMAN01 MER_SWORDMAN02 MER_SWORDMAN03 MER_SWORDMAN04 MER_SWORDMAN05 MER_SWORDMAN06
syn keyword hConstant MER_SWORDMAN07 MER_SWORDMAN08 MER_SWORDMAN09 MER_SWORDMAN10 HAVEQUEST PLAYTIME HUNTING
syn keyword hConstant QTYPE_NONE QTYPE_QUEST QTYPE_QUEST2 QTYPE_JOB QTYPE_JOB2 QTYPE_EVENT QTYPE_EVENT2 QTYPE_WARG
syn keyword hConstant QTYPE_WARG2
syn keyword hConstant FW_DONTCARE FW_THIN FW_EXTRALIGHT FW_LIGHT FW_NORMAL FW_MEDIUM FW_SEMIBOLD FW_BOLD FW_EXTRABOLD
syn keyword hConstant FW_HEAVY
syn keyword hConstant VAR_HEAD VAR_WEAPON VAR_HEAD_TOP VAR_HEAD_MID VAR_HEAD_BOTTOM VAR_HEADPALETTE VAR_BODYPALETTE
syn keyword hConstant VAR_SHIELD VAR_SHOES
syn keyword hConstant DIR_NORTH DIR_NORTHWEST DIR_WEST DIR_SOUTHWEST DIR_SOUTH DIR_SOUTHEAST DIR_EAST DIR_NORTHEAST
syn keyword hConstant IT_HEALING IT_USABLE IT_ETC IT_WEAPON IT_ARMOR IT_CARD IT_PETEGG IT_PETARMOR IT_AMMO
syn keyword hConstant IT_DELAYCONSUME IT_CASH
syn keyword hConstant HQO_OnLogout HQO_OnDeath HQO_OnMapChange
syn keyword hConstant IOT_NONE IOT_CHAR IOT_PARTY IOT_GUILD false true

" Maps (imported from db/map_index.txt)
syn match hMapName contained display "\%(alb_ship\|alb2trea\|alberta\|alberta_in\|alde_dun01\|alde_dun02\|alde_dun03\)"
syn match hMapName contained display "\%(alde_dun04\|aldeba_in\|aldebaran\|anthell01\|anthell02\|arena_room\)"
syn match hMapName contained display "\%(c_tower1\|c_tower2\|c_tower3\|c_tower4\|force_1-1\|force_1-2\|force_1-3\)"
syn match hMapName contained display "\%(force_2-1\|force_2-2\|force_2-3\|force_3-1\|force_3-2\|force_3-3\|gef_dun00\)"
syn match hMapName contained display "\%(gef_dun01\|gef_dun02\|gef_dun03\|gef_fild00\|gef_fild01\|gef_fild02\)"
syn match hMapName contained display "\%(gef_fild03\|gef_fild04\|gef_fild05\|gef_fild06\|gef_fild07\|gef_fild08\)"
syn match hMapName contained display "\%(gef_fild09\|gef_fild10\|gef_fild11\|gef_fild12\|gef_fild13\|gef_fild14\)"
syn match hMapName contained display "\%(gef_tower\|geffen\|geffen_in\|gl_cas01\|gl_cas02\|gl_church\|gl_chyard\)"
syn match hMapName contained display "\%(gl_dun01\|gl_dun02\|gl_in01\|gl_knt01\|gl_knt02\|gl_prison\|gl_prison1\)"
syn match hMapName contained display "\%(gl_sew01\|gl_sew02\|gl_sew03\|gl_sew04\|gl_step\|glast_01\|hunter_1-1\)"
syn match hMapName contained display "\%(hunter_2-1\|hunter_3-1\|in_hunter\|in_moc_16\|in_orcs01\|in_sphinx1\)"
syn match hMapName contained display "\%(in_sphinx2\|in_sphinx3\|in_sphinx4\|in_sphinx5\|iz_dun00\|iz_dun01\)"
syn match hMapName contained display "\%(iz_dun02\|iz_dun03\|iz_dun04\|job_sword1\|izlu2dun\|izlude\|izlude_in\)"
syn match hMapName contained display "\%(job_thief1\|knight_1-1\|knight_2-1\|knight_3-1\|mjo_dun01\|mjo_dun02\)"
syn match hMapName contained display "\%(mjo_dun03\|mjolnir_01\|mjolnir_02\|mjolnir_03\|mjolnir_04\|mjolnir_05\)"
syn match hMapName contained display "\%(mjolnir_06\|mjolnir_07\|mjolnir_08\|mjolnir_09\|mjolnir_10\|mjolnir_11\)"
syn match hMapName contained display "\%(mjolnir_12\|moc_castle\|moc_fild01\|moc_fild02\|moc_fild03\|moc_fild04\)"
syn match hMapName contained display "\%(moc_fild05\|moc_fild06\|moc_fild07\|moc_fild08\|moc_fild09\|moc_fild10\)"
syn match hMapName contained display "\%(moc_fild11\|moc_fild12\|moc_fild13\|moc_fild14\|moc_fild15\|moc_fild16\)"
syn match hMapName contained display "\%(moc_fild17\|moc_fild18\|moc_fild19\|moc_pryd01\|moc_pryd02\|moc_pryd03\)"
syn match hMapName contained display "\%(moc_pryd04\|moc_pryd05\|moc_pryd06\|moc_prydb1\|moc_ruins\|monk_in\|morocc\)"
syn match hMapName contained display "\%(morocc_in\|new_1-1\|new_1-2\|new_1-3\|new_1-4\|new_2-1\|new_2-2\|new_2-3\)"
syn match hMapName contained display "\%(new_2-4\|new_3-1\|new_3-2\|new_3-3\|new_3-4\|new_4-1\|new_4-2\|new_4-3\)"
syn match hMapName contained display "\%(new_4-4\|new_5-1\|new_5-2\|new_5-3\|new_5-4\|orcsdun01\|orcsdun02\)"
syn match hMapName contained display "\%(ordeal_1-1\|ordeal_1-2\|ordeal_2-1\|ordeal_2-2\|ordeal_3-1\|ordeal_3-2\)"
syn match hMapName contained display "\%(pay_arche\|pay_dun00\|pay_dun01\|pay_dun02\|pay_dun03\|pay_dun04\)"
syn match hMapName contained display "\%(pay_fild01\|pay_fild02\|pay_fild03\|pay_fild04\|pay_fild05\|pay_fild06\)"
syn match hMapName contained display "\%(pay_fild07\|pay_fild08\|pay_fild09\|pay_fild10\|pay_fild11\|payon\)"
syn match hMapName contained display "\%(payon_in01\|payon_in02\|priest_1-1\|priest_2-1\|priest_3-1\|prontera\)"
syn match hMapName contained display "\%(prt_are_in\|prt_are01\|pvp_room\|prt_castle\|prt_church\|prt_fild00\)"
syn match hMapName contained display "\%(prt_fild01\|prt_fild02\|prt_fild03\|prt_fild04\|prt_fild05\|prt_fild06\)"
syn match hMapName contained display "\%(prt_fild07\|prt_fild08\|prt_fild09\|prt_fild10\|prt_fild11\|prt_in\)"
syn match hMapName contained display "\%(prt_maze01\|prt_maze02\|prt_maze03\|prt_monk\|prt_sewb1\|prt_sewb2\)"
syn match hMapName contained display "\%(prt_sewb3\|prt_sewb4\|pvp_2vs2\|pvp_c_room\|pvp_n_1-1\|pvp_n_1-2\|pvp_n_1-3\)"
syn match hMapName contained display "\%(pvp_n_1-4\|pvp_n_1-5\|pvp_n_2-1\|pvp_n_2-2\|pvp_n_2-3\|pvp_n_2-4\|pvp_n_2-5\)"
syn match hMapName contained display "\%(pvp_n_3-1\|pvp_n_3-2\|pvp_n_3-3\|pvp_n_3-4\|pvp_n_3-5\|pvp_n_4-1\|pvp_n_4-2\)"
syn match hMapName contained display "\%(pvp_n_4-3\|pvp_n_4-4\|pvp_n_4-5\|pvp_n_5-1\|pvp_n_5-2\|pvp_n_5-3\|pvp_n_5-4\)"
syn match hMapName contained display "\%(pvp_n_5-5\|pvp_n_6-1\|pvp_n_6-2\|pvp_n_6-3\|pvp_n_6-4\|pvp_n_6-5\|pvp_n_7-1\)"
syn match hMapName contained display "\%(pvp_n_7-2\|pvp_n_7-3\|pvp_n_7-4\|pvp_n_7-5\|pvp_n_8-1\|pvp_n_8-2\|pvp_n_8-3\)"
syn match hMapName contained display "\%(pvp_n_8-4\|pvp_n_8-5\|pvp_n_room\|pvp_y_1-1\|pvp_y_1-2\|pvp_y_1-3\)"
syn match hMapName contained display "\%(pvp_y_1-4\|pvp_y_1-5\|pvp_y_2-1\|pvp_y_2-2\|pvp_y_2-3\|pvp_y_2-4\|pvp_y_2-5\)"
syn match hMapName contained display "\%(pvp_y_3-1\|pvp_y_3-2\|pvp_y_3-3\|pvp_y_3-4\|pvp_y_3-5\|pvp_y_4-1\|pvp_y_4-2\)"
syn match hMapName contained display "\%(pvp_y_4-3\|pvp_y_4-4\|pvp_y_4-5\|pvp_y_5-1\|pvp_y_5-2\|pvp_y_5-3\|pvp_y_5-4\)"
syn match hMapName contained display "\%(pvp_y_5-5\|pvp_y_6-1\|pvp_y_6-2\|pvp_y_6-3\|pvp_y_6-4\|pvp_y_6-5\|pvp_y_7-1\)"
syn match hMapName contained display "\%(pvp_y_7-2\|pvp_y_7-3\|pvp_y_7-4\|pvp_y_7-5\|pvp_y_8-1\|pvp_y_8-2\|pvp_y_8-3\)"
syn match hMapName contained display "\%(pvp_y_8-4\|pvp_y_8-5\|pvp_y_room\|sword_1-1\|sword_2-1\|sword_3-1\)"
syn match hMapName contained display "\%(treasure01\|treasure02\|wizard_1-1\|wizard_2-1\|wizard_3-1\|xmas\)"
syn match hMapName contained display "\%(xmas_dun01\|xmas_dun02\|xmas_fild01\|xmas_in\|beach_dun\|beach_dun2\)"
syn match hMapName contained display "\%(beach_dun3\|cmd_fild01\|cmd_fild02\|cmd_fild03\|cmd_fild04\|cmd_fild05\)"
syn match hMapName contained display "\%(cmd_fild06\|cmd_fild07\|cmd_fild08\|cmd_fild09\|cmd_in01\|cmd_in02\|comodo\)"
syn match hMapName contained display "\%(quiz_00\|quiz_01\|g_room1-1\|g_room1-2\|g_room1-3\|g_room2\|tur_dun01\)"
syn match hMapName contained display "\%(tur_dun02\|tur_dun03\|tur_dun04\|tur_dun05\|tur_dun06\|alde_gld\)"
syn match hMapName contained display "\%(aldeg_cas01\|aldeg_cas02\|aldeg_cas03\|aldeg_cas04\|aldeg_cas05\|gefg_cas01\)"
syn match hMapName contained display "\%(gefg_cas02\|gefg_cas03\|gefg_cas04\|gefg_cas05\|gld_dun01\|gld_dun02\)"
syn match hMapName contained display "\%(gld_dun03\|gld_dun04\|guild_room\|guild_vs1\|guild_vs2\|guild_vs3\)"
syn match hMapName contained display "\%(guild_vs4\|guild_vs5\|guild_vs1-1\|guild_vs1-2\|guild_vs1-3\|guild_vs1-4\)"
syn match hMapName contained display "\%(guild_vs2-1\|guild_vs2-2\|job_hunte\|job_knt\|job_prist\|job_wiz\|pay_gld\)"
syn match hMapName contained display "\%(payg_cas01\|payg_cas02\|payg_cas03\|payg_cas04\|payg_cas05\|prt_gld\)"
syn match hMapName contained display "\%(prtg_cas01\|prtg_cas02\|prtg_cas03\|prtg_cas04\|prtg_cas05\|alde_alche\)"
syn match hMapName contained display "\%(in_rogue\|job_cru\|job_duncer\|job_monk\|job_sage\|mag_dun01\|mag_dun02\)"
syn match hMapName contained display "\%(monk_test\|quiz_test\|yuno\|yuno_fild01\|yuno_fild02\|yuno_fild03\)"
syn match hMapName contained display "\%(yuno_fild04\|yuno_in01\|yuno_in02\|yuno_in03\|yuno_in04\|yuno_in05\)"
syn match hMapName contained display "\%(ama_dun01\|ama_dun02\|ama_dun03\|ama_fild01\|ama_in01\|ama_in02\|ama_test\)"
syn match hMapName contained display "\%(amatsu\|gon_dun01\|gon_dun02\|gon_dun03\|gon_fild01\|gon_in\|gon_test\)"
syn match hMapName contained display "\%(gonryun\|sec_in01\|sec_in02\|sec_pri\|umbala\|um_dun01\|um_dun02\|um_fild01\)"
syn match hMapName contained display "\%(um_fild02\|um_fild03\|um_fild04\|um_in\|niflheim\|nif_fild01\|nif_fild02\)"
syn match hMapName contained display "\%(nif_in\|yggdrasil01\|valkyrie\|himinn\|lou_in01\|lou_in02\|lou_dun03\)"
syn match hMapName contained display "\%(lou_dun02\|lou_dun01\|lou_fild01\|louyang\|siege_test\|n_castle\|nguild_gef\)"
syn match hMapName contained display "\%(nguild_prt\|nguild_pay\|nguild_alde\|jawaii\|jawaii_in\|gefenia01\)"
syn match hMapName contained display "\%(gefenia02\|gefenia03\|gefenia04\|new_zone01\|new_zone02\|new_zone03\)"
syn match hMapName contained display "\%(new_zone04\|payon_in03\|ayothaya\|ayo_in01\|ayo_in02\|ayo_fild01\)"
syn match hMapName contained display "\%(ayo_fild02\|ayo_dun01\|ayo_dun02\|que_god01\|que_god02\|yuno_fild05\)"
syn match hMapName contained display "\%(yuno_fild07\|yuno_fild08\|yuno_fild09\|yuno_fild11\|yuno_fild12\|alde_tt02\)"
syn match hMapName contained display "\%(turbo_n_1\|turbo_n_4\|turbo_n_8\|turbo_n_16\|turbo_e_4\|turbo_e_8\)"
syn match hMapName contained display "\%(turbo_e_16\|turbo_room\|airplane\|airport\|einbech\|einbroch\|ein_dun01\)"
syn match hMapName contained display "\%(ein_dun02\|ein_fild06\|ein_fild07\|ein_fild08\|ein_fild09\|ein_fild10\)"
syn match hMapName contained display "\%(ein_in01\|que_sign01\|que_sign02\|ein_fild03\|ein_fild04\|lhz_fild02\)"
syn match hMapName contained display "\%(lhz_fild03\|yuno_pre\|lhz_fild01\|lighthalzen\|lhz_in01\|lhz_in02\|lhz_in03\)"
syn match hMapName contained display "\%(lhz_que01\|lhz_dun01\|lhz_dun02\|lhz_dun03\|lhz_cube\|juperos_01\)"
syn match hMapName contained display "\%(juperos_02\|jupe_area1\|jupe_area2\|jupe_core\|jupe_ele\|jupe_ele_r\)"
syn match hMapName contained display "\%(jupe_gate\|y_airport\|lhz_airport\|airplane_01\|jupe_cave\|quiz_02\)"
syn match hMapName contained display "\%(hu_fild07\|hu_fild05\|hu_fild04\|hu_fild01\|yuno_fild06\|job_soul\|job_star\)"
syn match hMapName contained display "\%(que_job01\|que_job02\|que_job03\|abyss_01\|abyss_02\|abyss_03\|thana_step\)"
syn match hMapName contained display "\%(thana_boss\|tha_scene01\|tha_t01\|tha_t02\|tha_t03\|tha_t04\|tha_t07\)"
syn match hMapName contained display "\%(tha_t05\|tha_t06\|tha_t08\|tha_t09\|tha_t10\|tha_t11\|tha_t12\|auction_01\)"
syn match hMapName contained display "\%(auction_02\|hugel\|hu_in01\|que_bingo\|que_hugel\|p_track01\|p_track02\)"
syn match hMapName contained display "\%(odin_tem01\|odin_tem02\|odin_tem03\|hu_fild02\|hu_fild03\|hu_fild06\)"
syn match hMapName contained display "\%(ein_fild01\|ein_fild02\|ein_fild05\|yuno_fild10\|kh_kiehl02\|kh_kiehl01\)"
syn match hMapName contained display "\%(kh_dun02\|kh_dun01\|kh_mansion\|kh_rossi\|kh_school\|kh_vila\|force_map1\)"
syn match hMapName contained display "\%(force_map2\|force_map3\|job_hunter\|job_knight\|job_priest\|job_wizard\)"
syn match hMapName contained display "\%(ve_in02\|rachel\|ra_in01\|ra_fild01\|ra_fild02\|ra_fild03\|ra_fild04\)"
syn match hMapName contained display "\%(ra_fild05\|ra_fild06\|ra_fild07\|ra_fild08\|ra_fild09\|ra_fild10\|ra_fild11\)"
syn match hMapName contained display "\%(ra_fild12\|ra_fild13\|ra_san01\|ra_san02\|ra_san03\|ra_san04\|ra_san05\)"
syn match hMapName contained display "\%(ra_temin\|ra_temple\|ra_temsky\|que_rachel\|ice_dun01\|ice_dun02\|ice_dun03\)"
syn match hMapName contained display "\%(ice_dun04\|que_thor\|thor_camp\|thor_v01\|thor_v02\|thor_v03\|veins\|ve_in\)"
syn match hMapName contained display "\%(ve_fild01\|ve_fild02\|ve_fild03\|ve_fild04\|ve_fild05\|ve_fild06\|ve_fild07\)"
syn match hMapName contained display "\%(poring_c01\|poring_c02\|que_ng\|nameless_i\|nameless_n\|nameless_in\)"
syn match hMapName contained display "\%(abbey01\|abbey02\|abbey03\|poring_w01\|poring_w02\|que_san04\|moscovia\)"
syn match hMapName contained display "\%(mosk_in\|mosk_ship\|mosk_fild01\|mosk_fild02\|mosk_dun01\|mosk_dun02\)"
syn match hMapName contained display "\%(mosk_dun03\|mosk_que\|force_4-1\|force_5-1\|06guild_r\|06guild_01\)"
syn match hMapName contained display "\%(06guild_02\|06guild_03\|06guild_04\|06guild_05\|06guild_06\|06guild_07\)"
syn match hMapName contained display "\%(06guild_08\|z_agit\|que_temsky\|itemmall\|bossnia_01\|bossnia_02\)"
syn match hMapName contained display "\%(bossnia_03\|bossnia_04\|schg_cas01\|schg_cas02\|schg_cas03\|schg_cas04\)"
syn match hMapName contained display "\%(schg_cas05\|sch_gld\|cave\|moc_fild20\|moc_fild21\|moc_fild22\|que_ba\)"
syn match hMapName contained display "\%(que_moc_16\|que_moon\|arug_cas01\|arug_cas02\|arug_cas03\|arug_cas04\)"
syn match hMapName contained display "\%(arug_cas05\|aru_gld\|bat_room\|bat_a01\|bat_a02\|bat_b01\|bat_b02\)"
syn match hMapName contained display "\%(que_qsch01\|que_qsch02\|que_qsch03\|que_qsch04\|que_qsch05\|que_qaru01\)"
syn match hMapName contained display "\%(que_qaru02\|que_qaru03\|que_qaru04\|que_qaru05\|1@cata\|2@cata\|e_tower\)"
syn match hMapName contained display "\%(1@tower\|2@tower\|3@tower\|4@tower\|5@tower\|6@tower\|mid_camp\|mid_campin\)"
syn match hMapName contained display "\%(man_fild01\|man_fild03\|spl_fild02\|spl_fild03\|moc_fild22b\|que_dan01\)"
syn match hMapName contained display "\%(que_dan02\|schg_que01\|schg_dun01\|arug_que01\|arug_dun01\|1@orcs\|2@orcs\)"
syn match hMapName contained display "\%(1@nyd\|2@nyd\|nyd_dun01\|nyd_dun02\|manuk\|man_fild02\|man_in01\|splendide\)"
syn match hMapName contained display "\%(spl_fild01\|spl_in01\|spl_in02\|bat_c01\|bat_c02\|bat_c03\|moc_para01\)"
syn match hMapName contained display "\%(job3_arch01\|job3_arch02\|job3_arch03\|job3_guil01\|job3_guil02\)"
syn match hMapName contained display "\%(job3_guil03\|job3_rang01\|job3_rang02\|job3_rune01\|job3_rune02\)"
syn match hMapName contained display "\%(job3_rune03\|job3_war01\|job3_war02\|jupe_core2\|brasilis\|bra_in01\)"
syn match hMapName contained display "\%(bra_fild01\|bra_dun01\|bra_dun02\|dicastes01\|dicastes02\|dic_in01\)"
syn match hMapName contained display "\%(dic_fild01\|dic_fild02\|dic_dun01\|dic_dun02\|job3_gen01\|s_atelier\)"
syn match hMapName contained display "\%(job3_sha01\|mora\|bif_fild01\|bif_fild02\|1@mist\|dewata\|dew_in01\)"
syn match hMapName contained display "\%(dew_fild01\|dew_dun01\|dew_dun02\|que_house_s\|malangdo\|mal_in01\|mal_in02\)"
syn match hMapName contained display "\%(mal_dun01\|1@pump\|2@pump\|1@cash\|iz_dun05\|evt_mobroom\|alde_tt03\)"
syn match hMapName contained display "\%(dic_dun03\|1@lhz\|lhz_dun04\|que_lhz\|gld_dun01_2\|gld_dun02_2\|gld_dun03_2\)"
syn match hMapName contained display "\%(gld_dun04_2\|gld2_ald\|gld2_gef\|gld2_pay\|gld2_prt\|malaya\|ma_fild01\)"
syn match hMapName contained display "\%(ma_fild02\|ma_scene01\|ma_in01\|ma_dun01\|1@ma_h\|1@ma_c\|1@ma_b\|ma_zif01\)"
syn match hMapName contained display "\%(ma_zif02\|ma_zif03\|ma_zif04\|ma_zif05\|ma_zif06\|ma_zif07\|ma_zif08\)"
syn match hMapName contained display "\%(ma_zif09\|job_ko\|eclage\|ecl_fild01\|ecl_in01\|ecl_in02\|ecl_in03\)"
syn match hMapName contained display "\%(ecl_in04\|1@ecl\|ecl_tdun01\|ecl_tdun02\|ecl_tdun03\|ecl_tdun04\|ecl_hub01\)"
syn match hMapName contained display "\%(que_avan01\|moc_prydn1\|moc_prydn2\|iz_int\|iz_int01\|iz_int02\|iz_int03\)"
syn match hMapName contained display "\%(iz_int04\|iz_ac01\|iz_ac02\|iz_ng01\|treasure_n1\|treasure_n2\|iz_ac01_d\)"
syn match hMapName contained display "\%(iz_ac02_d\|iz_ac01_c\|iz_ac02_c\|iz_ac01_b\|iz_ac02_b\|iz_ac01_a\|iz_ac02_a\)"
syn match hMapName contained display "\%(izlude_d\|izlude_c\|izlude_b\|izlude_a\|prt_fild08d\|prt_fild08c\)"
syn match hMapName contained display "\%(prt_fild08b\|prt_fild08a\|te_prt_gld\|te_prtcas01\|te_prtcas02\|te_prtcas03\)"
syn match hMapName contained display "\%(te_prtcas04\|te_prtcas05\|teg_dun01\|teg_dun02\|te_alde_gld\|te_aldecas1\)"
syn match hMapName contained display "\%(te_aldecas2\|te_aldecas3\|te_aldecas4\|te_aldecas5\|1@gl_k\|2@gl_k\)"
syn match hMapName contained display "\%(gl_cas02_\|gl_chyard_\|silk_lair\|evt_bomb\|1@def01\|1@def02\|1@def03\)"
syn match hMapName contained display "\%(1@face\|1@sara\|dali\|dali02\|1@tnm1\|1@tnm2\|1@tnm3\|1@ge_st\|1@gef\)"
syn match hMapName contained display "\%(1@gef_in\|1@spa\|moro_vol\|moro_cav\|1@dth1\|1@dth2\|1@dth3\|1@rev\|1@xm_d\)"
syn match hMapName contained display "\%(1@eom\|1@jtb\|c_tower2_\|c_tower3_\)"

" Skills (imported from db/*/skill_db.txt)
syn keyword hSkillId NV_BASIC SM_SWORD SM_TWOHAND SM_RECOVERY SM_BASH SM_PROVOKE SM_MAGNUM SM_ENDURE MG_SRECOVERY
syn keyword hSkillId MG_SIGHT MG_NAPALMBEAT MG_SAFETYWALL MG_SOULSTRIKE MG_COLDBOLT MG_FROSTDIVER MG_STONECURSE
syn keyword hSkillId MG_FIREBALL MG_FIREWALL MG_FIREBOLT MG_LIGHTNINGBOLT MG_THUNDERSTORM AL_DP AL_DEMONBANE AL_RUWACH
syn keyword hSkillId AL_PNEUMA AL_TELEPORT AL_WARP AL_HEAL AL_INCAGI AL_DECAGI AL_HOLYWATER AL_CRUCIS AL_ANGELUS
syn keyword hSkillId AL_BLESSING AL_CURE MC_INCCARRY MC_DISCOUNT MC_OVERCHARGE MC_PUSHCART MC_IDENTIFY MC_VENDING
syn keyword hSkillId MC_MAMMONITE AC_OWL AC_VULTURE AC_CONCENTRATION AC_DOUBLE AC_SHOWER TF_DOUBLE TF_MISS TF_STEAL
syn keyword hSkillId TF_HIDING TF_POISON TF_DETOXIFY ALL_RESURRECTION KN_SPEARMASTERY KN_PIERCE KN_BRANDISHSPEAR
syn keyword hSkillId KN_SPEARSTAB KN_SPEARBOOMERANG KN_TWOHANDQUICKEN KN_AUTOCOUNTER KN_BOWLINGBASH KN_RIDING
syn keyword hSkillId KN_CAVALIERMASTERY PR_MACEMASTERY PR_IMPOSITIO PR_SUFFRAGIUM PR_ASPERSIO PR_BENEDICTIO
syn keyword hSkillId PR_SANCTUARY PR_SLOWPOISON PR_STRECOVERY PR_KYRIE PR_MAGNIFICAT PR_GLORIA PR_LEXDIVINA
syn keyword hSkillId PR_TURNUNDEAD PR_LEXAETERNA PR_MAGNUS WZ_FIREPILLAR WZ_SIGHTRASHER WZ_METEOR WZ_JUPITEL
syn keyword hSkillId WZ_VERMILION WZ_WATERBALL WZ_ICEWALL WZ_FROSTNOVA WZ_STORMGUST WZ_EARTHSPIKE WZ_HEAVENDRIVE
syn keyword hSkillId WZ_QUAGMIRE WZ_ESTIMATION BS_IRON BS_STEEL BS_ENCHANTEDSTONE BS_ORIDEOCON BS_DAGGER BS_SWORD
syn keyword hSkillId BS_TWOHANDSWORD BS_AXE BS_MACE BS_KNUCKLE BS_SPEAR BS_HILTBINDING BS_FINDINGORE BS_WEAPONRESEARCH
syn keyword hSkillId BS_REPAIRWEAPON BS_SKINTEMPER BS_HAMMERFALL BS_ADRENALINE BS_WEAPONPERFECT BS_OVERTHRUST
syn keyword hSkillId BS_MAXIMIZE HT_SKIDTRAP HT_LANDMINE HT_ANKLESNARE HT_SHOCKWAVE HT_SANDMAN HT_FLASHER
syn keyword hSkillId HT_FREEZINGTRAP HT_BLASTMINE HT_CLAYMORETRAP HT_REMOVETRAP HT_TALKIEBOX HT_BEASTBANE HT_FALCON
syn keyword hSkillId HT_STEELCROW HT_BLITZBEAT HT_DETECTING HT_SPRINGTRAP AS_RIGHT AS_LEFT AS_KATAR AS_CLOAKING
syn keyword hSkillId AS_SONICBLOW AS_GRIMTOOTH AS_ENCHANTPOISON AS_POISONREACT AS_VENOMDUST AS_SPLASHER NV_FIRSTAID
syn keyword hSkillId NV_TRICKDEAD SM_MOVINGRECOVERY SM_FATALBLOW SM_AUTOBERSERK AC_MAKINGARROW AC_CHARGEARROW
syn keyword hSkillId TF_SPRINKLESAND TF_BACKSLIDING TF_PICKSTONE TF_THROWSTONE MC_CARTREVOLUTION MC_CHANGECART MC_LOUD
syn keyword hSkillId AL_HOLYLIGHT MG_ENERGYCOAT NPC_PIERCINGATT NPC_MENTALBREAKER NPC_RANGEATTACK NPC_ATTRICHANGE
syn keyword hSkillId NPC_CHANGEWATER NPC_CHANGEGROUND NPC_CHANGEFIRE NPC_CHANGEWIND NPC_CHANGEPOISON NPC_CHANGEHOLY
syn keyword hSkillId NPC_CHANGEDARKNESS NPC_CHANGETELEKINESIS NPC_CRITICALSLASH NPC_COMBOATTACK NPC_GUIDEDATTACK
syn keyword hSkillId NPC_SELFDESTRUCTION NPC_SPLASHATTACK NPC_SUICIDE NPC_POISON NPC_BLINDATTACK NPC_SILENCEATTACK
syn keyword hSkillId NPC_STUNATTACK NPC_PETRIFYATTACK NPC_CURSEATTACK NPC_SLEEPATTACK NPC_RANDOMATTACK NPC_WATERATTACK
syn keyword hSkillId NPC_GROUNDATTACK NPC_FIREATTACK NPC_WINDATTACK NPC_POISONATTACK NPC_HOLYATTACK NPC_DARKNESSATTACK
syn keyword hSkillId NPC_TELEKINESISATTACK NPC_MAGICALATTACK NPC_METAMORPHOSIS NPC_PROVOCATION NPC_SMOKING
syn keyword hSkillId NPC_SUMMONSLAVE NPC_EMOTION NPC_TRANSFORMATION NPC_BLOODDRAIN NPC_ENERGYDRAIN NPC_KEEPING
syn keyword hSkillId NPC_DARKBREATH NPC_DARKBLESSING NPC_BARRIER NPC_DEFENDER NPC_LICK NPC_HALLUCINATION NPC_REBIRTH
syn keyword hSkillId NPC_SUMMONMONSTER RG_SNATCHER RG_STEALCOIN RG_BACKSTAP RG_TUNNELDRIVE RG_RAID RG_STRIPWEAPON
syn keyword hSkillId RG_STRIPSHIELD RG_STRIPARMOR RG_STRIPHELM RG_INTIMIDATE RG_GRAFFITI RG_FLAGGRAFFITI RG_CLEANER
syn keyword hSkillId RG_GANGSTER RG_COMPULSION RG_PLAGIARISM AM_AXEMASTERY AM_LEARNINGPOTION AM_PHARMACY
syn keyword hSkillId AM_DEMONSTRATION AM_ACIDTERROR AM_POTIONPITCHER AM_CANNIBALIZE AM_SPHEREMINE AM_CP_WEAPON
syn keyword hSkillId AM_CP_SHIELD AM_CP_ARMOR AM_CP_HELM AM_BIOETHICS AM_CALLHOMUN AM_REST AM_RESURRECTHOMUN CR_TRUST
syn keyword hSkillId CR_AUTOGUARD CR_SHIELDCHARGE CR_SHIELDBOOMERANG CR_REFLECTSHIELD CR_HOLYCROSS CR_GRANDCROSS
syn keyword hSkillId CR_DEVOTION CR_PROVIDENCE CR_DEFENDER CR_SPEARQUICKEN MO_IRONHAND MO_SPIRITSRECOVERY
syn keyword hSkillId MO_CALLSPIRITS MO_ABSORBSPIRITS MO_TRIPLEATTACK MO_BODYRELOCATION MO_DODGE MO_INVESTIGATE
syn keyword hSkillId MO_FINGEROFFENSIVE MO_STEELBODY MO_BLADESTOP MO_EXPLOSIONSPIRITS MO_EXTREMITYFIST MO_CHAINCOMBO
syn keyword hSkillId MO_COMBOFINISH SA_ADVANCEDBOOK SA_CASTCANCEL SA_MAGICROD SA_SPELLBREAKER SA_FREECAST SA_AUTOSPELL
syn keyword hSkillId SA_FLAMELAUNCHER SA_FROSTWEAPON SA_LIGHTNINGLOADER SA_SEISMICWEAPON SA_DRAGONOLOGY SA_VOLCANO
syn keyword hSkillId SA_DELUGE SA_VIOLENTGALE SA_LANDPROTECTOR SA_DISPELL SA_ABRACADABRA SA_MONOCELL SA_CLASSCHANGE
syn keyword hSkillId SA_SUMMONMONSTER SA_REVERSEORCISH SA_DEATH SA_FORTUNE SA_TAMINGMONSTER SA_QUESTION SA_GRAVITY
syn keyword hSkillId SA_LEVELUP SA_INSTANTDEATH SA_FULLRECOVERY SA_COMA BD_ADAPTATION BD_ENCORE BD_LULLABY
syn keyword hSkillId BD_RICHMANKIM BD_ETERNALCHAOS BD_DRUMBATTLEFIELD BD_RINGNIBELUNGEN BD_ROKISWEIL BD_INTOABYSS
syn keyword hSkillId BD_SIEGFRIED BA_MUSICALLESSON BA_MUSICALSTRIKE BA_DISSONANCE BA_FROSTJOKER BA_WHISTLE
syn keyword hSkillId BA_ASSASSINCROSS BA_POEMBRAGI BA_APPLEIDUN DC_DANCINGLESSON DC_THROWARROW DC_UGLYDANCE DC_SCREAM
syn keyword hSkillId DC_HUMMING DC_DONTFORGETME DC_FORTUNEKISS DC_SERVICEFORYOU NPC_RANDOMMOVE NPC_SPEEDUP NPC_REVENGE
syn keyword hSkillId WE_MALE WE_FEMALE WE_CALLPARTNER ITM_TOMAHAWK NPC_DARKCROSS NPC_GRANDDARKNESS NPC_DARKSTRIKE
syn keyword hSkillId NPC_DARKTHUNDER NPC_STOP NPC_WEAPONBRAKER NPC_ARMORBRAKE NPC_HELMBRAKE NPC_SHIELDBRAKE
syn keyword hSkillId NPC_UNDEADATTACK NPC_CHANGEUNDEAD NPC_POWERUP NPC_AGIUP NPC_SIEGEMODE NPC_CALLSLAVE NPC_INVISIBLE
syn keyword hSkillId NPC_RUN LK_AURABLADE LK_PARRYING LK_CONCENTRATION LK_TENSIONRELAX LK_BERSERK HP_ASSUMPTIO
syn keyword hSkillId HP_BASILICA HP_MEDITATIO HW_SOULDRAIN HW_MAGICCRASHER HW_MAGICPOWER PA_PRESSURE PA_SACRIFICE
syn keyword hSkillId PA_GOSPEL CH_PALMSTRIKE CH_TIGERFIST CH_CHAINCRUSH PF_HPCONVERSION PF_SOULCHANGE PF_SOULBURN
syn keyword hSkillId ASC_KATAR ASC_EDP ASC_BREAKER SN_SIGHT SN_FALCONASSAULT SN_SHARPSHOOTING SN_WINDWALK WS_MELTDOWN
syn keyword hSkillId WS_CARTBOOST ST_CHASEWALK ST_REJECTSWORD CR_ALCHEMY CR_SYNTHESISPOTION CG_ARROWVULCAN CG_MOONLIT
syn keyword hSkillId CG_MARIONETTE LK_SPIRALPIERCE LK_HEADCRUSH LK_JOINTBEAT HW_NAPALMVULCAN CH_SOULCOLLECT
syn keyword hSkillId PF_MINDBREAKER PF_MEMORIZE PF_FOGWALL PF_SPIDERWEB ASC_METEORASSAULT ASC_CDP WE_BABY WE_CALLPARENT
syn keyword hSkillId WE_CALLBABY TK_RUN TK_READYSTORM TK_STORMKICK TK_READYDOWN TK_DOWNKICK TK_READYTURN TK_TURNKICK
syn keyword hSkillId TK_READYCOUNTER TK_COUNTER TK_DODGE TK_JUMPKICK TK_HPTIME TK_SPTIME TK_POWER TK_SEVENWIND
syn keyword hSkillId TK_HIGHJUMP SG_FEEL SG_SUN_WARM SG_MOON_WARM SG_STAR_WARM SG_SUN_COMFORT SG_MOON_COMFORT
syn keyword hSkillId SG_STAR_COMFORT SG_HATE SG_SUN_ANGER SG_MOON_ANGER SG_STAR_ANGER SG_SUN_BLESS SG_MOON_BLESS
syn keyword hSkillId SG_STAR_BLESS SG_DEVIL SG_FRIEND SG_KNOWLEDGE SG_FUSION SL_ALCHEMIST AM_BERSERKPITCHER SL_MONK
syn keyword hSkillId SL_STAR SL_SAGE SL_CRUSADER SL_SUPERNOVICE SL_KNIGHT SL_WIZARD SL_PRIEST SL_BARDDANCER SL_ROGUE
syn keyword hSkillId SL_ASSASIN SL_BLACKSMITH BS_ADRENALINE2 SL_HUNTER SL_SOULLINKER SL_KAIZEL SL_KAAHI SL_KAUPE
syn keyword hSkillId SL_KAITE SL_KAINA SL_STIN SL_STUN SL_SMA SL_SWOO SL_SKE SL_SKA SM_SELFPROVOKE NPC_EMOTION_ON
syn keyword hSkillId ST_PRESERVE ST_FULLSTRIP WS_WEAPONREFINE CR_SLIMPITCHER CR_FULLPROTECTION PA_SHIELDCHAIN
syn keyword hSkillId HP_MANARECHARGE PF_DOUBLECASTING HW_GANBANTEIN HW_GRAVITATION WS_CARTTERMINATION WS_OVERTHRUSTMAX
syn keyword hSkillId CG_LONGINGFREEDOM CG_HERMODE CG_TAROTCARD CR_ACIDDEMONSTRATION CR_CULTIVATION ITEM_ENCHANTARMS
syn keyword hSkillId TK_MISSION SL_HIGH KN_ONEHAND AM_TWILIGHT1 AM_TWILIGHT2 AM_TWILIGHT3 HT_POWER GS_GLITTERING
syn keyword hSkillId GS_FLING GS_TRIPLEACTION GS_BULLSEYE GS_MADNESSCANCEL GS_ADJUSTMENT GS_INCREASING GS_MAGICALBULLET
syn keyword hSkillId GS_CRACKER GS_SINGLEACTION GS_SNAKEEYE GS_CHAINACTION GS_TRACKING GS_DISARM GS_PIERCINGSHOT
syn keyword hSkillId GS_RAPIDSHOWER GS_DESPERADO GS_GATLINGFEVER GS_DUST GS_FULLBUSTER GS_SPREADATTACK GS_GROUNDDRIFT
syn keyword hSkillId NJ_TOBIDOUGU NJ_SYURIKEN NJ_KUNAI NJ_HUUMA NJ_ZENYNAGE NJ_TATAMIGAESHI NJ_KASUMIKIRI NJ_SHADOWJUMP
syn keyword hSkillId NJ_KIRIKAGE NJ_UTSUSEMI NJ_BUNSINJYUTSU NJ_NINPOU NJ_KOUENKA NJ_KAENSIN NJ_BAKUENRYU NJ_HYOUSENSOU
syn keyword hSkillId NJ_SUITON NJ_HYOUSYOURAKU NJ_HUUJIN NJ_RAIGEKISAI NJ_KAMAITACHI NJ_NEN NJ_ISSEN NPC_EARTHQUAKE
syn keyword hSkillId NPC_FIREBREATH NPC_ICEBREATH NPC_THUNDERBREATH NPC_ACIDBREATH NPC_DARKNESSBREATH NPC_DRAGONFEAR
syn keyword hSkillId NPC_BLEEDING NPC_PULSESTRIKE NPC_HELLJUDGEMENT NPC_WIDESILENCE NPC_WIDEFREEZE NPC_WIDEBLEEDING
syn keyword hSkillId NPC_WIDESTONE NPC_WIDECONFUSE NPC_WIDESLEEP NPC_WIDESIGHT NPC_EVILLAND NPC_MAGICMIRROR
syn keyword hSkillId NPC_SLOWCAST NPC_CRITICALWOUND NPC_EXPULSION NPC_STONESKIN NPC_ANTIMAGIC NPC_WIDECURSE
syn keyword hSkillId NPC_WIDESTUN NPC_VAMPIRE_GIFT NPC_WIDESOULDRAIN ALL_INCCARRY NPC_TALK NPC_HELLPOWER
syn keyword hSkillId NPC_WIDEHELLDIGNITY NPC_INVINCIBLE NPC_INVINCIBLEOFF NPC_ALLHEAL GM_SANDMAN CASH_BLESSING
syn keyword hSkillId CASH_INCAGI CASH_ASSUMPTIO ALL_PARTYFLEE ALL_WEWISH HLIF_HEAL HLIF_AVOID HLIF_BRAIN HLIF_CHANGE
syn keyword hSkillId HAMI_CASTLE HAMI_DEFENCE HAMI_SKIN HAMI_BLOODLUST HFLI_MOON HFLI_FLEET HFLI_SPEED HFLI_SBR44
syn keyword hSkillId HVAN_CAPRICE HVAN_CHAOTIC HVAN_INSTRUCT HVAN_EXPLOSION MH_SUMMON_LEGION MH_NEEDLE_OF_PARALYZE
syn keyword hSkillId MH_POISON_MIST MH_PAIN_KILLER MH_LIGHT_OF_REGENE MH_OVERED_BOOST MH_ERASER_CUTTER MH_XENO_SLASHER
syn keyword hSkillId MH_SILENT_BREEZE MH_STYLE_CHANGE MH_SONIC_CRAW MH_SILVERVEIN_RUSH MH_MIDNIGHT_FRENZY MH_STAHL_HORN
syn keyword hSkillId MH_GOLDENE_FERSE MH_STEINWAND MH_HEILIGE_STANGE MH_ANGRIFFS_MODUS MH_TINDER_BREAKER MH_CBC MH_EQC
syn keyword hSkillId MH_MAGMA_FLOW MH_GRANITIC_ARMOR MH_LAVA_SLIDE MH_PYROCLASTIC MH_VOLCANIC_ASH MS_BASH MS_MAGNUM
syn keyword hSkillId MS_BOWLINGBASH MS_PARRYING MS_REFLECTSHIELD MS_BERSERK MA_DOUBLE MA_SHOWER MA_SKIDTRAP MA_LANDMINE
syn keyword hSkillId MA_SANDMAN MA_FREEZINGTRAP MA_REMOVETRAP MA_CHARGEARROW MA_SHARPSHOOTING ML_PIERCE ML_BRANDISH
syn keyword hSkillId ML_SPIRALPIERCE ML_DEFENDER ML_AUTOGUARD ML_DEVOTION MER_MAGNIFICAT MER_QUICKEN MER_SIGHT
syn keyword hSkillId MER_CRASH MER_REGAIN MER_TENDER MER_BENEDICTION MER_RECUPERATE MER_MENTALCURE MER_COMPRESS
syn keyword hSkillId MER_PROVOKE MER_AUTOBERSERK MER_DECAGI MER_SCAPEGOAT MER_LEXDIVINA MER_ESTIMATION MER_KYRIE
syn keyword hSkillId MER_BLESSING MER_INCAGI EL_CIRCLE_OF_FIRE EL_FIRE_CLOAK EL_FIRE_MANTLE EL_WATER_SCREEN
syn keyword hSkillId EL_WATER_DROP EL_WATER_BARRIER EL_WIND_STEP EL_WIND_CURTAIN EL_ZEPHYR EL_SOLID_SKIN
syn keyword hSkillId EL_STONE_SHIELD EL_POWER_OF_GAIA EL_PYROTECHNIC EL_HEATER EL_TROPIC EL_AQUAPLAY EL_COOLER
syn keyword hSkillId EL_CHILLY_AIR EL_GUST EL_BLAST EL_WILD_STORM EL_PETROLOGY EL_CURSED_SOIL EL_UPHEAVAL EL_FIRE_ARROW
syn keyword hSkillId EL_FIRE_BOMB EL_FIRE_BOMB_ATK EL_FIRE_WAVE EL_FIRE_WAVE_ATK EL_ICE_NEEDLE EL_WATER_SCREW
syn keyword hSkillId EL_WATER_SCREW_ATK EL_TIDAL_WEAPON EL_WIND_SLASH EL_HURRICANE EL_HURRICANE_ATK EL_TYPOON_MIS
syn keyword hSkillId EL_TYPOON_MIS_ATK EL_STONE_HAMMER EL_ROCK_CRUSHER EL_ROCK_CRUSHER_ATK EL_STONE_RAIN GD_APPROVAL
syn keyword hSkillId GD_KAFRACONTRACT GD_GUARDRESEARCH GD_GUARDUP GD_EXTENSION GD_GLORYGUILD GD_LEADERSHIP
syn keyword hSkillId GD_GLORYWOUNDS GD_SOULCOLD GD_HAWKEYES GD_BATTLEORDER GD_REGENERATION GD_RESTORE GD_EMERGENCYCALL
syn keyword hSkillId GD_DEVELOPMENT RL_GLITTERING_GREED RL_RICHS_COIN RL_MASS_SPIRAL RL_BANISHING_BUSTER RL_B_TRAP
syn keyword hSkillId RL_FLICKER RL_S_STORM RL_E_CHAIN RL_QD_SHOT RL_C_MARKER RL_FIREDANCE RL_H_MINE RL_P_ALTER
syn keyword hSkillId RL_FALLEN_ANGEL RL_R_TRIP RL_D_TAIL RL_FIRE_RAIN RL_HEAT_BARREL RL_AM_BLAST RL_SLUGSHOT
syn keyword hSkillId RL_HAMMER_OF_GOD RL_R_TRIP_PLUSATK RL_B_FLICKER_ATK RL_GLITTERING_GREED_ATK KN_CHARGEATK CR_SHRINK
syn keyword hSkillId AS_SONICACCEL AS_VENOMKNIFE RG_CLOSECONFINE WZ_SIGHTBLASTER SA_CREATECON SA_ELEMENTWATER
syn keyword hSkillId HT_PHANTASMIC BA_PANGVOICE DC_WINKCHARM BS_UNFAIRLYTRICK BS_GREED PR_REDEMPTIO MO_KITRANSLATION
syn keyword hSkillId MO_BALKYOUNG SA_ELEMENTGROUND SA_ELEMENTFIRE SA_ELEMENTWIND RK_ENCHANTBLADE RK_SONICWAVE
syn keyword hSkillId RK_DEATHBOUND RK_HUNDREDSPEAR RK_WINDCUTTER RK_IGNITIONBREAK RK_DRAGONTRAINING RK_DRAGONBREATH
syn keyword hSkillId RK_DRAGONHOWLING RK_RUNEMASTERY RK_MILLENNIUMSHIELD RK_CRUSHSTRIKE RK_REFRESH RK_GIANTGROWTH
syn keyword hSkillId RK_STONEHARDSKIN RK_VITALITYACTIVATION RK_STORMBLAST RK_FIGHTINGSPIRIT RK_ABUNDANCE
syn keyword hSkillId RK_PHANTOMTHRUST GC_VENOMIMPRESS GC_CROSSIMPACT GC_DARKILLUSION GC_RESEARCHNEWPOISON
syn keyword hSkillId GC_CREATENEWPOISON GC_ANTIDOTE GC_POISONINGWEAPON GC_WEAPONBLOCKING GC_COUNTERSLASH GC_WEAPONCRUSH
syn keyword hSkillId GC_VENOMPRESSURE GC_POISONSMOKE GC_CLOAKINGEXCEED GC_PHANTOMMENACE GC_HALLUCINATIONWALK
syn keyword hSkillId GC_ROLLINGCUTTER GC_CROSSRIPPERSLASHER AB_JUDEX AB_ANCILLA AB_ADORAMUS AB_CLEMENTIA AB_CANTO
syn keyword hSkillId AB_CHEAL AB_EPICLESIS AB_PRAEFATIO AB_ORATIO AB_LAUDAAGNUS AB_LAUDARAMUS AB_EUCHARISTICA
syn keyword hSkillId AB_RENOVATIO AB_HIGHNESSHEAL AB_CLEARANCE AB_EXPIATIO AB_DUPLELIGHT AB_DUPLELIGHT_MELEE
syn keyword hSkillId AB_DUPLELIGHT_MAGIC AB_SILENTIUM WL_WHITEIMPRISON WL_SOULEXPANSION WL_FROSTMISTY WL_JACKFROST
syn keyword hSkillId WL_MARSHOFABYSS WL_RECOGNIZEDSPELL WL_SIENNAEXECRATE WL_RADIUS WL_STASIS WL_DRAINLIFE
syn keyword hSkillId WL_CRIMSONROCK WL_HELLINFERNO WL_COMET WL_CHAINLIGHTNING WL_CHAINLIGHTNING_ATK WL_EARTHSTRAIN
syn keyword hSkillId WL_TETRAVORTEX WL_TETRAVORTEX_FIRE WL_TETRAVORTEX_WATER WL_TETRAVORTEX_WIND WL_TETRAVORTEX_GROUND
syn keyword hSkillId WL_SUMMONFB WL_SUMMONBL WL_SUMMONWB WL_SUMMON_ATK_FIRE WL_SUMMON_ATK_WIND WL_SUMMON_ATK_WATER
syn keyword hSkillId WL_SUMMON_ATK_GROUND WL_SUMMONSTONE WL_RELEASE WL_READING_SB WL_FREEZE_SP RA_ARROWSTORM
syn keyword hSkillId RA_FEARBREEZE RA_RANGERMAIN RA_AIMEDBOLT RA_DETONATOR RA_ELECTRICSHOCKER RA_CLUSTERBOMB
syn keyword hSkillId RA_WUGMASTERY RA_WUGRIDER RA_WUGDASH RA_WUGSTRIKE RA_WUGBITE RA_TOOTHOFWUG RA_SENSITIVEKEEN
syn keyword hSkillId RA_CAMOUFLAGE RA_RESEARCHTRAP RA_MAGENTATRAP RA_COBALTTRAP RA_MAIZETRAP RA_VERDURETRAP
syn keyword hSkillId RA_FIRINGTRAP RA_ICEBOUNDTRAP NC_MADOLICENCE NC_BOOSTKNUCKLE NC_PILEBUNKER NC_VULCANARM
syn keyword hSkillId NC_FLAMELAUNCHER NC_COLDSLOWER NC_ARMSCANNON NC_ACCELERATION NC_HOVERING NC_F_SIDESLIDE
syn keyword hSkillId NC_B_SIDESLIDE NC_MAINFRAME NC_SELFDESTRUCTION NC_SHAPESHIFT NC_EMERGENCYCOOL NC_INFRAREDSCAN
syn keyword hSkillId NC_ANALYZE NC_MAGNETICFIELD NC_NEUTRALBARRIER NC_STEALTHFIELD NC_REPAIR NC_TRAININGAXE
syn keyword hSkillId NC_RESEARCHFE NC_AXEBOOMERANG NC_POWERSWING NC_AXETORNADO NC_SILVERSNIPER NC_MAGICDECOY
syn keyword hSkillId NC_DISJOINT SC_FATALMENACE SC_REPRODUCE SC_AUTOSHADOWSPELL SC_SHADOWFORM SC_TRIANGLESHOT
syn keyword hSkillId SC_BODYPAINT SC_INVISIBILITY SC_DEADLYINFECT SC_ENERVATION SC_GROOMY SC_IGNORANCE SC_LAZINESS
syn keyword hSkillId SC_UNLUCKY SC_WEAKNESS SC_STRIPACCESSARY SC_MANHOLE SC_DIMENSIONDOOR SC_CHAOSPANIC SC_MAELSTROM
syn keyword hSkillId SC_BLOODYLUST SC_FEINTBOMB LG_CANNONSPEAR LG_BANISHINGPOINT LG_TRAMPLE LG_SHIELDPRESS
syn keyword hSkillId LG_REFLECTDAMAGE LG_PINPOINTATTACK LG_FORCEOFVANGUARD LG_RAGEBURST LG_SHIELDSPELL LG_EXEEDBREAK
syn keyword hSkillId LG_OVERBRAND LG_PRESTIGE LG_BANDING LG_MOONSLASHER LG_RAYOFGENESIS LG_PIETY LG_EARTHDRIVE
syn keyword hSkillId LG_HESPERUSLIT LG_INSPIRATION SR_DRAGONCOMBO SR_SKYNETBLOW SR_EARTHSHAKER SR_FALLENEMPIRE
syn keyword hSkillId SR_TIGERCANNON SR_HELLGATE SR_RAMPAGEBLASTER SR_CRESCENTELBOW SR_CURSEDCIRCLE SR_LIGHTNINGWALK
syn keyword hSkillId SR_KNUCKLEARROW SR_WINDMILL SR_RAISINGDRAGON SR_GENTLETOUCH SR_ASSIMILATEPOWER SR_POWERVELOCITY
syn keyword hSkillId SR_CRESCENTELBOW_AUTOSPELL SR_GATEOFHELL SR_GENTLETOUCH_QUIET SR_GENTLETOUCH_CURE
syn keyword hSkillId SR_GENTLETOUCH_ENERGYGAIN SR_GENTLETOUCH_CHANGE SR_GENTLETOUCH_REVITALIZE WA_SWING_DANCE
syn keyword hSkillId WA_SYMPHONY_OF_LOVER WA_MOONLIT_SERENADE MI_RUSH_WINDMILL MI_ECHOSONG MI_HARMONIZE WM_LESSON
syn keyword hSkillId WM_METALICSOUND WM_REVERBERATION WM_REVERBERATION_MELEE WM_REVERBERATION_MAGIC WM_DOMINION_IMPULSE
syn keyword hSkillId WM_SEVERE_RAINSTORM WM_POEMOFNETHERWORLD WM_VOICEOFSIREN WM_DEADHILLHERE WM_LULLABY_DEEPSLEEP
syn keyword hSkillId WM_SIRCLEOFNATURE WM_RANDOMIZESPELL WM_GLOOMYDAY WM_GREAT_ECHO WM_SONG_OF_MANA WM_DANCE_WITH_WUG
syn keyword hSkillId WM_SOUND_OF_DESTRUCTION WM_SATURDAY_NIGHT_FEVER WM_LERADS_DEW WM_MELODYOFSINK WM_BEYOND_OF_WARCRY
syn keyword hSkillId WM_UNLIMITED_HUMMING_VOICE SO_FIREWALK SO_ELECTRICWALK SO_SPELLFIST SO_EARTHGRAVE SO_DIAMONDDUST
syn keyword hSkillId SO_POISON_BUSTER SO_PSYCHIC_WAVE SO_CLOUD_KILL SO_STRIKING SO_WARMER SO_VACUUM_EXTREME
syn keyword hSkillId SO_VARETYR_SPEAR SO_ARRULLO SO_EL_CONTROL SO_SUMMON_AGNI SO_SUMMON_AQUA SO_SUMMON_VENTUS
syn keyword hSkillId SO_SUMMON_TERA SO_EL_ACTION SO_EL_ANALYSIS SO_EL_SYMPATHY SO_EL_CURE SO_FIRE_INSIGNIA
syn keyword hSkillId SO_WATER_INSIGNIA SO_WIND_INSIGNIA SO_EARTH_INSIGNIA GN_TRAINING_SWORD GN_REMODELING_CART
syn keyword hSkillId GN_CART_TORNADO GN_CARTCANNON GN_CARTBOOST GN_THORNS_TRAP GN_BLOOD_SUCKER GN_SPORE_EXPLOSION
syn keyword hSkillId GN_WALLOFTHORN GN_CRAZYWEED GN_CRAZYWEED_ATK GN_DEMONIC_FIRE GN_FIRE_EXPANSION
syn keyword hSkillId GN_FIRE_EXPANSION_SMOKE_POWDE GN_FIRE_EXPANSION_TEAR_GAS GN_FIRE_EXPANSION_ACID GN_HELLS_PLANT
syn keyword hSkillId GN_HELLS_PLANT_ATK GN_MANDRAGORA GN_SLINGITEM GN_CHANGEMATERIAL GN_MIX_COOKING GN_MAKEBOMB
syn keyword hSkillId GN_S_PHARMACY GN_SLINGITEM_RANGEMELEEATK AB_SECRAMENT WM_SEVERE_RAINSTORM_MELEE SR_HOWLINGOFLION
syn keyword hSkillId SR_RIDEINLIGHTNING RETURN_TO_ELDICASTES ALL_BUYING_STORE ALL_GUARDIAN_RECALL ALL_ODINS_POWER
syn keyword hSkillId KO_YAMIKUMO KO_RIGHT KO_LEFT KO_JYUMONJIKIRI KO_SETSUDAN KO_BAKURETSU KO_HAPPOKUNAI KO_MUCHANAGE
syn keyword hSkillId KO_HUUMARANKA KO_MAKIBISHI KO_MEIKYOUSISUI KO_ZANZOU KO_KYOUGAKU KO_JYUSATSU KO_KAHU_ENTEN
syn keyword hSkillId KO_HYOUHU_HUBUKI KO_KAZEHU_SEIRAN KO_DOHU_KOUKAI KO_KAIHOU KO_ZENKAI KO_GENWAKU KO_IZAYOI
syn keyword hSkillId KG_KAGEHUMI KG_KYOMU KG_KAGEMUSYA OB_ZANGETSU OB_OBOROGENSOU OB_OBOROGENSOU_TRANSITION_ATK
syn keyword hSkillId OB_AKAITSUKI ECL_SNOWFLIP ECL_PEONYMAMY ECL_SADAGUI ECL_SEQUOIADUST ECLAGE_RECALL GC_DARKCROW
syn keyword hSkillId RA_UNLIMIT GN_ILLUSIONDOPING RK_DRAGONBREATH_WATER RK_LUXANIMA NC_MAGMA_ERUPTION WM_FRIGG_SONG
syn keyword hSkillId SO_ELEMENTAL_SHIELD SR_FLASHCOMBO SC_ESCAPE AB_OFFERTORIUM WL_TELEKINESIS_INTENSE LG_KINGS_GRACE
syn keyword hSkillId ALL_FULL_THROTTLE SR_FLASHCOMBO_ATK_STEP1 SR_FLASHCOMBO_ATK_STEP2 SR_FLASHCOMBO_ATK_STEP3
syn keyword hSkillId SR_FLASHCOMBO_ATK_STEP4

" Mobs (imported from db/*/mob_db.txt)
syn keyword hMobId SCORPION PORING HORNET FARMILIAR FABRE PUPA CONDOR WILOW CHONCHON RODA_FROG WOLF SPORE ZOMBIE
syn keyword hMobId ARCHER_SKELETON CREAMY PECOPECO MANDRAGORA ORK_WARRIOR WORM_TAIL SNAKE MUNAK SOLDIER_SKELETON ISIS
syn keyword hMobId ANACONDAQ POPORING VERIT ELDER_WILOW THARA_FROG HUNTER_FLY GHOUL SIDE_WINDER OSIRIS BAPHOMET GOLEM
syn keyword hMobId MUMMY STEEL_CHONCHON OBEAUNE MARC DOPPELGANGER PECOPECO_EGG THIEF_BUG_EGG PICKY PICKY_ THIEF_BUG
syn keyword hMobId ROCKER THIEF_BUG_ THIEF_BUG__ MUKA SMOKIE YOYO METALLER MISTRESS BIGFOOT NIGHTMARE PORING_ LUNATIC
syn keyword hMobId MEGALODON STROUF VADON CORNUTUS HYDRA SWORD_FISH KUKRE PIRATE_SKEL KAHO CRAB SHELLFISH SKELETON
syn keyword hMobId POISON_SPORE RED_PLANT BLUE_PLANT GREEN_PLANT YELLOW_PLANT WHITE_PLANT SHINING_PLANT BLACK_MUSHROOM
syn keyword hMobId RED_MUSHROOM GOLDEN_BUG ORK_HERO VOCAL TOAD MASTERING DRAGON_FLY VAGABOND_WOLF ECLIPSE AMBERNITE
syn keyword hMobId ANDRE ANGELING ANT_EGG ANUBIS ARGIOPE ARGOS BAPHOMET_ BATHORY CARAMEL COCO DENIRO DESERT_WOLF
syn keyword hMobId DESERT_WOLF_B DEVIACE DEVIRUCHI DOKEBI DRAINLIAR DRAKE DROPS DUSTINESS EDDGA EGGYRA EVIL_DRUID FLORA
syn keyword hMobId FRILLDORA GHOSTRING GIEARTH GOBLIN_1 GOBLIN_2 GOBLIN_3 GOBLIN_4 GOBLIN_5 HODE HORN HORONG JAKK JOKER
syn keyword hMobId KHALITZBURG KOBOLD_1 KOBOLD_2 KOBOLD_3 MAGNOLIA MANTIS MARDUK MARINA MARINE_SPHERE MARIONETTE MARSE
syn keyword hMobId MARTIN MATYR MAYA MEDUSA MINOROUS MOONLIGHT MYST ORC_SKELETON ORC_ZOMBIE PASANA PETIT PETIT_ PHARAOH
syn keyword hMobId PHEN PHREEONI PIERE PLANKTON RAFFLESIA RAYDRIC REQUIEM SAND_MAN SAVAGE SAVAGE_BABE SKEL_WORKER SOHEE
syn keyword hMobId STAINER TAROU VITATA ZENORC ZEROM WHISPER NINE_TAIL THIEF_MUSHROOM CHONCHON_ FABRE_ WHISPER_
syn keyword hMobId WHISPER_BOSS SWITCH BON_GUN ORC_ARCHER ORC_LORD MIMIC WRAITH ALARM ARCLOUSE RIDEWORD SKEL_PRISONER
syn keyword hMobId ZOMBIE_PRISONER DARK_PRIEST PUNK ZHERLTHSH RYBIO PHENDARK MYSTELTAINN TIRFING EXECUTIONER ANOLIAN
syn keyword hMobId STING WANDER_MAN CRAMP BRILIGHT IRON_FIST HIGH_ORC CHOCO STEM_WORM PENOMENA KNIGHT_OF_ABYSS
syn keyword hMobId M_DESERT_WOLF M_SAVAGE META_FABRE META_PUPA META_CREAMY META_PECOPECO_EGG PROVOKE_YOYO SMOKING_ORC
syn keyword hMobId META_ANT_EGG META_ANDRE META_PIERE META_DENIRO META_PICKY META_PICKY_ MARIN SASQUATCH JAKK_XMAS
syn keyword hMobId GOBLINE_XMAS COOKIE_XMAS ANTONIO CRUISER MYSTCASE CHEPET KNIGHT_OF_WINDSTORM GARM GARGOYLE RAGGLER
syn keyword hMobId NERAID PEST INJUSTICE GOBLIN_ARCHER GRYPHON DARK_FRAME WILD_ROSE MUTANT_DRAGON WIND_GHOST MERMAN
syn keyword hMobId COOKIE ASTER CARAT BLOODY_KNIGHT CLOCK C_TOWER_MANAGER ALLIGATOR DARK_LORD ORC_LADY MEGALITH ALICE
syn keyword hMobId RAYDRIC_ARCHER GREATEST_GENERAL STALACTIC_GOLEM TRI_JOINT STEAM_GOBLIN SAGEWORM KOBOLD_ARCHER
syn keyword hMobId CHIMERA ARCHER_GUARDIAN KNIGHT_GUARDIAN SOLDIER_GUARDIAN EMPELIUM MAYA_PUPLE SKELETON_GENERAL
syn keyword hMobId WRAITH_DEAD MINI_DEMON CREMY_FEAR KILLER_MANTIS OWL_BARON KOBOLD_LEADER ANCIENT_MUMMY ZOMBIE_MASTER
syn keyword hMobId GOBLIN_LEADER CATERPILLAR AM_MUT DARK_ILLUSION GIANT_HONET GIANT_SPIDER ANCIENT_WORM LEIB_OLMAI
syn keyword hMobId CAT_O_NINE_TAIL PANZER_GOBLIN GAJOMART MAJORUROS GULLINBURSTI TURTLE_GENERAL MOBSTER PERMETER
syn keyword hMobId ASSULTER SOLIDER FUR_SEAL HEATER FREEZER OWL_DUKE DRAGON_TAIL SPRING_RABBIT SEE_OTTER TREASURE_BOX1
syn keyword hMobId TREASURE_BOX2 TREASURE_BOX3 TREASURE_BOX4 TREASURE_BOX5 TREASURE_BOX6 TREASURE_BOX7 TREASURE_BOX8
syn keyword hMobId TREASURE_BOX9 TREASURE_BOX10 TREASURE_BOX11 TREASURE_BOX12 TREASURE_BOX13 TREASURE_BOX14
syn keyword hMobId TREASURE_BOX15 TREASURE_BOX16 TREASURE_BOX17 TREASURE_BOX18 TREASURE_BOX19 TREASURE_BOX20
syn keyword hMobId TREASURE_BOX21 TREASURE_BOX22 TREASURE_BOX23 TREASURE_BOX24 TREASURE_BOX25 TREASURE_BOX26
syn keyword hMobId TREASURE_BOX27 TREASURE_BOX28 TREASURE_BOX29 TREASURE_BOX30 TREASURE_BOX31 TREASURE_BOX32
syn keyword hMobId TREASURE_BOX33 TREASURE_BOX34 TREASURE_BOX35 TREASURE_BOX36 TREASURE_BOX37 TREASURE_BOX38
syn keyword hMobId TREASURE_BOX39 TREASURE_BOX40 G_ASSULTER APOCALIPS LAVA_GOLEM BLAZZER GEOGRAPHER GRAND_PECO SUCCUBUS
syn keyword hMobId FAKE_ANGEL GOAT LORD_OF_DEATH INCUBUS THE_PAPER HARPY ELDER DEMON_PUNGUS NIGHTMARE_TERROR DRILLER
syn keyword hMobId GRIZZLY DIABOLIC EXPLOSION DELETER DELETER_ SLEEPER GIG ARCHANGELING DRACULA VIOLY GALAPAGO
syn keyword hMobId ROTAR_ZAIRO G_MUMMY G_ZOMBIE CRYSTAL_1 CRYSTAL_2 CRYSTAL_3 CRYSTAL_4 EVENT_BAPHO KARAKASA SHINOBI
syn keyword hMobId POISON_TOAD ANTIQUE_FIRELOCK MIYABI_NINGYO TENGU KAPHA BLOOD_BUTTERFLY RICE_CAKE_BOY LIVE_PEACH_TREE
syn keyword hMobId EVIL_CLOUD_HERMIT WILD_GINSENG BABY_LEOPARD WICKED_NYMPH ZIPPER_BEAR DARK_SNAKE_LORD G_FARMILIAR
syn keyword hMobId G_ARCHER_SKELETON G_ISIS G_HUNTER_FLY G_GHOUL G_SIDE_WINDER G_OBEAUNE G_MARC G_NIGHTMARE
syn keyword hMobId G_POISON_SPORE G_ARGIOPE G_ARGOS G_BAPHOMET_ G_DESERT_WOLF G_DEVIRUCHI G_DRAINLIAR G_EVIL_DRUID
syn keyword hMobId G_JAKK G_JOKER G_KHALITZBURG G_HIGH_ORC G_STEM_WORM G_PENOMENA G_SASQUATCH G_CRUISER G_CHEPET
syn keyword hMobId G_RAGGLER G_INJUSTICE G_GRYPHON G_DARK_FRAME G_MUTANT_DRAGON G_WIND_GHOST G_MERMAN G_ORC_LADY
syn keyword hMobId G_RAYDRIC_ARCHER G_TRI_JOINT G_KOBOLD_ARCHER G_CHIMERA G_MANTIS G_MARDUK G_MARIONETTE G_MATYR
syn keyword hMobId G_MINOROUS G_ORC_SKELETON G_ORC_ZOMBIE G_PASANA G_PETIT G_PETIT_ G_RAYDRIC G_REQUIEM G_SKEL_WORKER
syn keyword hMobId G_ZEROM G_NINE_TAIL G_BON_GUN G_ORC_ARCHER G_MIMIC G_WRAITH G_ALARM G_ARCLOUSE G_RIDEWORD
syn keyword hMobId G_SKEL_PRISONER G_ZOMBIE_PRISONER G_PUNK G_ZHERLTHSH G_RYBIO G_PHENDARK G_MYSTELTAINN G_TIRFING
syn keyword hMobId G_EXECUTIONER G_ANOLIAN G_STING G_WANDER_MAN G_DOKEBI INCANTATION_SAMURAI DRYAD KIND_OF_BEETLE
syn keyword hMobId STONE_SHOOTER WOODEN_GOLEM WOOTAN_SHOOTER WOOTAN_FIGHTER PARASITE PORING_V GIBBET DULLAHAN LOLI_RURI
syn keyword hMobId DISGUISE BLOODY_MURDERER QUVE LUDE HYLOZOIST AMON_RA HYEGUN CIVIL_SERVANT DANCING_DRAGON GARM_BABY
syn keyword hMobId INCREASE_SOIL LI_ME_MANG_RYANG BACSOJIN CHUNG_E BOILED_RICE G_ALICE G_ANCIENT_MUMMY
syn keyword hMobId G_ANTIQUE_FIRELOCK G_BABY_LEOPARD G_BATHORY G_BLOOD_BUTTERFLY G_C_TOWER_MANAGER G_CLOCK
syn keyword hMobId G_DARK_SNAKE_LORD G_DRACULA G_EVIL_CLOUD_HERMIT G_EXPLOSION G_FUR_SEAL G_GOBLIN_1 G_GOBLIN_2
syn keyword hMobId G_GOBLIN_3 G_GOBLIN_4 G_GOBLIN_5 G_GOBLIN_LEADER G_GOLEM G_GREATEST_GENERAL G_INCANTATION_SAMURA
syn keyword hMobId G_KAPHA G_KARAKASA G_KOBOLD_1 G_KOBOLD_2 G_KOBOLD_3 G_KOBOLD_LEADER G_LAVA_GOLEM G_LIVE_PEACH_TREE
syn keyword hMobId G_MARSE G_MIYABI_NINGYO G_MYST G_NIGHTMARE_TERROR G_PARASITE G_POISON_TOAD G_ROTAR_ZAIRO G_SAND_MAN
syn keyword hMobId G_SCORPION G_SHINOBI G_SMOKIE G_SOLDIER_SKELETON G_TENGU G_WICKED_NYMPH G_WILD_GINSENG G_WRAITH_DEAD
syn keyword hMobId G_ANCIENT_WORM G_ANGELING G_BLOODY_KNIGHT G_CRAMP G_DEVIACE G_DROPS G_ELDER G_ELDER_WILOW G_FLORA
syn keyword hMobId G_GHOSTRING G_GOBLIN_ARCHER G_HORONG G_HYDRA G_INCUBUS G_VOCAL DEVILING TAO_GUNKA TAMRUAN
syn keyword hMobId MIME_MONKEY LEAF_CAT KRABEN ORC_XMAS G_MANDRAGORA G_GEOGRAPHER A_LUNATIC A_MOBSTER A_ANCIENT_MUMMY
syn keyword hMobId G_FREEZER G_MARIN G_TAMRUAN G_GARGOYLE G_BLAZZER G_WHISPER_BOSS G_HEATER G_PERMETER G_SOLIDER
syn keyword hMobId G_BIGFOOT G_GIANT_HONET G_DARK_ILLUSION G_GARM_BABY G_GOBLINE_XMAS G_THIEF_BUG__ G_DANCING_DRAGON
syn keyword hMobId A_MUNAK A_BON_GUN A_HYEGUN METALING MINERAL OBSIDIAN PITMAN WASTE_STOVE UNGOLIANT PORCELLIO NOXIOUS
syn keyword hMobId VENOMOUS TEDDY_BEAR RSX_0806 G_WASTE_STOVE G_PORCELLIO G_DARK_PRIEST ANOPHELES MOLE HILL_WIND
syn keyword hMobId BACSOJIN_ CHUNG_E_ GREMLIN BEHOLDER SEYREN EREMES HARWORD MAGALETA SHECIL KATRINN G_SEYREN G_EREMES
syn keyword hMobId G_HARWORD G_MAGALETA G_SHECIL G_KATRINN B_SEYREN B_EREMES B_HARWORD B_MAGALETA B_SHECIL B_KATRINN
syn keyword hMobId YGNIZEM WHIKEBAIN ARMAIA EREND KAVAC RAWREL B_YGNIZEM G_WHIKEBAIN G_ARMAIA G_EREND G_KAVAC G_RAWREL
syn keyword hMobId POTON_CANON POTON_CANON_1 POTON_CANON_2 POTON_CANON_3 ARCHDAM DIMIK DIMIK_1 DIMIK_2 DIMIK_3 DIMIK_4
syn keyword hMobId MONEMUS VENATU VENATU_1 VENATU_2 VENATU_3 VENATU_4 HILL_WIND_1 GEMINI REMOVAL G_POTON_CANON
syn keyword hMobId G_ARCHDAM APOCALIPS_H ORC_BABY GREEN_IGUANA LADY_TANEE G_BACSOJIN G_SPRING_RABBIT G_KRABEN BREEZE
syn keyword hMobId PLASMA_Y PLASMA_R PLASMA_G PLASMA_P PLASMA_B DEATHWORD ANCIENT_MIMIC OBSERVATION SHELTER RETRIBUTION
syn keyword hMobId SOLACE THA_ODIUM THA_DESPERO THA_MAERO THA_DOLOR THANATOS G_THA_ODIUM G_THA_DESPERO G_THA_MAERO
syn keyword hMobId G_THA_DOLOR ACIDUS FERUS NOVUS ACIDUS_ FERUS_ NOVUS_ DETALE HYDRO DRAGON_EGG EVENT_JAKK A_SHECIL
syn keyword hMobId A_POTON_CANON R_PORING R_LUNATIC R_SAVAGE_BABE R_DESERT_WOLF_B R_BAPHOMET_ R_DEVIRUCHI
syn keyword hMobId G_DOPPELGANGER G_TREASURE_BOX KIEL KIEL_ ALICEL ALIOT ALIZA CONSTANT G_ALICEL G_ALIOT G_COOKIE_XMAS
syn keyword hMobId G_CARAT G_MYSTCASE G_WILD_ROSE G_CONSTANT G_ALIZA G_SNAKE G_ANACONDAQ G_MEDUSA G_RED_PLANT RANDGRIS
syn keyword hMobId SKOGUL FRUS SKEGGIOLD SKEGGIOLD_ G_HYDRO G_ACIDUS G_FERUS G_ACIDUS_ G_FERUS_ G_SKOGUL G_FRUS
syn keyword hMobId G_SKEGGIOLD G_SKEGGIOLD_ G_RANDGRIS EM_ANGELING EM_DEVILING GLOOMUNDERNIGHT AGAV ECHIO VANBERK
syn keyword hMobId ISILLA HODREMLIN SEEKER SNOWIER SIROMA ICE_TITAN GAZETI KTULLANUX MUSCIPULAR DROSERA ROWEEN GALION
syn keyword hMobId STAPO ATROCE G_AGAV G_ECHIO G_ICE_TITAN ICEICLE G_RAFFLESIA G_GALION SOCCER_BALL G_MEGALITH G_ROWEEN
syn keyword hMobId BLOODY_KNIGHT_ AUNOE FANAT TREASURE_BOX_ G_SEYREN_ G_EREMES_ G_HARWORD_ G_MAGALETA_ G_SHECIL_
syn keyword hMobId G_KATRINN_ B_SEYREN_ B_EREMES_ B_HARWORD_ B_MAGALETA_ B_SHECIL_ B_KATRINN_ G_SMOKIE_ EVENT_LUDE
syn keyword hMobId EVENT_HYDRO EVENT_MOON EVENT_RICECAKE EVENT_GOURD EVENT_DETALE EVENT_ALARM EVENT_BATHORY
syn keyword hMobId EVENT_BIGFOOT EVENT_DESERT_WOLF EVENT_DEVIRUCHI EVENT_FREEZER EVENT_GARM_BABY EVENT_GOBLINE_XMAS
syn keyword hMobId EVENT_MYST EVENT_SASQUATCH EVENT_GULLINBURSTI SWORD_GUARDIAN BOW_GUARDIAN SALAMANDER IFRIT KASA
syn keyword hMobId G_SALAMANDER G_KASA MAGMARING IMP KNOCKER BYORGUE GOLDEN_SAVAGE G_SNAKE_ G_ANACONDAQ_ G_SIDE_WINDER_
syn keyword hMobId G_ISIS_ G_TREASURE_BOX_ DREAMMETAL EVENT_PORING EVENT_BAPHOMET EVENT_OSIRIS EVENT_ORCHERO
syn keyword hMobId EVENT_MOBSTER G_EM_ANGELING G_EM_DEVILING E_MUKA E_POISONSPORE E_MAGNOLIA E_MARIN E_PLANKTON
syn keyword hMobId E_MANDRAGORA E_COCO E_CHOCO E_MARTIN E_SPRING_RABBIT ZOMBIE_SLAUGHTER RAGGED_ZOMBIE HELL_POODLE
syn keyword hMobId BANSHEE G_BANSHEE FLAME_SKULL NECROMANCER FALLINGBISHOP BEELZEBUB_FLY BEELZEBUB BEELZEBUB_
syn keyword hMobId TRISTAN_3RD E_LORD_OF_DEATH CRYSTAL_5 E_SHINING_PLANT ECLIPSE_P WOOD_GOBLIN LES VAVAYAGA UZHAS MAVKA
syn keyword hMobId GOPINICH G_MAVKA FREEZER_R GARM_BABY_R GARM_R GOPINICH_R G_RANDGRIS_ G_LOLI_RURI G_KNIGHT_OF_ABYSS
syn keyword hMobId POURING EVENT_SEYREN EVENT_KATRINN EVENT_BAPHOMET_ EVENT_ZOMBIE SWORD_GUARDIAN_ E_CONDOR E_TREASURE1
syn keyword hMobId E_TREASURE2 BOMBPORING BARRICADE BARRICADE_ S_EMPEL_1 S_EMPEL_2 OBJ_A OBJ_B OBJ_NEUTRAL OBJ_FLAG_A
syn keyword hMobId OBJ_FLAG_B OBJ_A2 OBJ_B2 MOROCC MOROCC_ MOROCC_1 MOROCC_2 MOROCC_3 MOROCC_4 G_MOROCC_1 G_MOROCC_2
syn keyword hMobId G_MOROCC_3 G_MOROCC_4 JAKK_H WHISPER_H DEVIRUCHI_H BAPHOMET_I PIAMETTE WISH_MAIDEN GARDEN_KEEPER
syn keyword hMobId GARDEN_WATCHER BLUE_FLOWER RED_FLOWER YELL_FLOWER CONSTANT_ TREASURE_BOX41 TREASURE_BOX42
syn keyword hMobId TREASURE_BOX43 TREASURE_BOX44 TREASURE_BOX45 TREASURE_BOX46 TREASURE_BOX47 TREASURE_BOX48
syn keyword hMobId TREASURE_BOX49 PIAMETTE_ G_YGNIZEM B_S_GUARDIAN B_B_GUARDIAN CRYSTAL_6 CRYSTAL_7 CRYSTAL_8 CRYSTAL_9
syn keyword hMobId TREASURE_BOX_I NAGHT_SIEGER ENTWEIHEN G_ENTWEIHEN_R G_ENTWEIHEN_H G_ENTWEIHEN_M G_ENTWEIHEN_S
syn keyword hMobId ANTONIO_ P_CHUNG_E NIGHTMARE_T M_WILD_ROSE M_DOPPELGANGER M_YGNIZEM E_STROUF E_MARC E_OBEAUNE
syn keyword hMobId E_VADON E_MARINA E_PORING BANSHEE_MASTER BEHOLDER_MASTER COBALT_MINERAL HEAVY_METALING
syn keyword hMobId HELL_APOCALIPS ZAKUDAM KUBLIN I_HIGH_ORC I_ORC_ARCHER I_ORC_SKELETON I_ORC_LADY DANDELION TATACHO
syn keyword hMobId CENTIPEDE NEPENTHES HILLSRION HARDROCK_MOMMOTH TENDRILRION CORNUS NAGA LUCIOLA_VESPA PINGUICULA
syn keyword hMobId G_TATACHO G_HILLSRION CENTIPEDE_LARVA WOOMAWANG WOOMAWANG_ G_MAJORUROS DRACO DRACO_EGG PINGUICULA_D
syn keyword hMobId AQUA_ELEMENTAL RATA DUNEYRR ANCIENT_TREE RHYNCHO PHYLLA S_NYDHOG DARK_SHADOW BRADIUM_GOLEM
syn keyword hMobId DANDELION_ G_DARK_SHADOW HIDEN_PRIEST DANDELION_H SILVERSNIPER MAGICDECOY_FIRE MAGICDECOY_WATER
syn keyword hMobId MAGICDECOY_EARTH MAGICDECOY_WIND W_NAGA W_BRADIUM_GOLEM E_CRAMP BOITATA IARA PIRANHA HEADLESS_MULE
syn keyword hMobId JAGUAR TOUCAN CURUPIRA S_WIND_GHOST S_SKOGUL S_SUCCUBUS E_HYDRA G_PIRANHA KO_ZANZOU

" Items (imported from db/*/item_db.conf)
syn keyword hItemId Red_Potion Orange_Potion Yellow_Potion White_Potion Blue_Potion Green_Potion Red_Herb Yellow_Herb
syn keyword hItemId White_Herb Blue_Herb Green_Herb Apple Banana Grape Carrot Sweet_Potato Meat Honey Milk
syn keyword hItemId Leaflet_Of_Hinal Leaflet_Of_Aloe Fruit_Of_Mastela Holy_Water Panacea Royal_Jelly Monster's_Feed
syn keyword hItemId Candy Candy_Striper Apple_Juice Banana_Juice Grape_Juice Carrot_Juice Pumpkin Ice_Cream Pet_Food
syn keyword hItemId Well_Baked_Cookie Piece_Of_Cake Falcon's_Feed Pecopeco's_Feed Fish_Slice Red_Slim_Potion
syn keyword hItemId Yellow_Slim_Potion White_Slim_Potion Cheese Nice_Sweet_Potato Popped_Rice Shusi KETUPAT Bun Mojji
syn keyword hItemId Rice_Cake Long_Rice_Cake Hash_Rice_Cake Chocolate HandMade_Chocolate HandMade_Chocolate_
syn keyword hItemId White_Chocolate Pizza Pizza_01 Rice_Ball Vita500_Bottle Tomyumkung Prawn Lemon Novice_Potion
syn keyword hItemId Lucky_Candy Lucky_Candy_Cane Lucky_Cookie Chocolate_Drink Egg Piece_Of_Cake_ Prickly_Fruit Grain
syn keyword hItemId Strawberry Delicious_Fish Bread Mushroom Orange KETUPAT_ Fish_Ball_Soup Wurst Mother's_Cake
syn keyword hItemId Prickly_Fruit_ Spaghetti Pizza_02 Brezel_ Caviar_Pancake Jam_Pancake Honey_Pancake
syn keyword hItemId Sour_Cream_Pancake Mushroom_Pancake Cute_Strawberry_Choco Lovely_Choco_Tart Light_Red_Pot
syn keyword hItemId Light_Orange_Pot Wing_Of_Fly Wing_Of_Butterfly Old_Blue_Box Branch_Of_Dead_Tree Anodyne Aloebera
syn keyword hItemId Yggdrasilberry Seed_Of_Yggdrasil Amulet Leaf_Of_Yggdrasil Spectacles Portable_Furnace Iron_Hammer
syn keyword hItemId Golden_Hammer Oridecon_Hammer Old_Card_Album Old_Violet_Box Worn_Out_Scroll Unripe_Apple
syn keyword hItemId Orange_Juice Bitter_Herb Rainbow_Carrot Earthworm_The_Dude Rotten_Fish Lusty_Iron Monster_Juice
syn keyword hItemId Sweet_Milk Well_Dried_Bone Singing_Flower Dew_Laden_Moss Deadly_Noxious_Herb Fatty_Chubby_Earthworm
syn keyword hItemId Baked_Yam Tropical_Banana Horror_Of_Tribe No_Recipient Old_Broom Silver_Knife_Of_Chaste
syn keyword hItemId Armlet_Of_Obedience Shining_Stone Contracts_In_Shadow Book_Of_Devil Pet_Incubator Gift_Box
syn keyword hItemId Center_Potion Awakening_Potion Berserk_Potion Union_Of_Tribe Heart_Of_Her Prohibition_Red_Candle
syn keyword hItemId Sway_Apron Inspector_Certificate Korea_Rice_Cake Gift_Box_1 Gift_Box_2 Gift_Box_3 Gift_Box_4
syn keyword hItemId Handsei Rice_Cake_Soup Gold_Coin_Moneybag Gold_Coin Copper_Coin_Moneybag Copper_Coin Mithril_Coin
syn keyword hItemId Silver_Coin Silver_Coin_Moneybag White_Gold_Coin Poison_Bottle Gold_Pill Magical_Carnation
syn keyword hItemId Memory_Of_Wedding Realgar_Wine Exorcize_Herb Durian RAMADAN Earth_Scroll_1_3 Earth_Scroll_1_5
syn keyword hItemId Cold_Scroll_1_3 Cold_Scroll_1_5 Fire_Scroll_1_3 Fire_Scroll_1_5 Wind_Scroll_1_3 Wind_Scroll_1_5
syn keyword hItemId Ghost_Scroll_1_3 Ghost_Scroll_1_5 Fire_Scroll_2_1 Fire_Scroll_2_5 Fire_Scroll_3_1 Fire_Scroll_3_5
syn keyword hItemId Cold_Scroll_2_1 Ora_Ora Animal_Blood Hinalle Aloe Clover Four_Leaf_Clover Singing_Plant Ment Izidor
syn keyword hItemId Illusion_Flower Shoot Flower Empty_Bottle Emperium Yellow_Gemstone Red_Gemstone Blue_Gemstone
syn keyword hItemId Dark_Red_Jewel Violet_Jewel Skyblue_Jewel Azure_Jewel Scarlet_Jewel Cardinal_Jewel Cardinal_Jewel_
syn keyword hItemId Red_Jewel Blue_Jewel White_Jewel Golden_Jewel Bluish_Green_Jewel Crystal_Jewel Crystal_Jewel_
syn keyword hItemId Crystal_Jewel__ Crystal_Jewel___ Red_Frame Blue_Porcelain White_Platter Black_Ladle Pencil_Case
syn keyword hItemId Rouge Stuffed_Doll Poring_Doll Chonchon_Doll Spore_Doll Bunch_Of_Flowers Wedding_Bouquet Glass_Bead
syn keyword hItemId Crystal_Mirror Witherless_Rose Frozen_Rose Baphomet_Doll Osiris_Doll Grasshopper_Doll Monkey_Doll
syn keyword hItemId Raccoondog_Doll Oridecon_Stone Elunium_Stone Danggie Tree_Root Reptile_Tongue Scorpion's_Tail Stem
syn keyword hItemId Pointed_Scale Resin Spawn Jellopy Garlet Scell Zargon Tooth_Of_Bat Fluff Chrysalis Feather_Of_Birds
syn keyword hItemId Talon Sticky_Webfoot Animal's_Skin Claw_Of_Wolves Mushroom_Spore Orcish_Cuspid Evil_Horn
syn keyword hItemId Powder_Of_Butterfly Bill_Of_Birds Scale_Of_Snakes Insect_Feeler Immortal_Heart Rotten_Bandage
syn keyword hItemId Orcish_Voucher Skel_Bone Mementos Shell Scales_Shell Posionous_Canine Sticky_Mucus Bee_Sting
syn keyword hItemId Grasshopper's_Leg Nose_Ring Yoyo_Tail Solid_Shell Horseshoe Raccoon_Leaf Snail's_Shell Horn
syn keyword hItemId Bear's_Foot Feather Heart_Of_Mermaid Fin Cactus_Needle Stone_Heart Shining_Scales Worm_Peelings
syn keyword hItemId Gill Decayed_Nail Horrendous_Mouth Rotten_Scale Nipper Conch Tentacle Sharp_Scale Crap_Shell
syn keyword hItemId Clam_Shell Flesh_Of_Clam Turtle_Shell Voucher_Of_Orcish_Hero Gold Alchol Detrimindexta
syn keyword hItemId Karvodailnirol Counteragent Mixture Scarlet_Dyestuffs Lemon_Dyestuffs Cobaltblue_Dyestuffs
syn keyword hItemId Darkgreen_Dyestuffs Orange_Dyestuffs Violet_Dyestuffs White_Dyestuffs Black_Dyestuffs Oridecon
syn keyword hItemId Elunium Anvil Oridecon_Anvil Golden_Anvil Emperium_Anvil Boody_Red Crystal_Blue Wind_Of_Verdure
syn keyword hItemId Yellow_Live Flame_Heart Mistic_Frozen Rough_Wind Great_Nature Iron Steel Star_Crumb Sparkling_Dust
syn keyword hItemId Iron_Ore Coal Patriotism_Marks Hammer_Of_Blacksmith Old_Magic_Book Penetration Frozen_Heart
syn keyword hItemId Sacred_Marks Phracon Emveretarcon Lizard_Scruff Colorful_Shell Jaws_Of_Ant Thin_N'_Long_Tongue
syn keyword hItemId Rat_Tail Moustache_Of_Mole Nail_Of_Mole Wooden_Block Long_Hair Dokkaebi_Horn Fox_Tail Fish_Tail
syn keyword hItemId Chinese_Ink Spiderweb Acorn Porcupine_Spike Wild_Boar's_Mane Tiger's_Skin Tiger_Footskin
syn keyword hItemId Limb_Of_Mantis Blossom_Of_Maneater Root_Of_Maneater Cobold_Hair Dragon_Canine Dragon_Scale
syn keyword hItemId Dragon_Train Petite_DiablOfs_Horn Petite_DiablOfs_Wing Elder_Pixie's_Beard Lantern Short_Leg
syn keyword hItemId Nail_Of_Orc Tooth_Of_ Sacred_Masque Tweezer Head_Of_Medusa Slender_Snake Skirt_Of_Virgin Tendon
syn keyword hItemId Detonator Single_Cell Tooth_Of_Ancient_Fish Lip_Of_Ancient_Fish Earthworm_Peeling Grit Moth_Dust
syn keyword hItemId Wing_Of_Moth Transparent_Cloth Golden_Hair Starsand_Of_Witch Pumpkin_Head Sharpened_Cuspid Reins
syn keyword hItemId Booby_Trap Tree_Of_Archer_1 Tree_Of_Archer_2 Tree_Of_Archer_3 Mushroom_Of_Thief_1
syn keyword hItemId Mushroom_Of_Thief_2 Mage_Test_1 Delivery_Message Merchant_Voucher_1 Merchant_Voucher_2
syn keyword hItemId Merchant_Voucher_3 Merchant_Voucher_4 Merchant_Voucher_5 Merchant_Voucher_6 Merchant_Voucher_7
syn keyword hItemId Merchant_Voucher_8 Merchant_Box_1 Merchant_Box_2 Merchant_Box_3 Kapra's_Pass Mage_Test_2
syn keyword hItemId Mage_Test_3 Mage_Test_4 Morocc_Potion Payon_Potion Mage_Test_Etc Merchant_Box_Etc Empty_Cylinder
syn keyword hItemId Empty_Potion Short_Daenggie Needle_Of_Alarm Round_Shell Worn_Out_Page Manacles
syn keyword hItemId Worn_Out_Prison_Uniform Sword Sword_ Sword__ Falchion Falchion_ Falchion__ Blade Blade_ Blade__
syn keyword hItemId Lapier Lapier_ Lapier__ Scimiter Scimiter_ Scimiter__ Katana Katana_ Katana__ Tsurugi Tsurugi_
syn keyword hItemId Tsurugi__ Ring_Pommel_Saber Haedonggum Orcish_Sword Ring_Pommel_Saber_ Saber Saber_ Hae_Dong_Gum_
syn keyword hItemId Flamberge Nagan Ice_Falchon Edge Fire_Brand Scissores_Sword Cutlas Solar_Sword Excalibur
syn keyword hItemId Mysteltainn_ Tale_Fing_ Byeorrun_Gum Immaterial_Sword Jewel_Sword Gaia_Sword Sasimi Holy_Avenger
syn keyword hItemId Town_Sword Town_Sword_ Star_Dust_Blade Flamberge_ Slayer Slayer_ Slayer__ Bastard_Sword
syn keyword hItemId Bastard_Sword_ Bastard_Sword__ Two_Hand_Sword Two_Hand_Sword_ Two_Hand_Sword__ Broad_Sword Balmung
syn keyword hItemId Broad_Sword_ Claymore Muramasa Masamune Dragon_Slayer Schweizersabel Zweihander Executioner_
syn keyword hItemId Katzbalger Zweihander_ Claymore_ Muramasa_C Executioner_C Altas_Weapon Muscle_Cutter Muramash
syn keyword hItemId Schweizersabel_ Executioner__ Dragon_Slayer_ Tae_Goo_Lyeon Bloody_Eater BF_Two_Handed_Sword1
syn keyword hItemId BF_Two_Handed_Sword2 Violet_Fear Death_Guidance Krieger_Twohand_Sword1 Veteran_Sword Krasnaya
syn keyword hItemId Claymore_C Knife Knife_ Knife__ Cutter Cutter_ Cutter__ Main_Gauche Main_Gauche_ Main_Gauche__ Dirk
syn keyword hItemId Dirk_ Dirk__ Dagger Dagger_ Dagger__ Stiletto Stiletto_ Stiletto__ Gladius Gladius_ Gladius__
syn keyword hItemId Damascus Forturn_Sword Sword_Breaker Mail_Breaker Damascus_ Weeder_Knife Combat_Knife Mama's_Knife
syn keyword hItemId House_Auger Bazerald Assasin_Dagger Exercise Moonlight_Sword Azoth Sucsamad Grimtooth_ Zeny_Knife
syn keyword hItemId Poison_Knife Princess_Knife Cursed_Dagger Counter_Dagger Novice_Knife Holy_Dagger Cinquedea
syn keyword hItemId Cinquedea_ Kindling_Dagger Obsidian_Dagger Fisherman's_Dagger Jur Jur_ Katar Katar_ Jamadhar
syn keyword hItemId Jamadhar_ Katar_Of_Cold_Icicle Katar_Of_Thornbush Katar_Of_Raging_Blaze Katar_Of_Piercing_Wind
syn keyword hItemId Ghoul_Leg Infiltrator Nail_Of_Loki Unholy_Touch Various_Jur Bloody_Roar Infiltrator_ Infiltrator_C
syn keyword hItemId Wild_Beast_Claw Inverse_Scale Drill_Katar Blood_Tears Scratcher Bloody_Roar_C Unholy_Touch_C
syn keyword hItemId Katar_Of_Cold_Icicle_ Katar_Of_Thornbush_ Katar_Of_Raging_Blaze_ Katar_Of_Piercing_Wind_ BF_Katar1
syn keyword hItemId BF_Katar2 Krieger_Katar1 Krieger_Katar2 Katar_Of_Speed Krishna Cakram Jamadhar_C Axe Axe_ Axe__
syn keyword hItemId Orcish_Axe Cleaver War_Axe Windhawk Golden_Axe Orcish_Axe_ Krieger_Onehand_Axe1 Vecer_Axe
syn keyword hItemId Orcish_Axe_C Tourist_Axe F_Tomahawk_C F_Right_Epsilon_C Battle_Axe Battle_Axe_ Battle_Axe__ Hammer
syn keyword hItemId Hammer_ Hammer__ Buster Buster_ Buster__ Two_Handed_Axe Two_Handed_Axe_ Two_Handed_Axe__ Brood_Axe
syn keyword hItemId Great_Axe Sabbath Right_Epsilon Slaughter Tomahawk Guillotine Doom_Slayer Doom_Slayer_
syn keyword hItemId Right_Epsilon_C Brood_Axe_C Tomahawk_C Berdysz Heart_Breaker Hurricane_Fury Great_Axe_C
syn keyword hItemId BF_Two_Handed_Axe1 BF_Two_Handed_Axe2 N_Battle_Axe Krieger_Twohand_Axe1 Holy_Celestial_Axe
syn keyword hItemId Veteran_Axe Bradium_Stonehammer Doom_Slayer_I Giant_Axe Two_Handed_Axe_C E_Tomahawk_C
syn keyword hItemId E_Right_Epsilon_C Javelin Javelin_ Javelin__ Spear Spear_ Spear__ Pike Pike_ Pike__ Lance Lance_
syn keyword hItemId Lance__ Gungnir Gelerdria Skewer Tjungkuletti Pole_Axe Gungnir_ Pole_Axe_C Long_Horn Battle_Hook
syn keyword hItemId Hunting_Spear Pole_XO Skewer_C BF_Spear1 Krieger_Onehand_Spear1 Spear_Of_Excellent Long_Horn_M
syn keyword hItemId Hunting_Spear_M Pike_C F_Pole_Axe_C E_Pole_Axe_C Guisarme Guisarme_ Guisarme__ Glaive Glaive_
syn keyword hItemId Glaive__ Partizan Partizan_ Partizan__ Trident Trident_ Trident__ Halberd Halberd_ Halberd__
syn keyword hItemId Crescent_Scythe Bill_Guisarme Zephyrus Longinus's_Spear Brionac Hell_Fire Staff_Of_Soul
syn keyword hItemId Wizardy_Staff Gae_Bolg Horseback_Lance Crescent_Scythe_ Spectral_Spear Ahlspiess Spectral_Spear_
syn keyword hItemId Gae_Bolg_ Zephyrus_ BF_Lance1 Ivory_Lance Cardo Battle_Fork Krieger_Twohand_Spear1 Lance_C
syn keyword hItemId Ahlspiess_C Club Club_ Club__ Mace Mace_ Mace__ Smasher Smasher_ Smasher__ Flail Flail_ Flail__
syn keyword hItemId Morning_Star Morning_Star_ Morning_Star__ Sword_Mace Sword_Mace_ Sword_Mace__ Chain Chain_ Chain__
syn keyword hItemId Stunner Spike Golden_Mace Long_Mace Slash Quadrille Grand_Cross Iron_Driver Mjolnir Spanner
syn keyword hItemId Stunner_ Warrior_Balmung Spanner_C Hollgrehenn_Hammer Good_Morning_Star Quadrille_C Spike_
syn keyword hItemId Golden_Mace_ Grand_Cross_ Nemesis BF_Morning_Star1 BF_Morning_Star2 Lunakaligo N_Mace
syn keyword hItemId Krieger_Onehand_Mace1 Mace_Of_Madness Veteran_Hammer Book Bible Tablet Book_Of_Billows
syn keyword hItemId Book_Of_Mother_Earth Book_Of_Blazing_Sun Book_Of_Gust_Of_Wind Book_Of_The_Apocalypse Girl's_Diary
syn keyword hItemId Legacy_Of_Dragon Diary_Of_Great_Sage Hardback Bible_Of_Battlefield Diary_Of_Great_Sage_C
syn keyword hItemId Encyclopedia Death_Note Diary_Of_Great_Basil Hardback_C Book_Of_Billows_ Book_Of_Mother_Earth_
syn keyword hItemId Book_Of_Blazing_Sun_ Book_Of_Gust_Of_Wind_ Principles_Of_Magic Ancient_Magic BF_Book1 BF_Book2
syn keyword hItemId Krieger_Book1 Krieger_Book2 Book_Of_Prayer Death_Note_M Encyclopedia_C F_Diary_Of_Great_Sage_C
syn keyword hItemId E_Diary_Of_Great_Sage_C Angra_Manyu Rod Rod_ Rod__ Wand Wand_ Wand__ Staff Staff_ Staff__ Arc_Wand
syn keyword hItemId Arc_Wand_ Arc_Wand__ Mighty_Staff Blessed_Wand Bone_Wand Staff_Of_Wing Survival_Rod Survival_Rod_
syn keyword hItemId Survival_Rod2 Survival_Rod2_ Hypnotist's_Staff Hypnotist's_Staff_ Mighty_Staff_C Lich_Bone_Wand
syn keyword hItemId Healing_Staff Piercing_Staff Staffy Survival_Rod_C Walking_Stick Release_Of_Wish Holy_Stick
syn keyword hItemId BF_Staff1 BF_Staff2 BF_Staff3 BF_Staff4 Thorn_Staff Eraser Healing_Staff_C N_Rod
syn keyword hItemId Krieger_Onehand_Staff1 Krieger_Onehand_Staff2 Staff_Of_Darkness Dead_Tree_Cane Piercing_Staff_M
syn keyword hItemId Lich_Bone_Wand_M La'cryma_Stick Croce_Staff Staff_Of_Bordeaux Bow Bow_ Bow__ Composite_Bow
syn keyword hItemId Composite_Bow_ Composite_Bow__ Great_Bow Great_Bow_ Great_Bow__ CrossBow CrossBow_ CrossBow__
syn keyword hItemId Arbalest Kakkung Arbalest_ Kakkung_ Hunter_Bow Bow_Of_Roguemaster Bow_Of_Rudra Repeting_CrossBow
syn keyword hItemId Balistar Luna_Bow Dragon_Wing Bow_Of_Minstrel Hunter_Bow_ Balistar_ Balistar_C Bow_Of_Rudra_C
syn keyword hItemId Burning_Bow Frozen_Bow Earth_Bow Gust_Bow Orc_Archer_Bow Kkakkung Double_Bound Ixion_Wing BF_Bow1
syn keyword hItemId BF_Bow2 Nepenthes_Bow Cursed_Lyre N_Composite_Bow Krieger_Bow1 Bow_Of_Evil Falken_Blitz Arrow
syn keyword hItemId Silver_Arrow Fire_Arrow Steel_Arrow Crystal_Arrow Arrow_Of_Wind Stone_Arrow Immatrial_Arrow
syn keyword hItemId Stun_Arrow Freezing_Arrow Flash_Arrow Curse_Arrow Rusty_Arrow Poison_Arrow Incisive_Arrow
syn keyword hItemId Oridecon_Arrow Arrow_Of_Counter_Evil Arrow_Of_Shadow Sleep_Arrow Silence_Arrow Iron_Arrow
syn keyword hItemId Venom_Knife Holy_Arrow Waghnakh Waghnakh_ Knuckle_Duster Knuckle_Duster_ Hora Hora_ Fist Fist_ Claw
syn keyword hItemId Claw_ Finger Finger_ Kaiser_Knuckle Berserk Claw_Of_Garm Berserk_ Kaiser_Knuckle_C Magma_Fist
syn keyword hItemId Icicle_Fist Electric_Fist Seismic_Fist Combo_Battle_Glove BF_Knuckle1 BF_Knuckle2 Horn_Of_Hilthrion
syn keyword hItemId Krieger_Knuckle1 Krieger_Knuckle2 Monk_Knuckle Fist_C Violin Violin_ Mandolin Mandolin_ Lute Lute_
syn keyword hItemId Guitar Guitar_ Harp Harp_ Guh_Moon_Goh Guh_Moon_Goh_ Electronic_Guitar Guitar_Of_Passion
syn keyword hItemId Guitar_Of_Blue_Solo Guitar_Of_Vast_Land Guitar_Of_Gentle_Breeze Oriental_Lute Base_Guitar
syn keyword hItemId Berserk_Guitar Guh_Moon_Gom Oriental_Lute_ BF_Instrument1 BF_Instrument2 Cello Harp_Of_Nepenthes
syn keyword hItemId Krieger_Instrument1 Berserk_Guitar_I Guitar_C Rope Rope_ Line Line_ Wire Wire_ Rante Rante_ Tail
syn keyword hItemId Tail_ Whip Whip_ Lariat Rapture_Rose Chemeti Whip_Of_Red_Flame Whip_Of_Ice_Piece Whip_Of_Earth
syn keyword hItemId Jump_Rope Bladed_Whip Queen's_Whip Electric_Wire Electric_Eel Sea_Witch_Foot Carrot_Whip
syn keyword hItemId Queen_Is_Whip Queen's_Whip_ BF_Whip1 BF_Whip2 Stem_Of_Nepenthes Whip_Of_Balance Krieger_Whip1
syn keyword hItemId Phenomena_Whip Rante_C Destruction_Rod Divine_Cross Krieger_Twohand_Staff1 Destruction_Rod_M Kronos
syn keyword hItemId Dea_Staff G_Staff_Of_Light Guard Guard_ Buckler Buckler_ Shield Shield_ Mirror_Shield
syn keyword hItemId Mirror_Shield_ Memorize_Book Holy_Guard Herald_Of_GOD Novice_Guard Novice_Shield Stone_Buckler
syn keyword hItemId Valkyrja's_Shield Angel's_Safeguard Arm_Guard Arm_Guard_ Improved_Arm_Guard Improved_Arm_Guard_
syn keyword hItemId Memorize_Book_ Platinum_Shield Orleans_Server Thorny_Buckler Strong_Shield Guyak_Shield
syn keyword hItemId Secular_Mission Herald_Of_GOD_ Exorcism_Bible Cross_Shield Magic_Study_Vol1 Shelter_Resistance
syn keyword hItemId Tournament_Shield Shield_Of_Naga Shadow_Guard Cracked_Buckler Valkyrja's_Shield_C Bradium_Shield
syn keyword hItemId Ahura_Mazda Sunglasses Sunglasses_ Glasses Glasses_ Diver's_Goggles Wedding_Veil Fancy_Flower
syn keyword hItemId Ribbon Ribbon_ Hair_Band Bandana Eye_Bandage Cat_Hairband Bunny_Band Flower_Hairband Biretta
syn keyword hItemId Biretta_ Flu_Mask Flu_Mask_ Hat Hat_ Turban Turban_ Goggle Goggle_ Cap Cap_ Helm Helm_
syn keyword hItemId Gemmed_Sallet Gemmed_Sallet_ Circlet Circlet_ Tiara Crown Santa's_Hat Weird_Goatee One_Eyed_Glass
syn keyword hItemId Beard Granpa_Beard Luxury_Sunglasses Spinning_Eyes Big_Sis'_Ribbon Sweet_Gents Golden_Gear
syn keyword hItemId Oldman's_Romance Western_Grace Coronet Fillet Holy_Bonnet Star_Sparkling Sunflower Angelic_Chain
syn keyword hItemId Satanic_Chain Magestic_Goat Snowy_Horn Sharp_Gear Mini_Propeller Mini_Glasses Prontera_Army_Cap
syn keyword hItemId Pierrot_Nose Gangster_Patch Munak_Turban Ganster_Mask Iron_Cane Cigar Smoking_Pipe
syn keyword hItemId Centimental_Flower Centimental_Leaf Jack_A_Dandy Stop_Post Doctor_Cap Ghost_Bandana Red_Bandana
syn keyword hItemId Eagle_Eyes Nurse_Cap Mr_Smile Bomb_Wick Sahkkat Phantom_Of_Opera Spirit_Chain Ear_Mufs Antler
syn keyword hItemId Apple_Of_Archer Elven_Ears Pirate_Bandana Mr_Scream Poo_Poo_Hat Funeral_Costume Masquerade
syn keyword hItemId Welding_Mask Pretend_Murdered Star_Dust Blinker Binoculars Goblini_Mask Green_Feeler Viking_Helm
syn keyword hItemId Cotton_Shirt Cotton_Shirt_ Leather_Jacket Leather_Jacket_ Adventure_Suit Adventurere's_Suit_ Mantle
syn keyword hItemId Mantle_ Coat Coat_ Mink_Coat Padded_Armor Padded_Armor_ Chain_Mail Chain_Mail_ Plate_Armor
syn keyword hItemId Plate_Armor_ Clothes_Of_The_Lord Glittering_Clothes Formal_Suit Silk_Robe Silk_Robe_ Scapulare
syn keyword hItemId Scapulare_ Saint_Robe Saint_Robe_ Holy_Robe Wooden_Mail Wooden_Mail_ Tights Tights_ Silver_Robe
syn keyword hItemId Silver_Robe_ Mage_Coat Thief_Clothes Thief_Clothes_ Ninja_Suit Wedding_Dress G_Strings
syn keyword hItemId Novice_Breast Full_Plate_Armor Full_Plate_Armor_ Robe_Of_Casting Flame_Sprits_Armor
syn keyword hItemId Flame_Sprits_Armor_ Water_Sprits_Armor Water_Sprits_Armor_ Wind_Sprits_Armor Wind_Sprits_Armor_
syn keyword hItemId Earth_Sprits_Armor Earth_Sprits_Armor_ Novice_Plate Odin's_Blessing Goibne's_Armor
syn keyword hItemId Angel's_Protection Vestment_Of_Grace Valkyrie_Armor Dress_Of_Angel Ninja_Suit_ Robe_Of_Casting_
syn keyword hItemId Meteo_Plate_Armor Orleans_Gown Divine_Cloth Sniping_Suit Golden_Armor Freyja_Overcoat
syn keyword hItemId Used_Mage_Coat G_Strings_ Mage_Coat_ Holy_Robe_ Diabolus_Robe Diabolus_Armor Assaulter_Plate
syn keyword hItemId Elite_Engineer_Armor Assassin_Robe Warlock_Battle_Robe Medic_Robe Elite_Archer_Suit
syn keyword hItemId Elite_Shooter_Suit Brynhild Spritual_Tunic Recuperative_Armor Chameleon_Armor Sprint_Mail Kandura
syn keyword hItemId Armor_Of_Naga Improved_Tights Life_Link Old_Pant N_Adventurer's_Suit Krieger_Suit1 Krieger_Suit2
syn keyword hItemId Krieger_Suit3 Incredible_Coat Sniping_Suit_M Dragon_Vest Sandals Sandals_ Shoes Shoes_ Boots Boots_
syn keyword hItemId Chrystal_Pumps Cuffs Spiky_Heel Sleipnir Grave Grave_ Safty_Boots Novice_Boots Slipper Novice_Shoes
syn keyword hItemId Fricco_Shoes Vidar's_Boots Goibne's_Combat_Boots Angel's_Arrival Valkyrie_Shoes
syn keyword hItemId High_Fashion_Sandals Variant_Shoes Tidal_Shoes Black_Leather_Boots Shadow_Walk Golden_Shoes
syn keyword hItemId Iron_Boots01 Iron_Boots02 Valley_Shoes Spiky_Heel_ Diabolus_Boots Black_Leather_Boots_
syn keyword hItemId Battle_Greave Combat_Boots Battle_Boots Paw_Of_Cat Refresh_Shoes Sprint_Shoes Beach_Sandal
syn keyword hItemId Boots_Perforated Fish_Shoes Krieger_Shoes1 Krieger_Shoes2 Krieger_Shoes3 Military_Boots Air_Boss
syn keyword hItemId Variant_Shoes_M Vital_Tree_Shoes Hood Hood_ Muffler Muffler_ Manteau Manteau_ Cape_Of_Ancient_Lord
syn keyword hItemId Ragamuffin_Cape Clack_Of_Servival Novice_Hood Skeleton's_Cape Novice_Manteau Celestial_Robe
syn keyword hItemId Pauldron Wing_Of_Eagle Falcon_Robe Vali's_Manteau Morpheus's_Shawl Morrigane's_Manteau
syn keyword hItemId Goibne's_Shoulder_Arms Angel's_Warmth Undershirt Undershirt_ Valkyrie_Manteau Cape_Of_Ancient_Lord_
syn keyword hItemId Dragon_Scale_Coat Dragon_Breath Wool_Scarf Rider_Insignia Rider_Insignia_ Ulfhedinn
syn keyword hItemId Mithril_Magic_Cape Ruffler Cloak_Of_Survival_C Skin_Of_Ventus Diabolus_Manteau Commander_Manteau
syn keyword hItemId Commander_Manteau_ Sheriff_Manteau Asprika Flame_Manteau Sylphid_Manteau Leather_Of_Tendrilion
syn keyword hItemId Musika Beach_Manteau Cheap_Running_Shirts Muffler_C Krieger_Muffler1 Fisher's_Muffler
syn keyword hItemId Rider_Insignia_M Mithril_Magic_Cape_M Dragon_Manteau Piece_Of_Angent_Skin Ring Earring Necklace
syn keyword hItemId Glove Brooch Clip Rosary Skul_Ring Gold_Ring Silver_Ring Flower_Ring Diamond_Ring
syn keyword hItemId An_Eye_Of_Dullahan Safety_Ring Critical_Ring Mitten_Of_Presbyter Matyr's_Flea_Guard
syn keyword hItemId Thimble_Of_Archer Ring_Of_Rogue Ring_ Earring_ Necklace_ Glove_ Brooch_ Rosary_ Belt Novice_Armlet
syn keyword hItemId Magingiorde Brysinggamen First_Age_Ring Bridegroom_Ring Bride_Ring Gold_Ring_ Silver_Ring_
syn keyword hItemId Exorcize_Sachet Purification_Sachet Kafra_Ring Fashionable_Sack Serin's_Gold_Ring
syn keyword hItemId Serin's_Gold_Ring_ The_Sign_ Moonlight_Ring Bunch_Of_Carnation Nile_Rose Morpheus's_Ring
syn keyword hItemId Morpheus's_Armlet Morrigane's_Belt Morrigane's_Pendant Cursed_Lucky_Brooch Sacrifice_Ring
syn keyword hItemId Shinobi's_Sash Bloody_Iron_Ball Hyper_Changer Lab_Passport Nile_Rose_ Vesper_Core01 Vesper_Core02
syn keyword hItemId Vesper_Core03 Vesper_Core04 Gauntlet_Of_Accuracy Scarf_Belt Ring_Of_Exorcism Lamp_Of_Hope
syn keyword hItemId Glove_Of_Archer Women's_Glory Golden_Necklace_ Ring_Of_Longing Thimble_Of_Archer_ Anniversary_Ring
syn keyword hItemId Shining_Ring Honor_Ring Lord_Ring Hunter_Earring Spiritual_Ring Ring_Of_Flame_Lord
syn keyword hItemId Ring_Of_Resonance Lesser_Elemental_Ring Republic_Ring Ring_Of_Water Ring_Of_Fire Ring_Of_Wind
syn keyword hItemId Ring_Of_Earth Elven_Ears_C Steel_Flower_C Critical_Ring_C Earring_C Ring_C Necklace_C Glove_C
syn keyword hItemId Brooch_C Rosary_C Safety_Ring_C Vesper_Core01_C Vesper_Core02_C Vesper_Core03_C Vesper_Core04_C
syn keyword hItemId Red_Silk_Seal Orleans_Glove Bison_Horn Expert_Ring Golden_Accessory Golden_Accessory2 Handcuff
syn keyword hItemId GUSLI Chinese_Handicraft 5_Anniversary_Coin Bloody_Iron_Ball_C Spiritual_Ring_C Ragnarok_Limited_Ed
syn keyword hItemId Certificate_TW Marvelous_Pandent Skul_Ring_ Librarian_Glove Pocket_Watch_ Lunatic_Brooch Iron_Wrist
syn keyword hItemId Medal_Swordman Medal_Thief Medal_Acolyte Medal_Mage Medal_Archer Medal_Merchant Icarus_Wing
syn keyword hItemId Bowman_Scarf Cursed_Hand Diabolus_Ring Morroc_Seal Morroc_Charm_Stone Morroc_Ring Medal_Gunner
syn keyword hItemId Directive_A Directive_B Navel_Ring Foot_Ring Shiny_Coin Ordinary_Coin Rusty_Coin All_In_One_Ring
syn keyword hItemId Angelic_Ring Sprint_Ring Pinguicula_Corsage Cold_Heart Black_Cat Cursed_Star Linen_Glove
syn keyword hItemId Academy_Badge Praxinus_C Beholder_Ring Hallow_Ring Clamorous_Ring Chemical_Ring Insecticide_Ring
syn keyword hItemId Fisher_Ring Decussate_Ring Bloody_Ring Satanic_Ring Dragoon_Ring Skul_Ring_C Small_Fishing_Rod
syn keyword hItemId Novice_Figure Swordman_Figure Acolyte_Figure Mage_Figure Archer_Figure Thief_Figure Merchant_Figure
syn keyword hItemId Krieger_Ring1 Krieger_Ring2 Krieger_Ring3 Lure Cool_Towel Shaman_Ring Shaman_Earing
syn keyword hItemId Dark_Knight_Belt Dark_Knight_Glove Aumdura's_Grace Ring_Of_Wise_King Eyes_Stone_Ring Oh_Holy_Night
syn keyword hItemId Orleans_Glove_M Spiritual_Ring_M Waterdrop_Brooch Bradium_Earing Bradium_Ring Bradium_Brooch
syn keyword hItemId Just_Got_Fish Magic_Stone_Ring Green_Apple_Ring Magical_Stone Magical_Stone_
syn keyword hItemId Will_Of_Exhausted_Angel Kuirpenring Swordman_Manual Thief_Manual Acolyte_Manual Archer_Manual
syn keyword hItemId Merchant_Manual Mage_Manual Poring_Card Fabre_Card Pupa_Card Drops_Card Poring__Card Lunatic_Card
syn keyword hItemId Pecopeco_Egg_Card Picky_Card Chonchon_Card Wilow_Card Picky__Card Thief_Bug_Egg_Card Andre_Egg_Card
syn keyword hItemId Roda_Frog_Card Condor_Card Thief_Bug_Card Savage_Babe_Card Andre_Larva_Card Hornet_Card
syn keyword hItemId Farmiliar_Card Rocker_Card Spore_Card Desert_Wolf_Babe_Card Plankton_Card Skeleton_Card
syn keyword hItemId Thief_Bug_Female_Card Kukre_Card Tarou_Card Wolf_Card Mandragora_Card Pecopeco_Card Ambernite_Card
syn keyword hItemId Poporing_Card Worm_Tail_Card Hydra_Card Muka_Card Snake_Card Zombie_Card Stainer_Card Creamy_Card
syn keyword hItemId Coco_Card Steel_Chonchon_Card Andre_Card Smokie_Card Horn_Card Martin_Card Ghostring_Card
syn keyword hItemId Poison_Spore_Card Vadon_Card Thief_Bug_Male_Card Yoyo_Card Elder_Wilow_Card Vitata_Card
syn keyword hItemId Angeling_Card Marina_Card Dustiness_Card Metaller_Card Thara_Frog_Card Soldier_Andre_Card
syn keyword hItemId Goblin_Card Cornutus_Card Anacondaq_Card Caramel_Card Zerom_Card Kaho_Card Orc_Warrior_Card
syn keyword hItemId Megalodon_Card Scorpion_Card Drainliar_Card Eggyra_Card Orc_Zombie_Card Golem_Card Pirate_Skel_Card
syn keyword hItemId BigFoot_Card Argos_Card Magnolia_Card Phen_Card Savage_Card Mantis_Card Flora_Card Hode_Card
syn keyword hItemId Desert_Wolf_Card Rafflesia_Card Marine_Sphere_Card Orc_Skeleton_Card Soldier_Skeleton_Card
syn keyword hItemId Giearth_Card Frilldora_Card Sword_Fish_Card Munak_Card Kobold_Card Skel_Worker_Card Obeaune_Card
syn keyword hItemId Archer_Skeleton_Card Marse_Card Zenorc_Card Matyr_Card Dokebi_Card Pasana_Card Sohee_Card
syn keyword hItemId Sand_Man_Card Whisper_Card Horong_Card Requiem_Card Marc_Card Mummy_Card Verit_Card Myst_Card
syn keyword hItemId Jakk_Card Ghoul_Card Strouf_Card Marduk_Card Marionette_Card Argiope_Card Hunter_Fly_Card Isis_Card
syn keyword hItemId Side_Winder_Card Petit_Card Bathory_Card Petit__Card Phreeoni_Card Deviruchi_Card Eddga_Card
syn keyword hItemId Medusa_Card Deviace_Card Minorous_Card Nightmare_Card Golden_Bug_Card Baphomet__Card
syn keyword hItemId Scorpion_King_Card Moonlight_Flower_Card Mistress_Card Daydric_Card Dracula_Card Orc_Load_Card
syn keyword hItemId Khalitzburg_Card Drake_Card Anubis_Card Joker_Card Knight_Of_Abyss_Card Evil_Druid_Card
syn keyword hItemId Doppelganger_Card Orc_Hero_Card Osiris_Card Berzebub_Card Maya_Card Baphomet_Card Pharaoh_Card
syn keyword hItemId Gargoyle_Card Goat_Card Gajomart_Card Galapago_Card Crab_Card Rice_Cake_Boy_Card Goblin_Leader_Card
syn keyword hItemId Steam_Goblin_Card Goblin_Archer_Card Flying_Deleter_Card Nine_Tail_Card Antique_Firelock_Card
syn keyword hItemId Grand_Peco_Card Grizzly_Card Gryphon_Card Gullinbursti_Card Gig_Card Nightmare_Terror_Card
syn keyword hItemId Neraid_Card Dark_Lord_Card Dark_Illusion_Card Dark_Frame_Card Dark_Priest_Card The_Paper_Card
syn keyword hItemId Demon_Pungus_Card Deviling_Card Poison_Toad_Card Dullahan_Card Dryad_Card Dragon_Tail_Card
syn keyword hItemId Dragon_Fly_Card Driller_Card Disguise_Card Diabolic_Card Vagabond_Wolf_Card Lava_Golem_Card
syn keyword hItemId Rideword_Card Raggler_Card Raydric_Archer_Card Leib_Olmai_Card Wraith_Dead_Card Wraith_Card
syn keyword hItemId Loli_Ruri_Card Rotar_Zairo_Card Lude_Card Rybio_Card Leaf_Cat_Card Marin_Card Mastering_Card
syn keyword hItemId Maya_Puple_Card Merman_Card Megalith_Card Majoruros_Card Civil_Servant_Card Mutant_Dragon_Card
syn keyword hItemId Mini_Demon_Card Mimic_Card Mystcase_Card Mysteltainn_Card Miyabi_Ningyo_Card Violy_Card
syn keyword hItemId Wander_Man_Card Vocal_Card Bon_Gun_Card Brilight_Card Bloody_Murderer_Card Blazzer_Card
syn keyword hItemId Sasquatch_Card Live_Peach_Tree_Card Succubus_Card Sageworm_Card Solider_Card Skeleton_General_Card
syn keyword hItemId Skel_Prisoner_Card Stalactic_Golem_Card Stem_Worm_Card Stone_Shooter_Card Sting_Card
syn keyword hItemId Spring_Rabbit_Card Sleeper_Card C_Tower_Manager_Card Shinobi_Card Increase_Soil_Card
syn keyword hItemId Wild_Ginseng_Card Baby_Leopard_Card Anolian_Card Cookie_XMAS_Card Amon_Ra_Card Owl_Duke_Card
syn keyword hItemId Owl_Baron_Card Iron_Fist_Card Arclouse_Card Archangeling_Card Apocalips_Card Antonio_Card
syn keyword hItemId Alarm_Card Am_Mut_Card Assulter_Card Aster_Card Ancient_Mummy_Card Ancient_Worm_Card
syn keyword hItemId Executioner_Card Elder_Card Alligator_Card Alice_Card Tirfing_Card Orc_Lady_Card Orc_Archer_Card
syn keyword hItemId Wild_Rose_Card Wicked_Nymph_Card Wooden_Golem_Card Wootan_Shooter_Card Wootan_Fighter_Card
syn keyword hItemId Evil_Cloud_Hermit_Card Incant_Samurai_Card Wind_Ghost_Card Li_Me_Mang_Ryang_Card Eclipse_Card
syn keyword hItemId Explosion_Card Injustice_Card Incubus_Card Giant_Spider_Card Giant_Honet_Card Dancing_Dragon_Card
syn keyword hItemId Shellfish_Card Zombie_Master_Card Zombie_Prisoner_Card Lord_Of_Death_Card Zherlthsh_Card
syn keyword hItemId Gibbet_Card Deleter_Card Geographer_Card Zipper_Bear_Card Tengu_Card Greatest_General_Card
syn keyword hItemId Chepet_Card Choco_Card Karakasa_Card Kapha_Card Carat_Card Caterpillar_Card Cat_O_Nine_Tail_Card
syn keyword hItemId Kobold_Leader_Card Kobold_Archer_Card Cookie_Card Quve_Card Kraben_Card Cramp_Card Cruiser_Card
syn keyword hItemId Cremy_Fear_Card Clock_Card Chimera_Card Killer_Mantis_Card Tao_Gunka_Card Whisper_Boss_Card
syn keyword hItemId Tamruan_Card Turtle_General_Card Toad_Card Kind_Of_Beetle_Card Tri_Joint_Card Parasite_Card
syn keyword hItemId Panzer_Goblin_Card Permeter_Card Fur_Seal_Card Punk_Card Penomena_Card Pest_Card Fake_Angel_Card
syn keyword hItemId Mobster_Card Knight_Windstorm_Card Freezer_Card Bloody_Knight_Card Hylozoist_Card High_Orc_Card
syn keyword hItemId Garm_Baby_Card Garm_Card Harpy_Card See_Otter_Card Blood_Butterfly_Card Hyegun_Card Phendark_Card
syn keyword hItemId Dark_Snake_Lord_Card Heater_Card Waste_Stove_Card Venomous_Card Noxious_Card Pitman_Card
syn keyword hItemId Ungoliant_Card Porcellio_Card Obsidian_Card Mineral_Card Teddy_Bear_Card Metaling_Card
syn keyword hItemId Rsx_0806_Card Mole_Card Anopheles_Card Hill_Wind_Card Ygnizem_Card Armaia_Card Whikebain_Card
syn keyword hItemId Erend_Card Rawrel_Card Kavac_Card B_Ygnizem_Card Removal_Card Gemini_Card Gremlin_Card
syn keyword hItemId Beholder_Card B_Seyren_Card Seyren_Card B_Eremes_Card Eremes_Card B_Harword_Card Harword_Card
syn keyword hItemId B_Magaleta_Card Magaleta_Card B_Katrinn_Card Katrinn_Card B_Shecil_Card Shecil_Card Venatu_Card
syn keyword hItemId Dimik_Card Archdam_Card Bacsojin_Card Chung_E_Card Apocalips_H_Card Orc_Baby_Card Lady_Tanee_Card
syn keyword hItemId Green_Iguana_Card Acidus_Card Acidus__Card Ferus_Card Ferus__Card Novus__Card Novus_Card Hydro_Card
syn keyword hItemId Dragon_Egg_Card Detale_Card Ancient_Mimic_Card Deathword_Card Plasma_Card Breeze_Card
syn keyword hItemId Retribution_Card Observation_Card Shelter_Card Solace_Card Tha_Maero_Card Tha_Odium_Card
syn keyword hItemId Tha_Despero_Card Tha_Dolor_Card Thanatos_Card Aliza_Card Alicel_Card Aliot_Card Kiel_Card
syn keyword hItemId Skogul_Card Frus_Card Skeggiold_Card Randgris_Card Gloom_Under_Night_Card Agav_Card Echio_Card
syn keyword hItemId Vanberk_Card Isilla_Card Hodremlin_Card Seeker_Card Snowier_Card Siroma_Card Ice_Titan_Card
syn keyword hItemId Gazeti_Card Ktullanux_Card Muscipular_Card Drosera_Card Roween_Card Galion_Card Stapo_Card
syn keyword hItemId Atroce_Card Byorgue_Card Sword_Guardian_Card Bow_Guardian_Card Salamander_Card Ifrit_Card Kasa_Card
syn keyword hItemId Magmaring_Card Imp_Card Knocker_Card Zombie_Slaughter_Card Ragged_Zombie_Card Hell_Poodle_Card
syn keyword hItemId Banshee_Card Flame_Skull_Card Necromancer_Card Fallen_Bishop_Card Tatacho_Card Aqua_Elemental_Card
syn keyword hItemId Draco_Card Luciola_Vespa_Card Centipede_Card Cornus_Card Dark_Shadow_Card Banshee_Master_Card
syn keyword hItemId Entweihen_Card Centipede_Larva_Card Hilsrion_Card Strength1 Strength2 Strength3 Strength4 Strength5
syn keyword hItemId Strength6 Strength7 Strength8 Strength9 Strength10 Inteligence1 Inteligence2 Inteligence3
syn keyword hItemId Inteligence4 Inteligence5 Inteligence6 Inteligence7 Inteligence8 Inteligence9 Inteligence10
syn keyword hItemId Dexterity1 Dexterity2 Dexterity3 Dexterity4 Dexterity5 Dexterity6 Dexterity7 Dexterity8 Dexterity9
syn keyword hItemId Dexterity10 Agility1 Agility2 Agility3 Agility4 Agility5 Agility6 Agility7 Agility8 Agility9
syn keyword hItemId Agility10 Vitality1 Vitality2 Vitality3 Vitality4 Vitality5 Vitality6 Vitality7 Vitality8 Vitality9
syn keyword hItemId Vitality10 Luck1 Luck2 Luck3 Luck4 Luck5 Luck6 Luck7 Luck8 Luck9 Luck10 Matk1 Matk2 Evasion6
syn keyword hItemId Evasion12 Critical5 Critical7 Atk2 Atk3 Str1_J Str2_J Str3_J Int1_J Int2_J Int3_J Vit1_J Vit2_J
syn keyword hItemId Vit3_J Agi1_J Agi2_J Agi3_J Dex1_J Dex2_J Dex3_J Luk1_J Luk2_J Luk3_J Headset Gemmed_Crown
syn keyword hItemId Joker_Jester Oxygen_Mask Gas_Mask Machoman_Glasses Loard_Circlet Puppy_Love Safety_Helmet
syn keyword hItemId Indian_Hair_Piece Antenna Ph.D_Hat Horn_Of_Lord_Kaho Fin_Helm Egg_Shell Boy's_Cap Bone_Helm
syn keyword hItemId Feather_Bonnet Corsair Kafra_Band Bankruptcy_Of_Heart Helm_Of_Sun Hat_Of_Bundle Hat_Of_Cake
syn keyword hItemId Helm_Of_Angel Hat_Of_Cook Wizardry_Hat Candle Spore_Hat Panda_Cap Mine_Helm Picnic_Hat Smokie_Hat
syn keyword hItemId Light_Bulb_Band Poring_Hat Cross_Band Fruit_Shell Deviruchi_Cap Mottled_Egg_Shell Blush
syn keyword hItemId Heart_Hair_Pin Hair_Protector Opera_Ghost_Mask Devil's_Wing Magician_Hat Bongun_Hat
syn keyword hItemId Fashion_Sunglass First_Moon_Hair_Pin Stripe_Band Mystery_Fruit_Shell Kitty_Bell Blue_Hair_Band
syn keyword hItemId Spinx_Helm Assasin_Mask Novice_Egg_Cap Love_Berry Ear_Of_Black_Cat Drooping_Kitty Brown_Bear_Cap
syn keyword hItemId Party_Hat Flower_Hairpin Straw_Hat Plaster Leaf_Headgear Fish_On_Head Horn_Of_Succubus Sombrero
syn keyword hItemId Ear_Of_Devil's_Wing Mask_Of_Fox Headband_Of_Power Indian_Headband Inccubus_Horn
syn keyword hItemId Cap_Of_Concentration Ear_Of_Angel's_Wing Cowboy_Hat Fur_Hat Tulip_Hairpin Sea_Otter_Cap
syn keyword hItemId Crossed_Hair_Band Headgear_Of_Queen Mistress_Crown Mushroom_Band Red_Tailed_Ribbon Lazy_Raccoon
syn keyword hItemId Pair_Of_Red_Ribbon Alarm_Mask Goblin_Mask_01 Goblin_Mask_02 Goblin_Mask_03 Goblin_Mask_04
syn keyword hItemId Big_Golden_Bell Blue_Coif Blue_Coif_ Orc_Hero_Helm Assassin_Mask_ Cone_Hat_ Tiger_Mask Cat_Hat
syn keyword hItemId Sales_Signboard Takius_Blindfold Round_Eyes Sunflower_Hairpin Dark_Blindfold Hat_Of_Cake_
syn keyword hItemId Cone_Hat_INA Well_Baked_Toast Detective_Hat Red_Bonnet Baby_Pacifier Galapago_Cap Super_Novice_Hat
syn keyword hItemId Angry_Mouth Fedora Winter_Hat Banana_Hat Mistic_Rose Ear_Of_Puppy Super_Novice_Hat_ Fedora_
syn keyword hItemId Zherlthsh_Mask Magni_Cap Ulle_Cap Fricca_Circlet Kiss_Of_Angel Morpheus's_Hood Morrigane's_Helm
syn keyword hItemId Goibne's_Helmet Bird_Nest Lion_Mask Close_Helmet Angeling_Hat Sheep_Hat Pumpkin_Hat Cyclops_Visor
syn keyword hItemId Santa's_Hat_ Alice_Doll Magic_Eyes Hibiscus Charming_Ribbon Marionette_Doll Crescent_Helm
syn keyword hItemId Kabuki_Mask Gambler_Hat Carnival_Joker_Jester Elephant_Hat Baseball_Cap Phrygian_Cap Silver_Tiara
syn keyword hItemId Joker_Jester_ Headset_OST Chinese_Crown Angeling_Hairpin Sunglasses_F Granpa_Beard_F Flu_Mask_F
syn keyword hItemId Viking_Helm_ Holy_Bonnet_ Golden_Gear_ Magestic_Goat_ Sharp_Gear_ Bone_Helm_ Corsair_ Tiara_ Crown_
syn keyword hItemId Spinx_Helm_ Munak_Turban_ Bongun_Hat_ Bride_Mask Feather_Beret Valkyrie_Helm Beret Satto_Hat Ayam
syn keyword hItemId Censor_Bar Hahoe_Mask Guardian_Lion_Mask Candle_ Gold_Tiara Phrygian_Cap_ Helm_Of_Darkness
syn keyword hItemId Puppy_Hat Bird_Nest_Hat Captain_Hat Laurel_Wreath Geographer_Band Twin_Ribbon Minstrel_Hat
syn keyword hItemId Fallen_Leaves Baseball_Cap_ Ribbon_Black Ribbon_Yellow Ribbon_Green Ribbon_Pink Ribbon_Red
syn keyword hItemId Ribbon_Orange Ribbon_White Drooping_Bunny Baseball_Cap_I Coppola Party_Hat_B Pumpkin_Hat_
syn keyword hItemId Tongue_Mask Event_Pierrot_Nose Wreath Romantic_White_Flower Gold_Spirit_Chain Rideword_Hat
syn keyword hItemId Yellow_Baseball_Cap Flying_Angel Dress_Hat Satellite_Hairband Black_Bunny_Band Moonlight_Flower_Hat
syn keyword hItemId Angelic_Chain_ Satanic_Chain_ Magestic_Goat_TW Bunny_Band_ Drooping_Kitty_ Smoking_Pipe_
syn keyword hItemId Pair_Of_Red_Ribbon_ Fish_On_Head_ Big_Golden_Bell_ Orc_Hero_Helm_TW Marcher_Hat Mini_Propeller_
syn keyword hItemId Red_Deviruchi_Cap White_Deviruchi_Cap Gray_Deviruchi_Cap White_Drooping_Kitty Gray_Drooping_Kitty
syn keyword hItemId Pink_Drooping_Kitty Blue_Drooping_Kitty Yellow_Drooping_Kitty Gray_Fur_Hat Blue_Fur_Hat
syn keyword hItemId Pink_Fur_Hat Red_Wizardry_Hat White_Wizardry_Hat Gray_Wizardry_Hat Blue_Wizardry_Hat
syn keyword hItemId Yellow_Wizardry_Hat Chullos Elven_Blindfold Elven_Sunglasses Angelic_Helm Satanic_Helm
syn keyword hItemId Robotic_Blindfold Human_Blindfold Robotic_Ears Round_Ears Drooping_Nine_Tail Lif_Doll_Hat
syn keyword hItemId Deviling_Hat Triple_Poring_Hat Valkyrie_Feather_Band Soulless_Wing Afro_Wig Elephant_Hat_
syn keyword hItemId Cookie_Hat Silver_Tiara_ Gold_Tiara_ Ati_Atihan_Hat Aussie_Flag_Hat Apple_Of_Archer_C Bunny_Band_C
syn keyword hItemId Sahkkat_C Lord_Circlet_C Flying_Angel_ Fallen_Leaves_ Chinese_Crown_ Tongue_Mask_ Happy_Wig
syn keyword hItemId Shiny_Wig Marvelous_Wig Fantastic_Wig Yellow_Bandana Yellow_Ribbon Drooping_Kitty_C Magestic_Goat_C
syn keyword hItemId Deviruchi_Cap_C euRO_Baseball_Cap Chick_Hat Water_Lily_Crown Vane_Hairpin Pecopeco_Hairband
syn keyword hItemId Vacation_Hat Red_Glasses Vanilmirth_Hat Drooping_Bunny_ Kettle_Hat Dragon_Skull Ramen_Hat
syn keyword hItemId Whisper_Mask Golden_Bandana Drooping_Nine_Tail_ Soulless_Wing_ Marvelous_Wig_ Ati_Atihan_Hat_
syn keyword hItemId Bullock_Helm Russian_Ribbon Lotus_Flower_Hat Flower_Coronet Cap_Of_Blindness Pirate_Dagger
syn keyword hItemId Freyja_Crown Carmen_Miranda's_Hat Brazilian_Flag_Hat Mahican Bulb_Hairband Large_Hibiscus
syn keyword hItemId Ayothaya_Hat Diadem Hockey_Mask Observer Umbrella_Hat Fisherman_Hat Poring_Party_Hat
syn keyword hItemId Hellomother_Hat Champion_Wreath Indonesian_Bandana Scarf Misstrance_Crown Little_Angel_Doll
syn keyword hItemId Robo_Eye Masquerade_C Orc_Hero_Helm_C Evil_Wing_Ears_C Dark_Blindfold_C kRO_Drooping_Kitty_C
syn keyword hItemId Corsair_C Loki_Mask Radio_Antenna Angeling_Wanna_Fly Jumping_Poring Guildsman_Recruiter
syn keyword hItemId Party_Recruiter_Hat Bf_Recruiter_Hat Friend_Recruiter_Hat Deprotai_Doll_Hat Claris_Doll_Hat
syn keyword hItemId Sorin_Doll_Hat Tayelin_Doll_Hat Binit_Doll_Hat Debril_Doll_Hat Gf_Recruiter_Hat Ph.D_Hat_
syn keyword hItemId Big_Sis'_Ribbon_ Boy's_Cap_ Pirate_Bandana_ Sunflower_ Poporing_Cap Helm_Of_Sun_ Muslim_Hat_M
syn keyword hItemId Muslim_Hat_F Pumpkin_Hat_H Wings_Of_Victory Pecopeco_Wing_Ears J_Captain_Hat Whikebain_Ears
syn keyword hItemId Gang_Scarf Ninja_Scroll Helm_Of_Abyss Dark_Snake_Lord_Hat Fried_Egg Hat_0f_King Hyegun_Hat
syn keyword hItemId White_Wing Dark_Wing Orchid_Hairband Hat_Of_Judge Drooping_White_Kitty Darkness_Helm
syn keyword hItemId L_Magestic_Goat L_Orc_Hero_Helm Satanic_Chain_P Antique_Pipe Rabbit_Ear_Hat Balloon_Hat
syn keyword hItemId Fish_Head_Hat Santa_Poring_Hat Bell_Ribbon Hunting_Cap Santa_Hat_1 Yoyo_Hat Ayam_ Neko_Mimi_Kafra
syn keyword hItemId Snake_Head Angel_Spirit Santa_Hat_2 Toast_C Louyang_Cap Valentine_Hat Bubblegum_Lower Tiraya_Bonnet
syn keyword hItemId Jasper_Crest Scuba_Mask Bone_Head Mandragora_Cap Fox_Hat Black_Glasses Mischievous_Fairy
syn keyword hItemId Fish_In_Mouth Blue_Ribbon Filir_Hat Academy_Freshman_Hat Academy_Graduating_Cap Old_Bandanna
syn keyword hItemId New_Cowboy_Hat Bread_Bag2 White_Snake_Hat Sweet_Candy Popcorn_Hat Campfire_Hat Poring_Cake_Cap
syn keyword hItemId Beer_Cap Crown_Parrot Soldier_Hat Evolved_Leaf Mask_Of_Ifrit Ifrit's_Ear Linguistic_Book_Cap
syn keyword hItemId Lovecap_China Fanta_Orange_Can Fanta_Grape_Can Karada_Meguri_Tea_Hat Royal_Milk_Tea_Hat Bread_Bag1
syn keyword hItemId Bogy_Cap Sacred_Torch_Coronet Chicken_Hat Brazil_Baseball_Cap Golden_Wreath Coke_Hat
syn keyword hItemId Bride's_Corolla Flower_Of_Fairy Fillet_Green Fillet_Red Fillet_Blue Fillet_White Necktie
syn keyword hItemId Status_Of_Baby_Angel Hair_Brush Candy_Cane_In_The_Mouth Cat_Foot_Hairpin Frog_Cap Solo_Play_Box1
syn keyword hItemId Solo_Play_Box2 Sun_Cap Dragonhelm_Gold Dragonhelm_Silver Dragonhelm_Copper Dog_Cap_
syn keyword hItemId Geographer_Band_ Vacation_Hat_ Spring_Rabbit_Hat Pinwheel_Cap Drooping_Bunny_Chusuk
syn keyword hItemId Adv_Dragon_Skull Adv_Whisper_Mask Spiked_Scarf Rainbow_Scarf Zaha_Doll_Hat Hairband_Of_Reginleif
syn keyword hItemId Hairband_Of_Grandpeco Bro_Flag Classic_Hat Shaman's_Hair_Ornament Bizofnil_Wing_Deco Hermose_Cap
syn keyword hItemId Dark_Knight_Mask Odin_Mask Tiger_Face J_Anniversary_Hat J_Poringcake_Hat J_Twin_Santahat Love_Daddy
syn keyword hItemId Anubis_Helm Hat_Of_Outlaw Boy's_Cap_I Ulle_Cap_I Spinx_Helm_I Power_Of_Thor Dice_Hat
syn keyword hItemId King_Tiger_Doll_Hat Wondering_Wolf_Helm Pizza_Hat Icecream_Hat Pirate's_Pride Necromencer's_Hood
syn keyword hItemId Rabbit_Magic_Hat China_Wedding_Veil Asara_Fairy_Hat Blue_Pajamas_Hat Pink_Pajamas_Hat Shark_Hat
syn keyword hItemId Sting_Hat Shower_Cap Samambaia Aquarius_Diadem Aquarius_Crown Pisces_Diadem Pisces_Crown
syn keyword hItemId Hawk_Eyes01 Hawk_Eyes02 L_Magestic_Goat2 Peacock_Feather Rabbit_Earplug Angry_Mouth_C
syn keyword hItemId Fanta_Zero_Lemon_Hat Sakura_Mist_Hat Sakura_Milk_Tea_Hat First_Leaf_Tea_Hat Lady_Tanee_Doll
syn keyword hItemId Lunatic_Hat King_Frog_Hat Evil's_Bone_Hat Raven_Cap Pirate_Dagger_J Emperor_Wreath_J Side_Cap
syn keyword hItemId Spare_Card Quati_Hat Tucan_Hat Jaguar_Hat Freyja_SCirclet7 Freyja_SCirclet30 Freyja_SCirclet60
syn keyword hItemId Freyja_SCirclet90 Time_Keeper_Hat Aries_Diadem Aries_Crown RJC_Katusa Scarlet_Rose Taurus_Diadem
syn keyword hItemId Taurus_Crown Fest_Lord_Circlet Fest_Bunny_Band Octopus_Hat Leaf_Cat_Hat Fur_Seal_Hat Wild_Rose_Hat
syn keyword hItemId Saci_Hat Piece_Of_White_Cloth_E Bullock_Helm_J Rabbit_Magic_Hat_J Good_Wedding_Veil_J
syn keyword hItemId Crown_Of_Deceit Dragon_Arhat_Mask Tiger_Arhat_Mask Bright_Fury Rabbit_Bonnet Gemini_Diadem
syn keyword hItemId Gemini_Crown Savage_Baby_Hat Bogy_Horn Pencil_in_Mouth Onigiri_Hat Dark_Knight_Mask_ Voyage_Hat
syn keyword hItemId Wanderer's_Sakkat Cancer_Diadem Cancer_Crown Para_Team_Hat Majestic_Evil_Horn Rune_Hairband
syn keyword hItemId Mosquito_Coil Mosquito_Coil_1Use K_Poring_Cake_Cap Sigrun's_Wings K_Rabbit_Bonnet Donut_In_Mouth
syn keyword hItemId 4Leaf_Clover_In_Mouth Bubble_Gum_In_Mouth Br_Twin_Ribbon RTC_Winner_Only RTC_Second_Best
syn keyword hItemId RTC_Third_Best Turtle_Hat Darkness_Helm_J Holy_Marching_Hat_J Imp_Hat Sleepr_Hat Gryphon_Hat
syn keyword hItemId Filir_Wing Shaman_Hat Golden_Crown Skull_Hood Weird_Pumpkin_Hat Drooping_Morocc_Minion
syn keyword hItemId F_Ribbon_Green Triangle_Rune_Cap Majestic_Goat_Repl Jewel_Crown_Repl Prontera_Army_Cap_Repl
syn keyword hItemId Feather_Bonnet_Repl Viking_Helm_Repl Red_Wing_Hat Catain_Bandanna Sea_Cat_Hat Snowman_Hat
syn keyword hItemId Im_Egg_Shell_Hat Rudolf_Santa_Hat Dying_Swan Amistr_Cap Splash_Hat Family_Hat Choco_Donut_In_Mouth
syn keyword hItemId Persika Ancient_Elven_Ear 3D_Glasses Fish_Pin Ribbon_Of_Life 3D_Glasses_ Cheer_Scarf Cheer_Scarf2
syn keyword hItemId Cheer_Scarf3 Cheer_Scarf4 Blush_Of_Groom Ribbon_Of_Bride Upgrade_Elephant_Hat Flower_Love_Hat
syn keyword hItemId Pirate_Eyepatch Victorious_Coronet Poem_Natalia_Hat October_Fest_Cap Diabolus_Helmet Boom_Boom_Hat
syn keyword hItemId Ph.D_Hat_V Santa_Beard Hat_Of_Expert Cowboy_Hat_J Classic_Hat_J Valentine_Pledge Carnival_Hat
syn keyword hItemId Carnival_Circlet Gold_Tulip_Hairpin Love_Chick_Hat Fools_Day_Hat Valkyrie_Helmet Book_File_Hat
syn keyword hItemId Honor_Gold_Ring Loyal_Ring3 Buzzy_Ball_Gum Summer_Knight Passion_FB_Hat Cool_FB_Hat Victory_FB_Hat
syn keyword hItemId Glory_FB_Hat Dark_Ashes Essence_Of_Fire Token_Of_Apostle Soul_Pendant Bapho_Doll New_Year_Rice_Cake
syn keyword hItemId Rice_Cake_Delivery_Box New_Year_Rice_Cake_Soup Wood Large_Magical_Fan Pickaxe Blue_Card_B
syn keyword hItemId Blue_Card_C Blue_Card_J Blue_Card_M Blue_Card_Q Blue_Card_T Blue_Card_V Blue_Card_Z Fur Peaked_Hat
syn keyword hItemId Hard_Skin Mystic_Horn 17Carat_Dia Towel_Of_Memory Marriage_Covenant Crystal_Of_Feardoom Seal_Scroll
syn keyword hItemId Morocc_Tracing_Log Glitering_PaperA Glitering_PaperB Horn_Of_Hilsrion Horn_Of_Tendrilion Weird_Part
syn keyword hItemId Decaying_Stem Invite_To_Meeting Rough_File Neat_Report Piece_Of_Fish Some_Of_Report Strong_Bine
syn keyword hItemId Ordinary_Branch Letter_From_Lugen Letter_From_Otto Supply_Box Clothing_Dye_Coupon
syn keyword hItemId Clothing_Dye_Coupon2 Unidentified_Mineral Marlin Mercenary_Contract Gray_Hollow Ornamental_Hairpin
syn keyword hItemId Yuanbao Blue_Card_6 Blue_Card_Annyver Blue_Card_Sary Blue_Card_E Blue_Card_Ven Blue_Card_Nt
syn keyword hItemId Moon_Admin_Ticket Plantain Moon_Cake15 Moon_Cake16 Moon_Cake17 Moon_Cake18 Moon_Cake19 Moon_Cake20
syn keyword hItemId Rabbit_Skin ABUNDANCE Shaman's_Old_Paper Broken_Sword Wing_Of_Bizofnil Dragon's_Mane Bazett's_Order
syn keyword hItemId Crystalized_Teardrop Portable_Toolbox Rough_Mineral Stone_Fragments Flower_Of_Alfheim Manuk_Coin
syn keyword hItemId Splendide_Coin Spirit_Of_Alfheim Dolly_Capsule Bradium_Fragments Shaggy_Muffler Withered_Flower
syn keyword hItemId Crystal_Of_Soul_01 Crystal_Of_Soul_02 Piece_Of_Darkness Purified_Bradium Dark_Red_Scale
syn keyword hItemId Singing_Crystal_Piece Egg_Of_Draco Traditional_Cookie Flavored_Alcohol Fish_With_Blue_Back
syn keyword hItemId Pumpkin_Pie_ Small_Snow_Flower Grilled_Rice_Cake Damp_Darkness Attendance_Card Report_On_Splendide
syn keyword hItemId Report_On_Manuk Big_Cell Morning_Dew Well_Ripened_Berry Sunset_On_The_Rock Apple_Pudding
syn keyword hItemId Plant_Neutrient Vital_Flower Mystic_Stone Fresh_Plant Vital_Flower_ Flame_Gemstone Bun_
syn keyword hItemId Succu_Pet_Coupon Imp_Pet_Coupon Chung_E_Pet_Coupon Natural_Leather Face_Paint Makeover_Brush
syn keyword hItemId Paint_Brush Surface_Paint Wolf's_Flute Lucky_Box Happy_Box Purification_Stone Guillotine_Antidote
syn keyword hItemId Ticket_Nightmare Ticket_Loli_Ruri Ticket_Goblin_Leader Ticket_Incubus Ticket_Miyabi_Ningyo
syn keyword hItemId Ticket_Whisper Ticket_Wicked_Nymph Ticket_Medusa Ticket_Stoneshooter Ticket_Marionette
syn keyword hItemId Ticket_Leafcat Ticket_Dullahan Ticket_Shinobi Ticket_Golem Ticket_Civil_Servant Heartbroken_Tears
syn keyword hItemId Vulcan_Bullet Magic_Gear_Fuel Liquid_Condensed_Bullet Chocolate_Of_Eternity Plain_Chocolate
syn keyword hItemId Key_Of_The_Mansion Peice_Of_Great_Bradium Glittering_Crystal Special_Exchange_Coupon
syn keyword hItemId Broken_Horn_Pipe Coke_Membership_Card Approval_Report Poring_Ticket Drops_Ticket Poporing_Ticket
syn keyword hItemId Lunatic_Ticket Picky_Ticket Pecopeco_Ticket Savage_Baby_Ticket Spore_Ticket Poison_Spore_Ticket
syn keyword hItemId Chonchon_Ticket Steel_Chonchon_Ticket Petit_Ticket Deviruchi_Ticket Isis_Ticket Smokie_Ticket
syn keyword hItemId Dokebi_Ticket Desert_Wolf_B_Ticket Yoyo_Ticket Sohee_Ticket Rocker_Ticket Hunter_Fly_Ticket
syn keyword hItemId Orc_Warrior_Ticket Bapho_Jr_Ticket Munak_Ticket Bongun_Ticket Goblin_Ticket Hardtack_Ticket
syn keyword hItemId Zherlthsh_Ticket Alice_Ticket Monkey_Wrench Blank_Card Slot_Coupon Magic_Book_FB Magic_Book_CB
syn keyword hItemId Magic_Book_LB Magic_Book_SG Magic_Book_LOV Magic_Book_MS Magic_Book_CM Magic_Book_TV Magic_Book_TS
syn keyword hItemId Magic_Book_JT Magic_Book_WB Magic_Book_HD Magic_Book_ES Magic_Book_ES_ Magic_Book_CL Magic_Book_CR
syn keyword hItemId Magic_Book_DL I_Love_You Thank_You I_Respect_You Glory_Of_Knights Seed_Of_Horny_Plant
syn keyword hItemId Bloodsuck_Plant_Seed Bomb_Mushroom_Spore Explosive_Powder Smoke_Powder Tear_Gas Oil_Bottle
syn keyword hItemId Mandragora_Flowerpot Disin_Delivery_Box Para_Team_Mark Mysterious_Dyestuff Mystic_Leaf_Cat_Ball
syn keyword hItemId Shining_Beads Carnium Bradium HD_Carnium HD_Bradium Guarantee_Weapon_9Up Guarantee_Weapon_8Up
syn keyword hItemId Guarantee_Weapon_7Up Guarantee_Weapon_6Up Guarantee_Armor_9Up Guarantee_Armor_8Up
syn keyword hItemId Guarantee_Armor_7Up Guarantee_Armor_6Up Blue_Card_7 Guarana_Fruit Guarantee_Weapon_11Up
syn keyword hItemId Guarantee_Armor_11Up HD_Oridecon HD_Elunium Midgard_Coin Exchange_Coupon Gun_Powder Black_Powder
syn keyword hItemId Yellow_Powder White_Powder Melange_Pot Savage_Meat Cooking_Skewer Black_Charcoal Wolf_Blood
syn keyword hItemId Cold_Ice Beef_Head_Meat Large_Cookpot Ice_Fragment Ice_Crystal Comodo_Tropic_Fruit Drocera_Tentacle
syn keyword hItemId Petti_Tail Fine_Noodle Cool_Gravy Coconut_Fruit Melon Pineapple Cheat_Key Virtual_Key Mirth_Key
syn keyword hItemId Master_Brush Mins_Picture Mins_Receipt Experiment_Seed Altered_Seed Saint_Cloth_Piece King_Shield
syn keyword hItemId Clear_Reagent Red_Reagent Black_Reagent Apple_Bomb_CB Pinepple_Bomb_CB Coconut_Bomb_CB
syn keyword hItemId Melon_Bomb_CB Banana_Bomb_CB Plant_Genetic_Grow Quality_Potion_Book F_Max_Weight_Up_Scroll
syn keyword hItemId F_Clothing_Dye_Coupon F_Happy_Box F_Mysterious_Dyestuff F_New_Style_Coupon F_Enriched_Elunium
syn keyword hItemId F_Enriched_Oridecon F_Token_Of_Siegfried F_Marriage_Covenant F_Clothing_Dye_Coupon2
syn keyword hItemId RF_Taining_Notice Bottle_To_Throw Pumpkin_Head_Crushed Worn_Cloth_Piece J_7Draw J_Semi_Draw
syn keyword hItemId GM_Handwriting Changed_Hydra_Ball Sapa_Feat_Cert Frozen_Skin_Piece Solid_Bloodstain
syn keyword hItemId Suspicious_Magic_Stone Unidentified_Relic E_Max_Weight_Up_Scroll E_Cloth_Dye_Coupon E_Happy_Box
syn keyword hItemId E_Mysterious_Dyestuff E_New_Style_Coupon E_Enriched_Elunium E_Enriched_Oridecon
syn keyword hItemId E_Token_Of_Siegfried E_Marriage_Covenant E_Cloth_Dye_Coupon2 Small_Bradium Premium_Reset_Stone
syn keyword hItemId Rakehorn_Helm Antler_Helm Twinhorn_Helm Singlehorn_Helm White_Spider_Limb Queen_Wing_Piece
syn keyword hItemId Calender_January Calender_February Calender_March Calender_April Calender_May Calender_June
syn keyword hItemId Calender_July Calender_August Calender_September Calender_October Calender_November
syn keyword hItemId Calender_December Fade_Notation_Green Fade_Notation_Red Fade_Notation_Purple Fade_Notation_Blue
syn keyword hItemId Muscle_Story Love_Ball Seagate_Mark Bless_Word_Paper1 Bless_Word_Paper2 Bless_Word_Paper3
syn keyword hItemId Bless_Word_Paper4 Bless_Word_Paper5 Bless_Word_Paper6 Bless_Word_Paper7 Bless_Word_Paper8
syn keyword hItemId Bless_Word_Paper9 Bless_Word_Paper10 Fortune_Cookie_Fail Free_Cash_Coupon Guidebook_Exchange
syn keyword hItemId Scarlet_Pts Indigo_Pts Yellow_Wish_Pts Lime_Green_Pts Amatsu_Bead_A Amatsu_Bead_Ma Amatsu_Bead_Tsu
syn keyword hItemId Amatsu_Bead_Jam Amatsu_Bead_Bo Amatsu_Bead_Ree Amatsu_Bead_! KVM_Badge Buy_Market_Permit
syn keyword hItemId Winning_Mark Card_Coin Mora_Coin Field_Shovel Urn Clue_Of_Lope Ring_Of_Lope Research_Tool_Bag
syn keyword hItemId Bathtub_R_Sample Teeth_Sample Scale_Sample Puddle_R_Sample Small_Pocket Splendid_Supply_Kit
syn keyword hItemId Bradium_Box Round_Feather Golden_Feather Angel_Magic_Power Auger_Of_Spirit Charm_Fire Charm_Ice
syn keyword hItemId Charm_Wind Charm_Earth Mould_Powder Ogre_Tooth Anolian_Skin Mud_Lump Skull Wing_Of_Red_Bat
syn keyword hItemId Claw_Of_Rat Stiff_Horn Glitter_Shell Tail_Of_Steel_Scorpion Claw_Of_Monkey Tough_Scalelike_Stem
syn keyword hItemId Coral_Reef Old_Portrait Bookclip_In_Memory Spoon_Stub Executioner's_Mitten Young_Twig
syn keyword hItemId Loki's_Whispers Mother's_Nightmare Foolishness_Of_Blind Old_Hilt Blade_Lost_In_Darkness Bloody_Edge
syn keyword hItemId Lucifer's_Lament Key_Of_Clock_Tower Underground_Key Invite_For_Duel Admission_For_Duel
syn keyword hItemId Claw_Of_Desert_Wolf Old_Frying_Pan Piece_Of_Egg_Shell Poison_Spore Red_Socks_With_Holes Matchstick
syn keyword hItemId Fang_Of_Garm Trade_Coupon Yarn Novice_Nametag Megaphone Fine_Grit Leather_Bag_Of_Infinity Fine_Sand
syn keyword hItemId Vigorgra Magic_Paint Cart_Parts Alice's_Apron Talon_Of_Griffin Stone Cotton_Mat Silk_Mat
syn keyword hItemId Old_Magazine Cyfar Brigan Animal_Pooopoo Payroll_Of_Kafra Gallar_Horn Gullraifnir Cargo_Free_Ticket
syn keyword hItemId Warp_Free_Ticket Cart_Free_Ticket Broken_Turtle_Shell Soft_Feather Dragon_Fly_Wing
syn keyword hItemId Sea_Otter_Leather Ice_Piece Stone_Piece Burn_Tree Broken_Armor_Piece Broken_Shell Tatters_Clothes
syn keyword hItemId Rust_Suriken Jewel_Of_Prayer Iron_Glove Iron_Maiden Mystery_Wheel Silver_Fancy Anger_Of_Valkurye
syn keyword hItemId Feather_Of_Angel Foot_Step_Of_Cat Beard_Of_Women Root_Of_Stone Soul_Of_Fish Saliva_Of_Bird
syn keyword hItemId Tendon_Of_Bear Symbol_Of_Sun Breath_Of_Soul Crystal_Of_Snow Indication_Of_Tempest Slilince_Wave
syn keyword hItemId Rough_Billows Air_Stream Wheel Mystery_Piece Broken_Steel_Piece Cold_Magma Burning_Heart Live_Coal
syn keyword hItemId Old_Magic_Circle Sharp_Leaf Peco_Wing_Feather Hideous_Dream Unknown_Liquid_Bottle Fake_Angel_Wing
syn keyword hItemId Fake_Angel_Loop Goat's_Horn Gaoat's_Skin Boroken_Shiled_Piece Shine_Spear_Blade Vroken_Sword
syn keyword hItemId Smooth_Paper Fright_Paper_Blade Broken_Pharaoh_Symbol Tutankhamen's_Mask Harpy's_Feather
syn keyword hItemId Harpy's_Claw Rent_Spell_Book Rent_Scroll Spawns Burning_Horse_Shoe Honey_Jar Hot_Hair Dragon's_Skin
syn keyword hItemId Sand_Lump Scropion's_Nipper Large_Jellopy Alcol_Create_Book FireBottle_Create_Book Acid_Create_Book
syn keyword hItemId Plant_Create_Book Mine_Create_Book Coating_Create_Book Slim_Potion_Create_Book Medicine_Bowl
syn keyword hItemId Fire_Bottle Acid_Bottle MenEater_Plant_Bottle Mini_Bottle Coating_Bottle Seed_Of_Life
syn keyword hItemId Yggdrasilberry_Dew Germination_Breed Life_Force_Pot Normal_Potion_Book Rag_T_Shirts Vacance_Ticket
syn keyword hItemId Jasmin Mother_Letter Yellow_Plate Bamboo_Cut Oil_Paper Glossy_Hair Old_Japaness_Clothes
syn keyword hItemId Poison_Powder Poison_Toad's_Skin Broken_Shuriken Black_Mask Broken_Wine_Vessel Tengu's_Nose
syn keyword hItemId Lord's_Passable_Ticket Black_Bear's_Skin Cloud_Piece Sharp_Feeler Hard_Peach Limpid_Celestial_Robe
syn keyword hItemId Soft_Silk_Cloth Mystery_Iron_Bit Great_Wing Taegeuk_Plate Tuxedo Leopard_Skin Leopard_Talon
syn keyword hItemId BurnBuster_Bag Packing_Ribbon Packing_Paper XMAS_Coupon Part_Of_Star's_Sob Star's_Sob Donation_Card
syn keyword hItemId Introduction_Of_Mr.Han Receipt_01 Cacao Sister_Letter Piano_Keyboard Quiz_Ticket Thin_Stem
syn keyword hItemId Festival_Mask Browny_Root Heart_Of_Tree Solid_Peeling Lamplight Blade_Of_Pinwheel
syn keyword hItemId Germinating_Sprout Soft_Leaf Air_Rifle Shoulder_Protection Tough_Vines Great_Leaf Coupon
syn keyword hItemId Flexible_String Log Beetle_Nipper Solid_Twig Gunpowder Piece_Of_Black_Cloth Black_Kitty_Doll
syn keyword hItemId Old_Manteau Rusty_Cleaver Dullahan's_Helm Dullahan_Armor Rojerta_Piece Hanging_Doll Needle_Pouch
syn keyword hItemId Bat_Cage Broken_Needle Red_Scarf Spool Rotten_Rope Striped_Socks Ectoplasm Tangled_Chain Tree_Knot
syn keyword hItemId Distorted_Portrait Stone_Of_Intelligence Pumpkin_Bucket Pill TCG_Card Gold_Bullion Silver_Bullion
syn keyword hItemId White_Gold_Bullion Gold_Ore Silver_Ore Mithril_Ore Soul_Of_Guild Soul_Of_Courage Soul_Of_Guard
syn keyword hItemId Soul_Of_Partnership Soul_Of_Correspondence Soul_Of_Proceeding Soul_Of_Confidence Soul_Of_Agreement
syn keyword hItemId Soul_Of_Harmony Soul_Of_Cooperate Soul_Of_Unity Soul_Of_Friendship Soul_Of_Peace Soul_Of_Spirit
syn keyword hItemId Soul_Of_Honor Soul_Of_Service Soul_Of_Glory Soul_Of_Victory Herb_Medicine Taeguk_Flag
syn keyword hItemId Digital_Print_Ticket China_Marble01 China_Marble02 China_Marble03 China_Marble04 China_Marble05
syn keyword hItemId China_Marble06 China_Marble07 Fan Cat_Eyed_Stone Dried_Sand Dragon_Horn Dragon_Fang
syn keyword hItemId Tiger_Skin_Panties Little_Blacky_Ghost Bib Milk_Bottle Figure Meat_Dumpling_Doll Golden_Necklace
syn keyword hItemId Ancient_Translator Ancient_Document Picture_Letter Munak_Doll Wellbeing_Letter Vita500_Lid
syn keyword hItemId Quiz_Ticket01 Quiz_Ticket02 Quiz_Ticket03 Quiz_Ticket04 Quiz_Ticket05 Thread_Skein Chilli
syn keyword hItemId Thread_Skein_ Thai_Ring Olivine Phlogopite Agate Muscovite Rose_Quartz Turquoise Citrine Pyroxene
syn keyword hItemId Biotite Leaf_Clothes Bamboo_Basket Gemstone Sword_Accessory KRATHONG Bag_Of_Rice Witch's_Spell_Book
syn keyword hItemId Authority_Of_Nine_World Fragment_Of_Soul Whisper_Of_Soul Witch's_Potion Wing_Of_Crow
syn keyword hItemId Free_Peco_Ticket Free_Flying_Ship_Ticket Jubilee Seal_Of_Witch The_Sign Dark_Crystal_Fragment
syn keyword hItemId Long_Limb Screw Old_Pick Old_Steel_Plate Air_Pollutant Fragment_Of_Crystal Poisonous_Gas
syn keyword hItemId Battered_Kettle Tube Fluorescent_Liquid Headlamp Legendary_Scroll Old_Copper_Key 2anny
syn keyword hItemId Flower_Of_Heaven Slate Piece_Of_Slate_1 Piece_Of_Slate_2 Piece_Of_Slate_3 Piece_Of_Slate_4
syn keyword hItemId Eye_Of_Hellion RO_Transportation_Card RO_Transportation_Card_ Will_Of_Darkness Worn_Out_Pendant
syn keyword hItemId File01 File02 File03 Armlet_Of_Prisoner Pile_Of_Ymir_Heart Lab_Staff_Record Indication_Of_Member01
syn keyword hItemId Indication_Of_Member02 Pass Friend's_Diary Transparent_Plate01 Transparent_Plate02
syn keyword hItemId Transparent_Plate03 Transparent_Plate04 Piece_Of_Crest1 Piece_Of_Crest2 Piece_Of_Crest3
syn keyword hItemId Piece_Of_Crest4 RO_Festival_Ticket Lotto01 Lotto02 Lotto03 Lotto04 Lotto05 Lotto06 Lotto07 Lotto08
syn keyword hItemId Lotto09 Lotto10 Lotto11 Lotto12 Lotto13 Lotto14 Lotto15 Lotto16 Lotto17 Lotto18 Lotto19 Lotto20
syn keyword hItemId Lotto21 Lotto22 Lotto23 Lotto24 Lotto25 Lotto26 Lotto27 Lotto28 Lotto29 Lotto30 Lotto31 Lotto32
syn keyword hItemId Lotto33 Lotto34 Lotto35 Lotto36 Lotto37 Lotto38 Word_Card01 Word_Card02 Word_Card03 Word_Card04
syn keyword hItemId Word_Card05 Word_Card06 Crushed_Can Moon_Cake1 Moon_Cake2 Moon_Cake3 Moon_Cake4 Moon_Cake5
syn keyword hItemId Moon_Cake6 Moon_Cake7 Moon_Cake8 Moon_Cake9 Stone_Of_Summons Letter_Of_Recommend Mission_ScrollA
syn keyword hItemId Mission_ScrollB Embryo_HandBook Skull_ Key_Red Key_Yellow Key_Blue Key_Green Key_Black
syn keyword hItemId Magic_Gem_Red Magic_Gem_Yellow Magic_Gem_Blue Magic_Gem_Green Magic_Gem_Black Several_Books
syn keyword hItemId Leather_Pouch Scroll Elemental_Potion_Book Golden_Bracelet Piece_Of_Memory_Green
syn keyword hItemId Piece_Of_Memory_Purple Piece_Of_Memory_Blue Piece_Of_Memory_Red Red_Feather Blue_Feather
syn keyword hItemId Cursed_Seal Tri_Headed_Dragon_Head Treasure_Box Dragonball_Green Dragonball_Blue Dragonball_Red
syn keyword hItemId Dragonball_Yellow Bloody_Page Piece_Of_Bone_Armor Scale_Of_Red_Dragon Yellow_Spice Sweet_Sauce
syn keyword hItemId Plain_Sauce Hot_Sauce Red_Spice Cooking_Oil Baphomet's_Horn RAMADAN_ Niflheim_Ticket BlueCard_A
syn keyword hItemId BlueCard_E BlueCard_F BlueCard_H BlueCard_L BlueCard_N BlueCard_O BlueCard_P BlueCard_U BlueCard_W
syn keyword hItemId BlueCard_Y Cookbook01 Cookbook02 Cookbook03 Cookbook04 Cookbook05 Cookbook06 Cookbook07 Cookbook08
syn keyword hItemId Cookbook09 Cookbook10 Pot Key_Of_Seal Warrior_Symbol 2nd_Floor_Pass 3rd_Floor_Pass Tavern_Wine
syn keyword hItemId Delivery_Box Villa_Spare_Key Kyll_Hire_Letter Iron_Box Yellow_Key_Card Golden_Key Kiel_Button
syn keyword hItemId Blue_Key_Card Red_Key_Card Steel_Piece Rosimier_Key Family_Portrait Elysia_Portrait
syn keyword hItemId Kyll_Hire_Letter2 Piece_Memo_Of_James Man_Portrait Toy_Motor Toy_Key Black_Key_Card
syn keyword hItemId Sturdy_Iron_Piece Elysia_Ring Fancy_Key_Card Valhalla_Flower Rune_Of_Darkness Burnt_Parts
syn keyword hItemId Pocket_Watch Monster_Ticket Marvelous_Medal Green_Key_Card Gold_Coin_ Women's_Medal Money_Envelope
syn keyword hItemId Chinese_Scroll Flame_Stone Ice_Stone Wind_Stone Shadow_Orb Summer_Feast_Ticket Manuscript_Paper
syn keyword hItemId Life_Book Id_Lottery_Ticket Stolen_Sandals Travel_Brochure_01 Travel_Brochure_02 Travel_Brochure_03
syn keyword hItemId Travel_Brochure_04 Photo_Album_01 Photo_Album_02 Photo_Album_03 Photo_Album_04 Sifted_Sand
syn keyword hItemId Poring_Coin Lotto39 Lotto40 Lotto41 Lotto42 Lotto43 Lotto44 Lotto45 Soccer_Ball Soccer_Shoes
syn keyword hItemId Brazilian_Flag Ticket01 Ticket02 Ticket03 Lotus_Flower Striped_Candle Green_Incense Longing_Heart
syn keyword hItemId Invitation_Letter Invitation_Ticket Key_Of_Flower_Garden Longing_Heart2 Ice_Heart Ice_Scale
syn keyword hItemId Bloody_Rune Rotten_Meat Sticky_Poison Will_Of_Darkness_ Suspicious_Hat White_Mask Hammer_Of_Wind
syn keyword hItemId Temple_Lottery_Ticket Diary_Of_Blue Magic_Necklace Magic_Necklace_ Ice_Particle Red_Jewel_
syn keyword hItemId Blue_Jewel_ Golden_Jewel_ Anti_Spell_Bead Silk_Handkerchief Black_Bead Anniversary_Ticket
syn keyword hItemId Gem_Of_Ruin Evil_Mind Proof_Of_Guard1 Proof_Of_Guard2 Proof_Of_Guard3 Proof_Of_Guard4 IPOD_Ticker
syn keyword hItemId Moon_Cake10 Moon_Cake11 Moon_Cake12 Moon_Cake13 Moon_Cake14 Sonia's_Letter Unique_Sword
syn keyword hItemId Unique_Shield Magic_Stone RO_Party_Ticket Flour Chicken_Egg Coin Evil_Dragon_Head Premium_Ticket
syn keyword hItemId Pumpkin_Mojo Food_Ticket Fox_Symbol Heart_Of_Fox_Queen Small_Rice_Dough Special_Packing_Paper
syn keyword hItemId MVP_Ticket Mini_Boss_Ticket Monster_Ticket_ Monster_Crystal Enriched_Elunium Enriched_Oridecon
syn keyword hItemId Token_Of_Siegfried New_Style_Coupon Name_Change_Coupon Spring_Stanza23 Registration_Ticket
syn keyword hItemId Bubble_Gum_Token Sage_Key Idiot_Key Pink_Gift_Box Clean_Beach_Brush Trash_Debris Perfume_Pouch
syn keyword hItemId Dragon_Spirit Special_Cogwheel Piece_Of_Cogwheel Broken_Thermometer Note_Of_Geologist
syn keyword hItemId Spoiled_Carrot_Juice Spoiled_Banana_Juice Spoiled_Apple_Juice Spoiled_Grape_Juice Black_Gemstone
syn keyword hItemId Update_Ticket Nokia5500 BlueCard_A_ BlueCard_R_ Handmade_Choco_Recipe Strawberry_Choco_Recipe
syn keyword hItemId Choco_Tart_Recipe Cacao_Bean BlueCard_G Gold_Coin_US Treasure_Box_ Debt_Note Diamond_Of_Ruin
syn keyword hItemId Forbidden_Secret_Art Unlucky_Emerald Token_Of_King HP_Doctor_Ticket SP_Doctor_Ticket Rok_Star_Badge
syn keyword hItemId Mission_Certificate1 Mission_Certificate2 Mission_Certificate3 Mission_Certificate4
syn keyword hItemId Mission_Certificate5 Mission_Certificate6 Mission_Certificate7 Mission_Certificate8
syn keyword hItemId Mission_Certificate9 Mission_Certificate10 Mission_Certificate11 Mission_Certificate12 Kaong
syn keyword hItemId Gulaman Leche_Flan Ube_Jam Sago Langka Sweet_Bean Sweet_Banana Macapuno Old_White_Cloth
syn keyword hItemId Clattering_Skull Broken_Farming_Utensil Broken_Crown Research_Note Sealed_Book Mithril Star_Crystal
syn keyword hItemId Geology_Report Yaga_Magic_Book Magic_Gourd_Bottle Yaga_Pestle Sticky_Herb High_Strength_Adhesive
syn keyword hItemId Yaga_Secret_Medicine Bok_Choy Chung_E_Cake Squid Egg_Yolk Sweet_Rice Lotus_Leaf String War_Badge
syn keyword hItemId Chung_E_Ticket Spring_Rabbit_Ticket Max_Weight_Up_Scroll Gold_Box Silver_Box Gold_Key_TW Silver_Key
syn keyword hItemId Heart_Box Gold_Key77 Silver_Key77 Fawner_Coupon1 Fawner_Coupon2 Fawner_Coupon3 Fawner_Coupon4
syn keyword hItemId Fawner_Coupon5 Fawner_Coupon6 Fawner_Coupon7 Fawner_Coupon8 Guyak Golden_Apple Fate_Of_Crow
syn keyword hItemId Mami_Photo_Album Author_Autograph Author_Memo Dark_Debris Dark_Crystal Golden_Apple_
syn keyword hItemId Girl_Fan_Letter Autograph_Book Battle_Manual_TW Brown_Ring Black_Anvil Ore Gold_Hammer Gold_Furnace
syn keyword hItemId Yellow_Cat_Eyed_Stone Gold_Anvil Red_Cat_Eyed_Stone Th_Red_Ring Green_Ring Blue_Ring
syn keyword hItemId Blue_Cat_Eyed_Stone White_Cat_Eyed_Stone RJC_Golden_Necklace Nokia5300 Morroc_Skin Green_Apple
syn keyword hItemId Whole_Barbecue Meat_Veg_Skewer Spirit_Liquor Heroic_Stone Continental_Guard_Paper Mineral_Report
syn keyword hItemId BF_Badge1 BF_Badge2 Goddess_Tear Valkyrie_Token Brynhild_Armor_Piece Hero_Remains Andvari_Ring
syn keyword hItemId Dusk_Glow Dawn_Essence Cold_Moonlight Hazy_Starlight Crystal_Key Valkyrie_Gift Spotted_Paper
syn keyword hItemId Torn_Paper Old_Paper Burnt_Paper Copy_Of_Spotted_Paper Copy_Of_Torn_Paper Copy_Of_Old_Paper
syn keyword hItemId Copy_Of_Burnt_Paper Soul_Crystal Wooden_Block_ Pass_F1 Pass_F2 Pass_F3 Pass_CF Heart
syn keyword hItemId Girl_Bunch_Of_Flower_ Handmade_Kitty_Doll Dragonball_Yellow_ Game_Ticket Peeps Jelly_Bean
syn keyword hItemId Marshmallow GOLD_ID4 Love_Flower Gold_Pouch Certificate SesamePouch Water RicePouch Corn BeanPouch
syn keyword hItemId Grass MVP_Monster_Scroll Monster_Scroll Pirate_Box Gold_Key Red_Ring Lusalka_Hair Golden_Thread
syn keyword hItemId Babayaga_Silver_Spoon Book_Of_Magic Pointed_Branch Pointed_Wooden_Flute Jade_Plate Sacred_Arrow
syn keyword hItemId Bean_Paste Dried_Fruit_Box Bag_Of_Nuts Chicken_Feed Mug Charcoal Sulfur Nitrate TRO_Memory_Book01
syn keyword hItemId TRO_Memory_Book02 TRO_Memory_Book03 VVS_Balmung Spiritualist_Dagger Jenoss_Ring1 Jenoss_Ring2
syn keyword hItemId Jenoss_Ring3 Jenoss_Ring4 Piano_Key Rok_Star_Badge_ Poppy_Wreath Bobbin_Of_Goddess
syn keyword hItemId Louis_Hair_Coupon Stolen_Cookie Stolen_Candy Yulia_Hat Portable_Snowman Test_Certificate
syn keyword hItemId Ancient_Document_TW Copper_Coin_ Silver_Coin_ Magic_Potion Particle_Of_Memory Festival_Ticket
syn keyword hItemId Hero's_Arsenal Essence_Of_Dragon RWC_Ticket KRATHONG_ Brazilian_Flag_ Golden_Coin_
syn keyword hItemId Cowking's_Nose_Ring Poison_Kit Poison_Herb_Nerium Poison_Herb_Rantana Poison_Herb_Makulata
syn keyword hItemId Poison_Herb_Seratum Poison_Herb_Scopolia Poison_Herb_Amoena Light_Granule Elder_Branch
syn keyword hItemId Special_Alloy_Trap Halloween_Ticket Letter_From_Chico Caskinya Box_Of_Seal Almighty_Charm
syn keyword hItemId Valentine_Gold_Ring Valentine_Silver_Ring Box Woven_Wool Ayothaya_Ticket Gold_Tulip
syn keyword hItemId Gift_From_Romiros Gift_From_Juliedge Festival_Ticket_ Lost_Card1 Lost_Card2 Lost_Card3 Lost_Card4
syn keyword hItemId Ancient_Gold_Coin Ancient_Silver_Coin Weapon_Exchange Treasure_Map1 Treasure_Map2 Treasure_Map3
syn keyword hItemId Treasure_Map4 Weird_Parchment1 Weird_Parchment2 Weird_Parchment3 Weird_Parchment4 Unwritten_Letter1
syn keyword hItemId Unwritten_Letter2 Oath_Day_Letter Immortality_Egg Illusion_Piece Cupid_Choco Gf_Magic_Coin
syn keyword hItemId Hunting_Medal_Badge Spring_Stanza1 Spring_Stanza2 Spring_Stanza3 Spring_Stanza4 Spring_Stanza5
syn keyword hItemId Spring_Stanza6 Spring_Stanza7 Spring_Stanza8 Spring_Stanza9 Spring_Stanza10 Spring_Stanza11
syn keyword hItemId Spring_Stanza12 Spring_Stanza13 Spring_Stanza14 Spring_Stanza15 Spring_Stanza16 Spring_Stanza17
syn keyword hItemId Spring_Stanza18 Spring_Stanza19 Spring_Stanza20 Spring_Stanza21 Spring_Stanza22 Poring_Egg
syn keyword hItemId Drops_Egg Poporing_Egg Lunatic_Egg Picky_Egg Chonchon_Egg Steel_Chonchon_Egg Hunter_Fly_Egg
syn keyword hItemId Savage_Bebe_Egg Baby_Desert_Wolf_Egg Rocker_Egg Spore_Egg Poison_Spore_Egg PecoPeco_Egg Smokie_Egg
syn keyword hItemId Yoyo_Egg Orc_Warrior_Egg Munak_Egg Dokkaebi_Egg Sohee_Egg Isis_Egg Green_Petite_Egg Deviruchi_Egg
syn keyword hItemId Bapho_Jr._Egg Bongun_Egg Zherlthsh_Egg Alice_Egg Rice_Cake_Egg Santa_Goblin_Egg Chung_E_Egg
syn keyword hItemId Spring_Rabbit_Egg Knife_Goblin_Egg Flail_Goblin_Egg Hammer_Goblin_Egg Red_Deleter_Egg Diabolic_Egg
syn keyword hItemId Wanderer_Egg New_Year_Doll_Egg Bacsojin_Egg Civil_Servant_Egg Leaf_Cat_Egg Loli_Ruri_Egg
syn keyword hItemId Marionette_Egg Shinobi_Egg Whisper_Egg Goblin_Leader_Egg Wicked_Nymph_Egg Miyabi_Ningyo_Egg
syn keyword hItemId Dullahan_Egg Medusa_Egg Stone_Shooter_Egg Incubus_Egg Golem_Egg Nightmare_Terror_Egg Succubus_Egg
syn keyword hItemId Imp_Egg Skull_Helm Monster_Oxygen_Mask Transparent_Headgear Pacifier Wig Queen's_Hair_Ornament
syn keyword hItemId Silk_Ribbon Punisher Wild_Flower Battered_Pot Stellar_Hairpin Tiny_Egg_Shell Backpack
syn keyword hItemId Rocker_Glasses Green_Lace Golden_Bell Bark_Shorts Monkey_Circlet Red_Muffler Sword_Of_Grave_Keeper
syn keyword hItemId Round_Hair_Ornament Golden_Earing Green_Lucky_Bag Fashionable_Glasses Star_Hairband Wine_On_Sleeve
syn keyword hItemId Spirit_Chain_ Nice_Badge Jade_Trinket Summer_Fan Death_Coil Queen's_Coronet Apro_Hair Ball_Mask
syn keyword hItemId Windup_Spring Hell_Horn Black_Butterfly_Mask Horn_Protector Prontera_Book_01 Adventure_Story01
syn keyword hItemId Great_Chef_Orleans01 Legend_Of_Kafra01 Mercenary_Rebellion Tyrant_Schmidt Blood_Flower01
syn keyword hItemId Blood_Flower02 Barmund Adventure_Story02 Reward_List_Book Barmund_Note Expedition_Report
syn keyword hItemId Expedition_Report_Vol1 Expedition_Report_Vol2 Expedition_Report_Vol3 Expedition_Report_Vol4
syn keyword hItemId Reward_List_Book2 Splendide_Selling_Item Manuk_Selling_Item Japan_Book1 Japan_Book2 Mix_Cook_Book
syn keyword hItemId Increase_Stamina_Study Vital_Drink_CB Swordman_Book_Basic Swordman_Book_Practice Swrodman_Book_Misc
syn keyword hItemId Thief_Book_Basic Thief_Book_Practice Thief_Book_Misc Archer_Book_Basic Archer_Book_Practice
syn keyword hItemId Archer_Book_Misc Acol_Book_Basic Acol_Book_Practice Acol_Book_Misc Mage_Book_Basic
syn keyword hItemId Mage_Book_Practice Mage_Book_Misc Mer_Book_Basic Mer_Book_Practice Mer_Book_Misc TK_Book_Basic
syn keyword hItemId TK_Book_Practice TK_Book_Misc Ninja_Book_Basic Ninja_Book_Practice Ninja_Book_Misc Gun_Book_Basic
syn keyword hItemId Gun_Book_Practice Gun_Book_Misc SN_Book_Basic SN_Book_Practice SN_Book_Misc Basic_Adventure
syn keyword hItemId Spiritualism_Guide Light_Yellow_Pot Light_White_Pot Light_Blue_Pot Siege_White_Potion
syn keyword hItemId Siege_Blue_Potion Iris Fanta_Orange Fanta_Grape Karada_Meguri_Tea Royal_Milk_Tea Coke_Zero
syn keyword hItemId Coke_No_Cal Coca_Cola Protect_Neck_Candy Enriched_Slim_Pot Coconut Asai_Fruit Puri_Potion
syn keyword hItemId N_Blue_Potion Beef_Toast Mora_Mandarin Pingui_Berry_Juice Red_Raffle_Sap Yellow_Raffle_Sap
syn keyword hItemId White_Raffle_Sap Mora_Hip_Tea Rafflecino Baklava Kanafeh MAAMOUL_ Jujube Coffee
syn keyword hItemId Girl_Bunch_Of_Flower Moon_Cookie Mysterious_Blood KETUPAT_F Special_White_Potion Steak Roasted_Beef
syn keyword hItemId Fore_Flank_Sirloin Fanta_Zero_Lemon Sakura_Mist Sakura_Milk_Tea First_Leaf_Tea Cold_Scroll_2_5
syn keyword hItemId Holy_Scroll_1_3 Holy_Scroll_1_5 Holy_Scroll_2_1 Arrow_Container Iron_Arrow_Container
syn keyword hItemId Steel_Arrow_Container Ori_Arrow_Container Fire_Arrow_Container Silver_Arrow_Container
syn keyword hItemId Wind_Arrow_Container Stone_Arrow_Container Crystal_Arrow_Container Shadow_Arrow_Container
syn keyword hItemId Imma_Arrow_Container Rusty_Arrow_Container Speed_Up_Potion Slow_Down_Potion Fire_Cracker Holy_Egg
syn keyword hItemId Water_Of_Darkness Pork_Belly Spareribs Giftbox_China Red_Pouch_Of_Surprise Egg_Boy Egg_Girl
syn keyword hItemId Giggling_Box Box_Of_Thunder Gloomy_Box Box_Of_Grudge Sleepy_Box Box_Of_Storm Box_Of_Sunlight
syn keyword hItemId Painting_Box Lotto_Box01 Lotto_Box02 Lotto_Box03 Lotto_Box04 Lotto_Box05 Stone_Of_Intelligence_
syn keyword hItemId Str_Dish01 Str_Dish02 Str_Dish03 Str_Dish04 Str_Dish05 Int_Dish01 Int_Dish02 Int_Dish03 Int_Dish04
syn keyword hItemId Int_Dish05 Vit_Dish01 Vit_Dish02 Vit_Dish03 Vit_Dish04 Vit_Dish05 Agi_Dish01 Agi_Dish02 Agi_Dish03
syn keyword hItemId Agi_Dish04 Agi_Dish05 Dex_Dish01 Dex_Dish02 Dex_Dish03 Dex_Dish04 Dex_Dish05 Luk_Dish01 Luk_Dish02
syn keyword hItemId Luk_Dish03 Luk_Dish04 Luk_Dish05 Str_Dish06 Str_Dish07 Str_Dish08 Str_Dish09 Str_Dish10 Int_Dish06
syn keyword hItemId Int_Dish07 Int_Dish08 Int_Dish09 Int_Dish10 Vit_Dish06 Vit_Dish07 Vit_Dish08 Vit_Dish09 Vit_Dish10
syn keyword hItemId Agi_Dish06 Agi_Dish07 Agi_Dish08 Agi_Dish09 Agi_Dish10 Dex_Dish06 Dex_Dish07 Dex_Dish08 Dex_Dish09
syn keyword hItemId Dex_Dish10 Luk_Dish06 Luk_Dish07 Luk_Dish08 Luk_Dish09 Luk_Dish10 Citron Meat_Skewer
syn keyword hItemId Bloody_Dead_Branch Random_Quiver Set_Of_Taiming_Item Accessory_Box Wrapped_Mask
syn keyword hItemId Bundle_Of_Magic_Scroll Poring_Box First_Aid_Kit Food_Package Tropical_Sograt Vermilion_The_Beach
syn keyword hItemId Elemental_Fire Elemental_Water Elemental_Earth Elemental_Wind Resist_Fire Resist_Water Resist_Earth
syn keyword hItemId Resist_Wind Sesame_Pastry Honey_Pastry Rainbow_Cake Outdoor_Cooking_Kits Indoor_Cooking_Kits
syn keyword hItemId High_end_Cooking_Kits Imperial_Cooking_Kits Fantastic_Cooking_Kits Cookie_Bag Lucky_Potion Red_Bag
syn keyword hItemId Ice_Cream_ Red_Envelope Green_Ale Women's_Bundle 1st_Stage_Prize 2nd_Stage_Prize 3rd_Stage_Prize
syn keyword hItemId 4th_Stage_Prize 5th_Stage_Prize Magic_Book Red_Can Sphere_Case_Wind Sphere_Case_Darkness
syn keyword hItemId Sphere_Case_Poison Sphere_Case_Water Sphere_Case_Fire Bullet_Case Bullet_Case_Blood
syn keyword hItemId Bullet_Case_Silver Special_Box Bow_Mercenary_Scroll1 Bow_Mercenary_Scroll2 Bow_Mercenary_Scroll3
syn keyword hItemId Bow_Mercenary_Scroll4 Bow_Mercenary_Scroll5 Bow_Mercenary_Scroll6 Bow_Mercenary_Scroll7
syn keyword hItemId Bow_Mercenary_Scroll8 Bow_Mercenary_Scroll9 Bow_Mercenary_Scroll10 SwordMercenary_Scroll1
syn keyword hItemId SwordMercenary_Scroll2 SwordMercenary_Scroll3 SwordMercenary_Scroll4 SwordMercenary_Scroll5
syn keyword hItemId SwordMercenary_Scroll6 SwordMercenary_Scroll7 SwordMercenary_Scroll8 SwordMercenary_Scroll9
syn keyword hItemId SwordMercenary_Scroll10 SpearMercenary_Scroll1 SpearMercenary_Scroll2 SpearMercenary_Scroll3
syn keyword hItemId SpearMercenary_Scroll4 SpearMercenary_Scroll5 SpearMercenary_Scroll6 SpearMercenary_Scroll7
syn keyword hItemId SpearMercenary_Scroll8 SpearMercenary_Scroll9 SpearMercenary_Scroll10 Holy_Arrow_Quiver
syn keyword hItemId Mercenary_Red_Potion Mercenary_Blue_Potion Red_Box Green_Box Magical_Moon_Cake Red_Box_ Moon_Cake
syn keyword hItemId Special_Moon_Cake Pumpkin_Pie Brezel Hometown_Gift Plain_Rice_Cake Hearty_Rice_Cake Salty_Rice_Cake
syn keyword hItemId Lucky_Rice_Cake Rice_Scroll Event_Cake Red_Box_C Str_Dish10_ Agi_Dish10_ Int_Dish10_ Dex_Dish10_
syn keyword hItemId Luk_Dish10_ Vit_Dish10_ Battle_Manual Insurance Bubble_Gum Kafra_Card Giant_Fly_Wing Neuralizer
syn keyword hItemId Convex_Mirror Blessing_10_Scroll Inc_Agi_10_Scroll Aspersio_5_Scroll Assumptio_5_Scroll
syn keyword hItemId Wind_Walk_10_Scroll Adrenaline_Scroll Megaphone_ Sweet_Candy_Striper Examination1 Examination2
syn keyword hItemId Examination3 Examination4 Examination5 Examination6 Gingerbread Kvass Cacao99 Strawberry_Choco
syn keyword hItemId Choco_Tart Choco_Lump New_Year_Rice_Cake_1 New_Year_Rice_Cake_2 Old_Yellow_Box M_Center_Potion
syn keyword hItemId M_Awakening_Potion M_Berserk_Potion Old_Gift_Box Green_Ale_US Magic_Card_Album Halohalo
syn keyword hItemId Masquerade_Ball_Box Payroll_Of_Kafra_ Str_Dish10_M Agi_Dish10_M Int_Dish10_M Dex_Dish10_M
syn keyword hItemId Luk_Dish10_M Vit_Dish10_M PRO_Gift_Box Cold_Medicine Bombring_Box Miracle_Medicine
syn keyword hItemId Cool_Summer_Outfit Secret_Medicine Inspector_Certificate_ Comp_Battle_Manual Comp_Bubble_Gum
syn keyword hItemId Comp_Insurance Sesame_Pastry_ Honey_Pastry_ Rainbow_Cake_ Tasty_Colonel Tasty_Major Mre_A Mre_B
syn keyword hItemId Mre_C Gold_Pill_1 Gold_Pill_2 Mimic_Scroll Disguise_Scroll Alice_Scroll Undead_Element_Scroll
syn keyword hItemId Holy_Element_Scroll Tresure_Box_WoE Internet_Cafe1 Internet_Cafe2 Internet_Cafe3 Internet_Cafe4
syn keyword hItemId Masquerade_Ball_Box2 Love_Angel Squirrel Gogo Mysterious_Can Mysterious_PET_Bottle Unripe_Fruit
syn keyword hItemId Dried_Yggdrasilberry PC_Bang_Coin_Box1 PC_Bang_Coin_Box2 PC_Bang_Coin_Box3 PC_Bang_Coin_Box4
syn keyword hItemId SP_Potion Mega_Resist_Potion Wild_Rose_Scroll Doppelganger_Scroll Ygnizem_Scroll Water_Of_Blessing
syn keyword hItemId Picture_Diary Mini_Heart Newcomer Kid Magic_Castle Bulging_Head Spray_Of_Flowers
syn keyword hItemId Large_Spray_Of_Flowers Thick_Manual50 Protection_Of_Angel Noive_Box Goddess_Bless Angel_Bless
syn keyword hItemId Powder_Snow Little_Heart Strawberry_Cake Pineapple_Juice Spicy_Sandwich Chocolate_Pie N_Fly_Wing
syn keyword hItemId N_Butterfly_Wing N_Magnifier J_Firecracker Charm_Of_Luck Charm_Of_Happiness Recall_MaleGM
syn keyword hItemId Recall_FemaleGM Ginseng Fruit_Juice Ansila Cherish_Box Yummy_Skewered_Dish Baked_Mushroom
syn keyword hItemId Grilled_Sausage Grilled_Corn Cherish_Box_Ori Mysterious_Rice_Powder Special_Alloy_Trap_Box
syn keyword hItemId Manuk's_Opportunity Manuk's_Courage Pinguicula's_fruit_Jam Luciola's_Honey_Jam Unripe_Acorn
syn keyword hItemId Acorn_Jelly Manuk's_Faith Cornus'_Tears Angeling_Potion Shout_Megaphone Dun_Tele_Scroll3
syn keyword hItemId Tiny_Waterbottle Buche_De_Noel Xmas_Gift Louise_Costume_Box Shiny_Wing_Gown Fan_Of_Wind
syn keyword hItemId Very_Soft_Plant Very_Red_Juice Delicious_Shaved_Ice Kuloren Fit_Pipe Staff_Of_Leader Charming_Lotus
syn keyword hItemId Gril_Doll Luxury_Whisky_Bottle Splendid_Mirror Oilpalm_Coconut Gril's_Naivety Magical_Lithography
syn keyword hItemId Hell_Contract Boy's_Naivety Flaming_Ice Acaraje Mysterious_Can2 Mysterious_PET_Bottle2
syn keyword hItemId 2009_Rice_Cake_Soup Pope's_Cookie Desert_Wolf_Babe_Scroll ValkyrieA_Scroll ValkyrieB_Scroll
syn keyword hItemId Vulcan_Bullet_Magazine Rainbow_Ruby_Water Rainbow_Ruby_Fire Rainbow_Ruby_Wind Rainbow_Ruby_Earth
syn keyword hItemId Runstone_Crush Runstone_Storm Runstone_Millennium Lucky_Egg_C RepairA RepairB RepairC Tantanmen
syn keyword hItemId Fools_Day_Box Fools_Day_Box2 PCBang_Gift_Box Castle_Treasure_Box Water_Of_Blessing_
syn keyword hItemId Rune_Kn_Test_Int 29Fruit Lucky_Egg_C2 Acti_Potion Underripe_Yggseed Psychic_ArmorS
syn keyword hItemId PCBang_Coupon_Box Leaf_Cat_Ball Pork_Belly_H Spareribs_H HE_Battle_Manual HE_Bubble_Gum
syn keyword hItemId PCBang_Coupon_Box2 Guarana_Candy Siege_Teleport_Scroll2 LUcky_Egg_C3 Boost500 Full_SwingK Mana_Plus
syn keyword hItemId Stamina_Up_M Digestive_F HP_Increase_Potion_(Small) HP_Increase_Potion_(Medium)
syn keyword hItemId HP_Increase_Potion_(Large) SP_Increase_Potion_(Small) SP_Increase_Potion_(Medium)
syn keyword hItemId SP_Increase_Potion_(Large) Enrich_White_PotionZ Savage_BBQ Wug_Blood_Cocktail Minor_Brisket
syn keyword hItemId Siroma_Icetea Drocera_Herb_Stew Petti_Tail_Noodle Black_Thing Vitata500 Enrich_Celermine_Juice
syn keyword hItemId F_Giant_Fly_Wing F_Battle_Manual F_Insurance F_Bubble_Gum F_Kafra_Card F_Neuralizer
syn keyword hItemId F_Dun_Tele_Scroll1 F_Str_Dish10_ F_Agi_Dish10_ F_Int_Dish10_ F_Dex_Dish10_ F_Luk_Dish10_
syn keyword hItemId F_Vit_Dish10_ F_WOB_Rune F_WOB_Schwaltz F_WOB_Rachel F_WOB_Local F_Greed_Scroll F_Glass_Of_Illusion
syn keyword hItemId F_Abrasive F_Med_Life_Potion F_Small_Life_Potion F_Regeneration_Potion F_B_Mdef_Potion
syn keyword hItemId F_S_Mdef_Potion F_B_Def_Potion F_S_Def_Potion F_Blessing_10_Scroll F_Inc_Agi_10_Scroll
syn keyword hItemId F_Aspersio_5_Scroll F_Wind_Walk_10_Scroll F_Adrenaline_Scroll F_Convex_Mirror RWC_Parti_Box
syn keyword hItemId RWC_Final_Comp_Box Cure_Free PCBang_Coupon_Box3 Gift_Bundle Chance_Box Caracas_Ring_Box
syn keyword hItemId Attend_3Day_Box Attend_7Day_Box Attend_10Day_Box Attend_15Day_Box Attend_20Day_Box Attend_25Day_Box
syn keyword hItemId GoldPC_First_Box PC_4Leaf_Clover_Box Ticket_Gift_Box Ticket_Gift_Box2 Vivid_Notation
syn keyword hItemId Curious_Snowball Crumpled_Paper Lucky_Egg_C4 E_Giant_Fly_Wing E_Battle_Manual E_Insurance
syn keyword hItemId E_Bubble_Gum E_Kafra_Card E_Neuralizer E_Dun_Tele_Scroll1 E_Str_Dish10_ E_Agi_Dish10_ E_Int_Dish10_
syn keyword hItemId E_Dex_Dish10_ E_Luk_Dish10_ E_Vit_Dish10_ E_WOB_Rune E_WOB_Schwaltz E_WOB_Rachel E_WOB_Local
syn keyword hItemId E_Siege_Teleport_Scroll E_Greed_Scroll E_Glass_Of_Illusion E_Abrasive E_Med_Life_Potion
syn keyword hItemId E_Small_Life_Potion E_Regeneration_Potion E_B_Mdef_Potion E_S_Mdef_Potion E_B_Def_Potion
syn keyword hItemId E_S_Def_Potion E_Blessing_10_Scroll E_Inc_Agi_10_Scroll E_Aspersio_5_Scroll E_Assumptio_5_Scroll
syn keyword hItemId E_Wind_Walk_10_Scroll E_Adrenaline_Scroll E_Convex_Mirror White_Slim_Potion_Box Mastela_Fruit_Box
syn keyword hItemId White_Potion_Box Royal_Jelly_Box2 Blue_Herb_Box2 Yggdrasil_Seed_Box NY_Rice_Cake_Soup
syn keyword hItemId Solo_Gift_Basket Couple_Event_Basket Splendid_Box GM_Warp_Box Fortune_Cookie1 Fortune_Cookie2
syn keyword hItemId Fortune_Cookie3 Mystic_Tree_Branch Lucky_Egg_C5 Suspicious_Dish Chalcenodny_Box Buy_Market_Permit2
syn keyword hItemId White_Slim_Pot_Box2 Poison_Bottle_Box2 MVP_Tele_Scroll Quest_Tele_Scroll Brysinggamen_Piece_Box
syn keyword hItemId Asprika_Piece_Box Brynhild_Piece_Box Sleipnir_Piece_Box Mjolnir_Piece_Box Magingiorde_Piece_Box
syn keyword hItemId Tenkaippin_Strong Tenkaippin_Clean Mysterious_Seed Bubble_Gum_Plus BM75 3D_Glasses_Box
syn keyword hItemId Cheer_Scarf_Box Cheer_Scarf2_Box Cheer_Scarf3_Box Cheer_Scarf4_Box Cheer_Scarf6_Box
syn keyword hItemId Cheer_Scarf8_Box Cheer_Scarf10_Box Cheer_Scarf10_Box2 Fruit_Basket Mora_Berry Arrow_Of_Elf_Cntr
syn keyword hItemId Hunting_Arrow_Cntr Lucky_Egg_C6 Rapid_Life_Water Ring_Of_Valkyrie_Box Vending_Search_Scroll
syn keyword hItemId Vending_Search_Scroll2 Uni_Catalog_Bz Old_Blue_Box_F Old_Bleu_Box Holy_Egg_2 Elixir_Of_Life
syn keyword hItemId Noble_Nameplate Lucky_Cookie01 Lucky_Cookie02 Lucky_Cookie03 Guyak_Candy Guyak_Pudding Pretzel
syn keyword hItemId Green_Beer Monster_Extract Easter_Scroll Black_Treasure_Box Indian_Rice_Cake Poison_Paralysis
syn keyword hItemId Poison_Leech Poison_Oblivion Poison_Contamination Poison_Numb Poison_Fever Poison_Laughing
syn keyword hItemId Poison_Fatigue Runstone_Nosiege Runstone_Rhydo Runstone_Verkana Runstone_Isia Runstone_Asir
syn keyword hItemId Runstone_Urj Runstone_Turisus Runstone_Pertz Runstone_Hagalas Runstone_Quality Runstone_Ancient
syn keyword hItemId Runstone_Mystic Runstone_Ordinary Runstone_Rare Snow_Flower Inc_Str_Scroll Inc_Int_Scroll
syn keyword hItemId Valentine_Gift_Box1 Valentine_Gift_Box2 Chocotate_Box Skull_Scroll Destruction_Scroll Royal_Scroll
syn keyword hItemId Immune_Scroll Mystic_Scroll Battle_Scroll Armor_Scroll Prayer_Scroll Soul_Scroll New_Year_Bun
syn keyword hItemId Traditional_Firecrack New_Gift_Envelope Loyal_Ring1_Box Loyal_Ring2_Box Loyal_Ring3_Box
syn keyword hItemId Bubble_Gum_Green Bubble_Gum_Yellow Bubble_Gum_Orange Bubble_Gum_Red Fools_Day_Box_Tw
syn keyword hItemId Summer_Knight_Box Reward_Job_BM25 Passion_FB_Hat_Box Cool_FB_Hat_Box Victory_FB_Hat_Box
syn keyword hItemId Glory_FB_Hat_Box Passion_Hat_Box2 Cool_Hat_Box2 Victory_Hat_Box2 Change_Slot_Card Change_Name_Card
syn keyword hItemId Falcon_Flute Battle_Manual_Box Insurance_Package Bubble_Gum_Box Str_Dish_Box Agi_Dish_Box
syn keyword hItemId Int_Dish_Box Dex_Dish_Box Luk_Dish_Box Vit_Dish_Box Kafra_Card_Box Giant_Fly_Wing_Box
syn keyword hItemId Neuralizer_Box Convex_Mirror_Box Blessing_10_Scroll_Box Inc_Agi_10_Scroll_Box Aspersio_5_Scroll_Box
syn keyword hItemId Assumptio_5_Scroll_Box Wind_Walk_10_Scroll_Box Adrenaline_Scroll_Box Megaphone_Box
syn keyword hItemId Enriched_Elunium_Box Enriched_Oridecon_Box Token_Of_Siegfried_Box Pet_Egg_Scroll_Box1
syn keyword hItemId Pet_Egg_Scroll_Box2 Pet_Egg_Scroll1 Pet_Egg_Scroll2 J_Aspersio_5_Scroll_Box J_Aspersio_5_Scroll
syn keyword hItemId Pet_Egg_Scroll_Box3 Pet_Egg_Scroll_Box4 Pet_Egg_Scroll_Box5 Pet_Egg_Scroll3 Pet_Egg_Scroll4
syn keyword hItemId Pet_Egg_Scroll5 Infiltrator_Box Muramasa_Box Excalibur_Box Combat_Knife_Box Counter_Dagger_Box
syn keyword hItemId Kaiser_Knuckle_Box Pole_Axe_Box Mighty_Staff_Box Right_Epsilon_Box Balistar_Box
syn keyword hItemId Diary_Of_Great_Sage_Box Asura_Box Apple_Of_Archer_Box Bunny_Band_Box Sahkkat_Box Lord_Circlet_Box
syn keyword hItemId Elven_Ears_Box Steel_Flower_Box Critical_Ring_Box Earring_Box Ring_Box Necklace_Box Glove_Box
syn keyword hItemId Brooch_Box Rosary_Box Safety_Ring_Box Vesper_Core01_Box Vesper_Core02_Box Vesper_Core03_Box
syn keyword hItemId Vesper_Core04_Box Emergency_Box1 Emergency_Box2 Emergency_Box3 Emergency_Scroll1 Emergency_Scroll2
syn keyword hItemId Emergency_Scroll3 Teleport_Box1 Teleport_Box2 Teleport_Box3 Teleport_Box4 Teleport_Box5
syn keyword hItemId Teleport_Box6 Teleport_Scroll1 Teleport_Scroll2 Teleport_Scroll3 Teleport_Scroll4 Teleport_Scroll5
syn keyword hItemId Teleport_Scroll6 Pet_Egg_Scroll_Box6 Pet_Egg_Scroll_Box7 Pet_Egg_Scroll_Box8 Pet_Egg_Scroll_Box9
syn keyword hItemId Pet_Egg_Scroll_Box10 Pet_Egg_Scroll_Box11 Pet_Egg_Scroll6 Pet_Egg_Scroll7 Pet_Egg_Scroll8
syn keyword hItemId Pet_Egg_Scroll9 Pet_Egg_Scroll10 Pet_Egg_Scroll11 White_Herb_Box Blue_Herb_Box Elunium_Box
syn keyword hItemId Oridecon_Box Branch_Of_Dead_Tree_Box Jujube_Dagger Dragon_Killer Ginnungagap Coward Coward_
syn keyword hItemId Angelwing_Short_Sword Khukri Jitte Jitte_ Kamaitachi Asura Asura_ Murasame Murasame_ Hakujin
syn keyword hItemId Hakujin_ Poison_Knife_ House_Auger_ Sucsamad_ Ginnungagap_ Warrior_Balmung_ Combat_Knife_C
syn keyword hItemId Counter_Dagger_C Asura_C Sword_Breaker_C Mail_Breaker_C Moonlight_Sword_C Scalpel Tooth_Blade
syn keyword hItemId Prinsence_Knife Dragon_Killer_ Sword_Breaker_ Mail_Breaker_ Assasin_Dagger_ Twilight_Desert
syn keyword hItemId Sandstorm BF_Dagger1 BF_Dagger2 Dagger_Of_Hunter Ivory_Knife N_Cutter N_Main_Gauche Krieger_Dagger1
syn keyword hItemId Fortune_Sword_I House_Auger_I Kamaitachi_I Krieg Weihna Damascus_C Six_Shooter Six_Shooter_
syn keyword hItemId Crimson_Bolt Crimson_Bolt_ The_Garrison The_Garrison_ Gold_Lux Wasteland_Outlaw BF_Pistol1
syn keyword hItemId Wasteland_Outlaw_C Krieger_Pistol1 P_Revolver1 P_Revolver2 Branch The_Cyclone The_Cyclone_ Dusk
syn keyword hItemId Rolling_Stone Black_Rose Gate_Keeper Drifter Butcher Butcher_ Destroyer Destroyer_ Inferno
syn keyword hItemId Long_Barrel Long_Barrel_ Jungle_Carbine Jungle_Carbine_ Gate_KeeperDD Thunder_P Thunder_P_
syn keyword hItemId Lever_Action_Rifle BF_Rifle1 BF_Gatling_Gun1 BF_Shotgun1 BF_Launcher1 Lever_Action_Rifle_C
syn keyword hItemId Krieger_Rifle1 Krieger_Gatling1 Krieger_Shotgun1 Krieger_Launcher1 Bullet Silver_Bullet
syn keyword hItemId Shell_Of_Blood Flare_Sphere Lighting_Sphere Poison_Sphere Blind_Sphere Freezing_Sphere Shuriken
syn keyword hItemId Nimbus_Shuriken Flash_Shuriken Sharp_Leaf_Shuriken Thorn_Needle_Shuriken Kunai_Of_Icicle
syn keyword hItemId Kunai_Of_Black_Soil Kunai_Of_Furious_Wind Kunai_Of_Fierce_Flame Kunai_Of_Deadly_Poison Apple_Bomb
syn keyword hItemId Coconut_Bomb Melon_Bomb Pineapple_Bomb Banana_Bomb Black_Lump Black_Hard_Lump Very_Hard_Lump
syn keyword hItemId Mysterious_Powder Boost500_To_Throw Full_SwingK_To_Throw Mana_Plus_To_Throw Cure_Free_To_Throw
syn keyword hItemId Stamina_Up_M_To_Throw Digestive_F_To_Throw HP_Inc_PotS_To_Throw HP_Inc_PotM_To_Throw
syn keyword hItemId HP_Inc_PotL_To_Throw SP_Inc_PotS_To_Throw SP_Inc_PotM_To_Throw SP_Inc_PotL_To_Throw
syn keyword hItemId En_White_PotZ_To_Throw Vitata500_To_Throw En_Cel_Juice_To_Throw Savage_BBQ_To_Throw
syn keyword hItemId Wug_Cocktail_To_Throw M_Brisket_To_Throw Siroma_Icetea_To_Throw Drocera_Stew_To_Throw
syn keyword hItemId Petti_Noodle_To_Throw Black_Thing_To_Throw Huuma_Bird_Wing Huuma_Giant_Wheel Huuma_Giant_Wheel_
syn keyword hItemId Huuma_Blaze Huuma_Calm_Mind BF_Huuma_Shuriken1 BF_Huuma_Shuriken2 Krieger_Huuma_Shuriken1
syn keyword hItemId Huuma_Blaze_I Huuma_Giant_Wheel_C Cutlas_ Excalibur_C Cutlas_C Solar_Sword_C Platinum_Shotel
syn keyword hItemId Curved_Sword Edger Nagan_C Fire_Brand_C Immaterial_Sword_C BF_Sword1 BF_Sword2 Twin_Edge_B
syn keyword hItemId Twin_Edge_R Elemental_Sword N_Falchion Krieger_Onehand_Sword1 Krieger_Onehand_Sword2
syn keyword hItemId Krieger_Onehand_Sword3 Holy_Saber Honglyun's_Sword Ruber Flamberge_C Insurance60_Package
syn keyword hItemId Assorted_Scroll_Box Drooping_Kitty_Box Magestic_Goat_Box Deviruchi_Cap_Box Executioner_Box
syn keyword hItemId Brood_Axe_Box Tomahawk_Box Bow_Of_Rudra_Box Cutlas_Box Solar_Sword_Box Sword_Breaker_Box
syn keyword hItemId Mail_Breaker_Box Moonlight_Sword_Box Spanner_Box Grape_Box Royal_Jelly_Box Yggdrasilberry_Box
syn keyword hItemId Weapon_Card_Scroll_Box Armor_Card_Scroll_Box Helmet_Card_Scroll_Box Garment_Card_Scroll_Box
syn keyword hItemId Shield_Card_Scroll_Box Shoes_Card_Scroll_Box Accy_Card_Scroll_Box Zeny_Card_Scroll_Box
syn keyword hItemId Pet_Egg_Scroll_Box1_ Pet_Egg_Scroll_Box2_ Pet_Egg_Scroll_Box3_ Pet_Egg_Scroll_Box4_
syn keyword hItemId Pet_Egg_Scroll_Box5_ Light_Red_Pot_Box Light_Orange_Pot_Box Light_Yellow_Pot_Box
syn keyword hItemId Light_White_Pot_Box Light_Center_Pot_Box Light_Awakening_Pot_Box Light_Berserk_Pot_Box
syn keyword hItemId Meteor_10_Scroll_Box Storm_10_Scroll_Box Vermilion_10_Scroll_Box Lex_Aeterna_Scroll_Box
syn keyword hItemId Magnificat_5_Scroll_Box CP_Helm_Scroll_Box CP_Shield_Scroll_Box CP_Armor_Scroll_Box
syn keyword hItemId CP_Weapon_Scroll_Box Repair_Scroll_Box Big_Bun_Box Pill__Box Superb_Fish_Slice_Box
syn keyword hItemId Chewy_Ricecake_Box Oriental_Pastry_Box Dun_Tele_Scroll1_Box Weapon_Card_Scroll_Box2
syn keyword hItemId Weapon_Card_Scroll_Box3 Armor_Card_Scroll_Box2 Accy_Card_Scroll_Box2 Weapon_Card_Scroll
syn keyword hItemId Armor_Card_Scroll Helmet_Card_Scroll Hood_Card_Scroll Hood_Card_Scroll2 Shoes_Card_Scroll
syn keyword hItemId Accy_Card_Scroll Weapon_Card_Scroll2 Weapon_Card_Scroll3 Armor_Card_Scroll2 Accy_Card_Scroll2
syn keyword hItemId PVP_Tele_Scroll_Box Giant_Fly_Wing_Box50 Giant_Fly_Wing_Box100 Dex_Dish_Box30 Dex_Dish_Box50
syn keyword hItemId Luk_Dish_Box30 Luk_Dish_Box50 Inc_Agi_10_Box30 Inc_Agi_10_Box50 Vit_Dish_Box30 Vit_Dish_Box50
syn keyword hItemId Insurance_Package30 Insurance_Package50 Convex_Mirror_Box5 Convex_Mirror_Box30 Blessing10_Box30
syn keyword hItemId Blessing10_Box50 Adrenaline10_Box30 Adrenaline10_Box50 Assumptio_5_Box30 Assumptio_5_Box50
syn keyword hItemId Aspersio_5_Box30 Aspersio_5_Box50 Agi_Dish_Box30 Agi_Dish_Box50 Wind_Walk10_Box30 Wind_Walk10_Box50
syn keyword hItemId Int_Dish_Box30 Int_Dish_Box50 Battle_Manual_Box1 Battle_Manual_Box5 Siegfried_Box5 Siegfried_Box20
syn keyword hItemId Kafra_Card_Box30 Kafra_Card_Box50 Str_Dish_Box30 Str_Dish_Box50 Bubble_Gum_Box1 Bubble_Gum_Box5
syn keyword hItemId Megaphone_Box1 Megaphone_Box5 Enriched_Elunium_Box5 Enriched_Oridecon_Box5 Handcuff_Box
syn keyword hItemId Super_Pet_Egg_Box1 Super_Pet_Egg_Box2 Super_Pet_Egg_Box3 Super_Pet_Egg_Box4 Super_Pet_Egg1
syn keyword hItemId Super_Pet_Egg2 Super_Pet_Egg3 Super_Pet_Egg4 Greed_Box30 Greed_Box50 Greed_Box100
syn keyword hItemId Flee_30_Scroll_Box Accuracy_30_Scroll_Box Super_Card_Pet_Egg_Box1 Super_Card_Pet_Egg_Box2
syn keyword hItemId Super_Card_Pet_Egg_Box3 Super_Card_Pet_Egg_Box4 Super_Card_Pet_Egg1 Super_Card_Pet_Egg2
syn keyword hItemId Super_Card_Pet_Egg3 Super_Card_Pet_Egg4 Vigorgra_Package1 Vigorgra_Package2 Vigorgra_Package3
syn keyword hItemId Vigorgra_Package4 Vigorgra_Package5 Vigorgra_Package6 Vigorgra_Package7 Vigorgra_Package8
syn keyword hItemId Vigorgra_Package9 Vigorgra_Package10 Vigorgra_Package11 Vigorgra_Package12 Infiltrator_Box1
syn keyword hItemId Muramasa_Box1 Excalibur_Box1 Combat_Knife_Box1 Counter_Dagger_Box1 Kaiser_Knuckle_Box1
syn keyword hItemId Pole_Axe_Box1 Mighty_Staff_Box1 Right_Epsilon_Box1 Balistar_Box1 Diary_Of_Sage_Box1 Asura_Box1
syn keyword hItemId Apple_Of_Archer_Box1 Bunny_Band_Box1 Sahkkat_Box1 Lord_Circlet_Box1 Elven_Ears_Box1
syn keyword hItemId Steel_Flower_Box1 Critical_Ring_Box1 Earring_Box1 Ring_Box1 Necklace_Box1 Glove_Box1 Brooch_Box1
syn keyword hItemId Rosary_Box1 Safety_Ring_Box1 Vesper_Core01_Box1 Vesper_Core02_Box1 Vesper_Core03_Box1
syn keyword hItemId Vesper_Core04_Box1 Drooping_Kitty_Box1 Magestic_Goat_Box1 Deviruchi_Cap_Box1 Executioner_Box1
syn keyword hItemId Brood_Axe_Box1 Tomahawk_Box1 Bow_Of_Rudra_Box1 Cutlas_Box1 Solar_Sword_Box1 Sword_Breaker_Box1
syn keyword hItemId Mail_Breaker_Box1 Moonlight_Sword_Box1 Spanner_Box1 Bok_Choy_Box Chung_E_Cake_Box
syn keyword hItemId Freyja_Overcoat_Box Freyja_Boots_Box Freyja_Cape_Box Freyja_Crown_Box Battle_Manual25_Box
syn keyword hItemId Battle_Manual100_Box J_Blessing10_Box J_Inc_Agi10_Box J_Wind_Walk10_Box J_Adrenaline10_Box
syn keyword hItemId Pet_Egg_Scroll12 Pet_Egg_Scroll13 Pet_Egg_Scroll14 Super_Pet_Egg5 Super_Pet_Egg6 Super_Pet_Egg7
syn keyword hItemId Super_Pet_Egg8 Pet_Egg_Scroll_E BRO_Package_1 Max_Weight_Up_Box Small_Life_Potion_Box
syn keyword hItemId Small_Life_Potion_Box30 Small_Life_Potion_Box50 Med_Life_Potion_Box Med_Life_Potion_Box30
syn keyword hItemId Med_Life_Potion_Box50 Abrasive_Box5 Abrasive_Box10 Regeneration_Box5 Regeneration_Box10
syn keyword hItemId Dun_Tele_Scroll_Box10 Pecopeco_Hairband_Box Red_Glasses_Box Whisper_Mask_Box Ramen_Hat_Box
syn keyword hItemId Gold_Box_ Silver_Box_ Gold_Key1_Box Gold_Key5_Box Silver_Key1_Box Silver_Key5_Box
syn keyword hItemId Pecopeco_Hairband_Box1 Red_Glasses_Box1 Whisper_Mask_Box1 Ramen_Hat_Box1 Glass_Of_Illusion_Box5
syn keyword hItemId Glass_Of_Illusion_Box10 Shadow_Armor_S_Box5 Shadow_Armor_S_Box10 Shadow_Armor_S_Box30
syn keyword hItemId Holy_Armor_S_Box5 Holy_Armor_S_Box10 Holy_Armor_S_Box30 S_Def_Potion_Box10 S_Def_Potion_Box30
syn keyword hItemId S_Def_Potion_Box50 B_Def_Potion_Box10 B_Def_Potion_Box30 B_Def_Potion_Box50 S_Mdef_Potion_Box10
syn keyword hItemId S_Mdef_Potion_Box30 S_Mdef_Potion_Box50 B_Mdef_Potion_Box10 B_Mdef_Potion_Box30 B_Mdef_Potion_Box50
syn keyword hItemId Battle_Manual_X3_Box In_Blue_Herb_Box Honey_Box Empty_Bottle_Box In_Royal_Jelly_Box
syn keyword hItemId 5_Anniversary_Coin_Box Battle_Manual_Box_TW Certificate_TW_Box Nagan_Box Skewer_Box
syn keyword hItemId Survival_Rod_Box Quadrille_Box Great_Axe_Box Bloody_Roar_Box Hardback_Box Fire_Brand_Box
syn keyword hItemId Immaterial_Sword_Box Unholy_Touch_Box Cloak_Of_Survival_Box Masquerade_Box Orc_Hero_Helm_Box
syn keyword hItemId Evil_Wing_Ears_Box Dark_Blindfold_Box kRO_Drooping_Kitty_Box Corsair_Box Bloody_Iron_Ball_Box
syn keyword hItemId Spiritual_Ring_Box Nagan_Box1 Skewer_Box1 Survival_Rod_Box1 Quadrille_Box1 Great_Axe_Box1
syn keyword hItemId Bloody_Roar_Box1 Hardback_Box1 Fire_Brand_Box1 Immaterial_Sword_Box1 Unholy_Touch_Box1
syn keyword hItemId Cloak_Of_Survival_Box1 Masquerade_Box1 Orc_Hero_Helm_Box1 Evil_Wing_Ears_Box1 Dark_Blindfold_Box1
syn keyword hItemId kRO_Drooping_Kitty_Box1 Corsair_Box1 Bloody_Iron_Ball_Box1 Spiritual_Ring_Box1
syn keyword hItemId Fire_Cracker_Love_Box Fire_Cracker_Wday_Box Fire_Cracker_Vday_Box Fire_Cracker_Bday_Box
syn keyword hItemId Fire_Cracker_Xmas_Box Blue_Gemstone_Box Blue_Potion_Box Food_Box_Lv1 Food_Box_Lv2 Food_Box_Lv3
syn keyword hItemId Indonesia_Box Knife_Goblin_Box Flail_Goblin_Box Hammer_Goblin_Box Red_Deleter_Box Diabolic_Box
syn keyword hItemId Wanderer_Box Green_Apple_Box Whole_Barbecue_Box Meat_Veg_Skewer_Box Spirit_Liquor_Box Green_Box_
syn keyword hItemId Power_Box1 Power_Box2 Resist_Box1 Resist_Box2 Stat_Boost1 Stat_Boost2 Stat_Boost3 Stat_Boost4
syn keyword hItemId Dun_Tele_Scroll2_Box5 Dun_Tele_Scroll2_Box10 Mbl_Str_Dish_Box Mbl_Agi_Dish_Box Mbl_Int_Dish_Box
syn keyword hItemId Mbl_Dex_Dish_Box Mbl_Luk_Dish_Box Mbl_Vit_Dish_Box Mbl_Kafra_Card_Box Mbl_Battle_Manual_Box
syn keyword hItemId Heroic_Stone_Box Mysterious_Travel_Sack1 Mysterious_Travel_Sack2 Mysterious_Travel_Sack3
syn keyword hItemId Mysterious_Travel_Sack4 WOB_Box_Rune5 WOB_Box_Rune10 WOB_Box_Schawaltz5 WOB_Box_Schawaltz10
syn keyword hItemId WOB_Box_Rachel5 WOB_Box_Rachel10 WOB_Box_Local5 WOB_Box_Local10 Spark_Candy_Box5 Spark_Candy_Box10
syn keyword hItemId Directive_A_Envelope Directive_B_Envelope Mini_Battle_Manual_Box Trial_Box Repair_Scroll_Box10
syn keyword hItemId Flying_Angel_Box Neko_Mimi_Box MFH_Box Chick_Hat_Box New_Style_Box Magician_Card_Box
syn keyword hItemId Acolyte_Card_Box Archer_Card_Box Swordman_Card_Box Thief_Card_Box Merchant_Card_Box
syn keyword hItemId Clock_Tower_Card_Box Geffenia_Card_Box Owl_Card_Box Ghost_Card_Box Nightmare_Card_Box
syn keyword hItemId Curse_Card_Box Sleep_Card_Box Freeze_Card_Box Stun_Card_Box Silence_Card_Box Blind_Card_Box
syn keyword hItemId Chaos_Card_Box Elunium_Box_ Oridecon_Box_ Fire_Converter_Box Water_Converter_Box Wind_Converter_Box
syn keyword hItemId Earth_Converter_Box Starter_Pack Mimic_Scroll_Box5 Disguise_Croll_Box5 Alice_Scroll_Box5
syn keyword hItemId Mimic_Scroll_Box10 Disguise_Croll_Box10 Alice_Scroll_Box10 Fish_Head_Hat_Box Santa_Poring_Hat_Box
syn keyword hItemId Bell_Ribbon_Box Hard_Core_Set_Box Kitty_Set_Box Soft_Core_Set_Box Deviruchi_Set_Box MVP_Hunt_Box
syn keyword hItemId Cook_Box Xmas_Pet_Scroll Party_Blessing_Box Party_Inc_Agi_Box Party_Assumptio_Box Love_Angel_Box
syn keyword hItemId Squirrel_Box Gogo_Box Crusader_Card_Box Alchemist_Card_Box Rogue_Card_Box Bard_Dancer_Card_Box
syn keyword hItemId Sage_Card_Box Monk_Card_Box Sylph_Box Undine_Box Salamander_Box Soul_Box Noum_Bpx Robo_Eye_Box
syn keyword hItemId Twin_Ribbon_Box Siege_Tele_Scroll_Box Valentine_Scroll_TW Love_Angel_Box_1m Squirrel_Box_1m
syn keyword hItemId Gogo_Box_1m Br_SwordPackage Br_MagePackage Br_AcolPackage Br_ArcherPackage Br_MerPackage
syn keyword hItemId Br_ThiefPackage Wasteland_Outlaw_Box Lever_Action_Rifle_Box All_In_One_Ring_Box Spiritual_Tunic_Box
syn keyword hItemId Recuperative_Armor_Box Shelter_Resistance_Box Sylphid_Manteau_Box Refresh_Shoes_Box Toast_Box
syn keyword hItemId Name_Change_Coupon_Box Mojji_Box Deprotai_Doll_Hat_Box Claris_Doll_Hat_Box Sorin_Doll_Hat_Box
syn keyword hItemId Tayelin_Doll_Hat_Box Binit_Doll_Hat_Box Debril_Doll_Hat_Box Iron_10_Box Steel_10_Box Coal_10_Box
syn keyword hItemId Poison_Bottle_30_Box TW_Scroll01 Picture_Diary_Box Mini_Heart_Box Newcomer_Box Kid_Box
syn keyword hItemId Magic_Castle_Box Bulging_Head_Box Picture_Diary_Box_1m Mini_Heart_Box_1m Newcomer_Box_1m Kid_Box_1m
syn keyword hItemId Magic_Castle_Box_1m Bulging_Head_Box_1m Ori_Stone_5_Box Ori_Stone_50_Box Acidbomb_10_Box
syn keyword hItemId Job_Manual50_Box Tiger_Mask_Box Cat_Hat_Box Alice_Doll_Box Speed_Up_Potion_Box5
syn keyword hItemId Speed_Up_Potion_Box10 Big_Bun_Box100 Big_Bun_Box500 Giant_Fly_Wing_Box500 Pill__Box100 Pill__Box500
syn keyword hItemId Basic_Siege_Supply_Box Adv_Siege_Supply_Box Elite_Siege_Supply_Box Poison_Bottle_10_Box
syn keyword hItemId Poison_Bottle_5_Box F_Drooping_W_Kitty_Box F_Rabbit_Ear_Hat_Box F_L_Orc_Hero_Helm_Box
syn keyword hItemId F_Love_Angel_Box F_Squirrel_Box F_Gogo_Box F_Love_Angel_Box_1m F_Squirrel_Box_1m F_Gogo_Box_1m
syn keyword hItemId F_Wasteland_Outlaw_Box F_Lever_Action_Rifle_Box F_All_In_One_Ring_Box F_Spritual_Tunic_Box
syn keyword hItemId F_Recuperative_Box F_Shelter_Resist_Box F_Sylphid_Manteau_Box F_Refresh_Shoes_Box F_Toast_Box
syn keyword hItemId F_Robo_Eye_Box F_Twin_Ribbon_Box F_Fish_Head_Hat_Box F_Santa_Poring_Hat_Box F_Bell_Ribbon_Box
syn keyword hItemId F_Mimic_Scroll_Box5 F_Disguise_Scroll_Box5 F_Alice_Scroll_Box5 F_Mimic_Scroll_Box10
syn keyword hItemId F_Disguise_Scroll_Box10 F_Alice_Scroll_Box10 F_New_Style_Coupon_Box F_Repair_Scroll_Box
syn keyword hItemId F_Repair_Scroll_Box10 F_WOB_Rune_Box5 F_WOB_Rune_Box10 F_WOB_Schwaltz_Box5 F_WOB_Schwaltz_Box10
syn keyword hItemId F_WOB_Rachel_Box5 F_WOB_Rachel_Box10 F_WOB_Local_Box5 F_WOB_Local_Box10 F_Spark_Candy_Box5
syn keyword hItemId F_Spark_Candy_Box10 F_Dun_Tel_Scroll2_Box5 F_Dun_Tel_Scroll2_Box10 F_Little_Angel_Doll_Box
syn keyword hItemId F_Triple_Poring_Hat_Box F_Nagan_Box F_Skewer_Box F_Survival_Rod_Box F_Quadrille_Box F_Great_Axe_Box
syn keyword hItemId F_Bloody_Roar_Box F_Hardback_Box F_Fire_Brand_Box F_Immaterial_Sword_Box F_Unholy_Touch_Box
syn keyword hItemId F_Clack_Of_Servival_Box F_Masquerade_Box F_Orc_Hero_Helm_Box F_Ear_Of_Devil_Wing_Box
syn keyword hItemId F_Dark_Blindfold_Box F_K_Drooping_Kitty_Box F_Corsair_Box F_Bloody_Iron_Ball_Box
syn keyword hItemId F_Spiritual_Ring_Box F_G_O_I_Box5 F_G_O_I_Box10 F_Shadow_Armor_S_Box5 F_Shadow_Armor_S_Box10
syn keyword hItemId F_Shadow_Armor_S_Box30 F_Holy_Armor_S_Box5 F_Holy_Armor_S_Box10 F_Holy_Armor_S_Box30
syn keyword hItemId FS_Def_Potion_Box10 FS_Def_Potion_Box30 FS_Def_Potion_Box50 FB_Def_Potion_Box10 FB_Def_Potion_Box30
syn keyword hItemId FB_Def_Potion_Box50 FS_Mdef_Potion_Box10 FS_Mdef_Potion_Box30 FS_Mdef_Potion_Box50
syn keyword hItemId FB_Mdef_Potion_Box10 FB_Mdef_Potion_Box30 FB_Mdef_Potion_Box50 F_Flying_Angel_Box F_Cat_Hat_Box
syn keyword hItemId F_M_F_H_Box F_Chick_Hat_Box F_Pecopeco_Hairband_Box F_Red_Glasses_Box F_Whisper_Mask_Box
syn keyword hItemId F_Ramen_Hat_Box F_Dun_Tele_Scroll1_Box F_Max_Weight_Up_Box F_S_Life_Potion_Box
syn keyword hItemId F_S_Life_Potion_Box30 F_S_Life_Potion_Box50 F_M_Life_Potion_Box F_M_Life_Potion_Box30
syn keyword hItemId F_M_Life_Potion_Box50 F_Abrasive_Box5 F_Abrasive_Box10 F_Regeneration_Box5 F_Regeneration_Box10
syn keyword hItemId F_Dun_Tele_Scroll_Box10 F_Infiltrator_Box F_Muramasa_Box F_Excalibur_Box F_Combat_Knife_Box
syn keyword hItemId F_Counter_Dagger_Box F_Kaiser_Knuckle_Box F_Mighty_Staff_Box F_Right_Epsilon_Box F_Balistar_Box
syn keyword hItemId F_Diary_Of_Great_Sage F_Asura_Box F_Apple_Of_Archer_Box F_Bunny_Band_Box F_Sahkkat_Box
syn keyword hItemId F_Lord_Circlet_Box F_Elven_Ears_Box F_Steel_Flower_Box F_Critical_Ring_Box F_Earring_Box F_Ring_Box
syn keyword hItemId F_Necklace_Box F_Glove_Box F_Brooch_Box F_Rosary_Box F_Safety_Ring_Box F_Vesper_Core_Box01
syn keyword hItemId F_Vesper_Core_Box02 F_Vesper_Core_Box03 F_Vesper_Core_Box04 F_Vigorgra_Package1 F_Vigorgra_Package2
syn keyword hItemId F_Vigorgra_Package3 F_Vigorgra_Package4 F_Vigorgra_Package5 F_Vigorgra_Package6 F_Vigorgra_Package7
syn keyword hItemId F_Vigorgra_Package8 F_Vigorgra_Package9 F_Vigorgra_Package10 F_Vigorgra_Package11
syn keyword hItemId F_Vigorgra_Package12 F_Battle_Manual_Box F_Insurance_Package F_Bubble_Gum_Box F_Str_Dish_Box
syn keyword hItemId F_Agi_Dish_Box F_Int_Dish_Box F_Dex_Dish_Box F_Luk_Dish_Box F_Vit_Dish_Box F_Kafra_Card_Box
syn keyword hItemId F_Giant_Fly_Wing_Box F_Neuralizer_Box F_Convex_Mirror_Box F_Blessing_10_Scroll_Box
syn keyword hItemId F_Inc_Agi_10_Scroll_Box F_Aspersio_5_Scroll_Box F_Assumptio_5_Scroll_Box F_Wind_Walk_10_Scroll_Box
syn keyword hItemId F_Adrenaline_Scroll_Box F_Megaphone_Box F_Enriched_Elunium_Box F_Enriched_Oridecon_Box
syn keyword hItemId F_Token_Of_Siegfried_Box F_Giant_Fly_Wing_Box50 F_Giant_Fly_Wing_Box100 F_Dex_Dish_Box30
syn keyword hItemId F_Dex_Dish_Box50 F_Luk_Dish_Box30 F_Luk_Dish_Box50 F_Inc_Agi_10_Box30 F_Inc_Agi_10_Box50
syn keyword hItemId F_Vit_Dish_Box30 F_Vit_Dish_Box50 F_Insurance_Package30 F_Insurance_Package50 F_Convex_Mirror_Box5
syn keyword hItemId F_Convex_Mirror_Box30 F_Blessing10_Box30 F_Blessing10_Box50 F_Adrenaline10_Box30
syn keyword hItemId F_Adrenaline10_Box50 F_Assumptio_5_Box30 F_Assumptio_5_Box50 F_Aspersio_5_Box30 F_Aspersio_5_Box50
syn keyword hItemId F_Agi_Dish_Box30 F_Agi_Dish_Box50 F_Wind_Walk10_Box30 F_Wind_Walk10_Box50 F_Int_Dish_Box30
syn keyword hItemId F_Int_Dish_Box50 F_Battle_Manual_Box1 F_Battle_Manual_Box5 F_Siegfried_Box5 F_Siegfried_Box20
syn keyword hItemId F_Kafra_Card_Box30 F_Kafra_Card_Box50 F_Str_Dish_Box30 F_Str_Dish_Box50 F_Bubble_Gum_Box1
syn keyword hItemId F_Bubble_Gum_Box5 F_Megaphone_Box1 F_Megaphone_Box5 F_Enriched_Elunium_Box5 FEnriched_Oridecon_Box5
syn keyword hItemId MP_Scroll_Box MP_Scroll_Box30 MP_Scroll_Box50 Quagmire_Scroll_Box Quagmire_Scroll_Box30
syn keyword hItemId Quagmire_Scroll_Box50 Healing_Staff_Box Yggdrasilberry_Box_ Dead_Tree_Branch_Box1
syn keyword hItemId Dead_Tree_Branch_Box2 Field_Manual_Box_2 Steamed_Tongue_Box_20 Steamed_Desert_Scorpions_Box_20
syn keyword hItemId Stew_Of_Immortality_Box_20 Dragon_Breath_Cocktail_Box_20 Hwergelmir's_Tonic_Box_20
syn keyword hItemId Nine_Tail_Dish_Box_20 Beholder_Ring_Box Hallow_Ring_Box Clamorous_Ring_Box Chemical_Ring_Box
syn keyword hItemId Insecticide_Ring_Box Fisher_Ring_Box Decussate_Ring_Box Bloody_Ring_Box Satanic_Ring_Box
syn keyword hItemId Dragoon_Ring_Box Beholder_Ring_Box2 Hallow_Ring_Box2 Clamorous_Ring_Box2 Chemical_Ring_Box2
syn keyword hItemId Insecticide_Ring_Box2 Fisher_Ring_Box2 Decussate_Ring_Box2 Bloody_Ring_Box2 Satanic_Ring_Box2
syn keyword hItemId Dragoon_Ring_Box2 Diary_Magic_Powder_Box Mini_Heart_Magic_Powder_Box Freshman_Magic_Powder_Box
syn keyword hItemId Kid_Magic_Powder_Box Magic_Magic_Powder_Box JJangu_Magic_Powder_Box Diary_Magic_Powder_Box4
syn keyword hItemId Mini_Heart_Magic_Powder_Box4 Freshman_Magic_Powder_Box4 Kid_Magic_Powder_Box4
syn keyword hItemId Magic_Magic_Powder_Box4 JJangu_Magic_Powder_Box4 Amplification_10_Scroll_Box2
syn keyword hItemId Amplification_30_Scroll_Box2 Amplification_50_Scroll_Box2 Quagmire_10_Scroll_Box2
syn keyword hItemId Quagmire_30_Scroll_Box2 Quagmire_50_Scroll_Box2 Healing_Staff_Box2 Emperium_Box
syn keyword hItemId Marriage_Covenant_Box Baricade_Repair_Kit Guardian_Stone_Repair_Kit Cloth_Dye_Coupon_Box
syn keyword hItemId Cloth_Dye_Coupon2_Box Cloth_Dye_Coupon3_Box Cloth_Dye_Coupon4_Box Angel_Scroll Devil_Scroll
syn keyword hItemId Mask_Of_Ifrit_Box Ifrit's_Ear_Box Scuba_Mask_Box PhreeoniS_Box GhostringS_Box July7_Scroll
syn keyword hItemId Bacsojin_Scroll Spiked_Scarf_Box Rainbow_Scarf_Box Animal_Scroll Mental_Potion20_Box
syn keyword hItemId Mental_Potion50_Box Tyr's_Blessing20_Box Tyr's_Blessing50_Box Heart_Scroll Holy_Celestial_Axe_Box
syn keyword hItemId Angeling_Pot_Box Shout_Megaphone_Box Anubis_Helm_Box Almighty_Charm_Box New_Year_Scroll
syn keyword hItemId Dice_Hat_Box King_Tiger_Doll_Hat_Box Pirate's_Pride_Box Necromencer's_Hood_Box Rabbit_Magic_Hat_Box
syn keyword hItemId China_Wedding_Veil_Box Asara_Fairy_Hat_Box Valentine_Pledge_Box Ox_Tail_Scroll Insurance60
syn keyword hItemId Zeny_Scroll Light_Center_Pot Light_Awakening_Pot Light_Berserk_Pot Meteor_10_Scroll Storm_10_Scroll
syn keyword hItemId Vermilion_10_Scroll Lex_Aeterna_Scroll Magnificat_5_Scroll CP_Helm_Scroll CP_Shield_Scroll
syn keyword hItemId CP_Armor_Scroll CP_Weapon_Scroll Repair_Scroll Big_Bun Pill_ Superb_Fish_Slice Chewy_Ricecake
syn keyword hItemId Oriental_Pastry Dun_Tele_Scroll1 PVP_Tele_Scroll Greed_Scroll Flee_30_Scroll Accuracy_30_Scroll
syn keyword hItemId Battle_Manual25 Battle_Manual100 Small_Life_Potion Med_Life_Potion Abrasive Regeneration_Potion
syn keyword hItemId Glass_Of_Illusion Shadow_Armor_S Holy_Armor_S S_Def_Potion B_Def_Potion S_Mdef_Potion B_Mdef_Potion
syn keyword hItemId Battle_Manual_X3 Fire_Cracker_Love Fire_Cracker_Wday Fire_Cracker_Vday Fire_Cracker_Bday
syn keyword hItemId Fire_Cracker_Xmas Str_Dish01_ Str_Dish02_ Str_Dish03_ Int_Dish01_ Int_Dish02_ Int_Dish03_
syn keyword hItemId Vit_Dish01_ Vit_Dish02_ Vit_Dish03_ Agi_Dish01_ Agi_Dish02_ Agi_Dish03_ Dex_Dish01_ Dex_Dish02_
syn keyword hItemId Dex_Dish03_ Luk_Dish01_ Luk_Dish02_ Luk_Dish03_ Knife_Goblin_Ring Flail_Goblin_Ring
syn keyword hItemId Hammer_Goblin_Ring Holy_Marble Red_Burning_Stone Skull_Of_Vagabond Str_Dish05_ Int_Dish05_
syn keyword hItemId Vit_Dish05_ Agi_Dish05_ Dex_Dish05_ Luk_Dish05_ Dun_Tele_Scroll2 WOB_Rune WOB_Schwaltz WOB_Rachel
syn keyword hItemId WOB_Local Spark_Candy Repair_Scroll_ Pty_Blessing_Scroll Pty_Inc_Agi_Scroll Pty_Assumptio_Scroll
syn keyword hItemId Siege_Teleport_Scroll Job_Manual50 Magic_Power_Scroll Quagmire_Scroll Unsealed_Magic_Spell
syn keyword hItemId Pierre_Treasurebox PhreeoniS GhostringS Greed_Scroll_C Mental_Potion Tyr's_Blessing TaogunkaS
syn keyword hItemId MistressS Orc_HeroS Orc_LoadS Job_Manual25 Luxurious_Dinner_W Luxurious_Dinner_E Spoiled_Cuisine
syn keyword hItemId Bone_Plate Odin's_Blessing_I Erde Red_Square_Bag Stunner_C King_Frog_Hat_Box Evil's_Bone_Hat_Box
syn keyword hItemId Dragon_Arhat_Mask_Box Tiger_Arhat_Mask_Box Buddah_Scroll Evil_Incarnation Tw_Aug_Scroll
syn keyword hItemId Red_Wing_Hat_Box Premium_Reset_Stone_Box Universal_Catalog_Gold_Box10 Universal_Catalog_Gold_Box50
syn keyword hItemId Cannon_Ball Holy_Cannon_Ball Dark_Cannon_Ball Soul_Cannon_Ball Iron_Cannon_Ball Shooting_Star
syn keyword hItemId F_Bow_Of_Rudra_C E_Bow_Of_Rudra_C Cheer_Scarf6 Cheer_Scarf8 Cheer_Scarf10 Small_Horn_Of_Devil
syn keyword hItemId Umbala_Spirit Hattah_Black Elven_Ears_ Skull_Cap Horn_Of_Ancient Sprout_Hat Mercury_Helm
syn keyword hItemId Cat_Ears_Beret White_Musang_Hat Black_Musang_Hat Heart_Eyepatch Wit_Pumpkin_Hat T_Mr_Smile
syn keyword hItemId T_Spinx_Helm T_Sunglasses T_Cigarette T_Valkyrie_Feather_Band Clear_Sun Runstone_Luxanima

" Script Commands (imported from src/map/script.c)
syn keyword hCommand jobchange jobname warp areawarp warpchar warpparty warpguild setlook changelook getitem rentitem
syn keyword hCommand getitem2 getnameditem groupranditem makeitem delitem delitem2 enable_items disable_items cutin
syn keyword hCommand viewpoint heal itemheal percentheal rand countitem countitem2 checkweight checkweight2 readparam
syn keyword hCommand getcharid getnpcid getpartyname getpartymember getpartyleader getguildname getguildmaster
syn keyword hCommand getguildmasterid strcharinfo strnpcinfo getequipid getequipname getbrokenid repair repairall
syn keyword hCommand getequipisequiped getequipisenableref getequipisidentify getequiprefinerycnt getequipweaponlv
syn keyword hCommand getequippercentrefinery successrefitem failedrefitem downrefitem statusup statusup2 bonus bonus2
syn keyword hCommand bonus3 bonus4 bonus5 autobonus autobonus2 autobonus3 skill addtoskill guildskill getskilllv
syn keyword hCommand getgdskilllv basicskillcheck getgmlevel getgroupid checkoption setoption setcart checkcart
syn keyword hCommand setfalcon checkfalcon setriding checkriding checkwug checkmadogear setmadogear save savepoint
syn keyword hCommand gettimetick gettime gettimestr openstorage guildopenstorage itemskill produce cooking monster
syn keyword hCommand getmobdrops areamonster killmonster killmonsterall clone doevent donpcevent cmdothernpc addtimer
syn keyword hCommand deltimer addtimercount initnpctimer stopnpctimer startnpctimer setnpctimer getnpctimer
syn keyword hCommand attachnpctimer detachnpctimer playerattached announce mapannounce areaannounce getusers
syn keyword hCommand getmapguildusers getmapusers getareausers getareadropitem enablenpc disablenpc hideoffnpc
syn keyword hCommand hideonnpc sc_start sc_start2 sc_start4 sc_end getstatus getscrate debugmes pet bpet resetlvl
syn keyword hCommand resetstatus resetskill skillpointcount changebase changesex waitingroom delwaitingroom
syn keyword hCommand kickwaitingroomall enablewaitingroomevent disablewaitingroomevent enablearena disablearena
syn keyword hCommand getwaitingroomstate warpwaitingpc attachrid detachrid isloggedin setmapflagnosave getmapflag
syn keyword hCommand setmapflag removemapflag pvpon pvpoff gvgon gvgoff emotion maprespawnguildid agitstart agitend
syn keyword hCommand agitcheck flagemblem getcastlename getcastledata setcastledata requestguildinfo getequipcardcnt
syn keyword hCommand successremovecards failedremovecards marriage wedding divorce ispartneron getpartnerid getchildid
syn keyword hCommand getmotherid getfatherid warppartner getitemname getitemslots makepet getexp getinventorylist
syn keyword hCommand getskilllist clearitem classchange misceffect playbgm playbgmall soundeffect soundeffectall
syn keyword hCommand strmobinfo guardian guardianinfo petskillbonus petrecovery petloot petheal petskillattack
syn keyword hCommand petskillattack2 petskillsupport skilleffect npcskilleffect specialeffect specialeffect2 nude
syn keyword hCommand mapwarp atcommand charcommand movenpc message npctalk mobcount getlook getsavepoint npcspeed
syn keyword hCommand npcwalkto npcstop getmapxy checkoption1 checkoption2 guildgetexp guildchangegm logmes summon
syn keyword hCommand isnight isday isequipped isequippedcnt cardscnt getrefine night day defpattern activatepset
syn keyword hCommand deactivatepset deletepset dispbottom getusersname recovery getpetinfo gethominfo getmercinfo
syn keyword hCommand checkequipedcard globalmes unequip getstrlen charisalpha charat setchar insertchar delchar
syn keyword hCommand strtoupper strtolower charisupper charislower substr explode implode sprintf sscanf strpos
syn keyword hCommand replacestr countstr setnpcdisplay compare getiteminfo setiteminfo getequipcardid sqrt pow distance
syn keyword hCommand md5 petstat callshop npcshopitem npcshopadditem npcshopdelitem npcshopattach equip autoequip
syn keyword hCommand setbattleflag getbattleflag setitemscript disguise undisguise getmonsterinfo addmonsterdrop
syn keyword hCommand delmonsterdrop axtoi query_sql query_logsql escape_sql atoi rid2name pcfollow pcstopfollow
syn keyword hCommand pcblockmove unitwalk unitkill unitwarp unitattack unitstop unittalk unitemote unitskilluseid
syn keyword hCommand unitskillusepos getvariableofnpc warpportal homevolution hommutate morphembryo checkhomcall
syn keyword hCommand homshuffle eaclass roclass checkvending checkchatting checkidle openmail openauction checkcell
syn keyword hCommand setcell setwall delwall searchitem mercenary_create mercenary_heal mercenary_sc_start
syn keyword hCommand mercenary_get_calls mercenary_get_faith mercenary_set_calls mercenary_set_faith readbook setfont
syn keyword hCommand areamobuseskill progressbar pushpc buyingstore searchstores showdigit agitstart2 agitend2
syn keyword hCommand agitcheck2 waitingroom2bg waitingroom2bg_single bg_team_setxy bg_warp bg_monster
syn keyword hCommand bg_monster_set_team bg_leave bg_destroy areapercentheal bg_get_data bg_getareausers bg_updatescore
syn keyword hCommand instance_create instance_destroy instance_attachmap instance_detachmap instance_attach instance_id
syn keyword hCommand instance_set_timeout instance_init instance_announce instance_npcname has_instance
syn keyword hCommand instance_warpall instance_check_party instance_mapname instance_set_respawn makerune checkdragon
syn keyword hCommand setdragon ismounting setmounting checkre getargcount getcharip is_function get_revision freeloop
syn keyword hCommand getrandgroupitem cleanmap cleanarea npcskill itemeffect consumeitem delequip bindatcmd unbindatcmd
syn keyword hCommand useatcmd getitembound getitembound2 countbound questinfo setquest erasequest completequest
syn keyword hCommand checkquest changequest showevent queue queuesize queueadd queueremove queueopt queuedel
syn keyword hCommand queueiterator qicheck qiget qiclear packageitem sit stand issit montransform bg_create_team
syn keyword hCommand bg_join_team bg_match_over
syn keyword hKeyword end close close2 next return callfunc callsub
syn keyword hDeprecated menu goto set setr jump_zero
syn keyword hStatement mes select prompt getarg input setarray cleararray copyarray getarraysize deletearray
syn keyword hStatement getelementofarray getd setd sleep sleep2 awake



" Ternary operator doesn't work too well, let's ignore it.
"syn cluster	hMultiGroup	contains=hNpcEvent,hCommentSkip,hCommentString,hComment2String,@hCommentGroup,hCommentStartError,hUserCont,hUserLabel,hNumber,hNumbersCom,hString
"syn region	hMulti		transparent start='?' skip='::' end=':' contains=ALLBUT,@hMultiGroup,@Spell,@hTopLevel
" Avoid matching foo::bar by requiring that the next char is not ':'
" Highlight User Labels
syn cluster	hLabelGroup	contains=hUserLabel,hDefaultLabel
syn match	hUserCont	transparent "^\s*\I\i*\s*:$" contains=@hLabelGroup
syn match	hUserCont	transparent ";\s*\I\i*\s*:$" contains=@hLabelGroup
syn match	hUserCont	transparent "^\s*\I\i*\s*:[^:]"me=e-1 contains=@hLabelGroup
syn match	hUserCont	transparent ";\s*\I\i*\s*:[^:]"me=e-1 contains=@hLabelGroup

" User defined labels
syn match	hUserLabel	display "[A-Z]_\i*" contained
syn match	hUserLabel	display "On\i*" contained

" Pre-defined labels
" chrif_connectack
syn match	hDefaultLabel	display "OnInterIfInit\%(Once\)\?:"me=e-1 contained
" clif_parse_WisMessage
syn match	hDefaultLabel	display "OnWhisperGlobal:"me=e-1 contained
" castle_guild_broken_sub
syn match	hDefaultLabel	display "OnGuildBreak:"me=e-1 contained
" guild_castledataloadack, guild_agit_start, guild_agit_end, guild_agit2_start, guild_agit2_end
syn match	hDefaultLabel	display "OnAgit\%(Init\|Start\|End\)2\?:"me=e-1 contained
" instance_init_npc
syn match	hDefaultLabel	display "OnInstanceInit:"me=e-1 contained
" npc_event_do_clock:
syn match	hDefaultLabel	display "On\%(Minute\|Hour\)[0-9]\{2\}:"me=e-1 contained
syn match	hDefaultLabel	display "On\%(Day\|Clock\|Sun\|Mon\|Tue\|Wed\|Thu\|Fri\|Sat\)[0-9]\{4\}:"me=e-1 contained
syn match	hDefaultLabel	display "OnDay[0-9]:"me=e-1 contained
" npc_event_do_oninit:
syn match	hDefaultLabel	display "OnInit:"me=e-1 contained
" npc_timerevent_quit:
syn match	hDefaultLabel	display "OnTimerQuit:"me=e-1 contained
" npc_touch_areanpc2
syn match	hDefaultLabel	display "OnTouchNPC:"me=e-1 contained
" npc_buylist_sub, npc_selllist_sub
syn match	hDefaultLabel	display "On\%(Buy\|Sell\)Item:"me=e-1 contained
" npc_timerevent_export
syn match	hDefaultLabel	display "OnTimer[0-9]\+:"me=e-1 contained
" BUILDIN(cmdothernpc)
syn match	hDefaultLabel	display "OnCommand\i\+:"me=e-1 contained
" script_defaults
syn match	hDefaultLabel	display "OnPC\%(Die\|Kill\|Login\|Logout\|LoadMap\|BaseLvUp\|JobLvUp\)Event:"me=e-1 contained
syn match	hDefaultLabel	display "OnNPCKillEvent:"me=e-1 contained
syn match	hDefaultLabel	display "OnTouch_\?:"me=e-1 contained

syn match	hSwitchLabel	display "\s*case\s*\i*\s*:"me=e-1 contains=hNumber,hConstant,hParam
syn match	hSwitchLabel	display "\s*default:"me=e-1

if exists("c_comment_strings")
  " A comment can contain hString and hNumber.
  " But a "*/" inside an hString in an hComment DOES end the comment!  So we
  " need to use a special type of hString: hCommentString, which also ends on
  " "*/", and sees a "*" at the start of the line as comment again.
  " Unfortunately this doesn't very well work for // type of comments :-(
  syntax match	hCommentSkip	contained "^\s*\*\%($\|\s\+\)"
  syntax region hCommentString	contained start=+\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end=+\*/+me=s-1 contains=hColor,hNpcEvent,hStringSpecial,hCommentSkip
  syntax region hComment2String	contained start=+\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end="$" contains=hColor,hNpcEvent,hStringSpecial
  syntax region hCommentL	start="//" skip="\\$" end="$" keepend contains=@hCommentGroup,hComment2String,hNumbersCom,hSpaceError,@Spell
  if exists("c_no_comment_fold")
    " Use "extend" here to have preprocessor lines not terminate halfway a
    " comment.
    syntax region hComment	matchgroup=hCommentStart start="/\*" end="\*/" contains=@hCommentGroup,hCommentStartError,hCommentString,hNumbersCom,hSpaceError,@Spell extend
  else
    syntax region hComment	matchgroup=hCommentStart start="/\*" end="\*/" contains=@hCommentGroup,hCommentStartError,hCommentString,hNumbersCom,hSpaceError,@Spell fold extend
  endif
else
  syn region	hCommentL	start="//" skip="\\$" end="$" keepend contains=@hCommentGroup,hSpaceError,@Spell
  if exists("c_no_comment_fold")
    syn region	hComment	matchgroup=hCommentStart start="/\*" end="\*/" contains=@hCommentGroup,hCommentStartError,hSpaceError,@Spell extend
  else
    syn region	hComment	matchgroup=hCommentStart start="/\*" end="\*/" contains=@hCommentGroup,hCommentStartError,hSpaceError,@Spell fold extend
  endif
endif
" keep a // comment separately, it terminates a preproc. conditional
syntax match	hCommentError		display "\*/"
syntax match	hCommentStartError	display "/\*"me=e-1 contained

if exists("c_minlines")
  let b:c_minlines = c_minlines
else
  if !exists("c_no_if0")
    let b:c_minlines = 50	" #if 0 constructs can be long
  else
    let b:c_minlines = 15	" mostly for () constructs
  endif
endif
if exists("c_curly_error")
  syn sync fromstart
else
  exec "syn sync ccomment hComment minlines=" . b:c_minlines
endif

" Define the default highlighting.
" Only used when an item doesn't have highlighting yet
hi def link hCommentL		hComment
hi def link hCommentStart	hComment
hi def link hDefaultLabel 	Boolean
hi def link hUserLabel		Label
hi def link hSwitchLabel	Boolean
hi def link hConditional	Conditional
hi def link hRepeat		Repeat
hi def link hNumber		Number
hi def link hParenError		Error
hi def link hErrInParen		Error
hi def link hErrInBracket	Error
hi def link hCommentError	Error
hi def link hCommentStartError	Error
hi def link hSpaceError		Error
hi def link hCurlyError		hError
hi def link hStatement		Type
hi def link hKeyword		Statement
hi def link hCommand		Function
hi def link hDeprecated		Error
hi def link hConstant		Constant
hi def link hMapName		PreProc
hi def link hSkillId		Constant
hi def link hMobId		Constant
hi def link hItemId		Constant
hi def link hParam		Float
hi def link hCommentString	hString
hi def link hComment2String	hString
hi def link hCommentSkip	hComment
hi def link hString		String
hi def link hComment		Comment
hi def link hNpcEvent		SpecialChar
hi def link hStringSpecial	SpecialChar
hi def link hColor		SpecialChar
hi def link hTodo		Todo

hi def link hTopError		Error
hi def link hTopMapflag		hTopLevelColor
hi def link hTopLocation	hTopLevelColor
hi def link hTopWDest		hTopLevelColor
hi def link hTopMobData		hTopLevelColor
hi def link hTopShopData	hTopLevelColor
hi def link hTopNameDup		hTopNpcName
hi def link hTopName		hTopNpcName
hi def link hDupName		hTopNpcName
hi def link hTopNameFunc	hTopLevelColor
hi def link hTopType		hTopKeyword
hi def link hTopTypeW		hTopKeyword
hi def link hTopTypeS		hTopKeyword
hi def link hTopTypeM		hTopKeyword
hi def link hTopTypeMF		hTopKeyword
hi def link hTopNpcName		Define
hi def link hTopLevelColor	Float
hi def link hTopKeyword		Float
hi def link hVariable		Include



let b:current_syntax = "herc"

" vim: set ts=8 tw=120 colorcolumn=120 :
