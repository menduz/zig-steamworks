const steam = @import("steamworks");
const builtin = @import("builtin");
const std = @import("std");
const t = std.testing;
const win = builtin.os.tag == .windows;
const u = @import("tests-utils.zig");

comptime {
    u.assert_type_size(u.ValvePackingSentinel_t, 32);
    // u.assert_type_size(steam.RemoteStorageEnumerateUserSubscribedFilesResult_t, (1 + 1 + 1 + 50 + 100) * 4 + 4);

    // win LobbyCreated_t 01000000........58708d6300008601
    u.assert_offset(steam.LobbyCreated_t, "m_eResult", 0);
    // u.assert_offset(steam.LobbyCreated_t, "m_ulSteamIDLobby", 8);
}

test "process declarations recursively" {
    std.testing.refAllDeclsRecursive(steam);
}

test "check callback sizes" {
    try u.check_callbacks_sizes();
}
test "serialization fixtures" {
    try u.test_serializer(
        steam.LobbyCreated_t{ .m_eResult = steam.EResult.k_EResultOK, .m_ulSteamIDLobby = 109775242587369560 },
        "01000000e0792f0358708d6300008601", // win
    );
    try u.test_serializer(
        steam.SteamAPICallCompleted_t{
            .m_hAsyncCall = 17318484247254066249,
            .m_iCallback = 2101,
            .m_cubParam = 32,
        },
        "49e4c665aa9d57f03508000020000000", // win
    );

    try u.test_serializer(
        steam.FavoritesListChanged_t{
            .m_nIP = 0,
            .m_nQueryPort = 1020003,
            .m_nConnPort = 131983636,
            .m_nAppID = 128567568,
            .m_nFlags = 3,
            .m_bAdd = true,
            .m_unAccountId = 131983648,
        },
        "0000000063900f0014e9dd0710c9a907030000000200030020e9dd07", // win
    );

    try u.test_serializer(
        steam.LobbyEnter_t{ .m_ulSteamIDLobby = 109775242663025437, .m_rgfChatPermissions = 0, .m_bLocked = false, .m_EChatRoomEnterResponse = 1 },
        "1ddb0f6800008601000000000000000001000000a4f7dc07", // win
    );

    try u.test_serializer(
        steam.LobbyDataUpdate_t{ .m_ulSteamIDLobby = 109775242663025437, .m_ulSteamIDMember = 109775242663025437, .m_bSuccess = true },
        "1ddb0f68000086011ddb0f680000860101c0666e04001f00", // win
    );

    try u.test_serializer(
        steam.PersonaStateChange_t{ .m_ulSteamID = 76561199045870667, .m_nChangeFlags = 16 },
        "4b04b540010010011000000000000000", // win
    );
}
