const steam = @import("steamworks");
const builtin = @import("builtin");
const std = @import("std");
const t = std.testing;
const win = builtin.os.tag == .windows;

extern "C" fn steam_callback_size(cb_id: c_int) callconv(.C) c_int;
extern "C" fn steam_callback_align(cb_id: c_int) callconv(.C) c_int;
extern "C" fn steam_callback_size_field(cb_id: c_int, field_number: c_int) callconv(.C) c_int;
extern "C" fn steam_callback_align_field(cb_id: c_int, field_number: c_int) callconv(.C) c_int;

pub const ValvePackingSentinel_t = struct {
    m_u32: u32 align(steam.StructPlatformPackSize),
    m_u64: u64 align(steam.StructPlatformPackSize),
    m_u16: u16 align(steam.StructPlatformPackSize),
    m_d: f64 align(steam.StructPlatformPackSize),
};

pub fn assert_callback_size(comptime id: comptime_int, comptime size: comptime_int) void {
    const T: type = get_callback_type(id);
    assert_type_size(T, size);
}

pub fn assert_type_size(comptime T: type, comptime size: comptime_int) void {
    if (@sizeOf(T) > 0 and @sizeOf(T) != size) {
        @compileLog(T, "Invalid size:", @sizeOf(T), "Desired size:", size);
    }
}

// const Error = error{ InvalidChar, IllegalCharacter, Overflow };

pub fn assert_offset(comptime T: type, comptime field: []const u8, offset: u32) void {
    if (@offsetOf(T, field) != offset) {
        @compileLog("Invalid offset, check the compiler logs", @offsetOf(T, field));
    }
}

pub const Error = error{ InvalidChar, IllegalCharacter, Overflow };

pub fn bytes_from_slice(slice: []const u8) []const u8 {
    @setEvalBranchQuota(10000);
    var bytes: [slice.len / 2]u8 = std.mem.zeroes([slice.len / 2]u8);
    for (slice, 0..) |char, index| {
        const shift: u3 = if (@rem(index, 2) == 0) 4 else 0;
        const pos: usize = @divFloor(index, 2);
        bytes[pos] = bytes[pos] | try charToInt(char) << shift;
    }
    return &bytes;
}

pub fn test_serializer(comptime value: anytype, comptime slice: []const u8) !void {
    const bytes: []const u8 = comptime bytes_from_slice(slice);
    comptime if (@sizeOf(@TypeOf(value)) > bytes.len) {
        @compileLog("Sizeof provided slice is not enough", @sizeOf(@TypeOf(value)), bytes.len, slice);
    };
    const from_slice_debug = comptime steam.from_slice_debug(@TypeOf(value), bytes);
    const from_slice = comptime steam.from_slice(@TypeOf(value), bytes);

    std.debug.print("{any}\n", .{from_slice});

    // ensure that both deserializers work the same regardless of alignment
    try t.expectEqualDeep(from_slice, from_slice_debug);

    // lastly compare against control value
    try t.expectEqualDeep(value, from_slice_debug);
}

fn charToInt(c: u8) !u8 {
    return switch (c) {
        '0'...'9' => c - '0',
        'A'...'F' => c - 'A' + 10,
        'a'...'f' => c - 'a' + 10,
        else => error.IllegalCharacter,
    };
}

const callbacks = [_]i32{ 101, 102, 103, 113, 117, 125, 143, 152, 154, 163, 164, 165, 166, 167, 168, 304, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351, 701, 702, 703, 704, 705, 714, 736, 738, 739, 502, 503, 504, 505, 506, 507, 509, 510, 512, 513, 515, 516, 5201, 5202, 5211, 5212, 5213, 5214, 5215, 5301, 5302, 5303, 5304, 5305, 5306, 1307, 1309, 1311, 1312, 1313, 1314, 1315, 1316, 1317, 1318, 1319, 1320, 1321, 1322, 1323, 1324, 1325, 1326, 1327, 1328, 1329, 1330, 1331, 1332, 1333, 1101, 1102, 1103, 1104, 1105, 1106, 1107, 1108, 1109, 1110, 1111, 1112, 1005, 1014, 1021, 1023, 1030, 1202, 1203, 1201, 2301, 2302, 4001, 4002, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4011, 4012, 4013, 4114, 2101, 2102, 2103, 2801, 2802, 2803, 2804, 3401, 3402, 3403, 3404, 3405, 3406, 3407, 3408, 3409, 3410, 3411, 3412, 3413, 3414, 3415, 3416, 3417, 3418, 3420, 3901, 3902, 4501, 4502, 4503, 4504, 4505, 4506, 4507, 4508, 4509, 4510, 4511, 4512, 4513, 4514, 4515, 4516, 4521, 4522, 4523, 4524, 4525, 4526, 4527, 4700, 4701, 4702, 4703, 4704, 4705, 4611, 4624, 5001, 5701, 5702, 5703, 1251, 1252, 1221, 1222, 1281, 201, 202, 203, 206, 115, 207, 208, 209, 210, 211, 1800, 1801 };

pub fn check_callbacks_sizes() !void {
    @setEvalBranchQuota(100000);
    inline for (callbacks) |cb_id| {
        const T = get_callback_type(cb_id);
        const expected_size = steam_callback_size(cb_id);
        const actual_size = @sizeOf(T);

        var print = false;

        std.debug.print("Checking {s}:\n", .{@typeName(T)});
        if (actual_size != expected_size) {
            std.debug.print("   size: C: {d}\tZig: {d}\n", .{ expected_size, actual_size });
            if (@sizeOf(T) > 0) {
                // try t.expectEqual(expected_size, @sizeOf(T));
            } else {
                std.debug.print("  IGNORED\n", .{});
            }
            print = true;
        }

        const expected_alignment = steam_callback_align(cb_id);
        const actual_alignment = @alignOf(T);
        if (expected_alignment != actual_alignment) {
            std.debug.print("  align: C: {d}\tZig: {d}\n", .{ expected_alignment, actual_alignment });
            if (@sizeOf(T) > 0) {
                // try t.expectEqual(expected_alignment, actual_alignment);
            } else {
                std.debug.print("  IGNORED\n", .{});
            }
            print = true;
        }

        if (print) {
            std.debug.print("  fields:\n", .{});
            inline for (@typeInfo(T).@"struct".fields, 0..) |field, i| {
                std.debug.print("    {s} align \tC: {d}\t Zig: {d}\n", .{ field.name, steam_callback_align_field(cb_id, @intCast(i)), field.alignment });
            }
        }
    }
}

pub fn get_callback_type(comptime id: comptime_int) type {
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
