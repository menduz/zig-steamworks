const steam = @import("steam.zig");
const std = @import("std");
const t = std.testing;

test {
    try test_serializer(
        steam.LobbyCreated_t{
            .m_eResult = steam.EResult.k_EResultOK,
            .m_ulSteamIDLobby = 109775242231394386,
        },
        "0100000052b0554e00008601",
    );
    try test_serializer(
        steam.LobbyCreated_t{ .m_eResult = steam.EResult.k_EResultOK, .m_ulSteamIDLobby = 109775242231394386 },
        "0100000052b0554e00008601",
    );
    try test_serializer(
        steam.PersonaStateChange_t{ .m_ulSteamID = 76561197998998680, .m_nChangeFlags = 32 },
        "98044f020100100120000000",
    );
    try test_serializer(
        steam.LobbyEnter_t{ .m_ulSteamIDLobby = 109775242587369560, .m_rgfChatPermissions = 0, .m_bLocked = false, .m_EChatRoomEnterResponse = 1 },
        "58708d630000860100000000008113ba01000000",
    );
    try test_serializer(
        steam.LobbyDataUpdate_t{ .m_ulSteamIDLobby = 109775242587369560, .m_ulSteamIDMember = 109775242587369560, .m_bSuccess = 1 },
        "58708d630000860158708d630000860101708d63",
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
