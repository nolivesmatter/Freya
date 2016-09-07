-- Designed for server core base

local new3 = Color3.new;
local pcall = pcall;
local assert = assert;
local Hex do
	local hTable = setmetatable({},{__mode = 'kv'});
	Hex = function(hex)
		hex = hex:gsub("#","")
		if not hTable[hex] then
			hTable[hex] = new3(tonumber("0x"..hex:sub(1,2))/255, tonumber("0x"..hex:sub(3,4))/255, tonumber("0x"..hex:sub(5,6))/255)
		end
		return hTable[hex]
	end
end

local Colours = _G.Valkyrie:GetComponent("Colour");

local Red = Colours.Red;
local Pink = Colours.Pink;
local Purple = Colours.Purple;
local DeepPurple = Colours.DeepPurple;
local Indigo = Colours.Indigo;
local Blue = Colours.Blue;
local LightBlue = Colours.LightBlue;
local Cyan = Colours.Cyan;
local Teal = Colours.Teal;
local Green = Colours.Green;
local LightGreen = Colours.LightGreen;
local Lime = Colours.Lime;
local Yellow = Colours.Yellow;
local Amber = Colours.Amber;
local Orange = Colours.Orange;
local DeepOrange = Colours.DeepOrange;
local Brown = Colours.Brown;
local Grey = Colours.Grey;
local BlueGrey = Colours.BlueGrey;
local Black = Colours.Black;
local White = Colours.White;

local function hue2rgb(p, q, t)
	if t < 0 then t = t + 1; end
	if t > 1 then t = t - 1; end
	if t < 1 / 6 then return p + (q - p) * 6 * t; end
	if t < .5 then return q; end
	if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6; end
	return p;
end

local floor = math.floor;
local sub = string.sub;
local min, max = math.min, math.max;

local function round(x)
	return floor(x + .5);
end;

local isc3 do
	local bc = BrickColor.new;
	isc3 = function(a)
		if type(a) == 'userdata' then
			return (pcall(bc,a));
		end
		return false;
	end
end

local owait = wait; local wait; do
	local canUseRStep = not not game.Players.LocalPlayer;
	local rstep; if canUseRStep then rstep = game:GetService"RunService".RenderStepped; end

	wait = function(time)
		if time then
			return owait(time);
		elseif canUseRStep then
			local otick = tick();
			rstep:wait();
			return tick() - otick;
		else 
			return owait();
		end
	end
end

local nmem = setmetatable({},{__mode = 'v'});
local HSLI = {
	new = function(H,S,L)
		H = max(min(1,H),0);
		S = max(min(1,S),0);
		L = max(min(1,L),0);
		local c = H..":"..S..":"..L;
		if not nmem[c] then
			if S == 0 then
				local nc3 = new3(L,L,L);
				nmem[c] = nc3;
				return nc3
			else
				local q = L < 0.5 and L * (1 + S) or L + S - L * S;
				local p = 2 * L - q;
				local nc3 = new3(hue2rgb(p, q, H + 1 / 3),
					hue2rgb(p, q, H),
					hue2rgb(p, q, H - 1 / 3))
				nmem[c] = nc3;
				return nc3;
			end
		end
		return nmem[c];
	end;
}

local function getHex(n)
	return sub("0123456789ABCDEF",(n-n%16)/16 + 1,(n-n%16)/16 + 1) ..sub("0123456789ABCDEF",n%16 + 1,n%16 + 1);
end

local format = string.format;
local HSLts = function(a) return format("%d, %d, %d", a.h, a.s, a.l) end;
local HSLeq = function(a,b) return a.C3 == b.C3 end;

local c3mul = function(a,b)
	if isc3(a) and isc3(b) then
		return new3(a.r*b.r,a.g*b.g,a.b*b.b);
	else
		error("Attempt to multiply "..type(a).." with "..type(b), 2);
	end
end;
local c3soft = function(a,b)
	if isc3(a) and isc3(b) then
		return new3((1-2*b.r)*a.r^2+2*b.r*a.r,(1-2*b.g)*a.g^2+2*b.g*a.g,(1-2*b.b)*a.b^2+2*b.b*a.b);
	else
		error("Attempt to perform "..type(a).." ^ "..type(b), 2);
	end
end
local c3div = function(a,b)
	if isc3(a) and isc3(b) then
		return new3(a.r/b.r,a.g/b.g,a.b/b.b);
	else
		error("Attempt to divide "..type(a).." with "..type(b), 2);
	end
end;
local c3sub = function(a,b)
	if isc3(a) and isc3(b) then
		return new3(max(a.r-b.r,0),max(a.g-b.g,0),max(a.b-b.b,0));
	else
		error("Attempt to subtract "..type(a).." from "..type(b), 2);
	end
end;
local c3add = function(a,b)
	if isc3(a) and isc3(b) then
		return new3(min(a.r+b.r,1),min(a.g+b.g,1),min(a.b+b.b,1));
	else
		error("Attempt to add "..type(a).." to "..type(b), 2);
	end
end;
local c3lerp = function(a,b,al)
	assert(a and b and al, "You must provide 2 Color3 values and an alpha", 2);
	if isc3(a) and isc3(b) then
		return new3(a.r+(b.r-a.r)*al, a.g+(b.g-a.g)*al, a.b+(b.b-a.b)*al);
	else
		error("You need to be lerping 2 Color3 values", 2);
	end
end

local Tweens = _G._Valkyrie:GetComponent("Tweens");

local rad,sin,cos = math.rad,math.sin, math.cos;
local function calculateCircularTween(origin, radius, degrees)
	local radians = rad(degrees);
	return UDim2.new(0, cos(radians) * radius, 0, sin(radians) * radius) + origin;
end

local function tweenColor3Property(self, prop, NewColor, TweenType, TweenTime, Callback)
	assert(isc3(NewColor), "Expected a Color3, got "..tostring(NewColor), 3);
	local TweenType = TweenType:lower();
	local Tween = TweenType and Tweens[TweenType:lower()] or Tweens.inoutquad;
	TweenTime = TweenTime or 1;
	assert(type(TweenTime) == 'number', "You need to supply a valid number as the tween duration", 3);
	local r,g,b,dr,dg,db;
	do
		local curr = self[prop];
		assert(curr, "Please supply a valid property name!", 3);
		r = curr.r;
		g,dr = curr.g,NewColor.r;
		b,dg = curr.b,NewColor.g;
		db = NewColor.b
	end
	do
		local tsmin, tsmax = min(r,g,b), max(r,g,b);
		local _r,_g,_b = r,g,b;
		local _dr,_dg,_db = dr,dg,db;
		local tdmin, tdmax = min(dr,dg,db), max(dr,dg,db);
		b = (tsmin + tsmax)*.5;
		db = (tdmin + tdmax)*.5;
		g = tsmin == tsmax and 0 or (b < 0.5 and (tsmax-tsmin)/(tsmax+tsmin) or (tsmax-tsmin)/(2-tsmax-tsmin))
		dg = tdmin == tdmax and 0 or (db < 0.5 and (tdmax-tdmin)/(tdmax+tdmin) or (tdmax-tdmin)/(2-tdmax-tdmin))
		if _r>_g and _r>_b then
			r = (_g-_b)/(tsmax-tsmin)
		elseif _g>_r and _g>_b then
			r = 2+(_b-_r)/(tsmax-tsmin)
		else
			r = 4+(_r-_g)/(tsmax-tsmin);
		end;
		if _dr>_dg and _dr>_db then
			dr = (_dg-_db)/(tsmax-tsmin)
		elseif _dg>_dr and _dg>_db then
			dr = 2+(_db-_dr)/(tsmax-tsmin)
		else
			dr = 4+(_dr-_dg)/(tsmax-tsmin);
		end;
		r,dr = r/6, dr/6;
		if r < 0 then r = r+1 end;
		if dr < 0 then dr = dr+1 end;
	end
	dr,dg,db = dr-r,dg-g,db-b;
	local i = 0;
	while i < TweenTime do
		self[prop] = HSLI.new(
			Tween(i, r, dr, TweenTime),
			Tween(i, g, dg, TweenTime),
			Tween(i, b, db, TweenTime)
		)
		i = i+wait();
	end
	self[prop] = NewColor;
	if type(Callback) == 'function' then local s,e = pcall(Callback) return assert(s,e,2); end;
end


local V2new = Vector2.new;
local unpack = unpack;

local IRS = V2new(96,96); -- I simply had to

local images 		= {
	action1 		= 242376228;
	action2 		= 242376304;
	action3			= 242376350;
	alert 			= 242376386;
	av				= 242376424;
	communication 	= 242376451;
	content 		= 242376482;
	device1 		= 242376518;
	device2			= 242376568;
	editor 			= 242376612;
	file 			= 242376638;
	hardware 		= 242376668;
	image1 			= 242376691;
	image2			= 242376708;
	image3 			= 242376730;
	maps 			= 242376766;
	navigation 		= 242372155;
	notification	= 242376827;
	social 			= 242376879;
	toggle 			= 242376921;
};
local Icons = {
	action1 		= {
		find_in_page 			= {0,0};
		["3d_rotation"] 		= {96,0};
		accessibility			= {192,0};
		account_balance_wallet	= {288,0};
		account_balance 		= {384,0};
		account_box 			= {480,0};
		account_child 			= {576,0};
		account_circle			= {672,0};
		add_shopping_cart		= {768,0};
		alarm_add				= {864,0};
		alarm_off				= {0,96};
		alarm_on 				= {96,96};
		alarm 					= {192,96};
		android					= {288,96};
		announcement			= {384,96};
		aspect_ratio			= {480,96};
		assessment				= {576,96};
		assignment_ind			= {672,96};
		assignment_late 		= {768,96};
		assignment_return 		= {864,96};
		assignment_returned 	= {0,192};
		assignment_turned_in 	= {96,192};
		assignment 				= {192,192};
		autorenew				= {288,192};
		backup					= {384,192};
		book 					= {480,192};
		bookmark_outline		= {576,192};
		bookmark				= {672,192};
		bug_report 				= {768,192};
		cached					= {864,192};
		check_circle			= {0,288};
		class 					= {96,288};
		credit_card				= {192,288};
		dashboard				= {288,288};
		delete 					= {384,288};
		description				= {480,288};
		dns 					= {576,288};
		done_all				= {672,288};
		done 					= {768,288};
		event 					= {864,288};
		exit_to_app				= {0,384};
		explore 				= {96,384};
		extension				= {192,384};
		face 					= {288,384};
		favorite_outline 		= {384,384};
		favorite 				= {480,384};
	};
	action2 		= {
		settings_phone 			= {0,0};
		settings_power			= {96,0};
		settings_remote			= {192,0};
		settings 				= {288,0};
		settings_voice			= {384,0};
		shop_two				= {480,0};
		shop 					= {576,0};
		shopping_basket			= {672,0};
		shopping_cart			= {768,0};
		speaker_notes			= {0,96};
		find_replace			= {96,96};
		flip_to_back			= {192,96};
		flip_to_front			= {288,96};
		get_app					= {384,96};
		grade					= {480,96};
		group_work				= {576,96};
		help					= {672,96};
		highlight_remove		= {768,96};
		history					= {0,192};
		home 					= {96,192};
		https					= {192,192};
		info_outline 			= {288,192};
		info 					= {384,192};
		input 					= {480,192};
		invert_colors			= {576,192};
		label_outline			= {672,192};
		label 					= {768,192};
		language				= {0,288};
		launch 					= {96,288};
		list 					= {192,288};
		lock_open				= {288,288};
		lock_outline 			= {384,288};
		lock 					= {480,288};
		loyalty					= {576,288};
		markunread_mailbox 		= {672,288};
		note_add				= {768,288};
		open_in_browser			= {0,384};
		open_in_new 			= {96,384};
		open_with				= {192,384};
		pageview				= {288,384};
		payement				= {384,384};
		perm_camera_mic			= {480,384};
		perm_contact_cal		= {576,384};
		perm_data_setting		= {672,384};
		perm_device_info		= {768,384};
		perm_identity			= {0,480};
		perm_media				= {96,480};
		perm_phone_msg			= {192,480};
		perm_scan_wifi			= {288,480};
		picture_in_picture		= {384,480};
		polymer					= {480,480};
		print					= {576,480};
		query_builder			= {672,480};
		question_answer			= {768,480};
		receipt					= {0,576};
		redeem					= {96,576};
		reorder					= {192,576};
		report_problem			= {288,576};
		restore					= {384,576};
		room 					= {480,576};
		schedule				= {576,576};
		search					= {672,576};
		settings_applications	= {768,576};
		settings_backup_restore	= {0,672};
		settings_bluetooth		= {92,672};
		settings_cell			= {192,672};
		settings_display		= {288,672};
		settings_ethernet		= {384,672};
		settings_input_antenna	= {480,672};
		settings_input_component= {576,672};
		settings_input_composite= {672,672};
		settings_input_hdmi		= {768,672};
		settings_input_svideo	= {0,768};
		settings_overscan		= {96,768};
	};
	action3			= {
		view_headline			= {0,0};
		view_list 				= {96,0};
		view_module				= {192,0};
		view_quilt				= {288,0};
		view_stream				= {384,0};
		view_week				= {480,0};
		visibility_off			= {576,0};
		visibility 				= {0,96};
		work					= {96,96};
		spellcheck				= {192,96};
		star_rate				= {288,96};
		stars 					= {384,96};
		store					= {480,96};
		subject					= {576,96};
		supervisor_account		= {0,192};
		swap_horiz				= {96,192};
		swap_vert_circle		= {192,192};
		swap_vert 				= {288,192};
		system_update_tv		= {384,192};
		tab_unselected			= {480,192};
		tab 					= {576,192};
		theaters				= {0,288};
		thumb_down				= {96,288};
		thumb_up 				= {192,288};
		thumbs_up_down			= {288,288};
		toc 					= {384,288};
		today 					= {480,288};
		track_changes			= {576,288};
		translate				= {0,384};
		trending_down			= {96,384};
		trending_neutral		= {192,384};
		trending_up 			= {288,384};
		turned_in_not			= {384,384};
		turned_in  				= {480,384};
		wallet_giftcard 		= {576,384};
		wallet_travel			= {0,480};
		wallet_membership		= {96,480};
		verified_user			= {192,480};
		view_agenda				= {288,480};
		view_array				= {384,480};
		view_carousel			= {480,480};
		view_column				= {576,480};
		view_day 				= {0,576};

	};
	alert 			= {
		error 					= {0,0};
		warning					= {96,0};
	};
	av				= {
		album 					= {0,0};
		av_timer				= {96,0};
		closed_caption			= {192,0};
		equalizer				= {288,0};
		explicit				= {384,0};
		fast_forward			= {480,0};
		fast_rewind				= {576,0};
		games 					= {672,0};
		hearing 				= {768,0};
		high_quality			= {864,0};
		loop 					= {0,96};
		mic_none 				= {96,96};
		mic_off					= {192,96};
		mic 					= {288,96};
		movie 					= {384,96};
		my_library_add			= {480,96};
		my_library_books		= {576,96};
		my_library_music		= {672,96};
		new_releases			= {768,96};
		not_interested			= {864,96};
		pause_circle_fill		= {0,192};
		pause_circle_outline	= {96,192};
		pause 					= {192,192};
		play_arrow 				= {288,192};
		play_circle_fill		= {384,192};
		play_circle_outline		= {480,192};
		play_shopping_bag		= {576,192};
		playlist_add			= {672,192};
		queue_music				= {768,192};
		queue 					= {864,192};
		radio 					= {0,288};
		recent_actors 			= {96,288};
		repeat_one				= {192,288};
		["repeat"] 				= {288,288};
		replay 					= {384,288};
		shuffle					= {480,288};
		skip_next				= {576,288};
		skip_previous			= {672,288};
		snooze					= {768,288};
		stop 					= {864,288};
		subtitles				= {0,384};
		surround_sound			= {96,384};
		web 					= {192,384};
		video_collection		= {288,384};
		videocam_off			= {384,384};
		videocam 				= {480,384};
		volume_down				= {576,384};
		volume_mute 			= {672,384};
		volume_off				= {768,384};
		volume_up 				= {864,384};
	};
	communication 	= {
		chat 					= {0,0};
		clear_all				= {96,0};
		comment 				= {192,0};
		contacts				= {288,0};
		dialer_sip				= {384,0};
		dialpad 				= {480,0};
		dnd_on 					= {576,0};
		email 					= {672,0};
		forum					= {0,96};
		import_export			= {96,96};
		invert_colors_off 		= {192,96};
		invert_colors_on 		= {288,96};
		live_help				= {384,96};
		location_off 			= {480,96};
		location_on				= {576,96};
		message					= {672,96};
		messenger				= {0,192};
		no_sim 					= {96,192};
		phone 					= {192,192};
		protable_wifi_off		= {288,192};
		quick_contacts_dialer	= {384,192};
		quick_contacts_mail 	= {480,192};
		ring_volume 			= {576,192};
		stay_current_landscape	= {672,192};
		stay_current_portrait	= {0,288};
		stay_primary_landscape	= {96,288};
		stay_primary_portrait	= {192,288};
		swap_calls				= {288,288};
		textsms					= {384,288};
		voicemail				= {480,288};
		vpn_key					= {576,288};
		business				= {672,288};
		call_end				= {0,384};
		call_made				= {96,384};
		call_merge				= {192,384};
		call_missed				= {288,384};
		call_received			= {384,384};
		call_split				= {480,384};
		call 					= {576,384};
	};
	content 		= {
		block 					= {0,0};
		clear 					= {96,0};
		content_copy			= {192,0};
		content_cut				= {288,0};
		content_paste			= {384,0};
		create					= {480,0};
		drafts					= {576,0};
		filter_list				= {0,96};
		flag 					= {96,96};
		forward					= {192,96};
		gesture					= {288,96};
		inbox					= {384,96};
		link 					= {480,96};
		mail 					= {576,96};
		markunread 				= {0,192};
		redo 					= {96,192};
		remove_circle_outline	= {192,192};
		remove_circle			= {288,192};
		remove 					= {384,192};
		reply_all				= {480,192};
		reply 					= {576,192};
		report 					= {0,288};
		save 					= {96,288};
		select_all 				= {192,288};
		send					= {288,288};
		sort 					= {384,288};
		text_format				= {480,288};
		undo 					= {576,288};
		add_box					= {0,348};
		add_circle_outline		= {96,348};
		add_circle 				= {192,348};
		add 					= {288,348};
		archive 				= {348,348};
		clear 					= {480,348};
	};
	device1 		= {
		network_wifi			= {672,384};
		nfc 					= {768,384};
		access_alarm			= {0,480};
		access_alarms			= {96,480};
		access_time 			= {192,480};
		add_alarm				= {288,480};
		airplanemode_off		= {384,480};
		airplanemode_on			= {480,480};
		battery_20				= {576,480};
		battery_30				= {672,480};
		battery_50				= {768,480};
		battery_60 				= {0,576};
		battery_80 				= {96,576};
		battery_90 				= {192,576};
		battery_alert 			= {288,576};
		battery_charging_20 	= {384,576};
		battery_charging_30		= {480,576};
		battery_charging_50		= {576,576};
		battery_charging_60		= {672,576};
		battery_charging_80 	= {768,576};
		battery_charging_90 	= {0,672};
		battery_charging_full	= {96,672};
		battery_full			= {192,672};
		battery_std 			= {288,672};
		battery_unknown 		= {384,672};
		bluetooth_connected		= {480,672};
		bluetooth_disabled		= {576,672};
		bluetooth_searching		= {672,672};
		bluetooth				= {768,672};
		brightness_auto			= {0,768};
		brightness_high 		= {96,768};
		brightness_low			= {192,768};
		brightness_medium		= {288,768};
		data_usage				= {384,768};
		developer_mode			= {480,768};
		devices 				= {576,768};
		dvr 					= {672,768};
		gps_fixed 				= {768,768};
		gps_not_fixed			= {0,864};
		gps_off 				= {96,864};
		location_disabled		= {192,864};
		location_searching		= {288,864};
		multitrack_audio		= {384,864};
		network_cell			= {480,864};
	};
-- TODO: Reupload device2
	device2			= {
		signal_wifi_statusbar_not_connected	= {0,0};
		signal_wifi_statusbar_null 			= {96,0};
		storage								= {192,0};
		usb									= {288,0};
		wifi_lock							= {384,0};
		wifi_tethering						= {480,0};
		now_wallpaper						= {576,0};
		now_widgets							= {0,96};
		screen_lock_landscape				= {96,96};
		screen_lock_portrait				= {192,96};
		screen_lock_rotation 				= {288,96};
		screen_rotation						= {384,96};
		sd_storage							= {480,96};
		settings_system_daydream 			= {576,96};
		signal_cellular_0_bar				= {0,192};
		signal_cellular_1_bar				= {96,192};
		signal_cellular_2_bar				= {192,192};
		signal_cellular_3_bar				= {288,192};
		signal_cellular_4_bar				= {384,192};
		signal_cellular_connected_no_internet_0_bar	= {480,192};
		signal_cellular_connected_no_internet_1_bar	= {576,192};
		signal_cellular_connected_no_internet_2_bar	= {0,288};
		signal_cellular_connected_no_internet_3_bar	= {96,288};
		signal_cellular_connected_no_internet_4_bar	= {192,288};
		signal_cellular_no_sim				= {288,288};
		signal_cellular_null				= {384,288};
		signal_cellular_off					= {480,288};
		signal_wifi_0_bar					= {576,288};
		signal_wifi_1_bar					= {0,384};
		signal_wifi_2_bar					= {96,384};
		signal_wifi_3_bar					= {192,384};
		signal_wifi_4_bar					= {288,384};
		signal_wifi_off						= {384,384};
		signal_wifi_statusbar_1_bar			= {480,384};
		signal_wifi_statusbar_2_bar			= {576,384};
		signal_wifi_statusbar_3_bar			= {0,480};
		signal_wifi_statusbar_4_bar			= {96,480};
		signal_wifi_statusbar_connected_no_internet_1 	= {192,480};
		signal_wifi_statusbar_connected_no_internet_2	= {288,480};
		signal_wifi_statusbar_connected_no_internet_3	= {384,480};
		signal_wifi_statusbar_connected_no_internet_4	= {480,480};
	};
	editor 			= {
		border_bottom			= {0,0};
		border_clear 			= {96,0};
		border_color 			= {192,0};
		border_horizontal		= {288,0};
		border_inner			= {384,0};
		border_left				= {480,0};
		border_outer			= {576,0};
		border_right			= {672,0};
		border_style			= {768,0};
		border_top				= {0,96};
		border_vertical			= {96,96};
		format_align_center		= {192,96};
		format_align_justify	= {288,96};
		format_align_left		= {384,96};
		format_align_right		= {480,96};
		format_bold				= {576,96};
		format_clear			= {672,96};
		format_color_fill		= {768,96};
		format_color_reset		= {0,192};
		format_color_text		= {96,192};
		format_indent_decrease	= {192,192};
		format_indent_increase	= {288,192};
		format_italic			= {384,192};
		format_line_spacing		= {480,192};
		format_list_bulleted	= {576,192};
		format_list_numbered	= {672,192};
		format_paint			= {768,192};
		format_quote			= {0,288};
		format_size 			= {96,288};
		format_strikethrough	= {192,288};
		format_textdirection_l_to_r	= {288,288};
		format_textdirection_r_to_l	= {384,288};
		format_underline		= {480,288};
		functions				= {576,288};
		insert_chart			= {672,288};
		insert_comment			= {768,288};
		insert_drive_file		= {0,384};
		insert_emoticon			= {96,384};
		insert_invitation		= {192,384};
		insert_link				= {288,384};
		insert_photo			= {384,384};
		merge_type				= {480,384};
		mode_comment			= {576,384};
		mode_edit				= {672,384};
		publish					= {768,384};
		vertical_align_bottom	= {0,480};
		vertical_align_center	= {96,480};
		vertical_align_top		= {192,480};
		wrap_text				= {288,480};
		attach_file				= {384,480};
		attach_money			= {480,480};
		border_all				= {576,480};
	};
	file 			= {
		cloud_off				= {0,0};
		cloud_queue				= {96,0};
		cloud_upload			= {192,0};
		cloud 					= {288,0};
		file_download			= {0,96};
		file_upload				= {96,96};
		folder_open				= {192,96};
		folder_shared			= {288,96};
		folder 					= {0,192};
		attachment				= {96,192};
		cloud_circle			= {192,192};
		cloud_done 				= {288,192};
		cloud_dowload			= {0,288};
	};
	hardware 		= {
		dock 					= {0,0};
		gamepad					= {96,0};
		headset_mic				= {192,0};
		headset 				= {288,0};
		keyboard_alt			= {384,0};
		keyboard_arrow_down		= {480,0};
		keyboard_arrow_left		= {576,0};
		keyboard_arrow_right	= {0,96};
		keyboard_arrow_up 		= {96,96};
		keyboard_backspace		= {192,96};
		keyboard_capslock 		= {288,96};
		keyboard_control		= {384,96};
		keyboard_hide			= {480,96};
		keyboard_return 		= {576,96};
		keyboard_tab 			= {0,192};
		keyboard 				= {96,192};
		keyboard_voice 			= {192,192};
		laptop_chromebook		= {288,192};
		laptop_mac 				= {384,192};
		laptop 					= {480,192};
		laptop_windows			= {576,192};
		memory 					= {0,288};
		mouse 					= {96,288};
		phone_android			= {192,288};
		phone_iphone 			= {288,288};
		phonelink_off			= {384,288};
		phonelink 				= {480,288};
		security				= {576,288};
		sim_card 				= {0,384};
		smartphone				= {96,384};
		speaker 				= {192,384};
		tablet_android			= {288,384};
		tablet_mac 				= {384,384};
		tablet 					= {480,384};
		tv 						= {576,384};
		watch  					= {0,480};
		cast_connected 			= {96,480};
		cast 					= {192,480};
		computer 				= {288,480};
		desktop 				= {384,480};
		desktop_mac 			= {480,480};
		desktop_windows 		= {576,480};
	};
	image1 			= {
		crop_free				= {0,0};
		crop_landscape			= {96,0};
		crop_original			= {192,0};
		crop_landscape 			= {288,0};
		crop_portrait			= {384,0};
		crop_square 			= {480,0};
		crop 					= {576,0};
		add_to_photos			= {672,0};
		adjust 					= {768,0};
		assistant_photo 		= {0,96};
		audiotrack 				= {96,96};
		blur_circular			= {192,96};
		blur_linear				= {288,96};
		blur_off 				= {384,96};
		blur_on 				= {480,96};
		brightness_1 			= {576,96};
		brightness_2 			= {672,96};
		brightness_3 			= {0,192};
		brightness_4			= {96,192};
		brightness_5			= {192,192};
		brightness_6	 		= {288,192};
		brightness_7 			= {384,192};
		brush 					= {480,192};
		camera_alt				= {576,192};
		camera_front			= {672,192};
		camera_rear 			= {0,288};
		camera_roll 			= {96,288};
		camera 					= {192,288};
		center_focus_strong		= {288,288};
		center_focus_weak 		= {384,288};
		collections 			= {480,288};
		color_lens				= {576,288};
		colorize 				= {672,288};
		compare 				= {0,384};
		control_point_duplicate	= {96,384};
		control_point 			= {192,384};
		crop_3_2 				= {288,384};
		crop_5_4 				= {384,384};
		crop_7_5 				= {480,384};
		crop_16_9				= {576,384};
		crop_din 				= {672,384};
	};
	image2			= {
		looks_3 				= {0,0};
		looks_4 				= {96,0};
		looks_5 				= {192,0};
		looks_6					= {288,0};
		looks_one 				= {384,0};
		looks_two 				= {480,0};
		dehaze 					= {576,0};
		details 				= {672,0};
		edit 					= {768,0};
		exposure_minus_1		= {0,96};
		exposure_minus_2		= {96,96};
		exposure_plus_1			= {192,96};
		exposure_plus_2			= {288,96};
		exposure 				= {384,96};
		exposure_zero 			= {480,96};
		filter_1 				= {576,96};
		filter_2 				= {672,96};
		filter_3 				= {768,96};
		filter_4 				= {0,192};
		filter_5 				= {96,192};
		filter_6 				= {192,192};
		filter_7 				= {288,192};
		filter_8 				= {384,192};
		filter_9_plus 			= {480,192};
		filter_9 				= {576,192};
		filter_b_and_w 			= {672,192};
		filter_center_focus 	= {768,192};
		filter_drama 			= {0,288};
		filter_frames 			= {96,288};
		filter_hdr 				= {192,288};
		filter_none 			= {288,288};
		filter_tilt_shift 		= {384,288};
		filter 					= {480,288};
		filter_vintage			= {576,288};
		flare 					= {672,288};
		flash_auto 				= {768,288};
		flash_off				= {0,384};
		flash_on 				= {96,384};
		flip 					= {192,384};
		gradient 				= {288,384};
		grain 					= {384,384};
		grid_off				= {480,384};
		grid_on 				= {576,384};
		hdr_off 				= {672,384};
		hdr_on 					= {768,384};
		hdr_strong				= {0,480};
		hdr_weak 				= {96,480};
		healing 				= {192,480};
		image_aspect_ratio		= {288,480};
		image 					= {384,480};
		iso 					= {480,480};
		landscape 				= {576,480};
		leak_add 				= {672,480};
		leak_remove 			= {768,480};
	};
	image3 			= {
		tonality				= {0,0};
		transform 				= {96,0};
		tune 					= {192,0};
		wb_auto 				= {288,0};
		wb_cloudy				= {384,0};
		wb_incandescent			= {480,0};
		wb_irradescent			= {576,0};
		wb_sunny 				= {0,96};
		looks 					= {96,96};
		loupe 					= {192,96};
		movie_creation			= {288,96};
		nature_people			= {384,96};
		nature 					= {480,96};
		navigate_before			= {576,96};
		navigate_next			= {0,192};
		palette					= {96,192};
		panorama_fisheye		= {192,192};
		panorama_horizontal		= {288,192};
		panorama_vertical		= {384,192};
		panorama 				= {480,192};
		panorama_wide_angle		= {576,192};
		photo_album				= {0,288};
		photo_camera			= {96,288};
		photo_library 			= {192,288};
		photo 					= {288,288};
		portrait				= {384,288};
		remove_red_eye			= {480,288};
		rotate_left				= {576,288};
		rotate_right			= {0,384};
		slideshow 				= {96,384};
		straighten				= {192,384};
		style 					= {288,384};
		switch_camera			= {384,384};
		switch_video 			= {480,384};
		tag_faces				= {576,384};
		texture 				= {0,480};
		timelapse				= {96,480};
		timer_3 				= {192,480};
		timer_10 				= {288,480};
		timer_auto				= {384,480};
		timer_off				= {480,480};
		timer 					= {576,480};
	};
	maps 			= {
		directions_subway		= {0,0};
		directions_train 		= {96,0};
		directions_transit 		= {192,0};
		directions_walk 		= {288,0};
		directions 				= {384,0};
		flight 					= {480,0};
		hotel 					= {576,0};
		layers_clear			= {672,0};
		layers 					= {0,96};
		local_airport 			= {96,96};
		local_atm 				= {192,96};
		local_attraction		= {288,96};
		local_bar 				= {384,96};
		local_cafe				= {480,96};
		local_car_wash 			= {576,96};
		local_convenience_store	= {672,96};
		local_drink 			= {0,192};
		local_florist			= {96,192};
		local_gas_station		= {192,192};
		local_grocery_store		= {288,192};
		local_hospital			= {384,192};
		local_hotel 			= {480,192};
		local_laundry_service	= {576,192};
		local_library			= {672,192};
		local_mall 				= {0,288};
		local_movies			= {96,288};
		local_offer				= {192,288};
		local_parking			= {288,288};
		local_pharmacy			= {384,288};
		local_phone 			= {480,288};
		local_pizza				= {576,288};
		local_play 				= {672,288};
		local_post_office		= {0,384};
		local_print_shop		= {96,384};
		local_restaurant		= {288,384};
		local_see 				= {384,384};
		local_taxi 				= {480,384};
		location_history		= {576,384};
		map 					= {672,384};
		my_location 			= {0,480};
		navigation 				= {96,480};
		pin_drop 				= {192,480};
		place 					= {288,480};
		rate_review				= {384,480};
		restaurant_menu			= {480,480};
		satellite				= {576,480};
		store_mall_directory	= {672,480};
		terrain 				= {0,576};
		traffic 				= {96,576};
		beenhere				= {192,576};
		directions_bike 		= {288,576};
		directions_bus 			= {384,576};
		directions_car 			= {480,576};
		directions_ferry 		= {576,576};
	};
	navigation 		= {
		apps 					= {0,0};
		arrow_back 				= {96,0};
		arrow_drop_down_circle	= {192,0};
		arrow_drop_down 		= {288,0};
		arrow_drop_up 			= {384,0};
		arrow_forward			= {480,0};
		cancel 					= {576,0};
		check 					= {0,96};
		chevron_left 			= {96,96};
		chevron_right 			= {192,96};
		close 					= {288,96};
		expand_less 			= {384,96};
		expand_more 			= {480,96};
		fullscreen_exit 		= {576,96};
		fullscreen 				= {0,192};
		menu 					= {96,192};
		more_horiz 				= {192,192};
		more_vert 				= {288,192};
		refresh 				= {384,192};
		unfold_less				= {480,192};
		unfold_more 			= {576,192};
	};
	notification	= {
		disc_full 				= {0,0};
		dnd_forwardslash 		= {96,0};
		do_not_disturb 			= {192,0};
		drive_eta 				= {288,0};
		event_available 		= {384,0};
		event_busy 				= {480,0};
		event_note 				= {0,96};
		folder_special 			= {96,96};
		mms 					= {192,96};
		more 					= {288,96};
		network_locked 			= {384,96};
		phone_bluetooth_speaker	= {480,96};
		phone_forwarded			= {0,192};
		phone_in_talk 			= {96,192};
		phone_locked 			= {192,192};
		phone_missed 			= {288,192};
		phone_paused 			= {384,192};
		play_download 			= {480,192};
		play_install 			= {0,288};
		sd_card 				= {96,288};
		sim_card_alert			= {192,288};
		sms_failed 				= {288,288};
		sms 					= {384,288};
		sync_disabled 			= {480,288};
		sync_problem 			= {0,384};
		sync 					= {96,384};
		system_update 			= {192,384};
		tap_and_play 			= {288,384};
		time_to_leave 			= {384,384};
		vibration 				= {480,384};
		voice_chat 				= {0,480};
		vpn_lock 				= {96,480};
		adb 					= {192,480};
		bluetooth_audio 		= {288,480};
	};
	social 			= {
		group_add 				= {0,96};
		group 					= {96,96};
		location_city 			= {192,96};
		mood 					= {288,96};
		notifications_none 		= {384,96};
		notifications_off 		= {480,96};
		notifications_on 		= {576,96};
		notifications_paused 	= {0,192};
		notifications 			= {96,192};
		pages 					= {192,192};
		party_mode 				= {288,192};
		people_outline 			= {384,192};
		people 					= {480,192};
		person_add 				= {576,192};
		person_outline 			= {0,288};
		person 					= {96,288};
		plus_one 				= {192,288};
		poll 					= {288,288};
		public 					= {384,288};
		school 					= {480,288};
		share 					= {576,288};
		whatshot 				= {0,384};
		cake 					= {96,384};
		domain 					= {192,384};
	};
	toggle 			= {
		check_box_outline_blank	= {0,0};
		check_box 				= {96,0};
		radio_button_off		= {384,0};
		radio_button_on 		= {0,96};
		start_half 				= {96,96};
		star_outline 			= {192,96};
		star 					= {0,192};
	};
};

local IUO = {
	LoadIcon = function(this, SpriteSet, Icon)
		assert(type(SpriteSet) == 'string', "You didn't supply a valid Spritesheet string", 2);
		assert(type(Icon) == 'string', "You didn't supply a valid Icon string", 2);
		SpriteSet = SpriteSet:lower();
		Icon = Icon:lower();
		assert(images[SpriteSet], "You didn't supply a valid spritesheet", 2)
		assert(Icons[SpriteSet][Icon], "You didn't supply a valid Icon name", 2);
		this.ImageRectSize = IRS;
		this.Image = "rbxassetid://"..tostring(images[SpriteSet]);
		this.ImageRectOffset = V2new(unpack(Icons[SpriteSet][Icon]));
	end;
	TweenImageColor3 = function(self, ...)
		tweenColor3Property(self, "ImageColor3", ...);
	end
};
local GUIUO = {
	TweenColor3 = function(self, ...)
		tweenColor3Property(self, "BackgroundColor3", ...);
	end;
	TweenBackgroundColor3 = function(self, ...)
		tweenColor3Property(self, "BackgroundColor3", ...);
	end;
	TweenBorderColor3 = function(self, ...)
		tweenColor3Property(self, "BorderColor3", ...);
	end;
	TweenCircularly = function(self, b, e, tween, duration, origin, radius, callback)
		local c = b - e;
		local i = 0;
		tween = tween and Tweens[tween:lower()] or Tweens.inoutquad;
		while i < duration do
			self.Position = calculateCircularTween(origin, radius, tween(i, b, c, duration));
			i = i + wait();	
		end
		self.Position = calculateCircularTween(origin, radius, e);
		if type(callback) == 'function' then pcall(callback) end;
	end;
	VTweenPosition = function(self, e, tween, duration, callback)
		local b = self.Position;
		local c = e - b;
		local i = 0;
		local tween = tween and Tweens[tween:lower()] or Tweens.inoutquad;
		duration = duration or 1;
		while i < duration do
			self.Position = UDim2.new(
				tween(i, b.X.Scale, c.X.Scale, duration),
				tween(i, b.X.Offset, c.X.Offset, duration),
				tween(i, b.Y.Scale, c.Y.Scale, duration),
				tween(i, b.Y.Offset, c.Y.Offset, duration)
			);
			i = i + wait();
		end
		self.Position = e;
		if type(callback) == 'function' then pcall(callback) end;
	end;
	VTweenSize = function(self, e, tween, duration, callback)
		local b = self.Size;
		local c = e - b;
		local i = 0;
		local tween = tween and Tweens[tween:lower()] or Tweens.inoutquad;
		duration = duration or 1;
		while i < duration do
			self.Size = UDim2.new(
				tween(i, b.X.Scale, c.X.Scale, duration),
				tween(i, b.X.Offset, c.X.Offset, duration),
				tween(i, b.Y.Scale, c.Y.Scale, duration),
				tween(i, b.Y.Offset, c.Y.Offset, duration)
			);
			i = i + wait();
		end
		self.Size = e;
		if type(callback) == 'function' then pcall(callback) end;
	end;
};
local ASDFIUO = {
	TweenTextColor3 = function(self, ...)
		tweenColor3Property(self, "TextColor3", ...);	
	end
};
local PartMod = {
	TweenSize = function(self, newSize, tween, duration, Callback)
		local oa = self.Anchored;
		self.Anchored = true;
		self.FormFactor = "Custom"
		tween = tween and Tweens[tween:lower()] or Tweens.inOutQuad;
		duration = duration or 1;
		local t = 0;
		local start = self.Size;
		local diff = newSize - start;
		while t < duration do
			t = t+wait();
			local p = self.CFrame;
			self.Size = start + (diff*tween(t,0,1,duration));
			self.CFrame = p;
		end
		local p = self.CFrame;
		self.Size = newSize;
		self.CFrame = p;
		self.Anchored = oa;
		if type(Callback) == 'function' then pcall(Callback) end;
	end;
	TweenPosition = function(self, newPos, tween, duration, Callback)
		local oa = self.Anchored;
		self.Anchored = true;
		tween = tween and Tweens[tween:lower()] or Tweens.inOutQuad;
		duration = duration or 1;
		local t = 0;
		local start = self.Position;
		local diff = newPos-start;
		while t < duration do
			t = t+wait();
			local oc = self.CanCollide;
			self.CanCollide = false;
			self.Position = start + (diff*tween(t,0,1,duration));
			self.CanCollide = oc;
		end
		local oc = self.CanCollide;
		self.CanCollide = false;
		self.Position = newPos;
		self.CanCollide = oc;
		self.Anchored = oa;
		if type(Callback) == 'function' then pcall(Callback) end;
	end;
	TweenCFrame = function(self, NewCF, TweenType, TweenTime, Callback)
		local start = self.CFrame;
		local tween = TweenType and Tweens[TweenType:lower()] or Tweens.inOutQuad;
		TweenTime = TweenTime or 1;
		assert(type(NewCF) == 'CFrame', "You need to supply a valid CFrame to tween to!", 2);
		local t = 0;
		while t < TweenTime do
			self.CFrame = start:Lerp(NewCF,tween(t,0,1,TweenTime));
			t = t+wait()
		end
		self.CFrame = NewCF;
		if type(Callback) == 'function' then pcall(Callback) end;
	end
}

return function(wrapper)
	wrapper:Override "Color3" {
		__index = function(t,k)
			if t[k] then return t[k] end;
			if k == "Hex" then
				return "#"..getHex(t.r*255)..getHex(t.g*255)..getHex(t.b*255)
			elseif k == "Lerp" then
				return c3lerp;
			end
		end;
		__add = c3add;
		__div = c3div;
		__pow = c3soft;
		__mul = c3mul;
		__sub = c3sub;
	};
	wrapper:OverrideGlobal "Color3" {
		new = function(...)
			local arr = {...}
			if #arr == 1 then
				if type(...) == 'string' then
					return Hex(...)
				elseif type(...) == 'table' then
					if (#arr[1]) == 3 then return new3(unpack(arr[1]));
					else return new3(arr[1].r or 0, arr[1].g or 0, arr[1].b or 0)
					end
				else
					error("Wrong arguments to Color3.new!",2)
				end
			elseif #arr ~= 0 and max(...) > 1 then
				local i = {};
				return new3(arr[1]/255,arr[2]/255,arr[3]/255)
			else
				return new3(...)
			end
		end;
		Red = Red;
		Pink = Pink;
		Purple = Purple;
		DeepPurple = DeepPurple;
		Indigo = Indigo;
		Blue = Blue;
		LightBlue = LightBlue;
		Cyan = Cyan;
		Teal = Teal;
		Green = Green;
		LightGreen = LightGreen;
		Lime = Lime;
		Yellow = Yellow;
		Amber = Amber;
		Orange = Orange;
		DeepOrange = DeepOrange;
		Brown = Brown;
		Grey = Grey;
		Gray = Grey;
		BlueGrey = BlueGrey;
		BlueGray = BlueGrey;
		Black = Black;
		White = White;
	};
	local ulist = wrapper.ulist.ref;
	local wlist = wrapper.wlist.ref;
	local colourwrap = wrapper {
		Red = Red;
		Pink = Pink;
		Purple = Purple;
		DeepPurple = DeepPurple;
		Indigo = Indigo;
		Blue = Blue;
		LightBlue = LightBlue;
		Cyan = Cyan;
		Teal = Teal;
		Green = Green;
		LightGreen = LightGreen;
		Lime = Lime;
		Yellow = Yellow;
		Amber = Amber;
		Orange = Orange;
		DeepOrange = DeepOrange;
		Brown = Brown;
		Grey = Grey;
		BlueGrey = BlueGrey;
	};
	local colourorigins = ulist[colourwrap];
	for k,v in next,colourorigins do
		local wrk = colourwrap[k];
		local pr = newproxy(true);
		wlist[v] = pr;
		wlist[pr] = pr;
		ulist[pr] = v[500];
		local mt = getmetatable(pr);
		mt.__index = function(_,n)
			return wrk[n];
		end;
		mt.__tostring = function(_)
			return k;
		end;
		mt.__metatable = "Locked: Valkyrie";
	end;
	
	local HSL = newproxy(true);
	do
		local HSL = getmetatable(HSL);
		HSL.__index = HSLI;
		HSL.__newindex = error;
		HSL.__tostring = function() return "HSL constructor" end
		HSL.__call = function(_,...) return HSLI.new(...) end;
		HSL.__metatable = "Locked Metatable: Valkyrie";
	end
	
	wrapper:OverrideGlobal "HSL" (HSL)
	
	wrapper:Override "Frame":Instance 			(GUIUO);
	wrapper:Override "ImageLabel":Instance 	(GUIUO);
	wrapper:Override "ImageButton":Instance (GUIUO);
	wrapper:Override "TextLabel":Instance 	(GUIUO);
	wrapper:Override "TextButton":Instance 	(GUIUO);
	wrapper:Override "TextBox":Instance 		(GUIUO);
	wrapper:Override "ImageLabel":Instance 	(IUO);
	wrapper:Override "ImageButton":Instance (IUO);
	wrapper:Override "TextLabel":Instance  	(ASDFIUO);
	wrapper:Override "TextButton":Instance	(ASDFIUO);
	wrapper:Override "TextBox":Instance 		(ASDFIUO);
	
	wrapper:OverrideGlobal "Tweens" (Tweens);
	wrapper:Override "Part":Instance (PartMod);
end;
