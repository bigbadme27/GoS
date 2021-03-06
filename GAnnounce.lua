local c = {}
local lastSound = GetGameTimer()
local sounds = {}
local mS = 0
local mS2 = 0
local sf = {
	{[1] = "Dlc_glados_killing_spree_ann_glados_kill_double_",[2] = 1},
	{[1] = "Dlc_glados_killing_spree_ann_glados_kill_triple_",[2] = 1},
	{[1] = "Dlc_glados_killing_spree_ann_glados_kill_ultra_",[2] = 2},
	{[1] = "Dlc_glados_killing_spree_ann_glados_kill_rampage_",[2] = 3},
	{[1] = "Dlc_glados_ann_glados_followup_respaw_",[2] = 13},
	{[1] = "Dlc_glados_ann_glados_ally_neg_",[2] = 26},
}

if not DirExists(SOUNDS_PATH.."\\Glados\\") then
	CreateDir(SOUNDS_PATH.."\\Glados\\")
	print("Downloading Soundfiles...")
end

for _,i in pairs(sf) do
	mS = mS + i[2]
end

for _,i in pairs(sf) do
	for l=1,i[2] do
		--print(i[1]..i[2])
		if not FileExist(SOUNDS_PATH.. "\\Glados\\" .. i[1] .. l .. ".wav") then
			DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/GS/" .. i[1]..l..".wav" , SOUNDS_PATH .. "\\Glados\\" .. i[1]..l..".wav", function() mS2 = mS2 + 1 end)
		else 
			mS2 = mS2 + 1
		end
	end
end

OnDraw( function()
	if ___ then return end
	DrawText(mS2,30,50,50,GoS.White)
	if mS2 < mS then
		FillRect(100,100,100+mS2/mS*1000,150,GoS.White)
	else
		FillRect(100,100,1000,150,GoS.Green)
		DelayAction(function() ___ = true init() end, 2)
	end
end)

function init()

c[GetNetworkID(myHero)] = {unit = myHero, dead = false, deadT = nil, lDmg = nil, lDmgT = nil, killer = nil, mk = 0, mks = nil, counted = false}
DelayAction( function() 
	for _,i in pairs(GetAllyHeroes()) do
		c[GetNetworkID(i)] = {unit = i, dead = false, deadT = nil, lDmg = nil, lDmgT = nil, killer = nil, mk = 0, mks = nil, counted = false}
	end
	for _,i in pairs(GetEnemyHeroes()) do
		c[GetNetworkID(i)] = {unit = i, dead = false, deadT = nil, lDmg = nil, lDmgT = nil, killer = nil, mk = 0, mks = nil, counted = false}
	end
end,0)

OnDamage( function (unit,target,dmg)
	if GetObjectType(unit) == Obj_AI_Hero and GetObjectType(target) == Obj_AI_Hero then
		c[GetNetworkID(target)].lDmg = unit
		c[GetNetworkID(target)].lDmgT = GetGameTimer()
	end
end)

OnTick( function ()
	for _,i in pairs(c) do
		if not i.dead and i.unit.dead and i.lDmg then	--onDeath
			i.deadT = GetGameTimer()
			i.killer = i.lDmg
		end
		
		if i.dead and not i.unit.dead and _ == GetNetworkID(myHero) then	--On Respawn
			Play("Dlc_glados_ann_glados_followup_respaw_",13)
			
		elseif not i.dead and i.unit.dead and _ == GetNetworkID(myHero) then	--On Death (Self)
			Play("Dlc_glados_ann_glados_ally_neg_",26)
		end
		
		
		if not i.dead and i.unit.dead and i.killer and i.deadT and not i.counted then
			print(GetObjectName(i.unit).." died to "..GetObjectName(i.killer))
			c[GetNetworkID(i.killer)].mko = c[GetNetworkID(i.killer)].mk
			c[GetNetworkID(i.killer)].mk = c[GetNetworkID(i.killer)].mk + 1
			i.counted = true
			c[GetNetworkID(i.killer)].mks = GetGameTimer()
		elseif i.killer and c[GetNetworkID(i.killer)].mks and GetGameTimer() - c[GetNetworkID(i.killer)].mks >= 10 and i.counted then
			c[GetNetworkID(i.killer)].mk = 0
			c[GetNetworkID(i.killer)].mks = nil
			i.counted = false
		end
		
		if i.mko and i.mko < i.mk then
			if i.mk == 2 then
				Play("Dlc_glados_killing_spree_ann_glados_kill_double_",1)
			elseif i.mk == 3 then
				Play("Dlc_glados_killing_spree_ann_glados_kill_triple_",1)
			elseif i.mk == 4 then
				Play("Dlc_glados_killing_spree_ann_glados_kill_ultra_",2)
			elseif i.mk == 5 then
				Play("Dlc_glados_killing_spree_ann_glados_kill_rampage_",3)
			end
			i.mko = i.mk
		end
		
		
		if i.lDmgT and GetGameTimer() - i.lDmgT >= 10 then
			i.lDmg = nil
			i.killer = nil
		end
		
		if i.unit.dead then 
			i.dead = true
		else
			i.dead = false
			i.killer = nil
			i.deadT = nil
		end
	end
end)

OnDraw( function()
	DrawText(math.floor(GetGameTimer()),20,5,5,GoS.White)
	for l,m in pairs(c) do
		local y = 0
		local mph = WorldToScreen(0,GetOrigin(m.unit))
		for _,i in pairs(m) do
			if type(i)=="Object" then
				i = GetObjectName(i)
			end
			DrawText(_..": "..tostring(i),20,mph.x,mph.y+y,GoS.White)
			y = y + 30
		end
	end
end)

function Play(str,m)
	if GetGameTimer() - lastSound > 2 or GetGameTimer() <= 20 then
		repeat 
			local rnd = math.random(1,m)
			PlaySound(SOUNDS_PATH.. [[\Glados\]] ..str..tostring(rnd) .. ".wav")
			--print("Ran Sound "..SOUNDS_PATH.. [[\Glados\]] ..str.. tostring(rnd) .. ".wav")
		until FileExist(SOUNDS_PATH.. [[\Glados\]] ..str.. "0"..tostring(rnd) .. ".wav")
		lastSound = GetGameTimer()
	else
		DelayAction(function () Play(str,m) end, 2)
		print("spam catch")
	end
end

if GetGameTimer() <= 20 then
	Play("Dlc_glados_ann_glados_battle_prepare_",10)
end
--1:15 creeps
end
