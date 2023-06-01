pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
--main 
--todo! 
--[[

	end game screen
	
	some kind of time for 
		plane to get you

	sfx for plane
	
	attacking delay/effect

	bugfix to prevent lag
		from particles

	

--]]

gamemode = 2 //0 is main, 1 is 
														//menu,
														//2 is game start
														//3 is game over


function _init()
	
	
	gamemode = 5
	
	reset_game()
	
	music(0)
	
	msg("for ryan",2.5)
	msg("192.168.0.1",.2)
--]]



end



mus_test = 0
function _update()	

	//do wind
	if time() % 5.5 == 0 
		and gamemode != 5
	then
		sfx(2)
	end
	


	//world mode
	if gamemode == 0 then
		
		
		if btnp(⬅️) then
		--	add_mob(1,pl.x,pl.y)
		end
		
		
		//upd time   time 10
		if time() % sec_per_hour == 0 then
			adv_hour()
		end
			
		
		nodes = choice_menu(0,116,9,1,inv)
		
	 get_player_input()
	 move_player()
	 lose_heat()
	-- passive_hp_regen()
	 player_death()
	 nearest_pl_obj()
	 stats_reg()
	 upd_res()
	 switch_menu()
	 move_camera()
	 mob_upd()
	 
		world_border()
	 
	 has_enough_fires()
	 
	 rnd_mobs()
	 
	 //snowfall
	 for i = 0,snow_level do
	 	add_part(138+camx,-10+camy,-rnd(5),rnd(4),7,5)
	 end
	 
	end
	
	//menu mode
	if gamemode == 1 then
		get_menu_input()
	end

	
	switch_buff = false
	
end


function _draw()
	cls()
	
	
	time_color()
	
	
	//regular play
	if gamemode == 0 then
		
		draw_world_border()

		map()
		
		draw_res()
	
		draw_player()
	
		draw_mobs()
		
		draw_ghost()
	
		draw_nodes(true)
		
		draw_part()
		
		hud()
		
		
	//ui	
	elseif gamemode == 1	then		
		//inventory drawn in menu call
		draw_menu()
		
	end
	
	//start screen
	if gamemode == 2 then
		start_screen()
	end
	
	//help screen
	if gamemode == 3 then
		help_screen()
		draw_part()
	end
	
	if gamemode == 4 then
		death_screen()
	end
	
	if gamemode == 5 then
		startup_screen()
	end
	
	if gamemode == 6 then
		victory_screen()
		draw_part()
	end
	
	
	draw_msg()
	
	
-- print(#part, pl.x,pl.y)

	
end


function reset_game()
	
	pl.hp = 10
	pl.warmth = 100
	pl.item=-1
	inv = {}
	
	camx = 0
	camy = 0
	camera(0,0)
	
	clear_part()
	
	res = {}
	mobs = {}
	
	msg_text = ""
	
	hour = 0
	day = 0
	
	
end
-->8

--player
pl = {x=63,
						y=63,
						vx=0,
						vy=0,
						spd=1.2,
						s=1,
						dir=1,
						ani={{2,3,4}},
					 flipp=false,
						action=0,
						item=-1, //held item
						last_angle=0,
						hp = 10,
						warmth=100,
						dmg = 1,
						closest_obj=0,	//closest thing
						can_atk = true,
						next_atk = 0
						
						}
						
//actions enum 0:harvest 1:weapon/tool 2:build	

--[[
	action 0 is standard harvest
	1 is place item	
--]]

//player inventory
inv = {}

function draw_player()
	spr(pl.s,pl.x,pl.y,1,1,pl.flipp)
	
	if pl.vx != 0 or pl.vy != 0 then
		
		pl.s = pl.ani[pl.dir][flr(time()*8%#pl.ani[pl.dir])+1]
	else
		pl.s = pl.ani[pl.dir][1] - 1
	end
	
	x = pl.x
	y = pl.y
	vx = pl.vx
	vy = pl.vy
	
	a = pl.last_angle
	
	//flips item to match player
	if pl.item  != -1 then
		local f = false
		if a > .25 and a < .75 then
			f = true
		end
	
		if pl.can_atk == false then
			for i = 0,15 do
				pal(i,7)
			end
		end
	
		spr(res_types[pl.item].ico, x+7*cos(a),y+7*sin(a),
			1,1,f)
		pal()
	end
end

function upd_ani()
	
	if pl.vx > 0 then
		pl.flipp = false
	elseif pl.vx < 0 then
		pl.flipp = true
	end	
	
	
	
end


function get_player_input()
	
	vx = bool2int(btn(➡️)) - bool2int(btn(⬅️))
	vy = bool2int(btn(⬇️)) - bool2int(btn(⬆️))
	
	pl.vx = vx
	pl.vy = vy
	
	upd_ani()
	
	if btnp(🅾️) then
		press_action()
	end
	
	if vx != 0 or vy != 0 then
		pl.last_angle = atan2(vx, vy)
	end
	
	if time() > pl.next_atk then
		pl.can_atk = true
	end
	
	
end


function press_action()

--	nodes = choice_menu(0,116,9,1,inv)
	
	//standard harvest/attack action
	if pl.action == 0 then
		 
		 if pl.closest_obj.name ==
		 	"tent" and hour > 10
		 	then
		 		next_day()
		 		return
		 	end
		 
		 harvest()
		end	
		
		//use tool/weapon
		if pl.action == 1 then
			
			m = get_closest(mobs,pl.x,pl.y)
			
			if m != false and pl.can_atk then
				 
				 if attack(pl, m) then
				 
				 	for d in all(all_mobs[m.t].drops) do
				 		add_inv(d)
						end			
						
	    end
	    
	    pl.can_atk = false
					pl.next_atk = time() + 1
					sfx(15)
			end
			

			
		end
		
		//place action
		if pl.action == 2 then
		
			//code to make sure placed
			//items don't overlap
		
			place_item()
			
		end
		
		if pl.action == 4 then
			throw_item()
		end
	
end

function harvest()
	r = closest_res(pl.x,pl.y)
		
		if r != false then
	
			if #inv == 18 then
				if #msg_queue < 2 then
					msg("you're carrying too much!",3)	
				end
				return
			end
	
	  if dist(pl.x,pl.y,r.x,r.y)
		< 15 then
			
			sfx(0)
			
			//decreases res durability
			res[find(res,r)].dur -= 1
			
			if r.dur <= 0 then
				add_inv(r.t)
			end
		
			for i = 1, rnd(5)+7 do		
				rot = rnd(.5)	
				add_part(r.x+4,r.y+4,cos(rot),-sin(rot),5,.3)
			end
			
			end
		end
				
end

function use_tool()


	
	//get closets res or mob
	//do damage or harvest
	//yah
end

function place_item()
		add_res(pl.x+10*cos(a),pl.y+10*sin(a),pl.item)
		rm_inv(pl.item)
		unequip()
end

function throw_item()
	
	for i = 0,10 do
		
		add_mob(4,pl.x,pl.y)
		mobs[#mobs].vx = cos(pl.last_angle)
		mobs[#mobs].vy = sin(pl.last_angle)
		mobs[#mobs].s = pl.item
		
		rm_inv(pl.item)
		unequip()
	end
	
end


switch_buff = false
function switch_menu()
	if btnp(❎) then	
		gamemode_1()
	end
end

function gamemode_1()
	gamemode = 1
	menu_reset()
	unequip()
	switch_buff = true
end

function gamemode_0()
	gamemode = 0
	nodes = choice_menu(0,116,9,1,inv)
	switch_buff = true
end

function move_player()
	
	if map_hit(pl.x+pl.vx,
												pl.y+pl.vy,
												7,7) then
		return												
	end
	
	pl.x += pl.vx*pl.spd
	pl.y += pl.vy*pl.spd
	
end

function equip(item)
	
	pl.item = item
	
	pl.action = res_types[item].t-1
	
end

function unequip()
	pl.item = -1
	pl.action = 0
end


function add_inv(obj)
	
	if #inv < 18 then
	 add(inv, obj)
		return true
	end
	
	return false
	
end

function rm_inv(t)
	
	for i in all(inv) do
		
		if i == t then
			del(inv, t)
			return true
		end
		
	end
	
	return false
	
end

//change to has method lolol
function has_item(t)
	
	for i in all(inv) do
		if i == t then
			return true
		end
	end
	
	return false
	
end


function has_item_num(t)
	
	c = 0
	
	for i in all(inv) do
		if i == t then
			c += 1
		end
	end
	
	return c
	
end

camx,camy = 0,0
camxv,camyv = 0,0

//implement cam and pl.pos
//offset
cam_spd = 1 //.1
function move_camera()
	
	camera(camx,camy)
	
	camx = camx + camxv*cam_spd
	camy = camy + camyv*cam_spd
	
	camxv = pl.x-camx-60
	camyv = pl.y-camy-60
end

function lose_heat()
	
	if hour <= 14 then
		if time() % 10 == 0 then
			pl.warmth -= 3
		end
	end
	
	fires = get_all(res,6)
	
		
		close = get_closest(fires,pl.x,pl.y)
		
		if close != false then
		
			if dist(pl.x,pl.y,close.x,close.y)
				< 30 then
					
					pl.warmth += .5
					passive_hp_regen()
			end
		
		end
	
	if hour > 14 then
		
		if time() % 2 == 0 then
			pl.warmth -= 5
		end
	end
	
	
end

function passive_hp_regen()
	
	if time() % 5 == 0 then
		pl.hp += 1
	end
	
end

//keeps player stats below 
//their max
function stats_reg()
	
	if pl.warmth > 100 then
		pl.warmth = 100
	end
	
	if pl.hp > 10 then
		pl.hp = 10
	end
	
	if pl.hp < 0 then
			pl.hp = 0
	end
	
	if pl.warmth < 0 then
		pl.warmth = 0
	end
	
end

function player_death()
	
	
	
	if pl.hp <= 0 then
	
		msg("cause of death: blood loss",5)
		gamemode = 4
		sfx(9) //death sound
	end
	
	if pl.warmth <= 0 then

		msg("cause of death: shivers",5)
		gamemode = 4
		sfx(9) //death sound
	end
	
end


function nearest_pl_obj()
	
	item = get_closest(res,pl.x,pl.y)
	
	i = res_types[item.t]
	
	pl.closest_obj = i
	
end
-->8
--lib

function bool2int(b)
	if b then
		return 1
	else
		return 0	
	end
end


function map_hit(x1,y1,w,h)
	
	for xx = x1,x1+w,w do
		for yy = y1,y1+h,h do
			
			mx = flr(xx/8)
			my = flr(yy/8)
			
			if fget(mget(mx,my)) == 1 then
				return true
			end
			
		end
	end
	
	return false
	
end


function get_col(x1,y1,h1,w1,
																	x2,y2,h2,w2)
	for xx = x1,x1+w1,w1 do
		for yy = y1,y1+h1,h1 do
			
			if xx >= x2 and xx <= x2+w2 and
				yy >= y2 and yy <= y2+h2 
					then
						return true
					end
			
		end
	end																		
	
	return false														
	
end

function dist(x1,y1,x2,y2)
	
	//haha lol forgot about int
	//limits! xd lol cringe
	
	
	xx = ((x2-x1)/100)^2
	yy = ((y2-y1)/100)^2
	s = sqrt(xx + yy)
	
	if s == 0 then
		return 1000
	end
	
	return s * 100
	
end


function has(t, v)
	
	for i in all(t) do
		if i == v then
			return true
		end
	end
	
	return false
	
end

function find(t, v)
	for i = 1, #t do
		
		if t[i] == v then
			return i
		end
		
	end
	
	return false
end

//
function get_closest(arr, x,y)
	
	item = 0
	
	closest = 1000
	
	for n in all(arr) do
		
		d = dist(x,y,n.x,n.y) 
		
		if n.x == x and n.y == y then
			d = 1001
		end
		
		if d < closest
			then
				closest = d
				item = n
			end
		
	end
	
	if item == 0 then
		return false
	end
	
	if closest == 1000 then
		return false
	end
	

	return item
	
end


function get_all(table, value)
	
	t={}
	
	for i = 1, #table do
		
		if table[i].t == value then
			add(t, table[i])
		end
		
	end
	

		return t
	
end

function get_all_inv(value)
	
	t={}
	
	for i = 1, #inv do
		
		if inv[i]== value then
			add(t, inv[i])
		end
		
	end
	
	
	return t
	
end



-->8
--particle system

part = {}
--x,y,vx,vy,col,life


function add_part(x,y,vx,vy,col,life)
		
		p = {x=x,y=y,vx=vx,vy=vy,col=col,life=life}
		add(part, p)
		
end



function draw_part()
	for p in all(part) do
	
				pset(p.x,p.y,p.col)
				
				if p.life <= 0 then
					del(part, p)
				end
		
		p.x += p.vx
		p.y += p.vy
		
		p.life -= .03
	
		
	end
	

end


function blood(x,y) 
	
	for i = 0,10 do
		
		ang = rnd(1)
		
		add_part(x,y,cos(ang),sin(ang),8,.2)
		
	end
	
end

function fire(x,y)

	for i = 0,5 do
		add_part(x,y,rnd(1)*-1,rnd(2)*-1,flr(rnd(4))+7,.1)
	end

end

function smoke(x,y)
	
	drift = -.5
	
	for i = 0,10 do
		
		ang = rnd(1)
		
	
		
		add_part(x+cos(ang)+1,
											y+sin(ang)+1,
											drift,
											-.90,
											5,
											3)
		
	end
	
end

function clear_part()
	for i in all(part) do
		del(part, i)
	end
end

-->8
--resouce objects

res = {}

--[[

		object types 
		
		- weapons
		- tools
		- placeables
		- consumables
		- static/crafting
]]--

//enum for resources in inv
//s is world sprite,dur is durability,
//ico inventory
//also contains crafting 
//craft{} is materials needed

--[[
cost change: 
cost is now [item,#]
for all items. annoying af
but it'll get the job done

--]]

res_types = {
			//1
			{s=74,dur=10,ico=17,name="log",t=1,cost={{t=1,am=1}}},//tree
			{s=75,dur=10,ico=18,name="stone",t=1,cost={{t=5,am=2}}},//stone
			{s=nil,dur=nil,ico=19,cost={{t=1,am=1}},name="charcoal",t=1},//coal
   {s=nil,dur=nil,ico=20,cost={ {t=1,am=2}, {t=5,am=1}},name="spear",t=2},//spear
			{s=76,dur=5,ico=21,name="flint",t=1,cost={{t=1,am=1}}}, //flint,
			//6
			{s=22,dur=8,ico=22,cost={{t=1,am=1},{t=2,am=1},{t=5,am=1}},name="campfire",t=3},//firewood
			{ico=30}, //ui item, equip item
			{ico=31}, //ui item, destory item
			{s=23,dur=5,ico=23,name="torch",t=3,cost={{t=1,am=1},{t=3,am=1}}},
			{s=65,dur =10, ico=37,name="snowball", t=5},//wall, placeable
			//11
			{s=33,dur=1,ico=33,name="raw meat",t=4,cost={{t=1,am=1}}},
			{ico=5},//ui item, eat
			{ico=5,dur=1,name="cooked meat",cost={{t=11,am=1}},t=4},
			{ico=42,name="start"}, //ui item, start
			{ico=43,name="compass"}, //ui for compass
			//16
			{ico=34,name="fur",t=1,cost={{t=1,am=1}}}, //fur
			{ico=35,name="tent",s=35,dur=15,cost={{t=16,am=2},{t=1,am=2},{t=5,am=1}},t=3},
			{ico=46},//throw ui element
			{s=38,ico=38,name="log bundle",t=3,cost={{t=1,am=3}},dur=5},
			//20
			{s=39,ico=39,name="signal fire",t=3,cost={{t=19,am=1},{t=3,am=2},{t=2,am=3}},dur=1000 },//signal fire
			{s=49,ico=49,name="ghost totem",t=3,cost={{t=16,am=2},{t=5,am=2},{t=11,am=1}},dur=10}
}

//item t reference
res_interact = {
	
	{8},//static item 1
	{7,8},//tool/weapon 2
	{7,8}, //placeable item 3
	{12,8},//consumable 4
	{18,8} //throwable 5
}

function add_res(x,y,ty)
	//x,y,type,durabiliyt
	r = {x=x,y=y,t=ty,dur=res_types[ty].dur}
	add(res, r)
end


function upd_res()
	
	for r in all(res) do
		
		if r.dur <= 0 then
			del(res, r)
			sfx(1)
		end
		
		
	end
	
	
end

function draw_res()
	
	light_campfires()
	
	for r in all(res) do
		
		ref = res_types[r.t]
		
		spr(ref.s, r.x, r.y)		
		
	end
end

//this shit could be removed
//bc of the new get_closest func
function closest_res(x,y)
	
	re = false//dummy return
	
	d =  50
	
	for r in all(res) do
		
		calc_d = dist(x,y,r.x,r.y)
		
		if calc_d < d then
			d = calc_d
			re = r
		end
		
	end
	

	
	return re
end




function light_campfires()
	
	index = get_all(res,6)
	
	for r in all(index) do
		
		fire(r.x+4,r.y)
		
	end
	
	index = get_all(res,9)
	
	for r in all(index) do
		
		fire(r.x+4,r.y)
		
	end
	
	index = get_all(res,20)
	
	for r in all(index) do
		
		if time() % .25 == 0 then
			smoke(r.x,r.y)
		end
		
		fire(r.x,r.y)
	end
	
end

-->8
--ui

--go into a ui loop :/

function hud()
	
	//heath bar
	v = pl.hp
	mod = v/10
	
	rectfill(camx,camy,camx+30,camy+5,2)
	rectfill(camx+1,camy+1,(29*mod)+camx,camy+4,8)
	spr(14,camx-1,camy-1)	
	
	//warmth
	
	w_color = 8
	
	if pl.warmth < 70 then
		w_color = 9
	end
	
	if pl.warmth < 50 then
		w_color = 12
	end
	
	mod1 = pl.warmth/100
	shift = 40
	rectfill(camx+shift,camy,camx+30+shift,camy+5,2)
	rectfill(camx+1+shift,camy+1,(29*mod1)+camx+shift,camy+4,w_color)
	spr(6,camx-5+shift,camy-1)	
	
	//hunger?
	
	//inventory
	rectfill(108+camx,2+camy,123+camx,10+camy,3)
	spr(41,115+camx,2+camy)
	print("x", 110+camx,4+camy,7)
	
end

function draw_nodes(do_rect)
	
	
	
	for n in all(nodes) do
		
		if do_rect then
		//outer rect
			rectfill(n.x,n.y,n.x+10,n.y+10, 9)
			
			--inner rect
			rectfill(n.x+1,n.y+1,n.x+9,n.y+9, 0)
		end
		--
		spr(res_types[n.v].ico,n.x+1,n.y+1)

	end
	
	
end




cx,cy = 0,0
cvx,cvy = 0,0

function draw_cursor()

	if #nodes == 0 then
		return
	end

	cvx = nodes[node].x - cx
	cvy = nodes[node].y - cy

	spd = .2

	cx += cvx*spd
	cy += cvy*spd

	spr(15,cx+2, cy+1)
end

function cursor_jitter()
	
	cx = cx + rnd(10)-7
	cy = cy + rnd(10)-7
	
end

function draw_back_arrow()
	rectfill(108+camx,2+camy,123+camx,10+camy,3)
	spr(44,115+camx,2+camy)
	print("x", 110+camx,4+camy,7)
end

function draw_menu()
	
	rectfill(-10+camx,0+camy,128+camx,128+camy,0)
	
	print("--paused--", 11+34+camx,11+camy,7)
	
	draw_back_arrow()
	
	if menu_mode == 0 then
		if #nodes == 0 then
			print("you have no items",32+camx,19+camy,7)
		end
			
			print("press up arrow to craft",22+camx,27+camy,7)
			print("press z to use items",24+camx,35+camy,7)		
	end
	
	if menu_mode == 1 then
		draw_crafting()
	end
	
	if menu_mode == 2 then
		draw_item_sub(sub_menu_item)
	end
	
	draw_nodes(true)
	draw_cursor()
	
	
	
					
end

menu_mode = 10
menu_debuff = true

node = 1
node_height=0
nodes = {}

//item being used in submenu
sub_menu_item = -1

//determine logic for moving 
//and selecting
function get_menu_input()
		
		cursor_input()
		
		if menu_mode == 0 then
			if btnp(❎) and not switch_buff  then
				
				gamemode_0()
				
			end
			
			if btnp(🅾️) then
				
				if #inv ==0 then
					return
				end
				
				sub_menu_item = nodes[node].v
				node = 1
				menu_mode = 2
				menu_debuff = false
				
			end
		end
		
		//crafting
		if menu_mode == 1 then
			
			if btnp(❎) then
				menu_reset()
			end
			
			//craft check
			if btnp(🅾️) then
			
				item = res_types[nodes[node].v]
				
				if has_materials(item) then				
					sfx(4)
					pay_craft_cost(item)	
					add_inv(nodes[node].v)
				else
					sfx(0)
					cursor_jitter()
				end			
			end
					
		end
		
		//item sub menu
		if menu_mode == 2 then
			
			if btnp(❎) then
				menu_reset()
			end
			
			if btnp(🅾️) and menu_debuff
			 then
				
				//equip
				if nodes[node].v == 7 then
					equip(sub_menu_item)
					gamemode_0()
				end
				
				if nodes[node].v == 8 then
					rm_inv(sub_menu_item)
					menu_reset()
					return
				end
				
				if nodes[node].v == 12 then
					rm_inv(sub_menu_item)
					pl.hp += 2
					menu_reset()
					return
				end
				
				if nodes[node].v == 18 then
					equip(sub_menu_item)
					gamemode_0()
				end
				
			end
			
		end
		
		

	menu_debuff = true
	
end

function cursor_input()

	if btnp(➡️) then 
			upd_node(1)
		end 
		
		if btnp(⬅️) then
			upd_node(-1)
		end
		
		if btnp(⬇️) then
			upd_node(node_height)
		end
		
		if btnp(⬆️) then
		 if not upd_node(-node_height)
		 	and menu_mode == 0 then
		 		craftable()
		 		menu_mode = 1
		 		node = 1
   end
		end
		
end

function upd_node(val)
	
	len = #nodes
	
	if node + val < 1 or node + val
		> len then
			
			return false
	end
		
	node += val		
	return true

end

function menu_reset()
	node = 1
	menu_mode = 0
	cx,cy = -10+camx,99+camy
	cvx,cvy = 0,0
 nodes = choice_menu(1,99,9,2,inv)
end


function draw_crafting()

	nodes = choice_menu(15,64,5,2,craft)
	
	node_id = nodes[node].v
	item = res_types[node_id]
	
	//item rect
	rect(15+camx,20+camy,113+camx,60+camy,7)
	print(item.name,17+camx,22+camy,7)
	print("cost:",17+camx,28+camy,7)	
	
	
	//prints cost
	c = 1
	for i in all(item.cost) do
		for am = 1,i.am do
			spr(res_types[i.t].ico
			,26+c*10+camx,26+camy)
			c += 1
		end
		
	end
	
end


--ui choice menu test code

--[[creates an array of nodes to 
navigated with a node_chooser.

x and y is positon
row and col are amount of itmes
 per colmn or row
data is the array that is displayed

returns an array to be used 
by a ui_display and node_chooser

--]]
function choice_menu(x,y,row,col,data)		
	
	node_height = row

	gap = 14
	y_gap = 15 //19

	nodelist = {}
	
	xmod = 0 //sets the x offset
	ymod = 0 //per indivudal node
	
	for d in all(data) do
		
		_x = x + (gap * xmod) + camx
		_y = y + (y_gap * ymod) + camy
		
		add(nodelist, {x=_x,y=_y,v=d})
		
		xmod += 1
		if xmod > row-1 then
			xmod = 0
			ymod += 1
			
			if ymod > col-1 then
				break
			end
		end
		
	end	
	
	return nodelist
	
end

//submenu for interacting
//with single items
function draw_item_sub(item)
	
	x = camx+20
	y = camy+20
	
	i = res_types[item]

	list_ui = res_interact[i.t]
	
	rectfill(x,y,x+60,y+60,0)
	rect(x,y,60+x,60+y,7)
	
	nodes = choice_menu(25,35,1,4,list_ui)
	
	if has(list_ui,7) then
		
		local n = find(list_ui,7)
	
  print("equip",nodes[n].x+15,nodes[n].y+2,7)
	end
	
	if has(list_ui,8) then
		
		local n = find(list_ui,8)
	
  print("destory",nodes[n].x+15,nodes[n].y+2,7)
	end
	
	if has(list_ui,12) then
		local n = find(list_ui,12)
	
  print("eat",nodes[n].x+15,nodes[n].y+2,7)
	end
	
	if has(list_ui,18) then
		local n = find(list_ui,18)
	
  print("throw",nodes[n].x+15,nodes[n].y+2,7)
	end

--	print("destory",nodes[2].x+15,nodes[2].y+2,7)

	print(i.name, x+2,y+2,7)

	
end




-->8
--crafting

//takes numbers from res array
//which are specifically for
//crafting

all_craft = {4,3,6,9,10,13,17,19} 
craft = {}


function has_materials(item)
	
	for c in all(item.cost) do
		
		pl_am = #get_all_inv(c.t)
		
		if pl_am < c.am then
			return false
		end
		
	end
	
	return true
	
end

function pay_craft_cost(item)
	for c in all(item.cost) do
		
		for i = 1, c.am do
			rm_inv(c.t)
		end
		
	end
end

function craftable()
	
	craft = {2,4,6,17,19, 20,21} //
	
	if pl.closest_obj.name == "campfire"
		then
			add(craft, 13) //cooked meat
			add(craft,3) //charcoal
			add(craft,9) //torch
		end
	
end


-->8
--world gen


--player random spawn
--random resource and 
--item placement

snow_level = 0


function world_border()
	//chill player if they go past
	if pl.x < 0 or pl.x > 1024
		or pl.y < 0 or pl.y > 512 then
			
			if snow_level == 0 then
				msg("you're freezing!",3)
			end
			
			snow_level = 10
			pl.warmth -= 1
			
			if time() % .25 == 0 then
				sfx(7)
			end
			
		
		else
		
			snow_level = 0

		end

end

function draw_world_border()
	
	rectfill(-128,-128, 1124,612,13)
	
end


function world_init(player_spawn)
	
	if player_spawn then
	
	pl.x = rnd(1024)
	pl.y = rnd(512)
	
	end
	
	for x = 0, 128,4 do
	
		for y = 0, 64,4 do
			
			c = flr(rnd(100))
			
			jitter = rnd(32)
			
			if c > 90 then
				add_res(x*8+jitter, y*8+jitter, 1)
				
			elseif c > 85 then
				add_res(x*8+jitter, y*8+jitter, 2)
			
			elseif c > 80 then
				add_res(x*8+jitter, y*8+jitter, 5)
				
			end
			
			
		end
	end
	
end

function rnd_mobs()
	
	if hour < 14 then
		
		if time() % 15 == 0 then
			
			add_mob(2,pl.x + rnd(256)-128,pl.y + rnd(256)-128)		
		end
		
		if time() % 20 == 0 then
			add_mob(1,pl.x + rnd(256)-128,pl.y + rnd(256)-128)			
		end
		
	end
	
	
end
-->8
--mobs

mobs = {}

all_mobs = {

//yeti
{hp=3,s=11,brain=0,dmg=2,drops={16}},

//goat
{hp=2,s=27,brain=1,dmg=0,drops={11}}	
,

//blood bird
{hp = 2,s=10, brain=1,dmg=1,drops={11}},

//bullet
{hp = 1,s=37,brain=3,dmg=2,drops={}}

}

function add_mob(_t,_x,_y)
	
	_mob = all_mobs[_t]
	
	
	add(mobs,{x=_x,
											y=_y,
											t=_t,
											hp=_mob.hp,
											dmg=_mob.dmg})
	
	if #mobs > 15 then
		del(mobs, mobs[1])
	end
	
end

function draw_mobs()
	
	for m in all(mobs) do
		
		mob = all_mobs[m.t]
		
		spr(mob.s,m.x,m.y)
--		print(m.hp, m.x,m.y,8)
		
	end
	
	
end

function mob_upd()
	
	for m in all(mobs) do
		
		mob = all_mobs[m.t]
		
		if m.hp <= 0 then
			del(mobs, m)
		end
		
	
		
		if mob.brain == 0 then
				brain_0(m)
		end 
		
		if mob.brain == 1 then
			brain_1(m)
		end
		
		if mob.brain == 3 then
			brain_3(m)
		end
		
	end //for loop
	
end //function




function brain_0(m)
			
			
				if	not	mob_chase(m,pl, 40) then
					mob_closest_res(m)
				end
		
	
end

function brain_1(m)
	
	if not flee_player(m) then
		mob_closest_res(m)	
	end
	
	mob_wander(m)
	
end

function brain_3(m)
--	m.x += m.vx
--	m.y += m.vy

close = get_closest(mobs,m.x,m.y)

if close != false then
	mob_chase(m,close,100)
end	
	
end


//general mob functions

function mob_closest_res(m)
	//chase res and destroy
				r = closest_res(m.x,m.y)
				if r != false then
					
						if dist(m.x,m.y,r.x,r.y) < 10 then
							
							r.dur -= .06
							if time() % .5 == 0 then
								for i = 1, rnd(5)+7 do		
									rot = rnd(.5)	
									add_part(r.x+4,r.y+4,cos(rot),-sin(rot),5,.3)
								end
							end
							
							return true
							
						else
					
							m.x = m.x + (r.x -m.x)*.05
							m.y = m.y + (r.y-m.y)*.05
							
							return true
							
						end //move to res
				end
		
			return false
		
end


function mob_chase(m, target, fov)
//chase player
			p_dist = dist(m.x,m.y,target.x,target.y)
	
			if p_dist < fov then
				
					m.x = m.x + (target.x-m.x)*.04
					m.y = m.y + (target.y-m.y)*.04
				
					if p_dist < 10 then
						attack(m,target)
					end
						
					return true					
					
			end

			return false

end


function flee_player(m)
	p_dist = dist(m.x,m.y,pl.x,pl.y)
	
	if p_dist < 20 then
		
		m.x = m.x + -(pl.x -m.x)*.02
		m.y = m.y + -(pl.y-m.y)*.02
		
		return true
	
	end
	
	return false
	
end


//make this not as shitty
function mob_wander(m)
	m.x = m.x + rnd(1)
	m.y = m.y + rnd(1)
end

//takes two mobs/mob and player
//as input, checks if there's 
//a hit and assigns damage
function attack(m1,m2)
	
	if dist(m1.x,m1.y,m2.x,m2.y)
		<= 15 then
		
			
			
			m2.hp -= m1.dmg
			
			blood(m2.x,m2.y)
			sfx(5)
			
			ang = atan2(m2.x-m1.x,m2.y-m1.y)
			
			m2.x += cos(ang) * 15
			m2.y += sin(ang) * 15
			
			m1.x += -cos(ang) * 10
			m1.y += -sin(ang) * 10
			
		end
		
		if m2.hp <= 0 then
			return true
		end
	
		return false
	
end

-->8
--day night cycle


is_day = true
hour = 0 //resets after 23
day = 0

sec_per_hour = 10


function adv_hour()
	
	hour += 1
	if hour > 23 then
		next_day()
	end
	
end

function next_day()
		hour = 0
		day += 1
		msg("it's a new day!",2)
end

function time_color()
	
	pal()
	
	if hour > 7 then
		pal(6,13)
	end
	
	if hour > 10 then
		pal(6,2)
	end
	
	if hour > 14 then
		pal(6,1)
	end
	
end
-->8
--start and end screens

screen_debuff = true

//gamemode 2
function start_screen()
	
	rectfill(0,0,128,128,13)
	
	for i = 0,16 do
		
		add_part(0 + (i*8),128,rnd(1),rnd(1)*-1,flr(rnd(4))+7,1)
		
		add_part(0 + (i),rnd(10),rnd(2),rnd(1)/2,7,3)
		
	end

	
	
	draw_part()
	
	print("icy monkey",43,63,1)	
	print("icy monkey",44,64,7)
	
	
	nodes = choice_menu(43,70,1,2,{14,15})		

	print("play",nodes[1].x + 12,nodes[1].y+3,7)
	print("help",nodes[2].x + 12,nodes[2].y+3,7)
	
	get_menu_input()
	draw_nodes()
	draw_cursor()
	
	if btnp(🅾️) then
		
		if node == 1 then
			reset_game()
			world_init(true)
			gamemode = 0
		--	msg("oh shit! here comes the ghost!",3)
		end
		
		if node == 2 then
			gamemode = 3
		end
		
		clear_part()
		
		screen_debuff = false
		
	end
	
	
end

//gamemode 3

help_text = "you are stranded in the frozen tundra!"

function help_screen()
	rectfill(0,0,128,128,13)
	
	print("press z to use/attack/harvest",5,10,7)
	print("press x to open inventory",5,16,7)	
	print("use arrow keys to move",5,22,7)
	
	//collect
	rect(5,35,40,75,3)
	print("collect",9,37,7)
	spr(74,7,45)
	spr(75,7,53)
	spr(76,7,62)
	print("wood",17,47)
	print("stone",17,55)
	print("flint",17,63)
	
	//avoid
	rect(45,35,90,75,8)
	print("avoid",53,37,7)
	spr(11,47,45)
	add_part(52,55,rnd(2)-1,1,7,.2)
	
	add_part(52,70,
										(rnd(2)-1)*.2,-.2,
										flr(rnd(3)),.5)
	print("yeti",57,46,7)
	print("freezing",57,56,7)
	print("ghosts",57,66,7)	
	
	//craft
	
	
	if btnp(🅾️) and screen_debuff then
		gamemode = 2
	end

	print("craft 3 signal fires to survive!",0,90,7)
	
	for i = 0,2 do
		
		spr(39, 45+(16*i),100)
		
	end
	
	//
	print("press z to return to menu",16,120,7)
	
	screen_debuff = true
	
end

//gamemode 4
function death_screen()
	
	
 rectfill(camx,camy,camx+128,camy+128,0)
	
	print("you h*cking died!",((128 - 16*4)/2)+camx,40+camy,7)
	
	if #msg_queue == 0 then
		
	 reset_game()
	 gamemode = 2
		
	end
	
end

//gamemode 5
function startup_screen()
	
	rectfill(0,0,128,128,0)
	
	
	
	if #msg_queue == 0 then
		gamemode = 2
		sfx(2)
	end
	
	
end

//gamemode 6
eg = {x=63,y=80}
function victory_screen()

	if time() % 2.5 == 0 then
		sfx(14)
	end

	camera(0,0)
	camx = 0
	camy = 0
	
	rectfill(0,0,128,128,12)
	
	spr(87,63,eg.y,2,2)
	
	line(eg.x,eg.y+10,eg.x,eg.y+10+cos(time()*5)*4,7)
	
	eg.y += sin(time())
	
	add_part(eg.x+15,eg.y+8,1,-1,13,2)
	
	for i = 0,5 do
		add_part(0,rnd(128),1,rnd(2)-1,7,5)
	end

	if #msg_queue == 0 then
		gamemode = 2
		clear_part()
	end

end

function win_game()
	clear_part()
	gamemode = 6
	msg("you survived!",5)
	msg("thanks for playing!",5)
end

-->8
--messaging system

msg_text = ""

msg_queue = {}

msg_time_offset = 0

function msg(text, dur)
	
	data = {text=text,dur=time()+dur+msg_time_offset}
	
	add(msg_queue,data)
	
	msg_time_offset += dur
	
end

msg_x = 0
msg_y = 0
msg_time = 0
do_msg = false
function draw_msg()
	
	if #msg_queue > 0 then
		msg_text = msg_queue[1].text
		do_msg = true
	end
	
	
--	print(msg_text,msg_x-.5,msg_y-.5,0)
	print(msg_text,msg_x,msg_y,2)
	
	if do_msg then
	
		msg_y += (camy+63-msg_y)*.1
		
		msg_x = (128 - (#msg_text * 4))/2 + camx
		
		if time() > msg_queue[1].dur then
			
			msg_y += (152+camy-msg_y)*.2
	
			if msg_y > 120+camy then
				msg_x = camx
				msg_y = camy
				del(msg_queue,msg_queue[1])
			end
				
			if #msg_queue < 1 then
				do_msg = false
				msg_time_offset = 0
				msg_text = ""
			end
			
		end
	
	else
	
		
	
	end
	
end
-->8
--the ghost of the wastes


ghost = {x=63,y=63,spd=.4,ang=0}

function draw_ghost()
	
	if dist(pl.x,pl.y,ghost.x,ghost.y) < 35
		then
		
			if time() % 1 == 0 then
				sfx(13)
			end			
			
		end 
	
	freeze_player()
	
	add_part(ghost.x,ghost.y,
										(rnd(2)-1)*.2,-.2,
										flr(rnd(3)),3)
	
	
	ghost.x += cos(ghost.ang) * ghost.spd
	ghost.y += sin(ghost.ang) * ghost.spd
	
	
			if dist(pl.x,pl.y,ghost.x,ghost.y) < 30 then
				ghost.ang = atan2(pl.x-ghost.x,pl.y-ghost.y)
			else
				if time() % 2 == 0 then			
					if rnd(10) > 5 then
						ghost.ang = rnd(1)
				 else
				 	ghost.ang = atan2(pl.x-ghost.x,pl.y-ghost.y)
				 end			
				end
			end

	
 //totems
		totems = get_all(res, 21)
		if #totems <= 0 then
			return
		end
		target = get_closest(totems,ghost.x,ghost.y)
		
		ghost.ang = atan2(target.x-ghost.x,target.y-ghost.y)
		
		if dist(ghost.x,ghost.y,
										target.x,target.y)
										< 15 then
											del(res, target)
										end
		


end


function freeze_player()
	
	d = dist(pl.x,pl.y,ghost.x,ghost.y)
	
	if d
		< 10 then
			
			if time() % .5 == 0 then
				pl.warmth -= 10
			end
		
			
		end
	
end

function ghost_totems()
	if #get_all(res, 21) > 0 then
		return true
	end
	
	return false

end
-->8
--plane and signal fires

function has_enough_fires()

 fires = get_all(res, 20)
 
 if #fires == 3 then
 	win_game()
 end
 
end


__gfx__
00000000000000000000000000177700000000000000240000028e00000000000000000000000000000000000077d0000077d0000077d0000001100077000077
000000000017770000177700017fff70001777000002ee4002888e000000000000000000000000000008200007cc7d0007cc7d0007cc7d000018810070000007
00700700017fff70017fff70017fff70017fff700002e7400298800000000000000000000000000000aa800000ccc70000ccc70000ccc7000118811000000000
00077000017fff70017fff70017efe70017fff7000244e40029988e00000000000077700000000000aaa800000c1c70000ccc70000c1c7001888878100000000
00077000017efe70017efe7000177700017efe700024440002aa98e000000000005777000000000000088820007777d0007777d0007777d01888788100000000
00700700001777000017770022111100001777000774400002aa98e0000000000055000000000000000888200e7777e00e7777e00e7777e00118811000000000
000000000011110000111220000002200211110077700000002aa8000000000000000000000000000000880000777d0000777670067777700018810070000007
00000000002202200220000000000000022022000700000000028e000000000000000000000000000000aa000670067006700000000006700001100077000077
00000000000000000000000000000100000000150000000000000000000400000000000000000000000000000000000000010001000000000000000000777700
0000000000005440000111000001121000001556000017700000000000484000000000000000000090009009000a00a000111401000000000077777007888870
0000000000054444000116d00012277100005550000155700024440000494000000000000000000099009999000a966a000100110000000007f5f5f778000887
0000000000544444001166d00122227100044f6000155d00024442200048400000000000000000000999999000006666444114410000000007fffff778008087
0000000005fff44401166d00012222210044f00000155d0024442542000400000000000000000000099999550677766604444444000000007555fff778080087
0000000005f9f4400166dd0001222221044f00000155d0004f4254f4000400000000000000000000099999550677766604444444000000007fff5ff778800087
0000000005fff40000dd00000012221144f0000001dd0000442505440002000000000000000000000990990006777700040040040000000007ffff7007888870
000000000044400000000000000111004f00000000000000000000000002000000000000000000000a000a000505050004004404000000000077770000777700
0000000000002e000000000000000000000000550000000000000000000000000000000000000000000000000005550000000000000000000000000000000000
002ee8000002eee000776000000000000000055600000000000000000040000000000000004444003777700000566650000e0000000000000007770000000000
02eeee800002e7e007e7760000544f0000005560001670000022fd0000242000000000000549a4403bbbb7700561116500e80000000000000078887000000000
02eeee80002eeee007eee7700544f2f0055556000177c7000044af0000244000000000000119a1103bbbbbb7051118150e888888000000000787778700000000
2e1111e8002eee0007eee7700544f2f000d56000017c7700022222af0040240000000000011111103bbbbbb10511811508888888000000000787878700000000
21111118077ee00007ee7760544f222f0d44000001777700244fa4fd0042440000000000054444403bbbb1100651115602882222000000000787778700000000
000000007770000006776600544f222fd440000000666000244fd000056426500000000005444440111110000065556000280000000000000078887000000000
00000000070000000000000000000000d44000000000000000000000055665500000000005444440000000000006660000020000000000000007770000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000067ee700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006eee700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000016777750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000015015550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666000000000000000000000000666666668888888800000000000000000000000000000000000400000000000000000000000000000000000000000000
66666666008888000000000000000000666666668888888800000000000000000000000000000000000405400011700000000000000000000000000000000000
66666666008888000000000000000000666666668888888800000000000000000000000000000000040444400015570000000000000000000000000000000000
6c666666088888800000000000000000666666664444448800000000000000000004440000000000004400000015557000017000000000000000000000000000
66c6666600777700000000000000000066666666444444880000000000000000004444440000000000054440015555d00011d700000000000000000000000000
666666c60777977000000000000000006666666688448888000000000000000004f444f40000000054444454015555d0001ddd70000000000000000000000000
66666c6607777770000000000000000066666666884488880000000000000000044004400000000005054000015555d0001ddd10000000000000000000000000
6666666600777700000000000000000066666666884488880000000000000000000000000000000000054000015555d001dddd10000000000000000000000000
66666666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000001dd1110000000000000000000000000
66666666666666666666666666666666000000000000000000000000000008888800000000000000000000000000000000000000000000000000000000000000
66666615516666666666666655556666000000000000000000000000000088888880000000000000000000000000000000000000000000000000000000000000
6661511551151666666666557777dd66000000000000000000000000000088888880000000000000000000000000000000000000000000000000000000000000
66115115551511666666665777777d66000000000000000000000000000060000600008000000000000000000000000000000000000000000000000000000000
661155155515116666666577777777d6000000000000000000000000000060000600088000000000000000000000000000000000000000000000000000000000
661555155555516666666000770007d6000000000000000000000000000060000600288000000000000000000000000000000000000000000000000000000000
661550000005516666666000770007d0000000000000000000000000002268000682220000000000000000000000000000000000000000000000000000000000
661000000000016666665700770077d0000000000000000000000000022262888622888000000000000000000000000000000000000000000000000000000000
66600000000006666666577777777d00000000000000000000000000022262222622888000000000000000000000000000000000000000000000000000000000
6666600000000666666657777777dd00000000000000000000000000002288888822220000000000000000000000000000000000000000000000000000000000
666666000000666666650707070d0000000000000000000000000000000888888802200000000000000000000000000000000000000000000000000000000000
6666666666666666666507070dd00000000000000000000000000000000088888000000000000000000000000000000000000000000000000000000000000000
666666666666666666665d0dd0000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666000000666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666600006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000707007707070000070707770077070707770770007700000770077707770770007000000000000000000000000000000
00000000000000000000000000000000707070707070000070707000700070700700707070000000707007007000707007000000000000000000000000000000
00000000000000000000000000000000777070707070000077707700700077000700707070000000707007007700707007000000000000000000000000000000
00000000000000000000000000000000007070707070000070707000700070700700707070700000707007007000707000000000000000000000000000000000
00000000000000000000000000000000777077000770000070707770077070707770707077700000777077707770777007000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000200000000000000000000010101010000000000000000000000000101010100000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040525340404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040626340404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040505140404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040606140404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
__sfx__
00010000326203463037640396403a6503a6503a650396403963038630366303663034620316202e6102b61027610256102e6002d6002d6002d6002a000346003360033600336000000000000000000000000000
000100003075031750337303473035740357403574034720337103370000000000000000000000000000000000000000003f7003b700397003870000000000000000000000000000000000000000000000000000
901600200d6510d6510d6510f6410f641106311063110621106310f6410c6410c6510c6510d6510d6510d6510c6510c6510c65109661086710867108671096710b6710c6610d6710d6710d6610d6410d6310e651
001e00003161032630326403264033640346303563035630346403464034630346303464034640346303463033650326603267032660336503364033630326303264032630326403265032650336503365000000
000200002e330313403235035360363703736037350373403833039330393403230031300303003030030300303003030030300313003130033300343003630037300393003a3003c3003d3003d3003e3003b300
0001000036150361503715037150381503a1503a14039140361403512032110291100010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
0010000000000190501c0502105027050000002d0503105034050380503905038050370503505033050310502f0502f0502f05031050370500000000000000000000000000000000000000000000000000000000
000100003d3503c3503c3503c3503c3503b3503b3503b3503a3503a3503935038350373503435033350303502f35029350283502835027350263502435022350203501e3501d3501a35018350173501635000000
53080000286472a64729637286572c6772967727667286372a637196471b6471b64718677176671c637216572465724657206571f657236573265733657216571e6571765716657176571b6571c6572265700607
011400002315023150221502215020150201501e1501e15020150201501b1501b1501d1501d1501d1501d1501915019150191501915014150141501615016150171501715019150191501e1501e1501b1501b150
010a00001a0601a0601a0601a0601e0601e0601e0601e0601c0601c0601c0601c0601f0601f0601f0601f06026060260602606026060260602606026060260600000000000000000000000000000002506025060
010a00000e0600e0600e0600e0601206012060120601206010060100601006010060130601306013060130601a0601a0601a0601a0601a0601a0601a0601a0600000000000000000000000000000000000000000
010a00000e6630e66300000000000e6630e66300000000000e6630e66300000000000e6630e6630e6630e66300000000000000000000000000000000000000000000000000000000000000000000000e6630e663
010400001031210332103421035210362103621036210362103521034210322103121032210322103121032210332103421034210342103421033210312103121031210322103421036210372103621036210362
9f0a00200022000220002200022000220002200022000220002200022000220002200022000220002200022000220002200022000220002200022000220002200022000220002200022000220002200022000220
000100001e6101f6102061021610226202462025630286402a6502f6503166034660376703b6503c6500060000600006000060000600006000060000600006000060000600006000060000600006000060000600
__music__
00 0a0b0c44

