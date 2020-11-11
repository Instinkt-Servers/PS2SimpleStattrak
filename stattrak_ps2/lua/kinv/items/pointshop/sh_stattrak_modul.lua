--[[
This Script is made by Instinkt https://steamcommunity.com/id/InstinktServers and is under GPL-3.0 License.
--]]

#NoSimplerr#
resource.AddFile("materials/mat_jack_job_gradient.vmt")
resource.AddFile("materials/tex_jack_job_gradient.vtf")
resource.AddFile("materials/mat_jack_job_modul.vmt")
resource.AddFile("materials/tex_jack_job_modul.vtf")
ITEM.baseClass	= "base_hat"
ITEM.PrintName	= "Stattrak Modul"
ITEM.Description = "Zähle deine Kills mit!"
ITEM.Price = {
	points = 1000000,
}

ITEM.static.validSlots = {
	"Stattrak",
	"Accessory",
	"Accessory2",
	"Extra",
}

ITEM.static.iconInfo = {
	["shop"] = {
		["iconMaterial"] = "mat_jack_job_modul",
		["useMaterialIcon"] = true
	},
	["inv"] = {
		["iconMaterial"] = "mat_jack_job_modul",
		["useMaterialIcon"] = true
	}
}

function ITEM.static.getBaseOutfit( )
	return {},2
end

function ITEM:Think( )
	KInventory.Items.base_hat.Think( self )
	local ply=self.owner
end
Pointshop2.AddItemHook( "Think", ITEM )

function ITEM:OnEquip()
	local ply=self.owner
	if(CLIENT)then
		local Data,Raw=nil,file.Read("stattrak_modul_data.txt")
		if(Raw)then
			local Tab=util.JSONToTable(Raw)
			if(Tab)then Data=Tab end
		end
		if not(Data)then Data={} end
		ply.JackaJobStattrakModul=Data
	end
end

function ITEM:OnHolster()
	local ply=self.owner
	if(CLIENT)then ply.JackaJobStattrakModul=nil end
end

function ITEM.static.getOutfitForModel( model )
	return ITEM.static.getBaseOutfit( )
end

----------------- finally, not-shit code -------------------
local AllowedWeapons={"m9k_","weapon_zm_","weapon_ttt_","csgo_","ryry_","blast_","clt_","divine_","47_","aquakrds","g36_","m4a1_","weapon_impact","weapon_aciiitomahawk","scout_","tmp_","rgmll","csgo_*", "bowie", "mp_","gut_","karam_","huntsman_","bowie_","m9_","flip_","falchion","dagger","butterfly_","bowie_","dagger_","bayonet","weapon_","m9","tfa","tfa_"}local function WeaponAllowed(class) 
	for key,prefix in pairs(AllowedWeapons)do
		if(string.find(class,prefix))then return true end
	end
	return false
end
if(CLIENT)then
	hook.Add("Initialize","JackaJobStattrakFonts",function()
		surface.CreateFont("StattrakModulFont",{
			font="Arial",
			size=300,
			weight=900,
			blursize=0,
			scanlines=0,
			antialias=true,
			underline=false,
			italic=false,
			strikeout=false,
			symbol=false,
			rotary=false,
			shadow=false,
			additive=false,
			outline=false
		})
	end)
	net.Receive("stattrak_modul_kill",function()
		local ply=LocalPlayer()
		if(ply.JackaJobStattrakModul)then
			local Wep=net.ReadString()
			local Amt=ply.JackaJobStattrakModul[Wep]
			if not(Amt)then Amt=0 end
			Amt=Amt+1
			ply.JackaJobStattrakModul[Wep]=Amt
			file.Write("stattrak_modul_data.txt",util.TableToJSON(ply.JackaJobStattrakModul))
		end
	end)
	local Gradient=Material("mat_jack_job_gradient")
	hook.Add("PostDrawViewModel","JackaJobStattrakModul",function(vm,ply,wep)
		if((vm)and(wep)and(ply)and(ply.JackaJobStattrakModul))then
			local Class=wep:GetClass()
			if(WeaponAllowed(Class))then
				local PosAng,Dist=nil,5
				local Muzz=vm:LookupAttachment("muzzle")
				if(Muzz)then PosAng=vm:GetAttachment(Muzz) end
				if not(PosAng)then PosAng=vm:GetAttachment(1) end
				if((PosAng)and(PosAng.Pos:Length()>40000))then PosAng=vm:GetAttachment(2);Dist=10 end
				if(PosAng)then
					local Pos,Ang,Kills=PosAng.Pos,PosAng.Ang,ply.JackaJobStattrakModul[wep:GetClass()]
					if not(Kills)then Kills=0 end
					local EAng=EyeAngles()
					local RenderAng=Angle(EAng.p,EAng.y,EAng.r) -- fuck it... the m9k weapons are so shitty and their viewmodels are so inconsistent
					RenderAng:RotateAroundAxis(RenderAng:Right(),90)
					RenderAng:RotateAroundAxis(EAng:Forward(),90)
					cam.Start3D2D(Pos+EAng:Forward()*Dist-EAng:Right()*13+EAng:Up()*1,RenderAng,.015)
					surface.SetMaterial(Gradient)
					surface.SetDrawColor(Color(255,255,255,225))
					surface.DrawTexturedRect(-220,0,900,256)
					draw.SimpleTextOutlined("Kills:","StattrakModulFont",-200,5,Color(255,255,255,225),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,1,Color(0,0,0,225))
					draw.SimpleTextOutlined(tostring(Kills),"StattrakModulFont",370,5,Color(255,225,100,225),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,1,Color(0,0,0,225))
					cam.End3D2D()
				end
			end
		end
	end)
elseif(SERVER)then
	util.AddNetworkString("stattrak_modul_kill")
	hook.Add("OnNPCKilled","JackaJobStattrakModulNPCKill",function(npc,attacker,inflictor)
		if((IsValid(attacker))and(attacker:IsPlayer()))then
			local Wep=attacker:GetActiveWeapon()
			if(IsValid(Wep))then
				local Class=Wep:GetClass()
				if(WeaponAllowed(Class))then
					net.Start("stattrak_modul_kill")
					net.WriteString(Class)
					net.Send(attacker)
				end
			end
		end
	end)
	hook.Add("DoPlayerDeath","JackaJobStattrakModulPlayerKill",function(victim,attacker,dmg)
		if((IsValid(attacker))and(attacker:IsPlayer()))then
			local Wep=attacker:GetActiveWeapon()
			if(IsValid(Wep))then
				local Class=Wep:GetClass()
				if(WeaponAllowed(Class))then
					net.Start("stattrak_modul_kill")
					net.WriteString(Wep:GetClass())
					net.Send(attacker)
				end
			end
		end
	end)
end