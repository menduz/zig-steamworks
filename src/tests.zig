const steam = @import("steam.zig");
const std = @import("std");
const t = std.testing;

test {
    try test_serializer(
        steam.LobbyCreated_t{ .m_eResult = steam.EResult.k_EResultOK, .m_ulSteamIDLobby = 109775242231394386 },
        "0100000052b0554e00008601", // mac
    );

    try test_serializer(
        steam.LobbyCreated_t{ .m_eResult = steam.EResult.k_EResultOK, .m_ulSteamIDLobby = 7498452822249142752 },
        "01000000e0792f031ddb0f6800008601", // win
    );

    try test_serializer(
        steam.PersonaStateChange_t{ .m_ulSteamID = 76561197998998680, .m_nChangeFlags = 32 },
        "98044f020100100120000000", // mac
    );

    try test_serializer(
        steam.PersonaStateChange_t{ .m_ulSteamID = 76561199045870667, .m_nChangeFlags = 16 },
        "4b04b540010010011000000000000000", // win
    );

    try test_serializer(
        steam.LobbyEnter_t{ .m_ulSteamIDLobby = 109775242587369560, .m_rgfChatPermissions = 0, .m_bLocked = false, .m_EChatRoomEnterResponse = 1 },
        "58708d630000860100000000008113ba01000000", // mac
    );

    try test_serializer(
        steam.LobbyEnter_t{ .m_ulSteamIDLobby = 109775242663025437, .m_rgfChatPermissions = 0, .m_bLocked = false, .m_EChatRoomEnterResponse = 1 },
        "1ddb0f6800008601000000000000000001000000a4f7dc07", // win
    );

    try test_serializer(
        steam.LobbyEnter_t{ .m_ulSteamIDLobby = 109775242231394386, .m_rgfChatPermissions = 0, .m_bLocked = false, .m_EChatRoomEnterResponse = 1 },
        "52b0554e000086010000000000f5452f01000000", // mac
    );

    try test_serializer(
        steam.LobbyDataUpdate_t{ .m_ulSteamIDLobby = 109775242587369560, .m_ulSteamIDMember = 109775242587369560, .m_bSuccess = 1 },
        "58708d630000860158708d630000860101708d63", // mac
    );

    try test_serializer(
        steam.LobbyDataUpdate_t{ .m_ulSteamIDLobby = 109775242663025437, .m_ulSteamIDMember = 109775242663025437, .m_bSuccess = 1 },
        "1ddb0f68000086011ddb0f680000860101c0666e04001f00", // win
    );

    try test_serializer(
        steam.LobbyChatMsg_t{ .m_ulSteamIDLobby = 109775242587369560, .m_ulSteamIDUser = 76561197998998680, .m_eChatEntryType = 1, .m_iChatID = 0 },
        "58708d630000860198044f0201001001019b5a0a00000000",
    );
}

comptime {
    // mac, LobbyChatMsg_t f39f356300008601 98044f0201001001 01...... 01000000
    assert_offset(steam.LobbyChatMsg_t, "m_ulSteamIDLobby", 0);
    assert_offset(steam.LobbyChatMsg_t, "m_ulSteamIDUser", 8);
    assert_offset(steam.LobbyChatMsg_t, "m_eChatEntryType", 16);
    assert_offset(steam.LobbyChatMsg_t, "m_iChatID", 20);

    // mac, LobbyEnter_t c2d6696300008601 c2d66963 00...... 01......
    assert_offset(steam.LobbyEnter_t, "m_ulSteamIDLobby", 0);
    assert_offset(steam.LobbyEnter_t, "m_rgfChatPermissions", 8);
    assert_offset(steam.LobbyEnter_t, "m_bLocked", 12);
    assert_offset(steam.LobbyEnter_t, "m_EChatRoomEnterResponse", 16);

    assert_callback_size(101, 1); // "23SteamServersConnected_t",
    assert_callback_size(102, 8); // "27SteamServerConnectFailure_t",
    assert_callback_size(103, 4); // "26SteamServersDisconnected_t",
    assert_callback_size(113, 16); // "22ClientGameServerDeny_t",
    assert_callback_size(115, 1); // "18GSPolicyResponse_t",
    assert_callback_size(125, 1); // "17LicensesUpdated_t",
    assert_callback_size(143, 20); // "28ValidateAuthTicketResponse_t",
    assert_callback_size(164, 256); // "Unknown",
    assert_callback_size(167, 32); // "Unknown",
    assert_callback_size(201, 16); // "17GSClientApprove_t",
    assert_callback_size(202, 140); // "14GSClientDeny_t",
    assert_callback_size(203, 12); // "14GSClientKick_t",
    // assert_callback_size(204, 8); // "20GSClientSteam2Deny_t",
    // assert_callback_size(205, 12); // "22GSClientSteam2Accept_t",
    assert_callback_size(206, 140); // "27GSClientAchievementStatus_t",
    assert_callback_size(207, 16); // "17GSGameplayStats_t",
    assert_callback_size(208, 18); // "21GSClientGroupStatus_t",
    assert_callback_size(211, 24); // "37ComputeNewPlayerCompatibilityResult_t",
    assert_callback_size(304, 12); // "20PersonaStateChange_t",
    assert_callback_size(331, 8); // "22GameOverlayActivated_t",
    assert_callback_size(333, 16); // "Unknown",
    assert_callback_size(334, 20); // "19AvatarImageLoaded_t",
    assert_callback_size(336, 12); // "26FriendRichPresenceUpdate_t",
    assert_callback_size(337, 264); // "Unknown",
    assert_callback_size(338, 20); // "Unknown",
    assert_callback_size(339, 16); // "Unknown",
    assert_callback_size(340, 18); // "Unknown",
    assert_callback_size(348, 1); // "27UnreadChatMessagesChanged_t",
    assert_callback_size(349, 1024); // "Unknown",
    assert_callback_size(350, 8); // "29EquippedProfileItemsChanged_t",

    // assert_callback_size(351, 20); // "22EquippedProfileItems_t", NOT present in steam.h

    assert_callback_size(502, 28); // "22FavoritesListChanged_t",
    assert_callback_size(503, 24); // "13LobbyInvite_t",
    assert_callback_size(504, 20); // "12LobbyEnter_t",
    assert_callback_size(505, 20); // "17LobbyDataUpdate_t",
    assert_callback_size(506, 28); // "17LobbyChatUpdate_t",
    assert_callback_size(507, 24); // "14LobbyChatMsg_t",
    assert_callback_size(509, 24); // "Unknown",
    assert_callback_size(510, 4); // "16LobbyMatchList_t",
    assert_callback_size(512, 20); // "13LobbyKicked_t",
    assert_callback_size(513, 12); // "14LobbyCreated_t",
    assert_callback_size(701, 1); // "11IPCountry_t",
    assert_callback_size(702, 1); // "Unknown",
    assert_callback_size(736, 1); // "Unknown",
    assert_callback_size(738, 1); // "Unknown",
    assert_callback_size(739, 4); // "Unknown",
    assert_callback_size(1014, 1); // "Unknown",
    assert_callback_size(1030, 16); // "18TimedTrialStatus_t",
    assert_callback_size(1101, 20); // "19UserStatsReceived_t",
    assert_callback_size(1102, 12); // "Unknown",
    assert_callback_size(1103, 148); // "23UserAchievementStored_t",
    assert_callback_size(1108, 8); // "Unknown",
    assert_callback_size(1109, 144); // "28UserAchievementIconFetched_t",
    assert_callback_size(1201, 20); // "22SocketStatusCallback_t",
    assert_callback_size(1202, 8); // "Unknown",
    assert_callback_size(1203, 9); // "Unknown",
    assert_callback_size(1309, 16); // "32RemoteStoragePublishFileResult_t",
    assert_callback_size(1316, 16); // "40RemoteStorageUpdatePublishedFileResult_t",
    assert_callback_size(1321, 12); // "38RemoteStoragePublishedFileSubscribed_t",
    assert_callback_size(1322, 12); // "40RemoteStoragePublishedFileUnsubscribed_t",
    assert_callback_size(1323, 12); // "35RemoteStoragePublishedFileDeleted_t",
    assert_callback_size(1329, 12); // "Unknown",
    assert_callback_size(1330, 20); // "Unknown",
    assert_callback_size(1800, 12); // "17GSStatsReceived_t",
    assert_callback_size(2102, 12); // "28HTTPRequestHeadersReceived_t",
    assert_callback_size(2103, 20); // "25HTTPRequestDataReceived_t",
    assert_callback_size(2301, 8); // "Unknown",
    assert_callback_size(2302, 1); // "Unknown",
    assert_callback_size(2801, 8); // "Unknown",
    assert_callback_size(2802, 8); // "Unknown",
    assert_callback_size(2803, 32); // "Unknown",
    assert_callback_size(2804, 24); // "Unknown",
    assert_callback_size(3405, 12); // "15ItemInstalled_t",
    assert_callback_size(3418, 4); // "32UserSubscribedItemsListChanged_t",
    assert_callback_size(3901, 8); // "Unknown",
    assert_callback_size(3902, 8); // "Unknown",
    assert_callback_size(4001, 1); // "PlaybackStatusHasChanged_t",
    assert_callback_size(4002, 4); // "VolumeHasChanged_t",
    assert_callback_size(4105, 1); // "MusicPlayerWantsPlay_t",
    assert_callback_size(4106, 1); // "MusicPlayerWantsPause_t",
    assert_callback_size(4107, 1); // "MusicPlayerWantsPlayPrevious_t",
    assert_callback_size(4108, 1); // "MusicPlayerWantsPlayNext_t",
    assert_callback_size(4611, 264); // "GetVideoURLResult_t",
    assert_callback_size(4624, 8); // "GetOPFSettingsResult_t",
    assert_callback_size(4700, 8); // "27SteamInventoryResultReady_t",
    assert_callback_size(4701, 4); // "26SteamInventoryFullUpdate_t",
    assert_callback_size(4702, 1); // "Unknown",
    assert_callback_size(5001, 1); // "30SteamParentalSettingsChanged_t",
    assert_callback_size(5201, 36); // "31SearchForGameProgressCallback_t",
    assert_callback_size(5202, 32); // "29SearchForGameResultCallback_t",
    assert_callback_size(5211, 12); // "39RequestPlayersForGameProgressCallback_t",
    assert_callback_size(5212, 56); //RequestPlayersForGameResultCallback_t
    assert_callback_size(5213, 20); // steam.RequestPlayersForGameFinalResultCallback_t
    assert_callback_size(5305, 1); // steam.AvailableBeaconLocationsUpdated_t
    assert_callback_size(5306, 1); // steam.ActiveBeaconsUpdated_t
    assert_callback_size(5701, 4); // steam.SteamRemotePlaySessionConnected_t
    assert_callback_size(5702, 4); // steam.SteamRemotePlaySessionDisconnected_t
    assert_callback_size(5703, 1024); // steam.SteamRemotePlayTogetherGuestInvite_t
}

fn assert_callback_size(comptime id: comptime_int, comptime size: comptime_int) void {
    const T: type = get_callback_type(id);

    if (@sizeOf(T) > 0 and @sizeOf(T) != size) {
        @compileLog(T, "Invalid size:", @sizeOf(T), "Desired size:", size);
    }
}

// const Error = error{ InvalidChar, IllegalCharacter, Overflow };

fn assert_offset(comptime T: type, comptime field: []const u8, offset: u32) void {
    if (@offsetOf(T, field) != offset) {
        @compileLog(@offsetOf(T, field));
        @compileError("Invalid offset, check the compiler logs");
    }
}

const Error = error{ InvalidChar, IllegalCharacter, Overflow };

fn test_serializer(value: anytype, comptime slice: []const u8) !void {
    var bytes: [slice.len / 2]u8 = std.mem.zeroes([slice.len / 2]u8);
    for (slice, 0..) |char, index| {
        var shift: u3 = if (@rem(index, 2) == 0) 4 else 0;
        var pos: usize = @divFloor(index, 2);
        bytes[pos] = bytes[pos] | try charToInt(char) << shift;
    }

    // ensure that both deserializers work the same regardless of alignment
    try t.expectEqualDeep(
        steam.from_slice(@TypeOf(value), &bytes),
        steam.from_slice_debug(@TypeOf(value), &bytes),
    );

    // lastly compare against control value
    try t.expectEqualDeep(value, steam.from_slice_debug(@TypeOf(value), &bytes));
}

fn charToInt(c: u8) !u8 {
    return switch (c) {
        '0'...'9' => c - '0',
        'A'...'F' => c - 'A' + 10,
        'a'...'f' => c - 'a' + 10,
        else => error.IllegalCharacter,
    };
}

fn get_callback_type(comptime id: comptime_int) type {
    return switch (id) {
        101 => steam.SteamServersConnected_t,
        102 => steam.SteamServerConnectFailure_t,
        103 => steam.SteamServersDisconnected_t,
        113 => steam.ClientGameServerDeny_t,
        117 => steam.IPCFailure_t,
        125 => steam.LicensesUpdated_t,
        143 => steam.ValidateAuthTicketResponse_t,
        152 => steam.MicroTxnAuthorizationResponse_t,
        154 => steam.EncryptedAppTicketResponse_t,
        163 => steam.GetAuthSessionTicketResponse_t,
        164 => steam.GameWebCallback_t,
        165 => steam.StoreAuthURLResponse_t,
        166 => steam.MarketEligibilityResponse_t,
        167 => steam.DurationControl_t,
        168 => steam.GetTicketForWebApiResponse_t,
        304 => steam.PersonaStateChange_t,
        331 => steam.GameOverlayActivated_t,
        332 => steam.GameServerChangeRequested_t,
        333 => steam.GameLobbyJoinRequested_t,
        334 => steam.AvatarImageLoaded_t,
        335 => steam.ClanOfficerListResponse_t,
        336 => steam.FriendRichPresenceUpdate_t,
        337 => steam.GameRichPresenceJoinRequested_t,
        338 => steam.GameConnectedClanChatMsg_t,
        339 => steam.GameConnectedChatJoin_t,
        340 => steam.GameConnectedChatLeave_t,
        341 => steam.DownloadClanActivityCountsResult_t,
        342 => steam.JoinClanChatRoomCompletionResult_t,
        343 => steam.GameConnectedFriendChatMsg_t,
        344 => steam.FriendsGetFollowerCount_t,
        345 => steam.FriendsIsFollowing_t,
        346 => steam.FriendsEnumerateFollowingList_t,
        347 => steam.SetPersonaNameResponse_t,
        348 => steam.UnreadChatMessagesChanged_t,
        349 => steam.OverlayBrowserProtocolNavigation_t,
        350 => steam.EquippedProfileItemsChanged_t,
        351 => steam.EquippedProfileItems_t,
        701 => steam.IPCountry_t,
        702 => steam.LowBatteryPower_t,
        703 => steam.SteamAPICallCompleted_t,
        704 => steam.SteamShutdown_t,
        705 => steam.CheckFileSignature_t,
        714 => steam.GamepadTextInputDismissed_t,
        736 => steam.AppResumingFromSuspend_t,
        738 => steam.FloatingGamepadTextInputDismissed_t,
        739 => steam.FilterTextDictionaryChanged_t,
        502 => steam.FavoritesListChanged_t,
        503 => steam.LobbyInvite_t,
        504 => steam.LobbyEnter_t,
        505 => steam.LobbyDataUpdate_t,
        506 => steam.LobbyChatUpdate_t,
        507 => steam.LobbyChatMsg_t,
        509 => steam.LobbyGameCreated_t,
        510 => steam.LobbyMatchList_t,
        512 => steam.LobbyKicked_t,
        513 => steam.LobbyCreated_t,
        515 => steam.PSNGameBootInviteResult_t,
        516 => steam.FavoritesListAccountsUpdated_t,
        5201 => steam.SearchForGameProgressCallback_t,
        5202 => steam.SearchForGameResultCallback_t,
        5211 => steam.RequestPlayersForGameProgressCallback_t,
        5212 => steam.RequestPlayersForGameResultCallback_t,
        5213 => steam.RequestPlayersForGameFinalResultCallback_t,
        5214 => steam.SubmitPlayerResultResultCallback_t,
        5215 => steam.EndGameResultCallback_t,
        5301 => steam.JoinPartyCallback_t,
        5302 => steam.CreateBeaconCallback_t,
        5303 => steam.ReservationNotificationCallback_t,
        5304 => steam.ChangeNumOpenSlotsCallback_t,
        5305 => steam.AvailableBeaconLocationsUpdated_t,
        5306 => steam.ActiveBeaconsUpdated_t,
        1307 => steam.RemoteStorageFileShareResult_t,
        1309 => steam.RemoteStoragePublishFileResult_t,
        1311 => steam.RemoteStorageDeletePublishedFileResult_t,
        1312 => steam.RemoteStorageEnumerateUserPublishedFilesResult_t,
        1313 => steam.RemoteStorageSubscribePublishedFileResult_t,
        1314 => steam.RemoteStorageEnumerateUserSubscribedFilesResult_t,
        1315 => steam.RemoteStorageUnsubscribePublishedFileResult_t,
        1316 => steam.RemoteStorageUpdatePublishedFileResult_t,
        1317 => steam.RemoteStorageDownloadUGCResult_t,
        1318 => steam.RemoteStorageGetPublishedFileDetailsResult_t,
        1319 => steam.RemoteStorageEnumerateWorkshopFilesResult_t,
        1320 => steam.RemoteStorageGetPublishedItemVoteDetailsResult_t,
        1321 => steam.RemoteStoragePublishedFileSubscribed_t,
        1322 => steam.RemoteStoragePublishedFileUnsubscribed_t,
        1323 => steam.RemoteStoragePublishedFileDeleted_t,
        1324 => steam.RemoteStorageUpdateUserPublishedItemVoteResult_t,
        1325 => steam.RemoteStorageUserVoteDetails_t,
        1326 => steam.RemoteStorageEnumerateUserSharedWorkshopFilesResult_t,
        1327 => steam.RemoteStorageSetUserPublishedFileActionResult_t,
        1328 => steam.RemoteStorageEnumeratePublishedFilesByUserActionResult_t,
        1329 => steam.RemoteStoragePublishFileProgress_t,
        1330 => steam.RemoteStoragePublishedFileUpdated_t,
        1331 => steam.RemoteStorageFileWriteAsyncComplete_t,
        1332 => steam.RemoteStorageFileReadAsyncComplete_t,
        1333 => steam.RemoteStorageLocalFileChange_t,
        1101 => steam.UserStatsReceived_t,
        1102 => steam.UserStatsStored_t,
        1103 => steam.UserAchievementStored_t,
        1104 => steam.LeaderboardFindResult_t,
        1105 => steam.LeaderboardScoresDownloaded_t,
        1106 => steam.LeaderboardScoreUploaded_t,
        1107 => steam.NumberOfCurrentPlayers_t,
        1108 => steam.UserStatsUnloaded_t,
        1109 => steam.UserAchievementIconFetched_t,
        1110 => steam.GlobalAchievementPercentagesReady_t,
        1111 => steam.LeaderboardUGCSet_t,
        1112 => steam.GlobalStatsReceived_t,
        1005 => steam.DlcInstalled_t,
        1014 => steam.NewUrlLaunchParameters_t,
        1021 => steam.AppProofOfPurchaseKeyResponse_t,
        1023 => steam.FileDetailsResult_t,
        1030 => steam.TimedTrialStatus_t,
        1202 => steam.P2PSessionRequest_t,
        1203 => steam.P2PSessionConnectFail_t,
        1201 => steam.SocketStatusCallback_t,
        2301 => steam.ScreenshotReady_t,
        2302 => steam.ScreenshotRequested_t,
        4001 => steam.PlaybackStatusHasChanged_t,
        4002 => steam.VolumeHasChanged_t,
        4101 => steam.MusicPlayerRemoteWillActivate_t,
        4102 => steam.MusicPlayerRemoteWillDeactivate_t,
        4103 => steam.MusicPlayerRemoteToFront_t,
        4104 => steam.MusicPlayerWillQuit_t,
        4105 => steam.MusicPlayerWantsPlay_t,
        4106 => steam.MusicPlayerWantsPause_t,
        4107 => steam.MusicPlayerWantsPlayPrevious_t,
        4108 => steam.MusicPlayerWantsPlayNext_t,
        4109 => steam.MusicPlayerWantsShuffled_t,
        4110 => steam.MusicPlayerWantsLooped_t,
        4011 => steam.MusicPlayerWantsVolume_t,
        4012 => steam.MusicPlayerSelectsQueueEntry_t,
        4013 => steam.MusicPlayerSelectsPlaylistEntry_t,
        4114 => steam.MusicPlayerWantsPlayingRepeatStatus_t,
        2101 => steam.HTTPRequestCompleted_t,
        2102 => steam.HTTPRequestHeadersReceived_t,
        2103 => steam.HTTPRequestDataReceived_t,
        2801 => steam.SteamInputDeviceConnected_t,
        2802 => steam.SteamInputDeviceDisconnected_t,
        2803 => steam.SteamInputConfigurationLoaded_t,
        2804 => steam.SteamInputGamepadSlotChange_t,
        3401 => steam.SteamUGCQueryCompleted_t,
        3402 => steam.SteamUGCRequestUGCDetailsResult_t,
        3403 => steam.CreateItemResult_t,
        3404 => steam.SubmitItemUpdateResult_t,
        3405 => steam.ItemInstalled_t,
        3406 => steam.DownloadItemResult_t,
        3407 => steam.UserFavoriteItemsListChanged_t,
        3408 => steam.SetUserItemVoteResult_t,
        3409 => steam.GetUserItemVoteResult_t,
        3410 => steam.StartPlaytimeTrackingResult_t,
        3411 => steam.StopPlaytimeTrackingResult_t,
        3412 => steam.AddUGCDependencyResult_t,
        3413 => steam.RemoveUGCDependencyResult_t,
        3414 => steam.AddAppDependencyResult_t,
        3415 => steam.RemoveAppDependencyResult_t,
        3416 => steam.GetAppDependenciesResult_t,
        3417 => steam.DeleteItemResult_t,
        3418 => steam.UserSubscribedItemsListChanged_t,
        3420 => steam.WorkshopEULAStatus_t,
        3901 => steam.SteamAppInstalled_t,
        3902 => steam.SteamAppUninstalled_t,
        4501 => steam.HTML_BrowserReady_t,
        4502 => steam.HTML_NeedsPaint_t,
        4503 => steam.HTML_StartRequest_t,
        4504 => steam.HTML_CloseBrowser_t,
        4505 => steam.HTML_URLChanged_t,
        4506 => steam.HTML_FinishedRequest_t,
        4507 => steam.HTML_OpenLinkInNewTab_t,
        4508 => steam.HTML_ChangedTitle_t,
        4509 => steam.HTML_SearchResults_t,
        4510 => steam.HTML_CanGoBackAndForward_t,
        4511 => steam.HTML_HorizontalScroll_t,
        4512 => steam.HTML_VerticalScroll_t,
        4513 => steam.HTML_LinkAtPosition_t,
        4514 => steam.HTML_JSAlert_t,
        4515 => steam.HTML_JSConfirm_t,
        4516 => steam.HTML_FileOpenDialog_t,
        4521 => steam.HTML_NewWindow_t,
        4522 => steam.HTML_SetCursor_t,
        4523 => steam.HTML_StatusText_t,
        4524 => steam.HTML_ShowToolTip_t,
        4525 => steam.HTML_UpdateToolTip_t,
        4526 => steam.HTML_HideToolTip_t,
        4527 => steam.HTML_BrowserRestarted_t,
        4700 => steam.SteamInventoryResultReady_t,
        4701 => steam.SteamInventoryFullUpdate_t,
        4702 => steam.SteamInventoryDefinitionUpdate_t,
        4703 => steam.SteamInventoryEligiblePromoItemDefIDs_t,
        4704 => steam.SteamInventoryStartPurchaseResult_t,
        4705 => steam.SteamInventoryRequestPricesResult_t,
        4611 => steam.GetVideoURLResult_t,
        4624 => steam.GetOPFSettingsResult_t,
        5001 => steam.SteamParentalSettingsChanged_t,
        5701 => steam.SteamRemotePlaySessionConnected_t,
        5702 => steam.SteamRemotePlaySessionDisconnected_t,
        5703 => steam.SteamRemotePlayTogetherGuestInvite_t,
        1251 => steam.SteamNetworkingMessagesSessionRequest_t,
        1252 => steam.SteamNetworkingMessagesSessionFailed_t,
        1221 => steam.SteamNetConnectionStatusChangedCallback_t,
        1222 => steam.SteamNetAuthenticationStatus_t,
        1281 => steam.SteamRelayNetworkStatus_t,
        201 => steam.GSClientApprove_t,
        202 => steam.GSClientDeny_t,
        203 => steam.GSClientKick_t,
        206 => steam.GSClientAchievementStatus_t,
        115 => steam.GSPolicyResponse_t,
        207 => steam.GSGameplayStats_t,
        208 => steam.GSClientGroupStatus_t,
        209 => steam.GSReputation_t,
        210 => steam.AssociateWithClanResult_t,
        211 => steam.ComputeNewPlayerCompatibilityResult_t,
        1800 => steam.GSStatsReceived_t,
        1801 => steam.GSStatsStored_t,
        1223 => steam.SteamNetworkingFakeIPResult_t,
        else => @compileError("unknown callback id"),
    };
}
