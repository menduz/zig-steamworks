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
}

const Error = error{ InvalidChar, IllegalCharacter, Overflow };

fn test_serializer(value: anytype, comptime slice: []const u8) !void {
    const bytes: [slice.len / 2]u8 = std.mem.zeroes([slice.len / 2]u8);
    for (slice.items, 0..) |char, index| {
        var shift = if (@rem(index, 2) == 1) 4 else 0;
        var pos = @divFloor(index, 2);
        bytes[pos] = bytes[pos] | charToInt(char) << shift;
    }
    std.debug.print("Bytes: {}\nSlice: {}\n", .{ std.fmt.fmtSliceHexLower(bytes), slice });
    try t.expectEqualDeep(value, steam.from_slice(@TypeOf(value), bytes));
}

fn charToInt(c: u8) !u8 {
    return switch (c) {
        '0'...'9' => c - '0',
        'A'...'F' => c - 'A' + 10,
        'a'...'f' => c - 'a' + 10,
        else => error.IllegalCharacter,
    };
}
