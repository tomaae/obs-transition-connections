obs = obslua
default_transition_name = ""
curr_scene_name = ""
transition_map_s = {}
transition_map_t = {}
transition_map_r = {}
attempts = 0

----------------------------------------------------------

function find_source_by_name_in_list(source_list, name)
	for i, source in pairs(source_list) do
		source_name = obs.obs_source_get_name(source)
		if source_name == name then
			return source
		end
	end

	return nil
end

function table_count(t)
	local count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
end

function table_wipe(t)
	for k in pairs (t) do
		t[k] = nil
	end
	return t
end

-- Reset transition to default if needed
function transition_stoped(cd)
	if default_transition_name == "" then
		return
	end
	
	local ct = obs.obs_frontend_get_current_transition()
	local curr_transition = obs.obs_source_get_name(ct)
	obs.obs_source_release(ct)

	if curr_transition ~= default_transition_name then
		local transitions = obs.obs_frontend_get_transitions()
		local obj_transition = find_source_by_name_in_list(transitions, default_transition_name)
		if obj_transition ~= nil then
			obs.obs_frontend_set_current_transition(obj_transition)
		else
			obs.script_log(obs.LOG_WARNING, "Transition does not exists: " .. default_transition_name)
		end
		obs.source_list_release(transitions)
	end
end

-- Set current scene name
function source_deactivated(cd)
	local currentScene = obs.obs_frontend_get_current_scene()
	curr_scene_name = obs.obs_source_get_name(currentScene)
	obs.obs_source_release(currentScene)

	if default_transition_name == "" then
		return
	end
	transition_stoped()
end

-- Change transition if needed
function source_activated(cd)
	if default_transition_name == "" then
		return
	end

	local source = obs.calldata_source(cd, "source")
	if source ~= nil then
		local source_id = obs.obs_source_get_id(source)
		if source_id == "scene" then
			local next_scene_name = obs.obs_source_get_name(source)
			local set_transition = default_transition_name
			local i = 1
			for k in pairs (transition_map_s) do
				if curr_scene_name == transition_map_s[i] and next_scene_name == transition_map_t[i] and transition_map_r[i] ~= "" and transition_map_r[i] ~= "-----" then
					set_transition = transition_map_r[i]
					break
				end
				i = i + 1
			end

			if set_transition ~= default_transition_name then
				local transitions = obs.obs_frontend_get_transitions()
				local obj_transition = find_source_by_name_in_list(transitions, set_transition)
				if obj_transition ~= nil then
					obs.obs_frontend_set_current_transition(obj_transition)
					obs.obs_transition_start(obj_transition, obs.OBS_TRANSITION_MODE_AUTO, 300, source)
				else
					obs.script_log(obs.LOG_WARNING, "Transition does not exists: " .. set_transition)
				end
				obs.source_list_release(transitions)
			end
		end
	end
end

----------------------------------------------------------

-- A function named script_description returns the description shown to
-- the user
function script_description()
	return "Set up custom transitions between 2 scenes."
end

-- A function named script_properties defines the properties that the user
-- can change for the entire script module itself

function transition_add(props, p, set)
	if default_transition_name == "" then
		return
	end
	
	table.insert(transition_map_s,"")
	table.insert(transition_map_t,"")
	table.insert(transition_map_r,"")

	local s = obs.obs_properties_add_list(props, "source_" .. table_count(transition_map_s), table_count(transition_map_s) .. ". source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local t = obs.obs_properties_add_list(props, "target_" .. table_count(transition_map_s), table_count(transition_map_s) .. ". target", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	obs.obs_property_list_add_string(s, "-----", "-----")
	obs.obs_property_list_add_string(t, "-----", "-----")
	local scenes = obs.obs_frontend_get_scene_names()
	if scenes ~= nil then
		for _, scene in ipairs(scenes) do
			obs.obs_property_list_add_string(s, scene, scene)
			obs.obs_property_list_add_string(t, scene, scene)
		end
		obs.bfree(scene)
	end

	local r = obs.obs_properties_add_list(props, "transition_" .. table_count(transition_map_s), table_count(transition_map_s) .. ". transition", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	obs.obs_property_list_add_string(r, "-----", "-----")
	local transitions = obs.obs_frontend_get_transitions()
	for i, source in pairs(transitions) do
		name = obs.obs_source_get_name(source)
		if name ~= default_transition_name then
			obs.obs_property_list_add_string(r, name, name)
		end
	end
	obs.source_list_release(transitions)

	return true
end

function script_properties()
	props = obs.obs_properties_create()

	local s = obs.obs_properties_add_list(props, "default_transition", "Default Transition", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local transitions = obs.obs_frontend_get_transitions()
	for i, source in pairs(transitions) do
		name = obs.obs_source_get_name(source)
		obs.obs_property_list_add_string(s, name, name)
	end
	obs.source_list_release(transitions)

	obs.obs_properties_add_button(props, "button", "Add New Transition", transition_add)

	local i = 1
	for k in pairs (transition_map_s) do
		local s = obs.obs_properties_add_list(props, "source_" .. i, i .. ". source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
		local t = obs.obs_properties_add_list(props, "target_" .. i, i .. ". target", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
		obs.obs_property_list_add_string(s, "-----", "-----")
		obs.obs_property_list_add_string(t, "-----", "-----")
		local scenes = obs.obs_frontend_get_scene_names()
		if scenes ~= nil then
			for _, scene in ipairs(scenes) do
				obs.obs_property_list_add_string(s, scene, scene)
				obs.obs_property_list_add_string(t, scene, scene)
			end
			obs.bfree(scene)
		end

		local r = obs.obs_properties_add_list(props, "transition_" .. i, i .. ". transition", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
		obs.obs_property_list_add_string(r, "-----", "-----")
		local transitions = obs.obs_frontend_get_transitions()
		for i, source in pairs(transitions) do
			name = obs.obs_source_get_name(source)
			if name ~= default_transition_name then
				obs.obs_property_list_add_string(r, name, name)
			end
		end
		obs.source_list_release(transitions)
		i = i + 1
	end

	return props
end

-- A function named script_defaults will be called to set the default settings
function script_defaults(settings)

end

-- A function named script_load will be called on startup
function script_load(settings)
	local sh = obs.obs_get_signal_handler()
	obs.signal_handler_connect(sh, "source_activate", source_activated)
	obs.signal_handler_connect(sh, "source_deactivate", source_deactivated)
end

-- A function named script_update will be called when settings are changed
function init_curr_scene()
	attempts = attempts + 1
	if attempts >= 30 then
		obs.remove_current_callback()
	end

	local currentScene = obs.obs_frontend_get_current_scene()
	local scene_name = obs.obs_source_get_name(currentScene)
	if scene_name ~= nil then
		obs.remove_current_callback()
		if curr_scene_name == "" then
			curr_scene_name = scene_name
			obs.obs_source_release(currentScene)
			transition_stoped()
		end
	end
end

function script_update(settings)
	attempts = 0
	obs.timer_add(init_curr_scene, 1000)


	default_transition_name = obs.obs_data_get_string(settings, "default_transition")

	transition_map_s = table_wipe(transition_map_s)
	transition_map_t = table_wipe(transition_map_t)
	transition_map_r = table_wipe(transition_map_r)
	local i = 1
	while true
		do
		local s = obs.obs_data_get_string(settings, "source_" .. i)
		local t = obs.obs_data_get_string(settings, "target_" .. i)
		local r = obs.obs_data_get_string(settings, "transition_" .. i)
		if s == "" and t == "" and r == "" then
			break
		end
		table.insert(transition_map_s, s)
		table.insert(transition_map_t, t)
		table.insert(transition_map_r, r)
		i = i + 1
	end
end

-- A function named script_save will be called when the script is saved
--
-- NOTE: This function is usually used for saving extra data (such as in this
-- case, a hotkey's save data).  Settings set via the properties are saved
-- automatically.
function script_save(settings)

end