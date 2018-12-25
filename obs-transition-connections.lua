obs         = obslua
default_transition_name = ""
curr_scene_name = ""

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

function transition_stoped(cd)
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

function source_deactivated(cd)
	local currentScene = obs.obs_frontend_get_current_scene()
	curr_scene_name = obs.obs_source_get_name(currentScene)
	obs.obs_source_release(currentScene)
	transition_stoped()
end

function source_activated(cd)
	if curr_scene_name == "" then
  	local currentScene = obs.obs_frontend_get_current_scene()
  	curr_scene_name = obs.obs_source_get_name(currentScene)
  	obs.obs_source_release(currentScene)
	end
	
	local source = obs.calldata_source(cd, "source")
	if source ~= nil then
		local source_id = obs.obs_source_get_id(source)
		if source_id == "scene" then
			local next_scene_name = obs.obs_source_get_name(source)
			
			local set_transition = default_transition_name
			if curr_scene_name == "Starting" and next_scene_name == "Playing" then
				set_transition = "Intro"
			end
			if curr_scene_name == "Starting" and next_scene_name == "Developing" then
				set_transition = "Intro"
			end
			
			if set_transition ~= default_transition_name then
    		local transitions = obs.obs_frontend_get_transitions()
  			local obj_transition = find_source_by_name_in_list(transitions, set_transition)
  			if obj_transition ~= nil then
--  				local sh = obs.obs_source_get_signal_handler(obj_transition)
--          obs.signal_handler_connect(sh, "transition_stop", function(source)
--            obs.remove_current_callback()
--            local transitions = obs.obs_frontend_get_transitions()
--            local obj_transition = find_source_by_name_in_list(transitions, default_transition_name)
--            obs.obs_frontend_set_current_transition(obj_transition)
--            obs.source_list_release(transitions)
--        	end)
        	obs.obs_frontend_set_current_transition(obj_transition)
  				obs.obs_transition_start(obj_transition, obs.OBS_TRANSITION_MODE_AUTO, 0, source)
  			else
  				obs.script_log(obs.LOG_WARNING, "Transition does not exists: " .. set_transition)
  			end
  			obs.source_list_release(transitions)
  		end
		end
	end
end

----------------------------------------------------------

-- A function named script_update will be called when settings are changed
function script_update(settings)
	default_transition_name = obs.obs_data_get_string(settings, "default_transition")
end

-- A function named script_description returns the description shown to
-- the user
function script_description()
	return "Set up custom transitions between 2 scenes."
end

-- A function named script_properties defines the properties that the user
-- can change for the entire script module itself
function script_properties()
	props = obs.obs_properties_create()
	
	local s = obs.obs_properties_add_list(props, "default_transition", "Default Transition", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local transitions = obs.obs_frontend_get_transitions()
  for i, source in pairs(transitions) do
    name = obs.obs_source_get_name(source)
    obs.obs_property_list_add_string(s, name, name)
  end
	obs.source_list_release(transitions)
	
	
	return props
end

-- A function named script_defaults will be called to set the default settings
function script_defaults(settings)

end

-- A function named script_load will be called on startup
function script_load(settings)
	default_transition_name = obs.obs_data_get_string(settings, "default_transition")
	if default_transition_name then
		local sh = obs.obs_get_signal_handler()
		obs.signal_handler_connect(sh, "source_activate", source_activated)
		obs.signal_handler_connect(sh, "source_deactivate", source_deactivated)
		--transition_stoped() -- User created transitions are not loaded on OBS start when script_load is triggered
	end
end

-- A function named script_save will be called when the script is saved
--
-- NOTE: This function is usually used for saving extra data (such as in this
-- case, a hotkey's save data).  Settings set via the properties are saved
-- automatically.
function script_save(settings)

end
