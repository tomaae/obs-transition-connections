# Open Broadcaster Software - Transition Connections
OBS Instant Replay is a script for Open Broadcaster Software which allows you to set up transition connections between 2 specific scenes.  

Example:
- Use "Intro" transition when switching specifically from "Starting" scene to "Playing" scene
- Use "Intro" transition when switching specifically from "Starting" scene to "Development" scene
- Otherwise use "Default" transition  
![OBS Transition Connections](https://raw.githubusercontent.com/tomaae/obs-transition-connections/github-resources/obs_scripts_config.png)  


# OBS Transition Connections installation
1. Copy file to OBS scripts directory  
(1) Copy "obs-transition-connections.lua" into OBS scripts directory (Usually "C:\Program Files (x86)\obs-studio\data\obs-plugins\frontend-tools\scripts\")  

2. Add script to OBS  
(1) In OBS main menu, open "Tools">"Scripts"  
![Open scripts window](https://raw.githubusercontent.com/tomaae/obs-transition-connections/github-resources/obs_scripts_open.png)  
(2) Click "+" button and add script "obs-transition-connections.lua"  

3. Configure OBS Transition Connections  
(1) Enable the script
(2) Select default transition  
(3) Click "Add New Transition" button  
(4) Select Source scene  
(5) Select Target scene  
(6) Select Transition  
*Repeat steps 3.2 - 3.5 to create additional transition connections*  
![Configure OBS Transition Connections](https://raw.githubusercontent.com/tomaae/obs-transition-connections/github-resources/obs_scripts_config.png)  
*NOTE: Transition connections will not trigger for any target scenes with Transition Override active*  
