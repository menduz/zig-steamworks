const steam = @import("steamworks");
const builtin = @import("builtin");
const std = @import("std");
const t = std.testing;
const win = builtin.os.tag == .windows;

const u = @import("tests-utils.zig");

comptime {
    u.assert_type_size(u.ValvePackingSentinel_t, 24);
    u.assert_type_size(steam.RemoteStorageEnumerateUserSubscribedFilesResult_t, (1 + 1 + 1 + 50 + 100) * 4);
}

test "process declarations recursively" {
    std.testing.refAllDeclsRecursive(steam);
}

test {
    try u.check_callbacks_sizes();

    try u.test_serializer(
        steam.SteamNetConnectionStatusChangedCallback_t{
            .m_hConn = 3659469708,
            .m_info = steam.SteamNetConnectionInfo_t{
                .m_identityRemote = steam.SteamNetworkingIdentity{
                    .m_eType = steam.ESteamNetworkingIdentityType.k_ESteamNetworkingIdentityType_SteamID,
                    .m_cbSize = 8,
                    .m_szUnknownRawString = [_]u8{ 0, 0, 0, 0, 0, 0, 64, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
                },
                .m_nUserData = -1,
                .m_hListenSocket = 0,
                .m_addrRemote = steam.SteamNetworkingIPAddr{ .m_ipv6 = [_]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, .m_port = 0 },
                .m__pad1 = 0,
                .m_idPOPRemote = 0,
                .m_idPOPRelay = 0,
                .m_eState = steam.ESteamNetworkingConnectionState.k_ESteamNetworkingConnectionState_Connecting,
                .m_eEndReason = 0,
                .m_szEndDebug = [_]u8{0} ** 128,
                .m_szConnectionDescription = [_]u8{ 35, 51, 54, 53, 57, 52, 54, 57, 55, 48, 56, 32, 80, 50, 80, 32, 115, 116, 101, 97, 109, 105, 100, 58, 57, 48, 48, 55, 49, 57, 57, 50, 53, 52, 55, 52, 48, 57, 57, 50, 48, 32, 118, 112, 111, 114, 116, 32, 48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
                .m_nFlags = 3,
                .reserved = [_]u32{0} ** 63,
            },
            .m_eOldState = steam.ESteamNetworkingConnectionState.k_ESteamNetworkingConnectionState_None,
        },
        "8c131fda10000000080000000000000000004001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000023333635393436393730382050325020737465616d69643a39303037313939323534373430393932302076706f72742030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", // mac
    );
    // 8c131fda1        0000000080000000000000000004001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000023333635393436393730382050325020737465616d69643a39303037313939323534373430393932302076706f72742030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    // 7a117d170202000010000000080000000000000000004001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffff000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000233339343037323434322050325020737465616d69643a39303037313939323534373430393932302076706f727420300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020000

    try u.test_serializer(
        steam.LobbyEnter_t{ .m_ulSteamIDLobby = 109775242587369560, .m_rgfChatPermissions = 0, .m_bLocked = false, .m_EChatRoomEnterResponse = 1 },
        "58708d630000860100000000008113ba01000000", // mac
    );

    try u.test_serializer(
        steam.LobbyEnter_t{ .m_ulSteamIDLobby = 109775242231394386, .m_rgfChatPermissions = 0, .m_bLocked = false, .m_EChatRoomEnterResponse = 1 },
        "52b0554e000086010000000000f5452f01000000", // mac
    );

    try u.test_serializer(
        steam.LobbyDataUpdate_t{ .m_ulSteamIDLobby = 109775242587369560, .m_ulSteamIDMember = 109775242587369560, .m_bSuccess = true },
        "58708d630000860158708d630000860101708d63", // mac
    );

    try u.test_serializer(
        steam.LobbyChatMsg_t{ .m_ulSteamIDLobby = 109775242587369560, .m_ulSteamIDUser = 76561197998998680, .m_eChatEntryType = 1, .m_iChatID = 0 },
        "58708d630000860198044f0201001001019b5a0a00000000",
    );

    try u.test_serializer(
        steam.LobbyCreated_t{ .m_eResult = steam.EResult.k_EResultOK, .m_ulSteamIDLobby = 109775242231394386 },
        "0100000052b0554e00008601", // mac
    );

    try u.test_serializer(
        steam.PersonaStateChange_t{ .m_ulSteamID = 76561197998998680, .m_nChangeFlags = 32 },
        "98044f020100100120000000", // mac
    );

    try u.test_serializer(
        steam.SteamRelayNetworkStatus_t{
            .m_eAvail = steam.ESteamNetworkingAvailability.k_ESteamNetworkingAvailability_Current,
            .m_bPingMeasurementInProgress = false,
            .m_eAvailNetworkConfig = steam.ESteamNetworkingAvailability.k_ESteamNetworkingAvailability_Current,
            .m_eAvailAnyRelay = steam.ESteamNetworkingAvailability.k_ESteamNetworkingAvailability_Current,
            .m_debugMsg = [_]u8{ 79, 75, 0, 102, 111, 114, 109, 105, 110, 103, 32, 112, 105, 110, 103, 32, 109, 101, 97, 115, 117, 114, 101, 109, 101, 110, 116, 0, 114, 111, 109, 32, 104, 116, 116, 112, 115, 58, 47, 47, 97, 112, 105, 46, 115, 116, 101, 97, 109, 112, 111, 119, 101, 114, 101, 100, 46, 99, 111, 109, 47, 73, 83, 116, 101, 97, 109, 65, 112, 112, 115, 47, 71, 101, 116, 83, 68, 82, 67, 111, 110, 102, 105, 103, 47, 118, 49, 63, 97, 112, 112, 105, 100, 61, 49, 52, 49, 49, 55, 50, 48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        },
        "640000000000000064000000640000004f4b00666f726d696e672070696e67206d6561737572656d656e7400726f6d2068747470733a2f2f6170692e737465616d706f77657265642e636f6d2f49537465616d417070732f476574534452436f6e6669672f76313f61707069643d313431313732300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", // mac
    );
}

comptime {
    // mac, LobbyChatMsg_t f39f356300008601 98044f0201001001 01...... 01000000
    u.assert_offset(steam.LobbyChatMsg_t, "m_ulSteamIDLobby", 0);
    u.assert_offset(steam.LobbyChatMsg_t, "m_ulSteamIDUser", 8);
    u.assert_offset(steam.LobbyChatMsg_t, "m_eChatEntryType", 16);
    u.assert_offset(steam.LobbyChatMsg_t, "m_iChatID", 20);

    // mac, LobbyEnter_t c2d6696300008601 c2d66963 00...... 01......
    u.assert_offset(steam.LobbyEnter_t, "m_ulSteamIDLobby", 0);
    u.assert_offset(steam.LobbyEnter_t, "m_rgfChatPermissions", 8);
    u.assert_offset(steam.LobbyEnter_t, "m_bLocked", 12);
    u.assert_offset(steam.LobbyEnter_t, "m_EChatRoomEnterResponse", 16);

    u.assert_type_size(steam.SteamNetworkingIPAddr, 18);
    u.assert_type_size(steam.SteamNetworkingIdentity, 136);
    u.assert_type_size(steam.SteamNetConnectionInfo_t, 696);
    u.assert_type_size(steam.SteamNetworkPingLocation_t, 512);

    // u.assert_callback_size(101, 1); // "23SteamServersConnected_t",
    // u.assert_callback_size(102, 8); // "27SteamServerConnectFailure_t",
    // u.assert_callback_size(103, 4); // "26SteamServersDisconnected_t",
    // u.assert_callback_size(113, 16); // "22ClientGameServerDeny_t",
    // u.assert_callback_size(115, 1); // "18GSPolicyResponse_t",
    // u.assert_callback_size(125, 1); // "17LicensesUpdated_t",
    // u.assert_callback_size(143, 20); // "28ValidateAuthTicketResponse_t",
    // u.assert_callback_size(164, 256); // "Unknown",
    // u.assert_callback_size(167, 32); // "Unknown",
    // u.assert_callback_size(201, 16); // "17GSClientApprove_t",
    // u.assert_callback_size(202, 140); // "14GSClientDeny_t",
    // u.assert_callback_size(203, 12); // "14GSClientKick_t",
    // // u.assert_callback_size(204, 8); // "20GSClientSteam2Deny_t",
    // // u.assert_callback_size(205, 12); // "22GSClientSteam2Accept_t",
    // u.assert_callback_size(206, 140); // "27GSClientAchievementStatus_t",
    // u.assert_callback_size(207, 16); // "17GSGameplayStats_t",
    // u.assert_callback_size(208, 18); // "21GSClientGroupStatus_t",
    // u.assert_callback_size(211, 24); // "37ComputeNewPlayerCompatibilityResult_t",
    // u.assert_callback_size(304, 12); // "20PersonaStateChange_t",
    // u.assert_callback_size(331, 8); // "22GameOverlayActivated_t",
    // u.assert_callback_size(333, 16); // "Unknown",
    // u.assert_callback_size(334, 20); // "19AvatarImageLoaded_t",
    // u.assert_callback_size(336, 12); // "26FriendRichPresenceUpdate_t",
    // u.assert_callback_size(337, 264); // "Unknown",
    // u.assert_callback_size(338, 20); // "Unknown",
    // u.assert_callback_size(339, 16); // "Unknown",
    // u.assert_callback_size(340, 18); // "Unknown",
    // u.assert_callback_size(348, 1); // "27UnreadChatMessagesChanged_t",
    // u.assert_callback_size(349, 1024); // "Unknown",
    // u.assert_callback_size(350, 8); // "29EquippedProfileItemsChanged_t",

    // // u.assert_callback_size(351, 20); // "22EquippedProfileItems_t", NOT present in steam.h

    // u.assert_callback_size(502, 28); // "22FavoritesListChanged_t",
    // u.assert_callback_size(503, 24); // "13LobbyInvite_t",
    // u.assert_callback_size(504, 20); // "12LobbyEnter_t",
    // u.assert_callback_size(505, 20); // "17LobbyDataUpdate_t",
    // u.assert_callback_size(506, 28); // "17LobbyChatUpdate_t",
    // u.assert_callback_size(507, 24); // "14LobbyChatMsg_t",
    // u.assert_callback_size(509, 24); // "Unknown",
    // u.assert_callback_size(510, 4); // "16LobbyMatchList_t",
    // u.assert_callback_size(512, 20); // "13LobbyKicked_t",
    // u.assert_callback_size(513, 12); // "14LobbyCreated_t",
    // u.assert_callback_size(701, 1); // "11IPCountry_t",
    // u.assert_callback_size(702, 1); // "Unknown",
    // u.assert_callback_size(736, 1); // "Unknown",
    // u.assert_callback_size(738, 1); // "Unknown",
    // u.assert_callback_size(739, 4); // "Unknown",
    // u.assert_callback_size(1014, 1); // "Unknown",
    // u.assert_callback_size(1030, 16); // "18TimedTrialStatus_t",
    // u.assert_callback_size(1101, 20); // "19UserStatsReceived_t",
    // u.assert_callback_size(1102, 12); // "Unknown",
    // u.assert_callback_size(1103, 148); // "23UserAchievementStored_t",
    // u.assert_callback_size(1108, 8); // "Unknown",
    // u.assert_callback_size(1109, 144); // "28UserAchievementIconFetched_t",
    // u.assert_callback_size(1201, 20); // "22SocketStatusCallback_t",
    // u.assert_callback_size(1202, 8); // "Unknown",
    // u.assert_callback_size(1203, 9); // "Unknown",
    // u.assert_callback_size(1309, 16); // "32RemoteStoragePublishFileResult_t",
    // u.assert_callback_size(1316, 16); // "40RemoteStorageUpdatePublishedFileResult_t",
    // u.assert_callback_size(1321, 12); // "38RemoteStoragePublishedFileSubscribed_t",
    // u.assert_callback_size(1322, 12); // "40RemoteStoragePublishedFileUnsubscribed_t",
    // u.assert_callback_size(1323, 12); // "35RemoteStoragePublishedFileDeleted_t",
    // u.assert_callback_size(1329, 12); // "Unknown",
    // u.assert_callback_size(1330, 20); // "Unknown",
    // u.assert_callback_size(1800, 12); // "17GSStatsReceived_t",
    // u.assert_callback_size(2102, 12); // "28HTTPRequestHeadersReceived_t",
    // u.assert_callback_size(2103, 20); // "25HTTPRequestDataReceived_t",
    // u.assert_callback_size(2301, 8); // "Unknown",
    // u.assert_callback_size(2302, 1); // "Unknown",
    // u.assert_callback_size(2801, 8); // "Unknown",
    // u.assert_callback_size(2802, 8); // "Unknown",
    // u.assert_callback_size(2803, 32); // "Unknown",
    // u.assert_callback_size(2804, 24); // "Unknown",
    // u.assert_callback_size(3405, 12); // "15ItemInstalled_t",
    // u.assert_callback_size(3418, 4); // "32UserSubscribedItemsListChanged_t",
    // u.assert_callback_size(3901, 8); // "Unknown",
    // u.assert_callback_size(3902, 8); // "Unknown",
    // u.assert_callback_size(4001, 1); // "PlaybackStatusHasChanged_t",
    // u.assert_callback_size(4002, 4); // "VolumeHasChanged_t",
    // u.assert_callback_size(4105, 1); // "MusicPlayerWantsPlay_t",
    // u.assert_callback_size(4106, 1); // "MusicPlayerWantsPause_t",
    // u.assert_callback_size(4107, 1); // "MusicPlayerWantsPlayPrevious_t",
    // u.assert_callback_size(4108, 1); // "MusicPlayerWantsPlayNext_t",
    // u.assert_callback_size(4611, 264); // "GetVideoURLResult_t",
    // u.assert_callback_size(4624, 8); // "GetOPFSettingsResult_t",
    // u.assert_callback_size(4700, 8); // "27SteamInventoryResultReady_t",
    // u.assert_callback_size(4701, 4); // "26SteamInventoryFullUpdate_t",
    // u.assert_callback_size(4702, 1); // "Unknown",
    // u.assert_callback_size(5001, 1); // "30SteamParentalSettingsChanged_t",
    // u.assert_callback_size(5201, 36); // "31SearchForGameProgressCallback_t",
    // u.assert_callback_size(5202, 32); // "29SearchForGameResultCallback_t",
    // u.assert_callback_size(5211, 12); // "39RequestPlayersForGameProgressCallback_t",
    // u.assert_callback_size(5212, 56); //RequestPlayersForGameResultCallback_t
    // u.assert_callback_size(5213, 20); // steam.RequestPlayersForGameFinalResultCallback_t
    // u.assert_callback_size(5305, 1); // steam.AvailableBeaconLocationsUpdated_t
    // u.assert_callback_size(5306, 1); // steam.ActiveBeaconsUpdated_t
    // u.assert_callback_size(5701, 4); // steam.SteamRemotePlaySessionConnected_t
    // u.assert_callback_size(5702, 4); // steam.SteamRemotePlaySessionDisconnected_t
    // u.assert_callback_size(5703, 1024); // steam.SteamRemotePlayTogetherGuestInvite_t
}
