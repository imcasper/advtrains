--trackplacer.lua
--holds code for the track-placing system. the default 'track' item will be a craftitem that places rails as needed. this will neither place or change switches nor place vertical rails.

local print=function(t, ...) minetest.log("action", table.concat({t, ...}, " ")) minetest.chat_send_all(table.concat({t, ...}, " ")) end

--keys:conn1_conn2 (example:1_4)
--values:{name=x, param2=x}
advtrains.trackplacer_dir_to_node_mapping={}
--keys are nodenames!
advtrains.trackplacer_modified_rails={}

function advtrains.trackplacer_register(nodename, conn1, conn2)
	for i=0,3 do
		advtrains.trackplacer_dir_to_node_mapping[((conn1+2*i)%8).."_"..((conn2+2*i)%8)]={name=nodename, param2=i}
		advtrains.trackplacer_dir_to_node_mapping[((conn2+2*i)%8).."_"..((conn1+2*i)%8)]={name=nodename, param2=i}
	end
	advtrains.trackplacer_modified_rails[nodename]=true
end
function advtrains.find_adjacent_tracks(pos)--TODO vertical calculations(check node below)
	local conn1=0
	while conn1<16 and not advtrains.is_track_and_drives_on(minetest.get_node(advtrains.dirCoordSet(pos, conn1)).name, advtrains.all_tracktypes) do
		conn1=conn1+1
	end
	if conn1>=16 then
		return nil, nil
	end
	local conn2=0
	while conn2<16 and not advtrains.is_track_and_drives_on(minetest.get_node(advtrains.dirCoordSet(pos, conn2)).name, advtrains.all_tracktypes) or conn2==conn1 do
		conn2=conn2+1
	end
	if conn2>=16 then
		return conn1, nil
	end
	return conn1, conn2
end

local modext={[0]="", "_30", "_45", "_60"}

function advtrains.placetrack(pos, nnpref)
	local conn1, conn2=advtrains.find_adjacent_tracks(pos)
	
	if not conn1 and not conn2 then
		minetest.set_node(pos, {name=nnpref.."_st"})
	elseif conn1 and not conn2 then
		local node1=minetest.get_node(advtrains.dirCoordSet(pos, conn1))
		local node1_conn1, node1_conn2=advtrains.get_track_connections(node1.name, node1.param2)
		local node1_backconnects=(conn1+8)%16==node1_conn1 or (conn1+8)%16==node1_conn2
		
		if not node1_backconnects and advtrains.trackplacer_modified_rails[node1.name] then
			--check if this rail has a dangling connection
			--TODO possible problems on |- situation
			if not advtrains.is_track_and_drives_on(minetest.get_node(advtrains.dirCoordSet(pos, node1_conn1)).name, advtrains.all_tracktypes) then
				if advtrains.trackplacer_dir_to_node_mapping[node1_conn1.."_"..((conn1+8)%16)] then
					minetest.set_node(advtrains.dirCoordSet(pos, conn1), advtrains.trackplacer_dir_to_node_mapping[node1_conn1.."_"..((conn1+8)%16)])
				end
			elseif not advtrains.is_track_and_drives_on(minetest.get_node(advtrains.dirCoordSet(pos, node1_conn2)).name, advtrains.all_tracktypes) then
				if advtrains.trackplacer_dir_to_node_mapping[node1_conn2.."_"..((conn1+8)%16)] then
					minetest.set_node(advtrains.dirCoordSet(pos, conn1), advtrains.trackplacer_dir_to_node_mapping[node1_conn2.."_"..((conn1+8)%16)])
				end
			end
		end
		--second end will be free. place standard rail
		local modulo=conn1%4
		minetest.set_node(pos, {name=nnpref.."_st"..modext[modulo], param2=(conn1-modulo)/4})

	elseif conn1 and conn2 then
		if not advtrains.trackplacer_dir_to_node_mapping[conn1.."_"..conn2] then
			minetest.set_node(pos, {name=nnpref.."_st"})
			return
		end
		local node1=minetest.get_node(advtrains.dirCoordSet(pos, conn1))
		local node1_conn1, node1_conn2=advtrains.get_track_connections(node1.name, node1.param2)
		local node1_backconnects=(conn1+8)%16==node1_conn1 or (conn1+8)%16==node1_conn2
		if not node1_backconnects and advtrains.trackplacer_modified_rails[node1.name] then
			--check if this rail has a dangling connection
			--TODO possible problems on |- situation
			if not advtrains.is_track_and_drives_on(minetest.get_node(advtrains.dirCoordSet(pos, node1_conn1)).name, advtrains.all_tracktypes) then
				if advtrains.trackplacer_dir_to_node_mapping[node1_conn1.."_"..((conn1+8)%16)] then
					minetest.set_node(advtrains.dirCoordSet(pos, conn1), advtrains.trackplacer_dir_to_node_mapping[node1_conn1.."_"..((conn1+8)%16)])
				end
			elseif not advtrains.is_track_and_drives_on(minetest.get_node(advtrains.dirCoordSet(pos, node1_conn2)).name, advtrains.all_tracktypes) then
				if advtrains.trackplacer_dir_to_node_mapping[node1_conn2.."_"..((conn1+8)%16)] then
					minetest.set_node(advtrains.dirCoordSet(pos, conn1), advtrains.trackplacer_dir_to_node_mapping[node1_conn2.."_"..((conn1+8)%16)])
				end
			end
		end
		
		local node2=minetest.get_node(advtrains.dirCoordSet(pos, conn2))
		local node2_conn1, node2_conn2=advtrains.get_track_connections(node2.name, node2.param2)
		local node2_backconnects=(conn2+8)%16==node2_conn1 or (conn2+8)%16==node2_conn2
		if not node2_backconnects and advtrains.trackplacer_modified_rails[node2.name] then
			--check if this rail has a dangling connection
			--TODO possible problems on |- situation
			if not advtrains.is_track_and_drives_on(minetest.get_node(advtrains.dirCoordSet(pos, node2_conn1)).name, advtrains.all_tracktypes) then
				if advtrains.trackplacer_dir_to_node_mapping[node2_conn1.."_"..((conn2+8)%16)] then
					minetest.set_node(advtrains.dirCoordSet(pos, conn2), advtrains.trackplacer_dir_to_node_mapping[node2_conn1.."_"..((conn2+8)%16)])
				end
			elseif not advtrains.is_track_and_drives_on(minetest.get_node(advtrains.dirCoordSet(pos, node2_conn2)).name, advtrains.all_tracktypes) then
				if advtrains.trackplacer_dir_to_node_mapping[node2_conn2.."_"..((conn1+8)%16)] then
					minetest.set_node(advtrains.dirCoordSet(pos, conn2), advtrains.trackplacer_dir_to_node_mapping[node2_conn2.."_"..((conn2+8)%16)])
				end
			end
		end
		minetest.set_node(pos, advtrains.trackplacer_dir_to_node_mapping[conn1.."_"..conn2])
	end
end


advtrains.trackworker_cycle_nodes={
	["swr_cr"]="st",
	["swr_st"]="st",
	["st"]="cr",
	["cr"]="swl_st",
	["swl_cr"]="swr_cr",
	["swl_st"]="swr_st",
}

function advtrains.register_track_placer(nnprefix, imgprefix, dispname)
	minetest.register_craftitem(nnprefix.."_placer",{
		description = dispname,
		inventory_image = imgprefix.."_placer.png",
		wield_image = imgprefix.."_placer.png",
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type=="node" then
				local pos=pointed_thing.above
				if minetest.registered_nodes[minetest.get_node(pos).name] and minetest.registered_nodes[minetest.get_node(pos).name].buildable_to then
					advtrains.placetrack(pos, nnprefix)
					if not minetest.setting_getbool("creative_mode") then
						itemstack:take_item()
					end
				end
			end
			return itemstack
		end,
	})
end



minetest.register_craftitem("advtrains:trackworker",{
	description = "Track Worker Tool\n\nLeft-click: change rail type (straight/curve/switch)\nRight-click: rotate rail",
	groups = {cracky=1}, -- key=name, value=rating; rating=1..3.
	inventory_image = "advtrains_trackworker.png",
	wield_image = "advtrains_trackworker.png",
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type=="node" then
			local pos=pointed_thing.under
			local node=minetest.get_node(pos)
			
			if not advtrains.is_track_and_drives_on(minetest.get_node(pos).name, advtrains.all_tracktypes) then return end
			if advtrains.is_train_at_pos(pos) then return end
			local nodeprefix, railtype, rotation=string.match(node.name, "^([^_]+)_([^_]+)(_?.*)$")
			--print(node.name.."\npattern recognizes:"..nodeprefix.." / "..railtype.." / "..rotation)
			if not advtrains.trackworker_cycle_nodes[railtype] then
				print("[advtrains]rail not workable by trackworker")
				return
			end
			if rotation==modext[#modext] then --increase param2
				minetest.set_node(pos, {name=nodeprefix.."_"..railtype..modext[0], param2=(node.param2+1)%4})
				return
			else
				local modpos
				for k,v in pairs(modext) do if v==rotation then modpos=k end end
				if not modpos then
					print("[advtrains]rail not workable by trackworker")
					return
				end
				minetest.set_node(pos, {name=nodeprefix.."_"..railtype..modext[modpos+1], param2=node.param2})
			end
			advtrains.invalidate_all_paths()
		end
	end,
	on_use=function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" then
			local pos=pointed_thing.under
			local node=minetest.get_node(pos)
			
			if not advtrains.is_track_and_drives_on(minetest.get_node(pos).name, advtrains.all_tracktypes) then return end
			if advtrains.is_train_at_pos(pos) then return end
			local nodeprefix, railtype, rotation=string.match(node.name, "^([^_]+)_([^_]+)(_?.*)$")
			
			if not advtrains.trackworker_cycle_nodes[railtype] then
				print("[advtrains]trackworker does not know what to set here...")
				return
			end
			minetest.set_node(pos, {name=nodeprefix.."_"..advtrains.trackworker_cycle_nodes[railtype]..rotation, param2=node.param2})
			--invalidate trains
			advtrains.invalidate_all_paths()
		end
	end,
})
